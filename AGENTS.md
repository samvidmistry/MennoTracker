# AGENTS.md

This file gives coding agents the guiding goal and constraints for the
MennoTracker workout program so that any change to the program stays aligned
with the owner's training intent.

## Program goal

Build and maintain a **hypertrophy-focused** training program that:

1. **Finishes in under 1 hour door to door** — including warm-up, working
   sets, rest, and getting in/out of the gym. Favor a small number of high-
   quality hard sets over high-volume "junk" volume. Keep total working sets
   per session and total reps per set in check so the timer stays under an
   hour.
2. **Keeps the legacy StrongLifts 5x5 compound lifts strong** — bench press,
   squat, overhead press, barbell/chest-supported row, and Romanian deadlift
   are maintenance anchors. They are trained in a low rep range (heavy, ~4-8
   reps) with full rest so strength carries over, even though the rest of the
   program chases hypertrophy.
3. **Drives muscle growth efficiently** — accessories live in the
   hypertrophy-effective range, biased toward moderate reps (roughly 8-15)
   where each set delivers the most growth per minute. Avoid very high rep
   caps (e.g. 20-25) that lengthen sets and fatigue without extra benefit.

## Design principles

- **Mechanical tension first.** Prefer moderate rep ranges (8-15) for most
  accessories; reserve 12-15 for isolation/metabolite work. Do not cap reps
  above ~15 unless there is a specific reason.
- **No redundant exercises.** Each muscle group should be covered by the
  fewest distinct movements that still hit it from useful angles. Avoid
  repeating the same pattern (e.g. the same press or pulldown) across days as
  a "top-up" when the weekly volume is already met elsewhere.
- **Compounds stay heavy and low-rep.** Never push the five anchor compounds
  into high-rep hypertrophy ranges; their job is strength maintenance.
- **Time is a hard constraint.** When adding volume or exercises, check that
  the session still fits under an hour at the prescribed rest times. If it
  does not, cut redundant volume before extending the session.

## Where the program lives

- Source of truth: `packages/program/lib/src/bro_split_program.dart`
- Human-readable spec: `docs/program.md`
- Progression engine: `packages/progression/lib/src/`
- Tests that assert the prescription: `packages/program/test/bro_split_program_test.dart`

Any change to set counts, rep ranges, exercises, or rest must update all four
locations together so the code, docs, and tests stay in sync.
