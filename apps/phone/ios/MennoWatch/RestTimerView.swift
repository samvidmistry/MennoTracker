import Foundation
import SwiftUI
import WatchKit

struct RestTimerView: View {
    @ObservedObject var coordinator: WorkoutCoordinator
    @State private var endTime: Date
    @State private var playedTenSecondHaptic = false
    @State private var didFinish = false

    init(seconds: Int, coordinator: WorkoutCoordinator) {
        self.coordinator = coordinator
        _endTime = State(initialValue: Date().addingTimeInterval(TimeInterval(seconds)))
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = remainingSeconds(at: context.date)

            VStack(spacing: 10) {
                Text("Rest")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(format(remaining))
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)

                Text("Tap to skip")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onAppear {
                handle(remaining: remaining)
            }
            .onChange(of: remaining) { _, newValue in
                handle(remaining: newValue)
            }
        }
        .highPriorityGesture(
            TapGesture(count: 2).onEnded {
                skip()
            }
        )
        .simultaneousGesture(
            TapGesture(count: 1).onEnded {
                skip()
            }
        )
    }

    private func remainingSeconds(at date: Date) -> Int {
        max(0, Int(ceil(endTime.timeIntervalSince(date))))
    }

    private func handle(remaining: Int) {
        if remaining == 10, !playedTenSecondHaptic {
            playedTenSecondHaptic = true
            WKInterfaceDevice.current().play(.start)
        }

        if remaining == 0, !didFinish {
            didFinish = true
            WKInterfaceDevice.current().play(.success)
            coordinator.advance()
        }
    }

    private func skip() {
        guard !didFinish else { return }
        didFinish = true
        coordinator.skipRest()
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
