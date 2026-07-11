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
import '../theme/app_colors.dart';
import '../widgets/common/soft_card.dart';
import 'add_expense_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/sms_service.dart';
import '../services/notification_service.dart';

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

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _loadData();
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestFirstLaunchPermissions();
    });
  }

  Future<void> _loadData() async {
    final transactions = await widget.database.getAllTransactions();
    final ghostBills = await widget.database.getAllGhostBills();

    double spent = 0.0;
    final now = DateTime.now();
    for (var t in transactions) {
      if (t.date.year == now.year &&
          t.date.month == now.month &&
          t.date.day == now.day &&
          t.category != 'Salary' &&
          t.category != 'Investment Returns' &&
          t.category != 'Other Income') {
        spent += t.amount;
      }
    }

    if (mounted) {
      setState(() {
        _recentTransactions = transactions.take(8).toList();
        _upcomingBills = ghostBills;
        _todaySpent = spent;
        _predictedSpend = GhostBillService.calculatePredictedSpend(ghostBills);
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _requestFirstLaunchPermissions() async {
    if (!mounted || kIsWeb) return;

    final smsStatus = await Permission.sms.status;
    if (!smsStatus.isGranted && !smsStatus.isPermanentlyDenied) {
      final bool? proceedSms = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (BuildContext dialogContext) {
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SoftCard(
              borderRadius: 28.0,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          AppColors.heroGradientStart.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sms_outlined,
                      color: AppColors.heroGradientStart,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Auto-Detect Bank SMS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Outfit',
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We automatically parse transaction SMS from your bank to track spending instantly. All parsing happens 100% locally on your device—no financial data ever leaves your phone.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppTheme.textGrayDark
                          : AppTheme.textGrayLight,
                      fontFamily: 'Inter',
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
                          child: Text(
                            'Not Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.textGrayDark
                                  : AppTheme.textGrayLight,
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
                            backgroundColor: AppColors.darkAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text(
                            'Enable SMS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Outfit',
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

    final notifStatus = await Permission.notification.status;
    if (!notifStatus.isGranted && !notifStatus.isPermanentlyDenied) {
      final bool? proceedNotif = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (BuildContext dialogContext) {
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SoftCard(
              borderRadius: 28.0,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          AppColors.heroGradientStart.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.heroGradientStart,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Budget Alerts & Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Outfit',
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Receive real-time budget warnings and upcoming predicted bill alerts directly from local background tasks.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppTheme.textGrayDark
                          : AppTheme.textGrayLight,
                      fontFamily: 'Inter',
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
                          child: Text(
                            'Not Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.textGrayDark
                                  : AppTheme.textGrayLight,
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
                            backgroundColor: AppColors.darkAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text(
                            'Enable Alerts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Outfit',
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
        await NotificationService().initialize();
      }
    }
  }

  void _openAddExpense({bool isIncome = false, bool isVoice = false}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          database: widget.database,
          isIncome: isIncome,
          initialVoiceTrigger: isVoice,
        ),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM dd');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor:
            isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.heroGradientStart,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header Area
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Outfit',
                                      color: isDark
                                          ? AppTheme.textLight
                                          : AppTheme.textDark,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateFormat.format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppTheme.textGrayDark
                                      : AppTheme.textGrayLight,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkAccent
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.08),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color:
                                    isDark ? Colors.white : AppTheme.textDark,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Hero Card (Safe-to-Spend Speedometer balance card) per v3 spec
                SliverToBoxAdapter(
                  child: Consumer<UserProvider>(
                    builder: (context, user, child) {
                      return SpeedometerWidget(
                        dailyLimit: user.dailyLimit,
                        currentSpent: _todaySpent,
                        predictedSpend: _predictedSpend,
                        onAddExpense: () => _openAddExpense(isIncome: false),
                        onVoiceEntry: () =>
                            _openAddExpense(isIncome: false, isVoice: true),
                        onExport: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryScreen(database: widget.database),
                            ),
                          );
                        },
                        onMore: () {
                          GhostBillsBottomSheet.show(context, widget.database);
                        },
                      );
                    },
                  ),
                ),

                // Dashboard Quick-Action Grid per v3 spec
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        // Highest-priority action: Plain Black
                        Expanded(
                          child: SoftCard(
                            borderRadius: 20,
                            backgroundColor: AppColors.darkAccent,
                            onTap: () => _openAddExpense(isIncome: false),
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add Expense',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Record manually',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Alternating coral-tinted card
                        Expanded(
                          child: SoftCard(
                            borderRadius: 20,
                            backgroundColor: isDark
                                ? const Color(0xFF3D241E)
                                : const Color(0xFFFDECE8),
                            onTap: () =>
                                _openAddExpense(isIncome: false, isVoice: true),
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.heroGradientStart
                                        .withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.mic_rounded,
                                    color: AppColors.heroGradientStart,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Voice Entry',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : AppTheme.textDark,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Speak naturally',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppTheme.textGrayDark
                                              : AppTheme.textGrayLight,
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Upcoming Ghost Bills Section
                if (_upcomingBills.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppColors.heroGradientStart,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Upcoming Bills',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Outfit',
                                  color: isDark
                                      ? AppTheme.textLight
                                      : AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => GhostBillsBottomSheet.show(
                                context, widget.database),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkAccent
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.1)),
                              ),
                              child: Text(
                                'See All (${_upcomingBills.length})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDark ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return GhostBillItem(bill: _upcomingBills[index]);
                      },
                      childCount: _upcomingBills.take(3).length,
                    ),
                  ),
                ],

                // Recent Transactions Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.darkAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Outfit',
                                color: isDark
                                    ? AppTheme.textLight
                                    : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HistoryScreen(database: widget.database),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.darkAccent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Outfit',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_recentTransactions.isEmpty)
                  SliverToBoxAdapter(
                    child: SoftCard(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 56,
                            color: (isDark
                                    ? AppTheme.textGrayDark
                                    : AppTheme.textGrayLight)
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Outfit',
                              color: isDark
                                  ? AppTheme.textLight
                                  : AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Use the action grid or buttons above to record your spending.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppTheme.textGrayDark
                                  : AppTheme.textGrayLight,
                              fontFamily: 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return TransactionListItem(
                          transaction: _recentTransactions[index],
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddExpenseScreen(
                                  database: widget.database,
                                  transactionToEdit: _recentTransactions[index],
                                ),
                              ),
                            );
                            _loadData();
                          },
                        );
                      },
                      childCount: _recentTransactions.length,
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
