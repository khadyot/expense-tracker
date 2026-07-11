import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_items.dart';
import 'add_expense_screen.dart';

class HistoryScreen extends StatefulWidget {
  final AppDatabase database;

  const HistoryScreen({super.key, required this.database});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await widget.database.getAllTransactions();
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(
      List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final dateFormat = DateFormat('MMMM d, yyyy');

    for (var transaction in transactions) {
      String key;
      final date = transaction.date;

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        key = 'Today';
      } else if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        key = 'Yesterday';
      } else {
        key = dateFormat.format(date);
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(transaction);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = _groupTransactionsByDate(_transactions);
    final sortedKeys = groupedTransactions.keys.toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundLight,
              AppTheme.backgroundLight.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header with Back Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.pop(context),
                      color: AppTheme.textDark,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryPurple))
                    : _transactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history_toggle_off,
                                  size: 64,
                                  color:
                                      AppTheme.textGrayLight.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No history yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppTheme.textGrayLight,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: sortedKeys.length,
                            itemBuilder: (context, index) {
                              final dateKey = sortedKeys[index];
                              final transactionsForDate =
                                  groupedTransactions[dateKey]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 24, 24, 8),
                                    child: Text(
                                      dateKey,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textGrayLight,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  ...transactionsForDate
                                      .map((tx) => TransactionListItem(
                                            transaction: tx,
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddExpenseScreen(
                                                    database: widget.database,
                                                    transactionToEdit: tx,
                                                  ),
                                                ),
                                              );
                                              _loadData();
                                            },
                                          )),
                                ],
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
