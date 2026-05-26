import Combine
import Foundation
import HealthKit

final class WorkoutSessionManager: NSObject, ObservableObject {
    @Published private(set) var isAvailable: Bool
    @Published private(set) var averageHeartRate: Double?
    @Published private(set) var maxHeartRate: Double?
    @Published private(set) var activeEnergyKilocalories: Double?

    private let healthStore: HKHealthStore
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var startDate: Date?
    private var exerciseNames: [String] = []
    private var isFinishing = false

    override init() {
        let store = HKHealthStore()
        healthStore = store

        if HKHealthStore.isHealthDataAvailable() {
            isAvailable = store.authorizationStatus(for: HKObjectType.workoutType()) != .sharingDenied
        } else {
            isAvailable = false
        }

        super.init()
    }

    func start(payload: WatchPayload) {
        guard isAvailable, session == nil else { return }

        exerciseNames = payload.blocks.map(\.exerciseName)
        averageHeartRate = nil
        maxHeartRate = nil
        activeEnergyKilocalories = nil

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor

        requestAuthorizationAndStart(configuration: configuration)
    }

    func finish(payload: WatchPayload?, completedSets: [SetLog]) {
        guard isAvailable, let session, let builder, !isFinishing else { return }
        isFinishing = true
        let endDate = Date()

        session.end()
        builder.endCollection(withEnd: endDate) { [weak self] _, _ in
            guard let self else { return }
            let metadata = self.metadata(
                payload: payload,
                completedSets: completedSets,
                endDate: endDate
            )

            builder.addMetadata(metadata) { [weak self] _, _ in
                builder.finishWorkout { _, error in
                    DispatchQueue.main.async {
                        guard let self else { return }
                        if error != nil {
                            self.isAvailable = false
                        }
                        self.session = nil
                        self.builder = nil
                        self.isFinishing = false
                    }
                }
            }
        }
    }

    private func requestAuthorizationAndStart(configuration: HKWorkoutConfiguration) {
        let workoutType = HKObjectType.workoutType()
        var shareTypes: Set<HKSampleType> = [workoutType]
        var readTypes: Set<HKObjectType> = [workoutType]

        if let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) {
            readTypes.insert(heartRateType)
        }

        if let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            shareTypes.insert(activeEnergyType)
            readTypes.insert(activeEnergyType)
        }

        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { [weak self] success, _ in
            guard let self else { return }
            DispatchQueue.main.async {
                guard success,
                      self.healthStore.authorizationStatus(for: workoutType) == .sharingAuthorized else {
                    self.isAvailable = false
                    return
                }
                self.beginSession(configuration: configuration)
            }
        }
    }

    private func beginSession(configuration: HKWorkoutConfiguration) {
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let builder = session.associatedWorkoutBuilder()
            let startDate = Date()

            builder.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            session.delegate = self
            builder.delegate = self

            self.session = session
            self.builder = builder
            self.startDate = startDate

            session.startActivity(with: startDate)
            builder.beginCollection(withStart: startDate) { [weak self] success, _ in
                guard !success else { return }
                DispatchQueue.main.async {
                    self?.isAvailable = false
                }
            }
        } catch {
            isAvailable = false
        }
    }

    private func metadata(
        payload: WatchPayload?,
        completedSets: [SetLog],
        endDate: Date
    ) -> [String: Any] {
        var metadata: [String: Any] = [
            HKMetadataKeyIndoorWorkout: true,
            "MennoTrackerCompletedSets": completedSets.count,
            "MennoTrackerExerciseList": exerciseNames.joined(separator: ", "),
            "MennoTrackerEndedAt": endDate
        ]

        if let startDate {
            metadata["MennoTrackerStartedAt"] = startDate
        }

        if let payload {
            metadata["MennoTrackerSessionId"] = payload.sessionId
            metadata["MennoTrackerWorkoutId"] = payload.workoutId
            metadata["MennoTrackerWorkoutName"] = payload.workoutName
        }

        if let averageHeartRate {
            metadata["MennoTrackerAverageHeartRateBPM"] = averageHeartRate
        }

        if let maxHeartRate {
            metadata["MennoTrackerMaxHeartRateBPM"] = maxHeartRate
        }

        if let activeEnergyKilocalories {
            metadata["MennoTrackerActiveEnergyKcal"] = activeEnergyKilocalories
        }

        return metadata
    }
}

extension WorkoutSessionManager: HKWorkoutSessionDelegate {
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {}

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isAvailable = false
            self.session = nil
            self.builder = nil
            self.isFinishing = false
        }
    }
}

extension WorkoutSessionManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        if let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate),
           collectedTypes.contains(heartRateType) {
            updateHeartRate(from: workoutBuilder, type: heartRateType)
        }

        if let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
           collectedTypes.contains(activeEnergyType) {
            updateActiveEnergy(from: workoutBuilder, type: activeEnergyType)
        }
    }

    private func updateHeartRate(from workoutBuilder: HKLiveWorkoutBuilder, type: HKQuantityType) {
        guard let statistics = workoutBuilder.statistics(for: type) else { return }
        let unit = HKUnit.count().unitDivided(by: .minute())
        let average = statistics.averageQuantity()?.doubleValue(for: unit)
        let maximum = statistics.maximumQuantity()?.doubleValue(for: unit)

        DispatchQueue.main.async {
            self.averageHeartRate = average
            self.maxHeartRate = maximum
        }
    }

    private func updateActiveEnergy(from workoutBuilder: HKLiveWorkoutBuilder, type: HKQuantityType) {
        guard let statistics = workoutBuilder.statistics(for: type) else { return }
        let total = statistics.sumQuantity()?.doubleValue(for: .kilocalorie())

        DispatchQueue.main.async {
            self.activeEnergyKilocalories = total
        }
    }
}
