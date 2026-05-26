# progression

Rep-range autoregulation progression engine for MennoTracker.

The package suggests the next working weight for an exercise from the persisted
`ExerciseState`, the most recent `ExerciseEntry`, and the program exercise block.
First-time suggestions are placeholders only; users should override them with a
real starting weight.
