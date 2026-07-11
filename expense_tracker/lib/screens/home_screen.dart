import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../database/database.dart';
import '../services/demo_seed_service.dart';
import '../services/ghost_bill_service.dart';
import '../widgets/speedometer_widget.dart';
import '../widgets/transaction_items.dart';
import '../widgets/ghost_bills_bottom_sheet.dart';
import '../theme/app_theme.dart';
import 'add_expense_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/sms_service.dart';
import '../services/notification_service.dart';
import '../widgets/common/glass_container.dart';

class HomeScreen extends StatefulWidget {
  final AppDatabase database;

  const HomeScreen({super.key, required this.database});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Transaction> _recentTransactions = [];
  List<GhostBill> _upcomingBills = [];
  double _todaySpent = 0.0;
  double _predictedSpend = 0.0;
  double _monthlyTotal = 0.0;
  int _activeDays = 1;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _loadData();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _requestFirstLaunchPermissions() async {
    if (!mounted || kIsWeb) return;

    // 1. Sequential check and explanation for SMS Permission
    final smsStatus = await Permission.sms.status;
    if (!smsStatus.isGranted && !smsStatus.isPermanentlyDenied) {
      final bool? proceedSms = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (BuildContext dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: GlassContainer(
              borderRadius: 28.0,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sms_outlined,
                      color: AppTheme.primaryPurple,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Auto-Detect Bank SMS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We can automatically parse transaction SMS from your bank to track your spending instantly. All parsing happens 100% locally on your device—no financial data ever leaves your phone.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.textGrayDark
                          : AppTheme.textGrayLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Not Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Enable SMS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (proceedSms == true) {
        await SmsService(widget.database).requestSmsPermissions();
      }
    }

    if (!mounted) return;

    // 2. Sequential check and explanation for Notification Permission
    final notifStatus = await Permission.notification.status;
    if (!notifStatus.isGranted && !notifStatus.isPermanentlyDenied) {
      final bool? proceedNotif = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (BuildContext dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: GlassContainer(
              borderRadius: 28.0,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppTheme.primaryPurple,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Stay on Track',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Get gentle daily reminders to log your expenses and instant alerts whenever you approach your daily budget threshold so you never overspend.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.textGrayDark
                          : AppTheme.textGrayLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Not Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Enable Alerts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (proceedNotif == true) {
        final granted =
            await NotificationService().requestNotificationPermissions();
        if (granted && mounted) {
          final user = Provider.of<UserProvider>(context, listen: false);
          if (user.isDailyReminderEnabled) {
            await NotificationService()
                .scheduleDailyReminder(user.dailyReminderTime);
          }
        }
      }
    }
  }

  Future<void> _loadData() async {
    // First-launch integration: check if database has no transactions
    final allTx = await widget.database.getAllTransactions();
    if (allTx.isEmpty) {
      await DemoSeedService(widget.database).loadDemoData();
      await _requestFirstLaunchPermissions();
    }

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final startOfMonth = DateTime(today.year, today.month, 1);

    final transactions = await widget.database.getTransactionsByDateRange(
      startOfDay,
      endOfDay,
    );

    final bills = await widget.database.getUpcomingGhostBills();
    final todayTotal =
        await widget.database.getTotalSpent(startOfDay, endOfDay);
    final monthTotal =
        await widget.database.getTotalSpent(startOfMonth, endOfDay);
    final activeDays =
        await widget.database.getActiveDayCount(startOfMonth, endOfDay);

    final todayBills = bills.where((b) {
      final daysUntil = b.nextDueDate.difference(today).inDays;
      return daysUntil <= 1;
    }).toList();

    final predicted = todayBills.fold<double>(
      0.0,
      (sum, bill) => sum + bill.predictedAmount,
    );

    setState(() {
      _recentTransactions = transactions;
      _upcomingBills = bills.take(3).toList();
      _todaySpent = todayTotal;
      _predictedSpend = predicted;
      _monthlyTotal = monthTotal;
      _activeDays = activeDays > 0 ? activeDays : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM dd');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.dark
            : Brightness.light, // iOS
      ),
      child: Scaffold(
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
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.primaryPurple,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Modern App Bar
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer<UserProvider>(
                                  builder: (context, user, child) {
                                    return Text(
                                      'Hello, ${user.name}!',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormat.format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppTheme.textGrayDark
                                        : AppTheme.textGrayLight,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.purpleGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppTheme.primaryPurple.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.person,
                                    color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Premium Card - Speedometer
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        decoration: BoxDecoration(
                          gradient: AppTheme.purpleGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Stack(
                            children: [
                              // Background Pattern
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.1,
                                  child: Image.asset(
                                    'assets/pattern.png',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SizedBox(),
                                  ),
                                ),
                              ),
                              // Content
                              Column(
                                children: [
                                  Consumer<UserProvider>(
                                    builder: (context, user, child) {
                                      final now = DateTime.now();
                                      final daysInMonth =
                                          DateUtils.getDaysInMonth(
                                              now.year, now.month);
                                      final monthlyBudget =
                                          user.dailyLimit * daysInMonth;
                                      final progress = (monthlyBudget > 0)
                                          ? (_monthlyTotal / monthlyBudget)
                                              .clamp(0.0, 1.0)
                                          : 0.0;

                                      return Column(
                                        children: [
                                          // Monthly Overview Section
                                          Container(
                                            padding: const EdgeInsets.all(24),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Monthly Spent',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.8),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          user.isPrivacyModeEnabled
                                                              ? '****'
                                                              : '${user.currency}${_monthlyTotal.toStringAsFixed(0)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 32,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          'Budget',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.8),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          user.isPrivacyModeEnabled
                                                              ? '****'
                                                              : '${user.currency}${monthlyBudget.toStringAsFixed(0)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 24),

                                                // Progress Bar
                                                Stack(
                                                  children: [
                                                    Container(
                                                      height: 12,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                    ),
                                                    AnimatedFractionallySizedBox(
                                                      duration: const Duration(
                                                          milliseconds: 1000),
                                                      curve:
                                                          Curves.easeOutCubic,
                                                      widthFactor: progress,
                                                      child: Container(
                                                        height: 12,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.5),
                                                              blurRadius: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${(progress * 100).toStringAsFixed(1)}% of budget used',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Stats Row
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft: Radius.circular(28),
                                                bottomRight:
                                                    Radius.circular(28),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(
                                                  child: _QuickStat(
                                                    icon: Icons.trending_up,
                                                    label: 'Avg/Day',
                                                    value: user
                                                            .isPrivacyModeEnabled
                                                        ? '****'
                                                        : '${user.currency}${(_monthlyTotal / _activeDays).toStringAsFixed(0)}',
                                                  ),
                                                ),
                                                Container(
                                                  width: 1,
                                                  height: 40,
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                ),
                                                Expanded(
                                                  child: _QuickStat(
                                                    icon: Icons
                                                        .account_balance_wallet,
                                                    label: 'Daily Limit',
                                                    value: user
                                                            .isPrivacyModeEnabled
                                                        ? '****'
                                                        : '${user.currency}${user.dailyLimit.toStringAsFixed(0)}',
                                                  ),
                                                ),
                                                Container(
                                                  width: 1,
                                                  height: 40,
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                ),
                                                Expanded(
                                                  child: _QuickStat(
                                                    icon: Icons.today,
                                                    label: 'Spend Today',
                                                    value: user
                                                            .isPrivacyModeEnabled
                                                        ? '****'
                                                        : '${user.currency}${_todaySpent.toStringAsFixed(0)}',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Ghost Bills Section
                  if (_upcomingBills.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFFFF9800),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Upcoming Bills',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => GhostBillsBottomSheet.show(
                                  context, widget.database),
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration:
                                Duration(milliseconds: 300 + (index * 100)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: GhostBillItem(bill: _upcomingBills[index]),
                          );
                        },
                        childCount: _upcomingBills.length,
                      ),
                    ),
                  ],

                  // Recent Transactions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Row(
                        children: [
                          const Text(
                            'Today\'s Activity',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HistoryScreen(database: widget.database),
                                ),
                              );
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_recentTransactions.isEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(48),
                        decoration: AppTheme.glassmorphism(
                          color: AppTheme.primaryPurple,
                          opacity: 0.05,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppTheme.textGrayDark
                                      : AppTheme.textGrayLight)
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppTheme.textGrayDark
                                    : AppTheme.textGrayLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first expense',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppTheme.textGrayDark
                                    : AppTheme.textGrayLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration:
                                Duration(milliseconds: 300 + (index * 80)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: TransactionListItem(
                              transaction: _recentTransactions[index],
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddExpenseScreen(
                                      database: widget.database,
                                      transactionToEdit:
                                          _recentTransactions[index],
                                    ),
                                  ),
                                );
                                _loadData();
                              },
                            ),
                          );
                        },
                        childCount: _recentTransactions.length,
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Premium FAB with Shadow
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: FloatingActionButton.extended(
                  heroTag: 'add_income',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AddExpenseScreen(
                                database: widget.database, isIncome: true),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(-1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeOutCubic;
                          var tween = Tween(begin: begin, end: end).chain(
                            CurveTween(curve: curve),
                          );
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                    _loadData();
                  },
                  backgroundColor: Colors.green,
                  elevation: 8,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Income',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FloatingActionButton.extended(
                  heroTag: 'add_expense',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AddExpenseScreen(
                                database: widget.database, isIncome: false),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeOutCubic;
                          var tween = Tween(begin: begin, end: end).chain(
                            CurveTween(curve: curve),
                          );
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                    _loadData();
                  },
                  backgroundColor: AppTheme.primaryPurple,
                  elevation: 8,
                  icon: const Icon(Icons.remove, color: Colors.white),
                  label: const Text(
                    'Add Expense',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
