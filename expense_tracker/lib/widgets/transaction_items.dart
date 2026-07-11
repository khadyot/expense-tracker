import 'package:flutter/material.dart';
import '../database/database.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Groceries':
        return Icons.shopping_basket;
      case 'Travel':
        return Icons.flight;
      case 'Car':
        return Icons.directions_car;
      case 'Home':
      case 'Rent':
        return Icons.home;
      case 'Salary':
        return Icons.work;
      case 'Investment Returns':
        return Icons.trending_up;
      default:
        return Icons.payment;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Groceries':
        return AppTheme.groceries;
      case 'Travel':
        return AppTheme.travel;
      case 'Car':
        return AppTheme.car;
      case 'Home':
        return AppTheme.home;
      case 'Salary':
      case 'Investment Returns':
      case 'Rent':
      case 'Other Income': // Assuming this is used
        return Colors.green;
      default:
        return AppTheme.primaryPurple;
    }
  }

  String _getSourceBadge(String source) {
    switch (source) {
      case 'sms':
        return 'SMS';
      case 'voice':
        return 'VOICE';
      case 'manual':
        return 'MANUAL';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(transaction.category);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: AppTheme.glassmorphism(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(transaction.category),
                    color: categoryColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              transaction.merchant,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (transaction.source != 'manual')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getSourceBadge(transaction.source),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              transaction.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: categoryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.textGrayDark
                                  : AppTheme.textGrayLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(transaction.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.textGrayDark
                                  : AppTheme.textGrayLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Amount
                Consumer<UserProvider>(
                  builder: (context, user, child) {
                    return Text(
                      user.isPrivacyModeEnabled
                          ? '₹****'
                          : '₹${transaction.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GhostBillItem extends StatelessWidget {
  final GhostBill bill;

  const GhostBillItem({
    super.key,
    required this.bill,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
    final daysUntil = bill.nextDueDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withOpacity(0.05),
            AppTheme.lightPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ghost Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Bill Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bill.merchant,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: bill.isInferred
                              ? AppColors.warningBorder.withValues(alpha: 0.2)
                              : AppTheme.primaryPurple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          bill.isInferred ? 'PREDICTED' : 'CONFIRMED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: bill.isInferred
                                ? AppColors.warningBorder
                                : AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        bill.frequency.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.textGrayDark
                              : AppTheme.textGrayLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Due ${dateFormat.format(bill.nextDueDate)} ($daysUntil days)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.textGrayDark
                              : AppTheme.textGrayLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Predicted Amount
            Consumer<UserProvider>(
              builder: (context, user, child) {
                final amountPrefix = bill.isInferred ? '≈ ₹' : '₹';
                final amountText = user.isPrivacyModeEnabled
                    ? '$amountPrefix****'
                    : '$amountPrefix${bill.predictedAmount.toStringAsFixed(0)}';
                final confidenceText =
                    bill.isInferred ? '${bill.confidence}% sure' : 'Confirmed';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amountText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: bill.isInferred
                            ? AppColors.warningBorder
                            : AppTheme.primaryPurple,
                      ),
                    ),
                    Text(
                      confidenceText,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.textGrayDark
                            : AppTheme.textGrayLight,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
