class NumberWordParser {
  static const Map<String, int> _wordToNumber = {
    'zero': 0,
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
    'eleven': 11,
    'twelve': 12,
    'thirteen': 13,
    'fourteen': 14,
    'fifteen': 15,
    'sixteen': 16,
    'seventeen': 17,
    'eighteen': 18,
    'nineteen': 19,
    'twenty': 20,
    'thirty': 30,
    'forty': 40,
    'fifty': 50,
    'sixty': 60,
    'seventy': 70,
    'eighty': 80,
    'ninety': 90,
  };

  static const Map<String, int> _multipliers = {
    'hundred': 100,
    'thousand': 1000,
    'lakh': 100000,
  };

  static String normalizeWords(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s.,]'), '')
        .replaceAll(' and ', ' ')
        .trim();
  }

  /// Parses an input string (containing digits or words like "two fifty", "150", "four thousand")
  /// and returns the extracted double value, or null if no valid number could be extracted.
  static double? parse(String input) {
    if (input.trim().isEmpty) return null;

    // Clean up input
    String clean = normalizeWords(input);

    // First check if input contains a direct digit string (e.g., "150", "1,200", "250.50")
    final digitMatch = RegExp(r'\b([0-9]+(?:[.,][0-9]+)?)\b').firstMatch(clean);
    if (digitMatch != null) {
      final numStr = digitMatch.group(1)!.replaceAll(',', '');
      final parsed = double.tryParse(numStr);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }

    // Tokenize words
    final words = clean.split(RegExp(r'\s+'));
    final List<int> numberTokens = [];
    final List<String> multiplierTokens = [];

    // Filter to only known number words
    for (final word in words) {
      if (_wordToNumber.containsKey(word)) {
        numberTokens.add(_wordToNumber[word]!);
        multiplierTokens.add('num');
      } else if (_multipliers.containsKey(word)) {
        numberTokens.add(_multipliers[word]!);
        multiplierTokens.add(word);
      } else if (int.tryParse(word) != null) {
        numberTokens.add(int.parse(word));
        multiplierTokens.add('num');
      }
    }

    if (numberTokens.isEmpty) return null;

    return _evaluateTokens(numberTokens, multiplierTokens).toDouble();
  }

  static int _evaluateTokens(List<int> values, List<String> types) {
    // Check for Indian English compound phrasing:
    // e.g., "two fifty" -> [2, 50], where first < 20 and second is tens (20..90) or (< 100)
    // or "twelve fifty" -> [12, 50]
    // or "three twenty five" -> [3, 20, 5] -> first is 3, rest sum to 25 -> 325
    if (types.every((t) => t == 'num')) {
      if (values.length == 2 &&
          values[0] >= 1 &&
          values[0] <= 19 &&
          values[1] >= 10 &&
          values[1] <= 99) {
        // e.g. "two fifty" (2, 50) -> 250; "four twenty" (4, 20) -> 420; "twelve fifty" (12, 50) -> 1250
        return values[0] * 100 + values[1];
      } else if (values.length == 3 &&
          values[0] >= 1 &&
          values[0] <= 9 &&
          values[1] >= 20 &&
          values[2] >= 1 &&
          values[2] <= 9) {
        // e.g. "three twenty five" (3, 20, 5) -> 325
        return values[0] * 100 + values[1] + values[2];
      }
    }

    int total = 0;
    int current = 0;

    for (int i = 0; i < values.length; i++) {
      final val = values[i];
      final type = types[i];

      if (type == 'hundred') {
        if (current == 0) current = 1;
        current *= 100;
      } else if (type == 'thousand' || type == 'lakh') {
        if (current == 0) current = 1;
        current *= val;
        total += current;
        current = 0;
      } else {
        // Normal number token
        // If current already has tens and we get ones (e.g. 20 + 5), add them
        if (current >= 20 && val < 10) {
          current += val;
        } else if (current > 0 && val >= 10 && types.every((t) => t == 'num')) {
          // Compound check inside longer sequence if any
          current = current * 100 + val;
        } else {
          current += val;
        }
      }
    }

    total += current;
    return total;
  }

  static bool isPurelyNumberWords(String input) {
    final clean = normalizeWords(input)
        .replaceAll(
            RegExp(r'\b(?:rupees|rs|inr|₹|bucks)\b', caseSensitive: false), '')
        .trim();
    if (clean.isEmpty) return false;
    final words = clean.split(RegExp(r'\s+'));
    for (final w in words) {
      if (w.isEmpty) continue;
      if (RegExp(r'^[0-9]+(?:[.,][0-9]+)?$').hasMatch(w)) continue;
      if (_wordToNumber.containsKey(w) || _multipliers.containsKey(w)) continue;
      if (w == 'and') continue;
      return false;
    }
    return true;
  }

  static String removeNumberWords(String input) {
    final clean = normalizeWords(input);
    final words = clean.split(RegExp(r'\s+'));
    final kept = <String>[];
    for (final w in words) {
      if (w.isEmpty) continue;
      if (RegExp(r'^[0-9]+(?:[.,][0-9]+)?$').hasMatch(w)) continue;
      if (_wordToNumber.containsKey(w) || _multipliers.containsKey(w)) continue;
      if (w == 'and') continue;
      if ([
        'rupees',
        'rs',
        'inr',
        '₹',
        'bucks',
        'spent',
        'paid',
        'for',
        'at',
        'on',
        'to'
      ].contains(w.toLowerCase())) continue;
      kept.add(w);
    }
    return kept.join(' ');
  }
}
