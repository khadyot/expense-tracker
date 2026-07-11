import 'dart:math';
import 'package:drift/drift.dart';
import '../database/database.dart';

class GhostBillService {
  final AppDatabase database;

  GhostBillService(this.database);

  /// Evaluates historical transactions and returns detected GhostBills companions.
  static List<GhostBillsCompanion> evaluateTransactions(
      List<Transaction> transactions) {
    if (transactions.isEmpty) return [];

    // Group transactions by normalized merchant name
    final Map<String, List<Transaction>> grouped = {};
    final Map<String, String> displayNames = {};

    for (final t in transactions) {
      final norm = t.merchant.trim().toLowerCase();
      if (norm.isEmpty) continue;
      grouped.putIfAbsent(norm, () => []).add(t);
      // Retain the latest display spelling
      displayNames[norm] = t.merchant.trim();
    }

    final List<GhostBillsCompanion> results = [];

    for (final entry in grouped.entries) {
      final norm = entry.key;
      final occurrences = entry.value;
      if (occurrences.length < 2) continue;

      // Sort chronologically ascending by date
      occurrences.sort((a, b) => a.date.compareTo(b.date));

      // 1. Check distinct calendar months
      final distinctMonths =
          occurrences.map((t) => '${t.date.year}-${t.date.month}').toSet();
      if (distinctMonths.length < 2) continue;

      // 2. Check recurrence intervals (25-35 days for monthly cadence) across consecutive occurrences
      bool hasMonthlyIntervals = true;
      int totalIntervalDays = 0;
      for (int i = 0; i < occurrences.length - 1; i++) {
        final diffDays =
            occurrences[i + 1].date.difference(occurrences[i].date).inDays;
        totalIntervalDays += diffDays;
        if (diffDays < 25 || diffDays > 35) {
          hasMonthlyIntervals = false;
        }
      }

      // 3. Check day-of-month within 5-day tolerance across occurrences
      final days = occurrences.map((t) => t.date.day).toList();
      bool hasConsistentDays = true;
      int maxDay = days.first;
      int minDay = days.first;
      for (int i = 0; i < days.length; i++) {
        if (days[i] > maxDay) maxDay = days[i];
        if (days[i] < minDay) minDay = days[i];
      }
      if ((maxDay - minDay) > 5) {
        // Also check if consecutive day differences are <= 5 (for borderline/rolling cases across months)
        bool consecutiveWithin5 = true;
        for (int i = 0; i < days.length - 1; i++) {
          final diff = (days[i + 1] - days[i]).abs();
          if (diff > 5) consecutiveWithin5 = false;
        }
        if (!consecutiveWithin5) {
          hasConsistentDays = false;
        }
      }

      // Merchant counts as recurring if across >= 2 distinct calendar months, with either:
      // day-of-month within 5-day tolerance OR interval falls in 25-35 day range
      if (!hasConsistentDays && !hasMonthlyIntervals) {
        continue;
      }

      // Compute average amount across occurrences
      double totalAmount = 0;
      for (final t in occurrences) {
        totalAmount += t.amount;
      }
      final avgAmount = totalAmount / occurrences.length;

      // Compute average interval
      final int avgIntervalDays = occurrences.length > 1
          ? (totalIntervalDays / (occurrences.length - 1)).round()
          : 30;
      final int effectiveInterval = avgIntervalDays > 0 ? avgIntervalDays : 30;

      // Predicted next date = last occurrence date + average interval
      final lastOcc = occurrences.last.date;
      final predictedNext = lastOcc.add(Duration(days: effectiveInterval));

      // Calculate confidence (0-100)
      int confidence = 75;
      if (hasConsistentDays && hasMonthlyIntervals) {
        confidence = 90;
      }
      if (occurrences.length >= 3) {
        confidence = min(100, confidence + 10);
      }
      // Check amount consistency
      double maxAmt = occurrences.first.amount;
      double minAmt = occurrences.first.amount;
      for (final t in occurrences) {
        if (t.amount > maxAmt) maxAmt = t.amount;
        if (t.amount < minAmt) minAmt = t.amount;
      }
      if ((maxAmt - minAmt).abs() < 1.0) {
        confidence = min(100, confidence + 5);
      }

      results.add(GhostBillsCompanion(
        merchant: Value(displayNames[norm] ?? norm),
        predictedAmount: Value(avgAmount),
        frequency: const Value('monthly'),
        nextDueDate: Value(predictedNext),
        lastOccurrence: Value(lastOcc),
        confidence: Value(confidence),
        isInferred: const Value(true),
        source: const Value('inferred'),
      ));
    }

    return results;
  }

  /// Queries all transactions, detects recurring bills, and upserts them into GhostBills table.
  Future<int> detectRecurring() async {
    final transactions = await database.getAllTransactions();
    final companions = evaluateTransactions(transactions);

    final existingBills = await database.getAllGhostBills();
    int upsertCount = 0;

    for (final companion in companions) {
      final merchantName = companion.merchant.value;
      final existingIndex = existingBills.indexWhere(
        (b) =>
            b.merchant.trim().toLowerCase() ==
            merchantName.trim().toLowerCase(),
      );

      if (existingIndex != -1) {
        final existing = existingBills[existingIndex];
        await (database.update(database.ghostBills)
              ..where((b) => b.id.equals(existing.id)))
            .write(companion);
      } else {
        await database.insertGhostBill(companion);
      }
      upsertCount++;
    }

    return upsertCount;
  }
}
