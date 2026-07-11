import 'package:drift/drift.dart';
import '../database/database.dart';
import 'ghost_bill_service.dart';

class DemoSeedService {
  final AppDatabase database;

  DemoSeedService(this.database);

  /// Populates sample transactions across normal categories and 4 recurring monthly subscriptions.
  /// Then triggers GhostBillService.detectRecurring() to dynamically detect ghost bills.
  Future<void> loadDemoData() async {
    // Only seed if database is completely empty
    final existingTransactions = await database.getAllTransactions();
    if (existingTransactions.isNotEmpty) {
      return;
    }

    final now = DateTime.now();

    final List<TransactionsCompanion> sampleTransactions = [
      // --- Recurring Subscriptions (4 monthly subscriptions: Netflix, Spotify, Gym, Broadband) ---
      // 1. Netflix (₹499/month, occurrences 60d, 30d, 1d ago -> next due in ~29 days)
      TransactionsCompanion(
        amount: const Value(499.0),
        merchant: const Value('Netflix'),
        date: Value(now.subtract(const Duration(days: 60))),
        category: const Value('Other'),
        source: const Value('manual'),
      ),
      TransactionsCompanion(
        amount: const Value(499.0),
        merchant: const Value('Netflix'),
        date: Value(now.subtract(const Duration(days: 30))),
        category: const Value('Other'),
        source: const Value('manual'),
      ),
      TransactionsCompanion(
        amount: const Value(499.0),
        merchant: const Value('Netflix'),
        date: Value(now.subtract(const Duration(days: 1))),
        category: const Value('Other'),
        source: const Value('manual'),
      ),

      // 2. Spotify (₹149/month, occurrences 62d, 32d, 2d ago -> next due in ~28 days)
      TransactionsCompanion(
        amount: const Value(149.0),
        merchant: const Value('Spotify'),
        date: Value(now.subtract(const Duration(days: 62))),
        category: const Value('Other'),
        source: const Value('manual'),
      ),
      TransactionsCompanion(
        amount: const Value(149.0),
        merchant: const Value('Spotify'),
        date: Value(now.subtract(const Duration(days: 32))),
        category: const Value('Other'),
        source: const Value('manual'),
      ),
      TransactionsCompanion(
        amount: const Value(149.0),
        merchant: const Value('Spotify'),
        date: Value(now.subtract(const Duration(days: 2))),
        category: const Value('Other'),
        source: const Value('manual'),
      ),

      // 3. Gym (₹1200/month, occurrences 65d, 35d, 5d ago -> next due in ~25 days)
      TransactionsCompanion(
        amount: const Value(1200.0),
        merchant: const Value('Gym'),
        date: Value(now.subtract(const Duration(days: 65))),
        category: const Value('Home'),
        source: const Value('manual'),
      ),
      TransactionsCompanion(
        amount: const Value(1200.0),
        merchant: const Value('Gym'),
        date: Value(now.subtract(const Duration(days: 35))),
        category: const Value('Home'),
        source: const Value('manual'),
      ),
      TransactionsCompanion(
        amount: const Value(1200.0),
        merchant: const Value('Gym'),
        date: Value(now.subtract(const Duration(days: 5))),
        category: const Value('Home'),
        source: const Value('manual'),
      ),

      // 4. Broadband (₹899/month, occurrences 58d, 28d ago -> next due in ~2 days)
      TransactionsCompanion(
        amount: const Value(899.0),
        merchant: const Value('Broadband'),
        date: Value(now.subtract(const Duration(days: 58))),
        category: const Value('Home'),
        source: const Value('manual'),
      ),
      TransactionsCompanion(
        amount: const Value(899.0),
        merchant: const Value('Broadband'),
        date: Value(now.subtract(const Duration(days: 28))),
        category: const Value('Home'),
        source: const Value('manual'),
      ),

      // --- Non-recurring realistic Indian sample transactions across last 60 days ---
      // Groceries
      TransactionsCompanion(
        amount: const Value(1450.0),
        merchant: const Value('BigBasket'),
        date: Value(now.subtract(const Duration(days: 55))),
        category: const Value('Groceries'),
        source: const Value('sms'),
      ),
      TransactionsCompanion(
        amount: const Value(680.0),
        merchant: const Value('Swiggy Instamart'),
        date: Value(now.subtract(const Duration(days: 42))),
        category: const Value('Groceries'),
        source: const Value('sms'),
      ),
      TransactionsCompanion(
        amount: const Value(2340.0),
        merchant: const Value('D-Mart'),
        date: Value(now.subtract(const Duration(days: 18))),
        category: const Value('Groceries'),
        source: const Value('sms'),
      ),
      TransactionsCompanion(
        amount: const Value(410.0),
        merchant: const Value('Zepto'),
        date: Value(now.subtract(const Duration(days: 4))),
        category: const Value('Groceries'),
        source: const Value('sms'),
      ),

      // Travel
      TransactionsCompanion(
        amount: const Value(340.0),
        merchant: const Value('Uber'),
        date: Value(now.subtract(const Duration(days: 50))),
        category: const Value('Travel'),
        source: const Value('sms'),
      ),
      TransactionsCompanion(
        amount: const Value(210.0),
        merchant: const Value('Ola Cabs'),
        date: Value(now.subtract(const Duration(days: 36))),
        category: const Value('Travel'),
        source: const Value('sms'),
      ),
      TransactionsCompanion(
        amount: const Value(1850.0),
        merchant: const Value('IRCTC'),
        date: Value(now.subtract(const Duration(days: 22))),
        category: const Value('Travel'),
        source: const Value('manual'),
      ),

      // Car
      TransactionsCompanion(
        amount: const Value(2500.0),
        merchant: const Value('Shell Petrol Pump'),
        date: Value(now.subtract(const Duration(days: 45))),
        category: const Value('Car'),
        source: const Value('sms'),
      ),
      TransactionsCompanion(
        amount: const Value(2000.0),
        merchant: const Value('HP Petrol'),
        date: Value(now.subtract(const Duration(days: 14))),
        category: const Value('Car'),
        source: const Value('sms'),
      ),

      // Home & Utilities
      TransactionsCompanion(
        amount: const Value(750.0),
        merchant: const Value('Urban Company'),
        date: Value(now.subtract(const Duration(days: 33))),
        category: const Value('Home'),
        source: const Value('manual'),
      ),
      TransactionsCompanion(
        amount: const Value(1420.0),
        merchant: const Value('Bescom Electricity'),
        date: Value(now.subtract(const Duration(days: 25))),
        category: const Value('Home'),
        source: const Value('sms'),
      ),

      // Other
      TransactionsCompanion(
        amount: const Value(560.0),
        merchant: const Value('Zomato'),
        date: Value(now.subtract(const Duration(days: 12))),
        category: const Value('Other'),
        source: const Value('sms'),
      ),
      TransactionsCompanion(
        amount: const Value(890.0),
        merchant: const Value('Swiggy Gourmet'),
        date: Value(now.subtract(const Duration(days: 3))),
        category: const Value('Other'),
        source: const Value('sms'),
      ),
    ];

    for (final companion in sampleTransactions) {
      await database.insertTransaction(companion);
    }

    // Dynamically detect and populate GhostBills based on these transactions
    final ghostService = GhostBillService(database);
    await ghostService.detectRecurring();
  }

  /// Clears all rows from Transactions and GhostBills, then reloads demo data via loadDemoData().
  Future<void> resetAndReloadDemoData() async {
    await database.delete(database.transactions).go();
    await database.delete(database.ghostBills).go();
    await loadDemoData();
  }
}
