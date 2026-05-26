# Reduced Galpin × Henselmans Program

This document is the standalone program spec for MennoTracker v1.
It expands the reduced program described in [`../PLAN.md`](../PLAN.md).

The program is an 8-week hypertrophy block inspired by the Andy Galpin × Menno
Henselmans collaboration.
MennoTracker v1 ships the reduced version only: two full-body workouts, alternated
as `A, B, A, B`, for roughly four training days per week.

The tracking style should feel close to StrongLifts: the app tells you what to do
today, suggests working weights, logs every set, runs rest timers, and updates the
next-session load suggestion.
The difference is that this program uses rep-range autoregulation instead of a
fixed linear 5×5 loading rule.

## Related docs

- [`altstore-setup.md`](altstore-setup.md) explains the Windows-to-iPhone install path.
- [`installing-watch-app.md`](installing-watch-app.md) explains the borrowed-Mac watch install path.
- [`migrate-to-paid-program.md`](migrate-to-paid-program.md) explains the paid Apple Developer Program path.
- [`../PLAN.md`](../PLAN.md) remains the source planning document.

## Scope for v1

- Program length: 8 weeks.
- Schedule pattern: `A, B, A, B`.
- Expected cadence: about 4 days per week.
- Program variant: reduced only.
- Workout style: full-body sessions.
- Progression style: rep-range autoregulation.
- Persistent unit of progression: exercise working weight.
- Source of truth in code: `packages/program/lib/src/`.
- Progression engine in code: `packages/progression/lib/src/`.

## Program at a glance

| Item | v1 value |
| --- | --- |
| Block length | 8 weeks |
| Workout count | 2 workouts: A and B |
| Weekly frequency | ~4 days/week |
| Pattern | A, B, A, B |
| Session length | ~55–70 minutes |
| Version shipped | Reduced version only |
| Progression model | Rep-range thresholds + deload rules |
| Primary platform | iPhone, with optional Apple Watch companion |

## Schedule pattern

Use four lifting days per week when recovery and life allow it.
The example below uses Monday, Tuesday, Thursday, and Friday.
Rest days can move as needed; keep the workout order intact.

| Day | Example workout | Notes |
| --- | --- | --- |
| Monday | Workout A | Start the week with the next scheduled workout. |
| Tuesday | Workout B | Second full-body session. |
| Wednesday | Rest | Optional light cardio, mobility, or walking. |
| Thursday | Workout A | Repeat A after at least one rest day. |
| Friday | Workout B | Finish the weekly ABAB sequence. |
| Saturday | Rest | Optional recovery work. |
| Sunday | Rest | Prepare for the next A workout. |

## Workout order rules

- Do not reset the pattern at the start of a calendar week.
- The next workout is whichever workout follows the last completed session.
- If you miss Tuesday, do Workout B on the next training day.
- If you miss a full week, resume with the next workout in sequence.
- Do not skip ahead to force a Monday A session.
- The app should calculate the next workout from session history, not weekday names.

## Reduced Workout A (16–17 work sets, ~55–65 min)

| Exercise | Sets | Reps | Rest |
| --- | ---: | ---: | ---: |
| Romanian deadlift | 3 | 8–12 | 2.5–3 min |
| Leg extension | 3 | 8–12 | 2–3 min |
| Barbell bench press | 3 | 6–10 | 2.5–3 min |
| Neutral-grip pulldown | 3 | 8–12 | 2–3 min |
| Seated calf raise | 2–3 | 8–12 | 1.5–2 min |
| Cable lateral raise | 2 | 8–12 | 1.5–2 min |

### Workout A implementation notes

- The set count for seated calf raise may be stored as a configurable block value.
- The app should display the planned range exactly as written above.
- Rest timer defaults should come from the workout table.
- A user may shorten or extend rest, but that should not change the program spec.
- Romanian deadlift and bench press are barbell exercises by default.
- Leg extension, pulldown, calf raise, and lateral raise are machine or cable exercises.
- Plate calculator behavior should depend on the exercise equipment metadata.

## Reduced Workout B (19 work sets, ~60–70 min)

| Exercise | Sets | Reps | Rest |
| --- | ---: | ---: | ---: |
| High-bar squat | 3 | 5–8 | 3 min |
| Lying leg curl | 3 | 8–12 | 2–3 min |
| Barbell overhead press | 3 | 6–10 | 2.5–3 min |
| Seated row | 3 | 8–12 | 2–3 min |
| Cable chest fly / pec deck | 3 | 6–10 | 1.5–2.5 min |
| Triceps pushdown | 2 | 8–12 | 1.5–2 min |
| Seated dumbbell curl | 2 | 8–12 | 1.5–2 min |

### Workout B implementation notes

- High-bar squat is the heaviest lower-body movement in Workout B.
- Overhead press is a barbell exercise by default.
- Cable chest fly / pec deck should allow either equipment label in the UI.
- Triceps pushdown and seated dumbbell curl use shorter rests.
- The exercise order should remain stable unless a future program version changes it.
- The watch payload should receive the same order the phone displays.
- The history screen should group trends by exercise identity, not display name alone.

## How to run a session

1. Open the Today screen.
2. Confirm the next workout is correct.
3. Review suggested working weights.
4. Override any weight that is clearly inappropriate.
5. Start the workout.
6. Complete planned sets in order.
7. Log actual reps for each set.
8. Rest according to the displayed timer.
9. Mark partial or failed sets honestly.
10. Finish the workout so the progression engine can update exercise state.

## Progression rules

The progression engine is described in [`../PLAN.md`](../PLAN.md#progression-engine-the-heart-of-the-app).
This section restates it in lifter-facing language.

### Top-set rule

- For each exercise, the app looks at the first hard working set.
- Warmups should not count toward progression.
- That first hard set is the effective top set.
- The number of clean reps on that set determines whether the next workout should be heavier.

### Weight-increase thresholds

| Program rep range | Add weight when the top set reaches |
| --- | --- |
| 5–8 | 9–10 clean reps |
| 6–10 | 11–12 clean reps |
| 8–12 | 13–14 clean reps |

### Increment rule

- The default increase is about 2.5% of the current working weight.
- The app then snaps that increase to the smallest usable load jump.
- A barbell default jump is a 2.5 kg plate pair.
- A dumbbell default jump is 1 kg when available.
- A machine default jump is one pin or the configured machine increment.
- The lifter can override the suggestion.
- The overridden working weight becomes the value persisted for that exercise.

### Deload rule inside a workout

- If a non-first set drops below the bottom of the target rep range, the app should react.
- The first suggestion is local to the current workout.
- Reduce the remaining sets for that exercise by about 10%.
- This is meant to keep the session productive instead of turning every later set into a grind.
- The current workout can continue after the reduction.

### Deload rule across workouts

- If the same exercise misses again in the next session, reduce the persisted working weight.
- The default persistent reduction is 10%.
- The next workout should start from that lower suggested weight.
- This is not a punishment; it is a reset to restore useful training volume.

### User settings

The following values should be configurable in Settings:

- Rep-range threshold table.
- Increment percentage.
- Deload percentage.
- Smallest barbell jump.
- Smallest dumbbell jump.
- Machine increment.
- Unit preference: kg or lb.
- Plate inventory.

## Why this program

The app is built around the Andy Galpin × Menno Henselmans hypertrophy program.
The v1 scope deliberately uses only the reduced version so the first release can focus on
reliable logging, progression suggestions, rest timers, watch ergonomics, and history.

The official-version program data structure remains supported by the model described in
[`../PLAN.md`](../PLAN.md#data-model).
The full version may be added later as data, without changing the core app flow.

## Notes for v2

The official-version data should be encoded under `packages/program/lib/src/`.
Keep the program definitions pure Dart and testable on Windows.
Do not make the phone UI hard-code reduced-program exercise lists.
Do not make the watch UI hard-code reduced-program exercise lists.
Use stable exercise identifiers so old history remains readable after new programs are added.

Suggested v2 work items:

- Add official-version `Program` constants beside the reduced constant.
- Add tests that assert workout order, exercise order, sets, reps, and rest values.
- Add a program selector in Settings.
- Add migration behavior for users who switch programs mid-block.
- Keep progression rules shared unless the official version requires separate thresholds.
- Update this document after the data is encoded.

## Acceptance checklist

- Workout A matches `../PLAN.md` exactly.
- Workout B matches `../PLAN.md` exactly.
- Schedule uses ABAB over roughly four training days per week.
- Progression thresholds match the plan.
- Deload behavior matches the plan.
- v1 is clearly reduced-only.
- v2 points at `packages/program/lib/src/` for official-version data.
