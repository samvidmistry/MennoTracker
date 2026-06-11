# 5-day bro split + compound maintenance

This document is the standalone program spec for MennoTracker v1.

MennoTracker now ships a fresh 5-day bro split. It keeps a bro-split feel while
maintaining the main compound lifts with only 2 hard sets each.

## Program at a glance

| Item | v1 value |
| --- | --- |
| Block length | 8 weeks |
| Workout count | 5 workouts |
| Pattern | Day 1, Day 2, Day 3, Day 4, Day 5 |
| Progression model | Hit the top of the range on all sets before adding weight |
| Source of truth in code | `packages/program/lib/src/` |
| Progression engine in code | `packages/progression/lib/src/` |

## Workout order rules

- The next workout is whichever day follows the last completed session.
- After Day 5, cycle back to Day 1.
- If you miss a day, resume with the next workout in sequence.
- The app calculates the next workout from session history, not weekday names.

## Day 1 - Chest + Triceps

| Exercise | Sets | Reps | Rest |
| --- | ---: | ---: | ---: |
| Bench press | 2 | 4-6 | 2-3 min |
| Incline machine press | 2 | 8-12 | 90 sec |
| Pec deck / cable fly | 2 | 12-20 | 60-90 sec |
| Triceps pressdown | 2 | 10-15 | 60-90 sec |

## Day 2 - Back + Biceps

| Exercise | Sets | Reps | Rest |
| --- | ---: | ---: | ---: |
| Chest-supported row / barbell row | 2 | 6-8 | 2 min |
| Neutral-grip lat pulldown | 3 | 8-12 | 90 sec |
| Cable row | 2 | 10-15 | 90 sec |
| Reverse pec deck | 2 | 15-25 | 60 sec |
| Cable curl | 2 | 10-15 | 60-90 sec |

Use straps if grip limits back work.

## Day 3 - Legs

| Exercise | Sets | Reps | Rest |
| --- | ---: | ---: | ---: |
| Squat | 2 | 4-6 | 2-3 min |
| Leg press / hack squat | 2 | 8-12 | 90-120 sec |
| Leg curl | 3 | 10-15 | 60-90 sec |
| Calf raise | 2 | 8-15 | 60-90 sec |

## Day 4 - Shoulders + small chest/back top-up

| Exercise | Sets | Reps | Rest |
| --- | ---: | ---: | ---: |
| Overhead press | 2 | 4-6 | 2-3 min |
| Cable lateral raise | 3 | 12-20 | 60-90 sec |
| Reverse pec deck | 2 | 15-25 | 60 sec |
| Incline machine press / push-up | 2 | 10-15 | 90 sec |
| Pulldown / cable row | 2 | 10-15 | 90 sec |

## Day 5 - Arms + posterior chain

| Exercise | Sets | Reps | Rest |
| --- | ---: | ---: | ---: |
| Romanian deadlift | 2 | 6-8 | 2-3 min |
| Triceps pressdown | 3 | 10-15 | 60-90 sec |
| Overhead triceps extension | 2 | 12-20 | 60-90 sec |
| Preacher curl | 3 | 8-12 | 60-90 sec |
| Incline curl / cable curl | 2 | 10-15 | 60-90 sec |
| Optional abs | 2 | 10-20 | 60 sec |

## Progression rules

For every exercise, keep the same weight until all hard sets hit the top of the
prescribed rep range with clean form. If all hard sets hit the top, add weight
next time. If not, keep the same weight.

### Compounds

Compounds are:

- Bench press
- Squat
- Overhead press
- Chest-supported row / barbell row
- Romanian deadlift

| Lift | Increase by |
| --- | ---: |
| Bench press | +2.5 kg |
| Squat | +2.5 kg |
| Overhead press | +1.25 kg |
| Row | +2.5 kg |
| Romanian deadlift | +2.5 kg |

Example for bench press at 2 x 4-6:

| Result | Next time |
| --- | --- |
| `60 kg x 6, 6` | Increase |
| `60 kg x 6, 5` | Keep the same weight |
| `60 kg x 5, 4` | Keep the same weight |
| `60 kg x 3, 3` | Missed minimum; reduce only if this is the second miss in a row |

### Non-compounds

Use the same rule: hit the top of the rep range on all hard sets before adding
weight. Increase by the smallest possible jump for that exercise.

Typical jumps:

- Machines/cables: +1 plate
- Dumbbells: +1-2 kg per dumbbell
- Bodyweight: add reps first, then add weight only if needed

### Deload rule

If an exercise misses the minimum reps for 2 workouts in a row, reduce that
exercise by 10% next time.

Example for squat at 2 x 4-6:

| Session | Result |
| --- | --- |
| Week 1 | `90 kg x 4, 3` |
| Week 2 | `90 kg x 3, 3` |
| Next time | Reduce to around `80 kg` |

## Simple rule to remember

- Hit the top of the rep range on all sets: add weight next time.
- Do not hit the top: keep the same weight.
- Miss the bottom badly for 2 sessions: reduce weight by 10%.
