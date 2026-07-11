import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import '../database/database.dart';
import 'package:drift/drift.dart' as drift;
import '../constants/category_keywords.dart';

class SmsService {
  static const platform = MethodChannel('com.expensetracker/sms');
  final AppDatabase database;

  SmsService(this.database) {
    _setupSmsListener();
  }

  void _setupSmsListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onSmsTransaction') {
        final String jsonStr = call.arguments as String;
        final Map<String, dynamic> data = jsonDecode(jsonStr);

        await _handleSmsTransaction(data);
      }
    });
  }

  Future<void> _handleSmsTransaction(Map<String, dynamic> data) async {
    try {
      final amount = (data['amount'] as num).toDouble();
      final merchant = data['merchant'] as String;
      final dateStr = data['date'] as String;
      final rawSms = data['rawSms'] as String;

      final date = DateTime.parse(dateStr);

      // Check for duplicates (reconciliation)
      final duplicate = await database.findDuplicate(amount, date, 'sms');

      if (duplicate != null) {
        print('Duplicate transaction found, skipping SMS entry');
        return;
      }

      // Insert transaction
      await database.insertTransaction(
        TransactionsCompanion(
          amount: drift.Value(amount),
          merchant: drift.Value(merchant),
          date: drift.Value(date),
          category: drift.Value(_categorizeTransaction(merchant)),
          source: const drift.Value('sms'),
          rawData: drift.Value(rawSms),
        ),
      );

      print('SMS transaction saved: ₹$amount at $merchant');
    } catch (e) {
      print('Error handling SMS transaction: $e');
    }
  }

  String _categorizeTransaction(String merchant) {
    return CategoryKeywords.categorize(merchant);
  }

  Future<bool> requestSmsPermissions() async {
    final status = await Permission.sms.status;

    if (status.isGranted || status.isPermanentlyDenied) {
      return status.isGranted;
    }

    final result = await Permission.sms.request();
    return result.isGranted;
  }
}
