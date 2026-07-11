import '../constants/category_keywords.dart';
import '../utils/merchant_matcher.dart';
import '../utils/number_word_parser.dart';

class VoiceParseResult {
  final double? amount;
  final String merchant;
  final String category;
  final double confidenceScore;
  final bool isHighConfidence;
  final bool isAmountClean;
  final bool isMerchantMatched;
  final bool isCategoryInferred;
  final String rawText;

  const VoiceParseResult({
    required this.amount,
    required this.merchant,
    required this.category,
    required this.confidenceScore,
    required this.isHighConfidence,
    required this.isAmountClean,
    required this.isMerchantMatched,
    required this.isCategoryInferred,
    required this.rawText,
  });

  @override
  String toString() =>
      'VoiceParseResult(amount: $amount, merchant: $merchant, category: $category, score: $confidenceScore, highConfidence: $isHighConfidence)';
}

class LocalVoiceParser {
  static const double threshold = 2.0;

  /// Parses spoken/STT [rawText] against known templates in strict priority order:
  /// 1. "<amount> for <merchant>"
  /// 2. "<merchant> for <amount>"
  /// 3. "spent <amount> at <merchant>"
  /// 4. "<amount> at <merchant>"
  /// 5. "<merchant> <amount> rupees|rs|inr"
  ///
  /// Evaluates confidence scoring:
  /// - Amount extracted cleanly: +1.0
  /// - Merchant matched known DB merchant: +1.0
  /// - Merchant present as raw text but unmatched: +0.5
  /// - Category inferred from keywords: +0.5
  static VoiceParseResult parse(String rawText, List<String> knownMerchants,
      {bool isIncome = false}) {
    final cleanText = rawText.trim();
    if (cleanText.isEmpty) {
      return VoiceParseResult(
        amount: null,
        merchant: '',
        category: isIncome ? 'Other Income' : 'Other',
        confidenceScore: 0.0,
        isHighConfidence: false,
        isAmountClean: false,
        isMerchantMatched: false,
        isCategoryInferred: false,
        rawText: rawText,
      );
    }

    String? amountPart;
    String? merchantPart;

    // Template 1: "<amount> for <merchant>"
    // e.g. "150 for Starbucks", "two fifty for groceries"
    final t1 = RegExp(r'^(.+?)\s+for\s+(.+)$', caseSensitive: false)
        .firstMatch(cleanText);
    if (t1 != null) {
      final possibleAmount = NumberWordParser.parse(t1.group(1)!);
      if (possibleAmount != null) {
        amountPart = t1.group(1);
        merchantPart = t1.group(2);
      }
    }

    // Template 2: "<merchant> for <amount>"
    // e.g. "Starbucks for 150 rupees", "Uber for two hundred"
    if (amountPart == null) {
      final t2 = RegExp(r'^(.+?)\s+for\s+(.+)$', caseSensitive: false)
          .firstMatch(cleanText);
      if (t2 != null) {
        final possibleAmount = NumberWordParser.parse(t2.group(2)!);
        if (possibleAmount != null) {
          merchantPart = t2.group(1);
          amountPart = t2.group(2);
        }
      }
    }

    // Template 3: "spent <amount> at <merchant>"
    // e.g. "spent 450 at D-Mart"
    if (amountPart == null) {
      final t3 = RegExp(r'^(?:spent|paid)\s+(.+?)\s+(?:at|on|to)\s+(.+)$',
              caseSensitive: false)
          .firstMatch(cleanText);
      if (t3 != null) {
        final possibleAmount = NumberWordParser.parse(t3.group(1)!);
        if (possibleAmount != null) {
          amountPart = t3.group(1);
          merchantPart = t3.group(2);
        }
      }
    }

    // Template 4: "<amount> at <merchant>"
    // e.g. "500 at Shell petrol pump"
    if (amountPart == null) {
      final t4 = RegExp(r'^(.+?)\s+(?:at|on|to)\s+(.+)$', caseSensitive: false)
          .firstMatch(cleanText);
      if (t4 != null) {
        final possibleAmount = NumberWordParser.parse(t4.group(1)!);
        if (possibleAmount != null) {
          amountPart = t4.group(1);
          merchantPart = t4.group(2);
        }
      }
    }

    // Template 5: "<merchant> <amount> rupees|rs|inr"
    // e.g. "Uber 250 rupees", "Starbucks 150 rs"
    if (amountPart == null) {
      final t5 = RegExp(
              r'^(.+?)\s+([0-9.,]+|\w+(?:\s+\w+){0,3})\s*(?:rupees|rs|inr|₹|bucks)?$',
              caseSensitive: false)
          .firstMatch(cleanText);
      if (t5 != null && NumberWordParser.isPurelyNumberWords(t5.group(2)!)) {
        final possibleAmount = NumberWordParser.parse(t5.group(2)!);
        if (possibleAmount != null) {
          merchantPart = t5.group(1);
          amountPart = t5.group(2);
        }
      }
    }

    // Fallback: if none of the 5 templates matched cleanly, try finding any amount in the string
    if (amountPart == null) {
      final possibleAmount = NumberWordParser.parse(cleanText);
      if (possibleAmount != null) {
        amountPart = possibleAmount.toString();
        merchantPart = NumberWordParser.removeNumberWords(cleanText);
      } else {
        merchantPart = cleanText;
      }
    }

    // Clean up currency suffix words from merchantPart if present
    if (merchantPart != null) {
      merchantPart = merchantPart
          .replaceAll(
              RegExp(r'\b(?:rupees|rs|inr|₹)\b', caseSensitive: false), '')
          .trim();
    }

    final double? amount =
        amountPart != null ? NumberWordParser.parse(amountPart) : null;
    final bool isAmountClean = amount != null && amount > 0;

    // Fuzzy match merchant
    final merchantMatch =
        MerchantMatcher.match(merchantPart ?? '', knownMerchants);
    final String finalMerchant =
        merchantMatch.merchant.isNotEmpty ? merchantMatch.merchant : 'Unknown';
    final bool isMerchantMatched = merchantMatch.isMatched;

    // Infer category
    final String inferredCategory = CategoryKeywords.categorize(
      '$finalMerchant $cleanText',
      isIncome: isIncome,
    );
    final bool isCategoryInferred = isIncome
        ? inferredCategory != 'Other Income'
        : inferredCategory != 'Other';

    // Calculate confidence score
    double score = 0.0;
    if (isAmountClean) {
      score += 1.0;
    }
    if (isMerchantMatched) {
      score += 1.0;
    } else if (finalMerchant.isNotEmpty && finalMerchant != 'Unknown') {
      score += 0.5;
    }
    if (isCategoryInferred) {
      score += 0.5;
    }

    return VoiceParseResult(
      amount: amount,
      merchant: finalMerchant,
      category: inferredCategory,
      confidenceScore: score,
      isHighConfidence: score >= threshold,
      isAmountClean: isAmountClean,
      isMerchantMatched: isMerchantMatched,
      isCategoryInferred: isCategoryInferred,
      rawText: rawText,
    );
  }
}
