import 'package:string_similarity/string_similarity.dart';

class MerchantMatchResult {
  final String merchant;
  final bool isMatched;
  final double similarity;

  const MerchantMatchResult({
    required this.merchant,
    required this.isMatched,
    required this.similarity,
  });
}

class MerchantMatcher {
  /// Compares [rawMerchant] against a list of [knownMerchants] using Dice's coefficient
  /// (`string_similarity`). If similarity >= [threshold] (default 0.7), snaps to the known
  /// merchant spelling and marks [isMatched] = true.
  static MerchantMatchResult match(
      String rawMerchant, List<String> knownMerchants,
      {double threshold = 0.7}) {
    final cleanRaw = _capitalize(rawMerchant.trim());
    if (cleanRaw.isEmpty) {
      return const MerchantMatchResult(
          merchant: 'Unknown', isMatched: false, similarity: 0.0);
    }

    if (knownMerchants.isEmpty) {
      return MerchantMatchResult(
          merchant: cleanRaw, isMatched: false, similarity: 0.0);
    }

    // Perform best match on case-insensitive basis while preserving target casing
    String bestTarget = cleanRaw;
    double highestRating = 0.0;

    for (final known in knownMerchants) {
      if (known.trim().isEmpty) continue;
      // Exact match check
      if (known.toLowerCase() == cleanRaw.toLowerCase()) {
        return MerchantMatchResult(
            merchant: known, isMatched: true, similarity: 1.0);
      }
      final rating = cleanRaw.toLowerCase().similarityTo(known.toLowerCase());
      if (rating > highestRating) {
        highestRating = rating;
        bestTarget = known;
      }
    }

    if (highestRating >= threshold) {
      return MerchantMatchResult(
        merchant: bestTarget,
        isMatched: true,
        similarity: highestRating,
      );
    }

    return MerchantMatchResult(
      merchant: cleanRaw,
      isMatched: false,
      similarity: highestRating,
    );
  }

  static String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      }
      return word;
    }).join(' ');
  }
}
