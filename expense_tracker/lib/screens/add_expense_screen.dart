import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/database.dart';
import '../services/voice_service.dart';
import '../services/local_voice_parser.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'package:drift/drift.dart' as drift;

class AddExpenseScreen extends StatefulWidget {
  final AppDatabase database;
  final bool isIncome;
  final Transaction? transactionToEdit;

  const AddExpenseScreen({
    super.key,
    required this.database,
    this.isIncome = false,
    this.transactionToEdit,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _merchantController =
      TextEditingController(); // Kept for logic, but will be synced with Autocomplete
  late String _selectedCategory;
  List<String> _merchantSuggestions = [];

  late VoiceService _voiceService;
  bool _isListening = false;
  String _voiceText = '';
  DateTime _selectedDate = DateTime.now();

  bool _isAmountUncertain = false;
  bool _isMerchantUncertain = false;
  bool _isCategoryUncertain = false;

  late AnimationController _pulseController;

  late final List<String> _categories;
  late final bool _isIncomeMode;

  @override
  void initState() {
    super.initState();

    // Determine mode based on transaction if editing, otherwise use isIncome flag
    if (widget.transactionToEdit != null) {
      final incomeCategories = [
        'Salary',
        'Investment Returns',
        'Rent',
        'Other Income'
      ];
      _isIncomeMode =
          incomeCategories.contains(widget.transactionToEdit!.category);
      _selectedDate = widget.transactionToEdit!.date;
      _amountController.text = widget.transactionToEdit!.amount
          .toStringAsFixed(0); // Keep whole numbers
      _merchantController.text = widget.transactionToEdit!.merchant;
      _selectedCategory = widget.transactionToEdit!.category;
    } else {
      _isIncomeMode = widget.isIncome;
      _selectedCategory = _isIncomeMode ? 'Salary' : 'Groceries';
    }

    _loadSuggestions();

    _categories = _isIncomeMode
        ? ['Salary', 'Investment Returns', 'Rent', 'Other Income']
        : ['Groceries', 'Travel', 'Car', 'Home', 'Other'];

    // If not editing, select first category (or if editing category is not in list, careful)
    if (widget.transactionToEdit == null) {
      _selectedCategory = _categories.first;
    } else if (!_categories.contains(_selectedCategory)) {
      // Fallback if category not found in list (e.g. legacy data)
      if (_categories.contains('Other')) {
        _selectedCategory = 'Other';
      } else {
        _selectedCategory = _categories.first;
      }
    }

    _voiceService = VoiceService(widget.database);
    _voiceService.initialize();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _amountController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    final merchants = await widget.database.getDistinctMerchants();
    if (mounted) {
      setState(() {
        _merchantSuggestions = merchants;
      });
    }
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      }
      return word;
    }).join(' ');
  }

  void _onVoiceResultParsed(VoiceParseResult result) {
    if (!mounted) return;
    setState(() {
      _isListening = false;
      if (result.amount != null && result.amount! > 0) {
        _amountController.text = result.amount!
            .toStringAsFixed(result.amount! == result.amount!.toInt() ? 0 : 2);
      }
      if (result.merchant.isNotEmpty && result.merchant != 'Unknown') {
        _merchantController.text = _capitalize(result.merchant);
      }
      if (_categories.contains(result.category)) {
        _selectedCategory = result.category;
      }

      _isAmountUncertain = !result.isAmountClean;
      _isMerchantUncertain = !result.isMerchantMatched;
      _isCategoryUncertain = !result.isCategoryInferred;
    });

    if (result.isHighConfidence) {
      _showHighConfidenceConfirmation(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Uncertain fields flagged (${result.confidenceScore.toStringAsFixed(1)}/2.5). Please review highlighted inputs.'),
          backgroundColor: AppColors.warningBorder,
        ),
      );
    }
  }

  void _showHighConfidenceConfirmation(VoiceParseResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: _themeColor),
            const SizedBox(width: 8),
            const Text('High Confidence Match',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confidence: ${result.confidenceScore.toStringAsFixed(1)}/2.5',
                style: const TextStyle(fontSize: 13, color: AppTheme.textGray)),
            const SizedBox(height: 12),
            Text('Amount: ₹${result.amount ?? 0}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Merchant: ${result.merchant}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Category: ${result.category}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Text('Save this entry automatically?',
                style: TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Review / Edit',
                style: TextStyle(color: AppTheme.textGray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveManualExpense();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('One-Tap Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      bool canListen = kIsWeb;
      if (!kIsWeb) {
        final permission = await Permission.microphone.request();
        canListen = permission.isGranted;
      }
      if (canListen) {
        await _voiceService.startListening(
          isIncome: _isIncomeMode,
          onTextChange: (text) => setState(() => _voiceText = text),
          onError: (error) {
            setState(() => _isListening = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onResultParsed: _onVoiceResultParsed,
        );
        setState(() => _isListening = true);
      }
    }
  }

  Future<void> _saveManualExpense() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _merchantController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount and merchant')),
      );
      return;
    }

    if (widget.transactionToEdit != null) {
      // Update existing
      final merchantName = _capitalize(_merchantController.text.trim());
      await widget.database.updateTransaction(
        widget.transactionToEdit!.toCompanion(true).copyWith(
              amount: drift.Value(amount),
              merchant: drift.Value(merchantName),
              date: drift.Value(_selectedDate),
              category: drift.Value(_selectedCategory),
              // Keep original source
            ),
      );
    } else {
      // Insert new
      final merchantName = _capitalize(_merchantController.text.trim());
      await widget.database.insertTransaction(
        TransactionsCompanion(
          amount: drift.Value(amount),
          merchant: drift.Value(merchantName),
          date: drift.Value(_selectedDate),
          category: drift.Value(_selectedCategory),
          source: const drift.Value('manual'),
        ),
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Color get _themeColor =>
      _isIncomeMode ? Colors.green : AppTheme.primaryPurple;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _themeColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    widget.transactionToEdit != null
                        ? 'Edit ${_isIncomeMode ? "Income" : "Expense"}'
                        : 'Add ${_isIncomeMode ? "Income" : "Expense"}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 32),

              // Amount Input
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: _isAmountUncertain
                    ? BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.warningSurfaceDark
                            : AppColors.warningSurfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.warningBorder, width: 2),
                      )
                    : null,
                child: Center(
                  child: Column(
                    children: [
                      if (_isAmountUncertain)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 16, color: AppColors.warningBorder),
                              const SizedBox(width: 6),
                              Text('Low confidence amount - review required',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.warningBorder,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _amountController.text.isEmpty
                                  ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppTheme.textGrayDark
                                      : AppTheme.textGrayLight)
                                  : _themeColor,
                            ),
                          ),
                          IntrinsicWidth(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                if (_isAmountUncertain)
                                  setState(() => _isAmountUncertain = false);
                              },
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: _themeColor,
                              ),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(
                                  fontSize: 48,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppTheme.textGrayDark
                                      : AppTheme.textGrayLight,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Enter Amount',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Merchant Input
              // Merchant Input (Autocomplete)
              LayoutBuilder(builder: (context, constraints) {
                return Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return _merchantSuggestions.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  initialValue:
                      TextEditingValue(text: _merchantController.text),
                  onSelected: (String selection) {
                    _merchantController.text = selection;
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    // Sync controllers
                    textEditingController.addListener(() {
                      _merchantController.text = textEditingController.text;
                    });

                    // If we have an initial value (edit mode), set it once
                    if (_merchantController.text.isNotEmpty &&
                        textEditingController.text.isEmpty) {
                      // This is tricky in build, but initialValue handles it mostly.
                      // However, if we edit, we want the controller to drive.
                      // But Autocomplete manages its own controller in fieldViewBuilder.
                      // We rely on initialValue above.
                    }

                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onChanged: (v) {
                        if (_isMerchantUncertain)
                          setState(() => _isMerchantUncertain = false);
                      },
                      decoration: InputDecoration(
                        hintText: _isIncomeMode
                            ? 'Source (e.g. Salary)'
                            : 'Merchant/Description',
                        filled: true,
                        fillColor: _isMerchantUncertain
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? AppColors.warningSurfaceDark
                                : AppColors.warningSurfaceLight)
                            : Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: _isMerchantUncertain
                              ? BorderSide(
                                  color: AppColors.warningBorder, width: 2)
                              : BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: _isMerchantUncertain
                              ? BorderSide(
                                  color: AppColors.warningBorder, width: 2)
                              : BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        suffixIcon: _isMerchantUncertain
                            ? Icon(Icons.warning_amber_rounded,
                                color: AppColors.warningBorder)
                            : null,
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context).cardColor,
                        child: Container(
                          width: constraints.maxWidth,
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).cardColor,
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                title: Text(option),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 24),

              // Date Selection
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: _themeColor, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down,
                          color: AppTheme.textGray),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Category Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isCategoryUncertain)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 16, color: AppColors.warningBorder),
                          const SizedBox(width: 6),
                          Text('Low confidence category - review required',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.warningBorder,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  Container(
                    padding: _isCategoryUncertain
                        ? const EdgeInsets.all(8)
                        : EdgeInsets.zero,
                    decoration: _isCategoryUncertain
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.warningBorder, width: 1.5),
                          )
                        : null,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSelected = category == _selectedCategory;
                        return _CategoryChip(
                          label: category,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              if (_isCategoryUncertain)
                                _isCategoryUncertain = false;
                            });
                          },
                          selectedColor: _themeColor,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Voice Input Button
              Center(
                child: GestureDetector(
                  onTap: _toggleVoiceInput,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _isIncomeMode
                              ? LinearGradient(colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade700
                                ])
                              : AppTheme.purpleGradient,
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: (_themeColor).withOpacity(
                                      0.5 * _pulseController.value,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 36,
                        ),
                      );
                    },
                  ),
                ),
              ),

              if (_voiceText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassmorphism(
                    color: _themeColor,
                    opacity: 0.1,
                  ),
                  child: Text(
                    _voiceText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveManualExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(widget.transactionToEdit != null
                      ? 'Save Changes'
                      : (_isIncomeMode ? 'Add Income' : 'Add Expense')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
  });

  IconData _getIcon(String category) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(label),
              size: 16,
              color: isSelected ? Colors.white : AppTheme.textGray,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
