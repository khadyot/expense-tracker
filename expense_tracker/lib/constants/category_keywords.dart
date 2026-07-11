class CategoryKeywords {
  static const Map<String, List<String>> expenseKeywords = {
    'Groceries': [
      'swiggy',
      'zomato',
      'grocery',
      'groceries',
      'bigbasket',
      'zepto',
      'blinkit',
      'instamart',
      'd-mart',
      'dmart',
      'reliance fresh',
      'supermarket',
      'vegetables',
      'milk',
      'bread',
      'coffee',
      'tea',
      'starbucks',
      'cafe',
      'restaurant',
      'food',
    ],
    'Travel': [
      'uber',
      'ola',
      'rapido',
      'metro',
      'irctc',
      'train',
      'flight',
      'bus',
      'auto',
      'taxi',
      'cab',
      'redbus',
      'makemytrip',
    ],
    'Car': [
      'fuel',
      'petrol',
      'diesel',
      'shell',
      'hpcl',
      'bpcl',
      'indian oil',
      'service',
      'repair',
      'toll',
      'fastag',
      'parking',
    ],
    'Home': [
      'electricity',
      'water',
      'rent',
      'broadband',
      'wifi',
      'airtel',
      'jio',
      'gas',
      'maintenance',
      'maid',
      'cook',
      'utility',
      'bill',
    ],
  };

  static const Map<String, List<String>> incomeKeywords = {
    'Salary': [
      'salary',
      'payroll',
      'stipend',
      'wages',
      'bonus',
    ],
    'Investment Returns': [
      'dividend',
      'interest',
      'zerodha',
      'groww',
      'mutual fund',
      'stocks',
      'returns',
      'profit',
    ],
    'Rent': [
      'rent received',
      'tenant',
      'lease',
    ],
    'Other Income': [
      'freelance',
      'consulting',
      'gift',
      'refund',
      'cashback',
    ],
  };

  /// Categorizes a transaction based on merchant name or raw input text.
  /// Returns the matching category string (`Groceries`, `Travel`, `Car`, `Home`, etc.)
  /// or `Other` / `Other Income` if no match is found.
  static String categorize(String input, {bool isIncome = false}) {
    final lower = input.toLowerCase();
    final mapping = isIncome ? incomeKeywords : expenseKeywords;

    for (final entry in mapping.entries) {
      for (final keyword in entry.value) {
        // Check exact or word boundary / substring matches
        if (lower.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }

    return isIncome ? 'Other Income' : 'Other';
  }
}
