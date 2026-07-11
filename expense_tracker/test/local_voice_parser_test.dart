import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/local_voice_parser.dart';

void main() {
  group('LocalVoiceParser Tests', () {
    final knownMerchants = [
      'Starbucks',
      'Swiggy',
      'Zomato',
      'Uber',
      'Ola',
      'D-Mart',
      'BigBasket',
      'Shell Petrol Pump',
      'MakeMyTrip',
    ];

    // --- HIGH CONFIDENCE (>= 2.0) CASES ---

    test(
        'Case 1: Template 1 (<amount> for <merchant>) - clean digits and known merchant',
        () {
      final res = LocalVoiceParser.parse('150 for Starbucks', knownMerchants);
      expect(res.amount, equals(150.0));
      expect(res.merchant, equals('Starbucks'));
      expect(res.category, equals('Groceries'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test(
        'Case 2: Template 1 - Indian English compound numbers ("two fifty for Swiggy")',
        () {
      final res =
          LocalVoiceParser.parse('two fifty for Swiggy', knownMerchants);
      expect(res.amount, equals(250.0));
      expect(res.merchant, equals('Swiggy'));
      expect(res.category, equals('Groceries'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test(
        'Case 3: Template 1 - Spoken thousands with unmatched merchant ("four thousand for rent")',
        () {
      final res =
          LocalVoiceParser.parse('four thousand for rent', knownMerchants);
      expect(res.amount, equals(4000.0));
      expect(res.merchant, equals('Rent'));
      expect(res.category, equals('Home'));
      // +1 amount, +0.5 unmatched merchant, +0.5 inferred category -> 2.0
      expect(res.confidenceScore, equals(2.0));
      expect(res.isHighConfidence, isTrue);
    });

    test(
        'Case 4: Template 2 (<merchant> for <amount>) - digits with currency suffix',
        () {
      final res =
          LocalVoiceParser.parse('Starbucks for 150 rupees', knownMerchants);
      expect(res.amount, equals(150.0));
      expect(res.merchant, equals('Starbucks'));
      expect(res.category, equals('Groceries'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test(
        'Case 5: Template 2 - Spoken compound hundreds ("Uber for two hundred")',
        () {
      final res =
          LocalVoiceParser.parse('Uber for two hundred', knownMerchants);
      expect(res.amount, equals(200.0));
      expect(res.merchant, equals('Uber'));
      expect(res.category, equals('Travel'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test(
        'Case 6: Template 2 - Spoken Indian compound ("Zomato for twelve fifty")',
        () {
      final res =
          LocalVoiceParser.parse('Zomato for twelve fifty', knownMerchants);
      expect(res.amount, equals(1250.0));
      expect(res.merchant, equals('Zomato'));
      expect(res.category, equals('Groceries'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test('Case 7: Template 3 (spent <amount> at <merchant>) - exact match', () {
      final res = LocalVoiceParser.parse('spent 450 at D-Mart', knownMerchants);
      expect(res.amount, equals(450.0));
      expect(res.merchant, equals('D-Mart'));
      expect(res.category, equals('Groceries'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test(
        'Case 8: Template 3 - three token Indian compound ("spent three twenty five at Uber")',
        () {
      final res = LocalVoiceParser.parse(
          'spent three twenty five at Uber', knownMerchants);
      expect(res.amount, equals(325.0));
      expect(res.merchant, equals('Uber'));
      expect(res.category, equals('Travel'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test('Case 9: Template 3 - variation ("paid 1500 to Shell petrol pump")',
        () {
      final res = LocalVoiceParser.parse(
          'paid 1500 to Shell petrol pump', knownMerchants);
      expect(res.amount, equals(1500.0));
      expect(res.merchant, equals('Shell Petrol Pump'));
      expect(res.category, equals('Car'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test('Case 10: Template 4 (<amount> at <merchant>) - clean match', () {
      final res =
          LocalVoiceParser.parse('500 at Shell petrol pump', knownMerchants);
      expect(res.amount, equals(500.0));
      expect(res.merchant, equals('Shell Petrol Pump'));
      expect(res.category, equals('Car'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test('Case 11: Template 4 - STT typo fuzzy matching ("eighty at Starbuck")',
        () {
      final res = LocalVoiceParser.parse('eighty at Starbuck', knownMerchants);
      expect(res.amount, equals(80.0));
      // Snaps to Starbucks via string_similarity rating >= 0.7
      expect(res.merchant, equals('Starbucks'));
      expect(res.isMerchantMatched, isTrue);
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test(
        'Case 12: Template 5 (<merchant> <amount> rupees) - trailing currency word',
        () {
      final res = LocalVoiceParser.parse('Uber 250 rupees', knownMerchants);
      expect(res.amount, equals(250.0));
      expect(res.merchant, equals('Uber'));
      expect(res.category, equals('Travel'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test('Case 13: Template 5 - abbreviation ("Starbucks 150 rs")', () {
      final res = LocalVoiceParser.parse('Starbucks 150 rs', knownMerchants);
      expect(res.amount, equals(150.0));
      expect(res.merchant, equals('Starbucks'));
      expect(res.category, equals('Groceries'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    test(
        'Case 14: Fallback - direct numeric and known merchant ("BigBasket 1200")',
        () {
      final res = LocalVoiceParser.parse('BigBasket 1200', knownMerchants);
      expect(res.amount, equals(1200.0));
      expect(res.merchant, equals('BigBasket'));
      expect(res.category, equals('Groceries'));
      expect(res.confidenceScore, equals(2.5));
      expect(res.isHighConfidence, isTrue);
    });

    // --- LOW CONFIDENCE (< 2.0) / UNCERTAIN CASES ---

    test(
        'Case 15: Low confidence - amount missing ("spent money at some random store")',
        () {
      final res = LocalVoiceParser.parse(
          'spent money at some random store', knownMerchants);
      expect(res.amount, isNull);
      expect(res.isAmountClean, isFalse);
      expect(res.isMerchantMatched, isFalse);
      // +0 amount, +0.5 unmatched merchant, +0 category -> 0.5
      expect(res.confidenceScore, lessThan(LocalVoiceParser.threshold));
      expect(res.isHighConfidence, isFalse);
    });

    test(
        'Case 16: Low confidence - unknown merchant & unknown category ("some stuff for five hundred")',
        () {
      final res =
          LocalVoiceParser.parse('some stuff for five hundred', knownMerchants);
      expect(res.amount, equals(500.0));
      expect(res.isAmountClean, isTrue);
      expect(res.isMerchantMatched, isFalse);
      expect(res.category, equals('Other'));
      // +1 amount, +0.5 unmatched merchant, +0 category -> 1.5
      expect(res.confidenceScore, equals(1.5));
      expect(res.isHighConfidence, isFalse);
    });

    test(
        'Case 17: Low confidence - awkward STT phrasing without category ("unknown item two fifty rupees")',
        () {
      final res = LocalVoiceParser.parse(
          'unknown item two fifty rupees', knownMerchants);
      expect(res.amount, equals(250.0));
      expect(res.merchant, equals('Unknown Item'));
      expect(res.isMerchantMatched, isFalse);
      expect(res.category, equals('Other'));
      // +1 amount, +0.5 unmatched merchant, +0 category -> 1.5
      expect(res.confidenceScore, equals(1.5));
      expect(res.isHighConfidence, isFalse);
    });

    test(
        'Case 18: Low confidence - only merchant/category, no amount ("just groceries")',
        () {
      final res = LocalVoiceParser.parse('just groceries', knownMerchants);
      expect(res.amount, isNull);
      expect(res.isAmountClean, isFalse);
      expect(res.category, equals('Groceries'));
      // +0 amount, +0.5 unmatched merchant ('just groceries'), +0.5 inferred category -> 1.0
      expect(res.confidenceScore, equals(1.0));
      expect(res.isHighConfidence, isFalse);
    });
  });
}
