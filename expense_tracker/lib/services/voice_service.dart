import 'package:speech_to_text/speech_to_text.dart';
import '../database/database.dart';
import 'package:drift/drift.dart' as drift;
import 'local_voice_parser.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final AppDatabase database;

  bool _isListening = false;
  String _lastWords = '';

  VoiceService(this.database);

  Future<bool> initialize() async {
    return await _speechToText.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
  }

  Future<void> startListening({
    required Function(String) onTextChange,
    required Function(String) onError,
    required Function(VoiceParseResult) onResultParsed,
    bool isIncome = false,
  }) async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        _isListening = true;
        _speechToText.listen(
          onResult: (result) {
            _lastWords = result.recognizedWords;
            onTextChange(_lastWords);

            if (result.finalResult) {
              _processVoiceInput(_lastWords, onError, onResultParsed, isIncome);
            }
          },
        );
      } else {
        onError("Speech recognition not available");
      }
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  Future<void> _processVoiceInput(
    String text,
    Function(String) onError,
    Function(VoiceParseResult) onResultParsed,
    bool isIncome,
  ) async {
    try {
      final existingMerchants = await database.getDistinctMerchants();
      final result =
          LocalVoiceParser.parse(text, existingMerchants, isIncome: isIncome);
      onResultParsed(result);
    } catch (e) {
      print('Error processing voice input: $e');
      onError(e.toString());
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

  Future<void> saveVoiceTransaction(
      VoiceParseResult result, DateTime date) async {
    final amount = result.amount ?? 0.0;
    String merchant = result.merchant;

    merchant = _capitalize(merchant.trim());
    final category = result.category;

    // Check for duplicates
    final duplicate = await database.findDuplicate(amount, date, 'voice');

    if (duplicate != null) {
      throw Exception(
          'Duplicate transaction: ₹$amount for $merchant already exists today.');
    }

    await database.insertTransaction(
      TransactionsCompanion(
        amount: drift.Value(amount),
        merchant: drift.Value(merchant),
        date: drift.Value(date),
        category: drift.Value(category),
        source: const drift.Value('voice'),
        rawData: drift.Value(result.rawText),
      ),
    );

    print('Voice transaction saved: ₹$amount for $merchant');
  }

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
}
