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

  bool _isIncome(String category) {
    final c = category.toLowerCase();
    return c == 'salary' ||
        c == 'investment returns' ||
        c == 'other income' ||
        c == 'income' ||
        c == 'bonus';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Groceries':
        return Icons.shopping_basket_rounded;
      case 'Travel':
        return Icons.flight_rounded;
      case 'Car':
        return Icons.directions_car_rounded;
      case 'Home':
      case 'Rent':
        return Icons.home_rounded;
      case 'Salary':
      case 'Investment Returns':
      case 'Other Income':
        return Icons.work_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.getCategoryDotColor(transaction.category);
    final dateFormat = DateFormat('MMM dd, yyyy • h:mm a');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInc = _isIncome(transaction.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: AppTheme.softDecoration(
        isDark: isDark,
        borderRadius: 20,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                // Circular merchant icon/avatar on the left
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(transaction.category),
                    color: categoryColor,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                // Merchant name and timestamp stacked
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              transaction.merchant,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppTheme.textLight
                                    : AppTheme.textDark,
                                fontFamily: 'Inter',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (transaction.source != 'manual') ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.darkAccent
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                transaction.source.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppTheme.textGrayDark
                                      : AppTheme.textGrayLight,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            transaction.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppTheme.textGrayDark
                                  : AppTheme.textGrayLight,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppTheme.textGrayDark
                                  : AppTheme.textGrayLight,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dateFormat.format(transaction.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppTheme.textGrayDark
                                    : AppTheme.textGrayLight,
                                fontFamily: 'Inter',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Tabular amount right-aligned and colored per v3 spec
                Consumer<UserProvider>(
                  builder: (context, user, child) {
                    final prefix = isInc ? '+₹' : '-₹';
                    final amountFormatted = user.isPrivacyModeEnabled
                        ? '$prefix****'
                        : '$prefix${transaction.amount.toStringAsFixed(2)}';

                    return Text(
                      amountFormatted,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Outfit',
                        color: isInc
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE63920),
                      ),
                      textAlign: TextAlign.right,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = AppColors.getCategoryDotColor(bill.merchant);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: AppTheme.softDecoration(
        isDark: isDark,
        borderRadius: 20,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            // Circular icon on the left
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: categoryColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Merchant Details Stacked
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bill.merchant,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? AppTheme.textLight : AppTheme.textDark,
                            fontFamily: 'Inter',
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
                              : AppColors.heroGradientStart
                                  .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bill.isInferred ? 'PREDICTED' : 'CONFIRMED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: bill.isInferred
                                ? (isDark
                                    ? const Color(0xFFFDE047)
                                    : const Color(0xFFCA8A04))
                                : AppColors.heroGradientStart,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        bill.frequency.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: categoryColor,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textGrayDark
                              : AppTheme.textGrayLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Due ${dateFormat.format(bill.nextDueDate)} (${daysUntil >= 0 ? "$daysUntil d" : "Overdue"})',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.textGrayDark
                              : AppTheme.textGrayLight,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right-aligned colored amount per v3 spec
            Consumer<UserProvider>(
              builder: (context, user, child) {
                final prefix = bill.isInferred ? '≈ -₹' : '-₹';
                final amountText = user.isPrivacyModeEnabled
                    ? '$prefix****'
                    : '$prefix${bill.predictedAmount.toStringAsFixed(2)}';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amountText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Outfit',
                        color: Color(0xFFE63920),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bill.isInferred
                          ? '${bill.confidence}% sure'
                          : 'Confirmed',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppTheme.textGrayDark
                            : AppTheme.textGrayLight,
                        fontFamily: 'Inter',
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
