import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/database.dart';
import '../services/voice_service.dart';
import '../services/local_voice_parser.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common/soft_card.dart';
import 'package:drift/drift.dart' as drift;

class AddExpenseScreen extends StatefulWidget {
  final AppDatabase database;
  final bool isIncome;
  final Transaction? transactionToEdit;
  final bool initialVoiceTrigger;

  const AddExpenseScreen({
    super.key,
    required this.database,
    this.isIncome = false,
    this.transactionToEdit,
    this.initialVoiceTrigger = false,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
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
    _isIncomeMode = widget.isIncome;

    if (_isIncomeMode) {
      _categories = ['Salary', 'Investment Returns', 'Other Income'];
      _selectedCategory = 'Salary';
    } else {
      _categories = [
        'Groceries',
        'Travel',
        'Car',
        'Home',
        'Shopping',
        'Steam',
        'Shell',
        'Netflix',
        'Other'
      ];
      _selectedCategory = 'Groceries';
    }

    if (widget.transactionToEdit != null) {
      _amountController.text =
          widget.transactionToEdit!.amount.toStringAsFixed(2);
      _merchantController.text = widget.transactionToEdit!.merchant;
      _selectedCategory = widget.transactionToEdit!.category;
      _selectedDate = widget.transactionToEdit!.date;
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _loadMerchantSuggestions();

    _voiceService = VoiceService(widget.database);
    _voiceService.initialize();

    if (widget.initialVoiceTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _toggleVoiceInput();
      });
    }
  }

  Future<void> _loadMerchantSuggestions() async {
    final suggestions =
        await widget.database.getUniqueMerchants(isIncome: _isIncomeMode);
    if (mounted) {
      setState(() {
        _merchantSuggestions = suggestions;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _pulseController.dispose();
    if (_isListening) {
      _voiceService.stopListening();
    }
    super.dispose();
  }

  void _onKeypadTap(String value) {
    if (_isAmountUncertain) {
      setState(() => _isAmountUncertain = false);
    }
    if (value == 'BACKSPACE') {
      if (_amountController.text.isNotEmpty) {
        setState(() {
          _amountController.text = _amountController.text
              .substring(0, _amountController.text.length - 1);
        });
      }
    } else if (value == '.') {
      if (!_amountController.text.contains('.')) {
        setState(() {
          _amountController.text += _amountController.text.isEmpty ? '0.' : '.';
        });
      }
    } else {
      // Limit decimal places to 2
      if (_amountController.text.contains('.')) {
        final parts = _amountController.text.split('.');
        if (parts.length > 1 && parts[1].length >= 2) {
          return; // Max 2 decimal digits
        }
      }
      setState(() {
        if (_amountController.text == '0' && value != '.') {
          _amountController.text = value;
        } else {
          _amountController.text += value;
        }
      });
    }
  }

  void _onVoiceResultParsed(VoiceParseResult result) {
    setState(() {
      _isAmountUncertain = false;
      _isMerchantUncertain = false;
      _isCategoryUncertain = false;

      if (result.amount != null && result.amount! > 0) {
        _amountController.text = result.amount!.toStringAsFixed(2);
        if (!result.isAmountClean) _isAmountUncertain = true;
      }
      if (result.merchant.isNotEmpty && result.merchant != 'Unknown') {
        _merchantController.text = result.merchant;
        if (!result.isMerchantMatched) _isMerchantUncertain = true;
      }
      if (_categories.contains(result.category)) {
        _selectedCategory = result.category;
        if (!result.isCategoryInferred) _isCategoryUncertain = true;
      }
    });

    bool hasAnyUncertainty = _isAmountUncertain ||
        _isMerchantUncertain ||
        _isCategoryUncertain ||
        !result.isHighConfidence;

    if (!hasAnyUncertainty &&
        result.amount != null &&
        result.merchant.isNotEmpty &&
        result.merchant != 'Unknown') {
      _showHighConfidenceConfirmation(result);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify fields marked with warning'),
            backgroundColor: AppColors.heroGradientStart,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showHighConfidenceConfirmation(VoiceParseResult result) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SoftCard(
          borderRadius: 28,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Auto-Parsed Successfully',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Outfit',
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '₹${result.amount?.toStringAsFixed(2)} at ${result.merchant} (${result.category})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Edit First',
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
                      onPressed: () {
                        Navigator.pop(context);
                        _saveManualExpense();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'Confirm & Save',
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
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.heroGradientStart,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission required for Voice Entry'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveManualExpense() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0 || _merchantController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount and merchant name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final transactionCompanion = TransactionsCompanion(
      amount: drift.Value(amount),
      merchant: drift.Value(_merchantController.text),
      date: drift.Value(_selectedDate),
      category: drift.Value(_selectedCategory),
      source: drift.Value('manual'),
      isRecurring: const drift.Value(false),
    );

    if (widget.transactionToEdit != null) {
      final updatedTransaction = Transaction(
        id: widget.transactionToEdit!.id,
        amount: amount,
        merchant: _merchantController.text,
        date: _selectedDate,
        category: _selectedCategory,
        source: widget.transactionToEdit!.source,
        isRecurring: widget.transactionToEdit!.isRecurring,
        rawData: widget.transactionToEdit!.rawData,
        createdAt: widget.transactionToEdit!.createdAt,
      );
      await widget.database.updateTransaction(updatedTransaction);
    } else {
      await widget.database.insertTransaction(transactionCompanion);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildKeypadButton(String label, {IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Material(
        color: isDark ? const Color(0xFF262626) : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _onKeypadTap(label),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 58,
            alignment: Alignment.center,
            child: icon != null
                ? Icon(icon,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    size: 24)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Outfit',
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor =
        _isIncomeMode ? const Color(0xFF10B981) : AppColors.heroGradientStart;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: isDark ? AppTheme.textLight : AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.transactionToEdit != null
              ? 'Edit ${_isIncomeMode ? "Income" : "Expense"}'
              : (_isIncomeMode ? 'Add Income' : 'Add Expense'),
          style: TextStyle(
            color: isDark ? AppTheme.textLight : AppTheme.textDark,
            fontWeight: FontWeight.w700,
            fontFamily: 'Outfit',
            fontSize: 20,
          ),
        ),
        actions: [
          // Voice mic trigger button
          GestureDetector(
            onTap: _toggleVoiceInput,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? themeColor
                        : (isDark
                            ? const Color(0xFF262626)
                            : const Color(0xFFEEEEEE)),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: themeColor.withValues(
                                  alpha: 0.5 * _pulseController.value),
                              blurRadius: 12,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListening
                        ? Colors.white
                        : (isDark ? AppTheme.textLight : AppTheme.textDark),
                    size: 22,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable fields area
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Large ₹ Amount Display above keypad per v3 spec
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          if (_isAmountUncertain) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    size: 16,
                                    color: AppColors.heroGradientStart),
                                const SizedBox(width: 6),
                                const Text(
                                  'Low confidence amount - check carefully',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.heroGradientStart,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Outfit',
                                  color: _amountController.text.isEmpty
                                      ? (isDark
                                          ? AppTheme.textGrayDark
                                          : AppTheme.textGrayLight)
                                      : themeColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _amountController.text.isEmpty
                                    ? '0'
                                    : _amountController.text,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Outfit',
                                  color: _amountController.text.isEmpty
                                      ? (isDark
                                          ? AppTheme.textGrayDark
                                          : AppTheme.textGrayLight)
                                      : themeColor,
                                ),
                              ),
                            ],
                          ),
                          if (_voiceText.isNotEmpty && _isListening) ...[
                            const SizedBox(height: 8),
                            Text(
                              _voiceText,
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? AppTheme.textGrayDark
                                    : AppTheme.textGrayLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Merchant Input Autocomplete
                    LayoutBuilder(builder: (context, constraints) {
                      return Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
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
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          textEditingController.addListener(() {
                            _merchantController.text =
                                textEditingController.text;
                          });

                          return TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            onChanged: (v) {
                              if (_isMerchantUncertain) {
                                setState(() => _isMerchantUncertain = false);
                              }
                            },
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.textLight
                                  : AppTheme.textDark,
                              fontFamily: 'Inter',
                            ),
                            decoration: InputDecoration(
                              hintText: _isIncomeMode
                                  ? 'Source (e.g. Employer Name)'
                                  : 'Merchant (e.g. Amazon, Starbucks)',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? AppTheme.textGrayDark
                                    : AppTheme.textGrayLight,
                                fontWeight: FontWeight.normal,
                              ),
                              filled: true,
                              fillColor: _isMerchantUncertain
                                  ? AppColors.heroGradientStart
                                      .withValues(alpha: 0.15)
                                  : (isDark
                                      ? const Color(0xFF262626)
                                      : const Color(0xFFEEEEEE)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 16),
                              prefixIcon: Icon(
                                _isIncomeMode
                                    ? Icons.work_outline_rounded
                                    : Icons.storefront_rounded,
                                color: isDark
                                    ? AppTheme.textGrayDark
                                    : AppTheme.textGrayLight,
                              ),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(16),
                              color: isDark
                                  ? const Color(0xFF262626)
                                  : Colors.white,
                              child: Container(
                                width: constraints.maxWidth,
                                constraints:
                                    const BoxConstraints(maxHeight: 180),
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  separatorBuilder: (context, index) => Divider(
                                      height: 1,
                                      color:
                                          Colors.grey.withValues(alpha: 0.2)),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final String option =
                                        options.elementAt(index);
                                    return ListTile(
                                      title: Text(
                                        option,
                                        style: TextStyle(
                                          color: isDark
                                              ? AppTheme.textLight
                                              : AppTheme.textDark,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    const SizedBox(height: 16),

                    // Date Selection Box
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF262626)
                              : const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                color: themeColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('MMMM dd, yyyy').format(_selectedDate),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppTheme.textLight
                                    : AppTheme.textDark,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_drop_down_rounded,
                                color: isDark
                                    ? AppTheme.textGrayDark
                                    : AppTheme.textGrayLight),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Category Chips
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Outfit',
                        color: isDark
                            ? AppTheme.textGrayDark
                            : AppTheme.textGrayLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSelected = category == _selectedCategory;
                        final dotColor =
                            AppColors.getCategoryDotColor(category);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              if (_isCategoryUncertain)
                                _isCategoryUncertain = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? dotColor
                                  : (isDark
                                      ? const Color(0xFF262626)
                                      : const Color(0xFFEEEEEE)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : dotColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontFamily: 'Inter',
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? AppTheme.textLight
                                            : AppTheme.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Section: Custom 3-Column Keypad & Solid Black Pill Button per v3 spec
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              decoration: BoxDecoration(
                color:
                    isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3-Column Numeric Keypad
                  Column(
                    children: [
                      Row(
                        children: [
                          _buildKeypadButton('1'),
                          const SizedBox(width: 10),
                          _buildKeypadButton('2'),
                          const SizedBox(width: 10),
                          _buildKeypadButton('3'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildKeypadButton('4'),
                          const SizedBox(width: 10),
                          _buildKeypadButton('5'),
                          const SizedBox(width: 10),
                          _buildKeypadButton('6'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildKeypadButton('7'),
                          const SizedBox(width: 10),
                          _buildKeypadButton('8'),
                          const SizedBox(width: 10),
                          _buildKeypadButton('9'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildKeypadButton('.'),
                          const SizedBox(width: 10),
                          _buildKeypadButton('0'),
                          const SizedBox(width: 10),
                          _buildKeypadButton('BACKSPACE',
                              icon: Icons.backspace_outlined),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Solid Black Pill Save Button (999px radius) per v3 spec
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveManualExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        widget.transactionToEdit != null
                            ? 'Save Changes'
                            : (_isIncomeMode ? 'Save Income' : 'Save Expense'),
                        style: const TextStyle(
                          fontSize: 16,
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
          ],
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
