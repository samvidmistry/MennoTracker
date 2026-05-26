import 'package:program/program.dart';

void main() {
  final program = kReducedProgram;
  print('${program.name} — ${program.workouts.length} workouts, '
      '${program.exercises.length} exercises');
  for (final w in program.workouts) {
    print('  ${w.name}: ${w.blocks.length} blocks');
  }
}
