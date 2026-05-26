import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menno_tracker/src/widgets/plate_calculator.dart';

void main() {
  final inventory = <double, int>{20: 2, 10: 2, 5: 2, 2.5: 2, 1.25: 2};

  test('computes greedy plates per side', () {
    expect(PlateCalculator.computePlatesPerSide(80, 20, inventory), [20, 10]);
    expect(PlateCalculator.computePlatesPerSide(60, 20, inventory), [20]);
    expect(PlateCalculator.computePlatesPerSide(22.5, 20, inventory), [1.25]);
    expect(PlateCalculator.computePlatesPerSide(21, 20, inventory), isEmpty);
  });

  testWidgets('shows fallback when exact loading is impossible', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlateCalculator(
            weightKg: 21,
            barWeightKg: 20,
            platePairsAvailable: inventory,
          ),
        ),
      ),
    );

    expect(find.textContaining('Cannot make exactly'), findsOneWidget);
    expect(find.textContaining('closest'), findsOneWidget);
  });
}
