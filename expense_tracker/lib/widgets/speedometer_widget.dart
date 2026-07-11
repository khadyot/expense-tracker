import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

class SpeedometerWidget extends StatelessWidget {
  final double dailyLimit;
  final double currentSpent;
  final double predictedSpend; // Including ghost bills
  final VoidCallback? onAddExpense;
  final VoidCallback? onVoiceEntry;
  final VoidCallback? onExport;
  final VoidCallback? onMore;

  const SpeedometerWidget({
    super.key,
    required this.dailyLimit,
    required this.currentSpent,
    this.predictedSpend = 0,
    this.onAddExpense,
    this.onVoiceEntry,
    this.onExport,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final safeToSpend = math.max(0.0, dailyLimit - currentSpent);
    final percentage =
        (dailyLimit > 0) ? (currentSpent / dailyLimit * 100) : 0.0;
    final isOverBudget = currentSpent > dailyLimit;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroGradientStart.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Card Title / Status Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOverBudget
                              ? Icons.warning_amber_rounded
                              : Icons.verified_user_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOverBudget ? 'Over Limit' : 'Safe to Spend',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (predictedSpend > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Ghost Bills: ₹${predictedSpend.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}% Used',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Large Bold Numeral for Safe-to-Spend Balance (Hero Card layout per reference)
          Text(
            '₹${safeToSpend.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Outfit',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available of limit ₹${dailyLimit.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Spent: ₹${currentSpent.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.90),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Row of Circular Icon-Buttons Beneath Numeral per v3 spec
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _HeroIconButton(
                icon: Icons.add_rounded,
                label: 'Add',
                onTap: onAddExpense,
              ),
              _HeroIconButton(
                icon: Icons.mic_rounded,
                label: 'Voice',
                onTap: onVoiceEntry,
              ),
              _HeroIconButton(
                icon: Icons.download_rounded,
                label: 'Export',
                onTap: onExport,
              ),
              _HeroIconButton(
                icon: Icons.grid_view_rounded,
                label: 'More',
                onTap: onMore,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _HeroIconButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
