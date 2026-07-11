import 'package:flutter/material.dart';
import '../database/database.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import 'transaction_items.dart';
import 'common/glass_container.dart';

class GhostBillsBottomSheet extends StatelessWidget {
  final AppDatabase database;

  const GhostBillsBottomSheet({super.key, required this.database});

  static void show(BuildContext context, AppDatabase database) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GhostBillsBottomSheet(database: database),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return GlassContainer(
          borderRadius: 28.0,
          margin: const EdgeInsets.only(top: 24),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warningBorder.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: AppColors.warningBorder,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'All Upcoming Bills',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // List of all ghost bills sorted soonest first
              Expanded(
                child: FutureBuilder<List<GhostBill>>(
                  future: database.getAllGhostBills(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final bills = snapshot.data ?? [];
                    if (bills.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: Colors.grey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No upcoming bills predicted yet.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppTheme.textGrayDark
                                    : AppTheme.textGrayLight,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Sort soonest first by predicted next due date
                    final sortedBills = List<GhostBill>.from(bills)
                      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: sortedBills.length,
                      itemBuilder: (context, index) {
                        return GhostBillItem(bill: sortedBills[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
