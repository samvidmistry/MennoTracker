import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menno_tracker/src/db/database.dart';
import 'package:menno_tracker/src/providers/providers.dart';
import 'package:menno_tracker/src/screens/settings_screen.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('unit radio writes to settings repo', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('lb'));
    await tester.pumpAndSettle();

    expect(await database.settingsDao.getString('unit'), 'lb');
  });
}
