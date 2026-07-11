import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:drift/web.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    try {
      final result = await WasmDatabase.open(
        databaseName: 'expense_tracker_db',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      if (result.missingFeatures.isNotEmpty) {
        // If critical WASM features are missing, fallback to standard WebDatabase
        return WebDatabase('expense_tracker_db');
      }
      return result.resolvedExecutor;
    } catch (_) {
      // Fallback to IndexedDB/sql.js WebDatabase if WASM setup encounters any environment restriction
      return WebDatabase('expense_tracker_db');
    }
  });
}
