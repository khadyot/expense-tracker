import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracker/database/database.dart';
import 'package:expense_tracker/services/ghost_bill_service.dart';
import 'package:expense_tracker/services/demo_seed_service.dart';

void main() {
  late AppDatabase database;
  late GhostBillService ghostService;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    ghostService = GhostBillService(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('GhostBillService Tests', () {
    test('Case 1: Clear recurring pattern that should be detected', () async {
      final baseDate = DateTime(2026, 5, 15);
      await database.insertTransaction(TransactionsCompanion(
        amount: const Value(499.0),
        merchant: const Value('Netflix'),
        date: Value(baseDate),
        category: const Value('Other'),
        source: const Value('manual'),
      ));
      await database.insertTransaction(TransactionsCompanion(
        amount: const Value(499.0),
        merchant: const Value('netflix'), // test case-insensitive grouping
        date: Value(baseDate.add(const Duration(days: 30))),
        category: const Value('Other'),
        source: const Value('manual'),
      ));
      await database.insertTransaction(TransactionsCompanion(
        amount: const Value(499.0),
        merchant: const Value('Netflix'),
        date: Value(baseDate.add(const Duration(days: 60))),
        category: const Value('Other'),
        source: const Value('manual'),
      ));

      final count = await ghostService.detectRecurring();
      expect(count, equals(1));

      final bills = await database.getAllGhostBills();
      expect(bills.length, equals(1));
      expect(bills.first.merchant, equals('Netflix'));
      expect(bills.first.predictedAmount, equals(499.0));
      expect(bills.first.confidence, greaterThanOrEqualTo(90));
      expect(bills.first.isInferred, isTrue);
      expect(bills.first.source, equals('inferred'));
    });

    test('Case 2: One-off merchant that should NOT be flagged as recurring',
        () async {
      await database.insertTransaction(TransactionsCompanion(
        amount: const Value(85000.0),
        merchant: const Value('Apple Store'),
        date: Value(DateTime(2026, 6, 10)),
        category: const Value('Other'),
        source: const Value('manual'),
      ));

      final count = await ghostService.detectRecurring();
      expect(count, equals(0));

      final bills = await database.getAllGhostBills();
      expect(bills, isEmpty);
    });

    test(
        'Case 3: Irregular merchant with inconsistent amounts/dates that should NOT be flagged',
        () async {
      final dates = [
        DateTime(2026, 5, 5),
        DateTime(2026, 5, 22),
        DateTime(2026, 6, 8),
        DateTime(2026, 7, 27),
      ];
      final amounts = [340.0, 1200.0, 450.0, 890.0];

      for (int i = 0; i < dates.length; i++) {
        await database.insertTransaction(TransactionsCompanion(
          amount: Value(amounts[i]),
          merchant: const Value('Amazon'),
          date: Value(dates[i]),
          category: const Value('Other'),
          source: const Value('sms'),
        ));
      }

      final count = await ghostService.detectRecurring();
      expect(count, equals(0));

      final bills = await database.getAllGhostBills();
      expect(bills, isEmpty);
    });

    test(
        'Case 4: Borderline case at the edge of day-of-month tolerance (5 days vs 6 days difference)',
        () async {
      // 1. Gym: Occurrences on May 10 and June 15 (diff == 5 days tolerance edge) -> SHOULD be detected
      await database.insertTransaction(TransactionsCompanion(
        amount: const Value(1200.0),
        merchant: const Value('Gym'),
        date: Value(DateTime(2026, 5, 10)),
        category: const Value('Home'),
        source: const Value('manual'),
      ));
      await database.insertTransaction(TransactionsCompanion(
        amount: const Value(1200.0),
        merchant: const Value('Gym'),
        date: Value(DateTime(2026, 6, 15)),
        category: const Value('Home'),
        source: const Value('manual'),
      ));

      // 2. Electricity: Occurrences on May 10 and June 16 (diff == 6 days across months, interval 37 days outside 25-35 range) -> should NOT be detected
      await database.insertTransaction(TransactionsCompanion(
        amount: const Value(1420.0),
        merchant: const Value('Bescom Electricity'),
        date: Value(DateTime(2026, 5, 10)),
        category: const Value('Home'),
        source: const Value('sms'),
      ));
      await database.insertTransaction(TransactionsCompanion(
        amount: const Value(1420.0),
        merchant: const Value('Bescom Electricity'),
        date: Value(DateTime(2026, 6, 16)),
        category: const Value('Home'),
        source: const Value('sms'),
      ));

      final count = await ghostService.detectRecurring();
      expect(count, equals(1));

      final bills = await database.getAllGhostBills();
      expect(bills.length, equals(1));
      expect(bills.first.merchant, equals('Gym'));
    });
  });

  group('DemoSeedService & First-Launch Integration Tests', () {
    test(
        'loadDemoData seeds transactions and detects exactly 4 recurring ghost bills when database is empty',
        () async {
      final demoService = DemoSeedService(database);
      await demoService.loadDemoData();

      final transactions = await database.getAllTransactions();
      expect(transactions, isNotEmpty);
      expect(transactions.length, greaterThanOrEqualTo(20));

      final bills = await database.getAllGhostBills();
      expect(bills.length, equals(4));

      final merchants = bills.map((b) => b.merchant).toSet();
      expect(
          merchants, containsAll(['Netflix', 'Spotify', 'Gym', 'Broadband']));
    });

    test(
        'loadDemoData does NOT overwrite or duplicate data if transactions table already has rows',
        () async {
      // First seed
      final demoService = DemoSeedService(database);
      await demoService.loadDemoData();
      final txCountAfterFirstSeed =
          (await database.getAllTransactions()).length;

      // Call loadDemoData again
      await demoService.loadDemoData();
      final txCountAfterSecondSeed =
          (await database.getAllTransactions()).length;

      expect(txCountAfterSecondSeed, equals(txCountAfterFirstSeed));
    });
  });
}
