// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:drift/drift.dart';
import 'connection/connection.dart';

part 'database.g.dart';

// Tables
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get merchant => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get category => text().withDefault(const Constant('Other'))();
  TextColumn get source => text()(); // 'sms', 'voice', 'manual'
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get rawData => text().nullable()(); // Original SMS or voice text
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class GhostBills extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get predictedAmount => real()();
  TextColumn get merchant => text()();
  TextColumn get frequency => text()(); // 'monthly', 'weekly', 'daily'
  DateTimeColumn get nextDueDate => dateTime()();
  DateTimeColumn get lastOccurrence => dateTime()();
  IntColumn get confidence => integer()(); // 0-100 confidence score
  BoolColumn get isInferred => boolean().withDefault(const Constant(true))();
  TextColumn get source => text().withDefault(const Constant('inferred'))();
}

// Database
@DriftDatabase(tables: [Transactions, GhostBills])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1 && to == 2) {
          await m.addColumn(ghostBills, ghostBills.isInferred);
          await m.addColumn(ghostBills, ghostBills.source);
        }
      },
    );
  }

  // Transactions
  Future<List<Transaction>> getAllTransactions() {
    return (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<Transaction>> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return (select(transactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  Future<bool> updateTransaction(TransactionsCompanion transaction) {
    return update(transactions).replace(transaction);
  }

  Future<int> deleteAllTransactions() {
    return delete(transactions).go();
  }

  // Check for duplicate transactions (reconciliation logic)
  Future<Transaction?> findDuplicate(
      double amount, DateTime date, String source) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final results = await (select(transactions)
          ..where((t) =>
              t.amount.equals(amount) &
              t.date.isBetweenValues(dayStart, dayEnd) &
              t.source.isNotValue(source)))
        .get();

    return results.isNotEmpty ? results.first : null;
  }

  // Ghost Bills
  Future<List<GhostBill>> getAllGhostBills() => select(ghostBills).get();

  Future<List<GhostBill>> getUpcomingGhostBills() {
    return (select(ghostBills)
          ..where((g) => g.nextDueDate.isBiggerOrEqualValue(DateTime.now()))
          ..orderBy([(g) => OrderingTerm.asc(g.nextDueDate)]))
        .get();
  }

  Future<int> insertGhostBill(GhostBillsCompanion bill) {
    return into(ghostBills).insert(bill);
  }

  Future<int> deleteAllGhostBills() {
    return delete(ghostBills).go();
  }

  Future<void> clearAllData() async {
    await batch((batch) {
      batch.deleteWhere(transactions, (row) => const Constant(true));
      batch.deleteWhere(ghostBills, (row) => const Constant(true));
    });
  }

  // Analytics
  Future<double> getTotalSpent(DateTime start, DateTime end) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.date.isBetweenValues(start, end) &
          transactions.category.isNotIn(
              ['Salary', 'Investment Returns', 'Rent', 'Other Income']));

    final result = await query.getSingle();
    return result.read(transactions.amount.sum()) ?? 0.0;
  }

  Future<Map<String, double>> getSpendingByCategory(
      DateTime start, DateTime end) async {
    final results = await (select(transactions)
          ..where((t) => t.date.isBetweenValues(start, end)))
        .get();

    final Map<String, double> categoryTotals = {};
    for (final transaction in results) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryTotals;
  }

  Future<List<String>> getDistinctMerchants() async {
    final query = selectOnly(transactions, distinct: true)
      ..addColumns([transactions.merchant]);

    final result = await query.get();
    return result.map((row) => row.read(transactions.merchant)!).toList();
  }

  Future<int> getActiveDayCount(DateTime start, DateTime end) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.date])
      ..where(transactions.date.isBetweenValues(start, end) &
          transactions.category.isNotIn(
              ['Salary', 'Investment Returns', 'Rent', 'Other Income']));

    final results = await query.get();

    final uniqueDays = results
        .map((row) => row.read(transactions.date))
        .where((date) => date != null)
        .map((date) => DateTime(date!.year, date.month, date.day))
        .toSet();

    return uniqueDays.length;
  }
}
