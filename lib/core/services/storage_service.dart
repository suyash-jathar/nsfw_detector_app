import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';

/// Handles all local persistence — scan history and user preferences.
class StorageService {
  static const String _resultsBoxName = 'scan_results';
  static const String _keyOnboardingDone = 'onboarding_done';
  static const String _keyAutoSave = 'auto_save';
  static const String _keyTotalScanned = 'total_scanned';

  late Box<String> _resultsBox;
  late SharedPreferences _prefs;
  bool _initialized = false;

  bool get initialized => _initialized;

  Future<void> init() async {
    await Hive.initFlutter();
    _resultsBox = await Hive.openBox<String>(_resultsBoxName);
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ── Onboarding ─────────────────────────────────────────────────────────
  bool get isOnboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;
  Future<void> markOnboardingDone() =>
      _prefs.setBool(_keyOnboardingDone, true);

  // ── Settings ───────────────────────────────────────────────────────────
  bool get autoSave => _prefs.getBool(_keyAutoSave) ?? true;
  Future<void> setAutoSave(bool value) => _prefs.setBool(_keyAutoSave, value);

  // ── Scan Counter ───────────────────────────────────────────────────────
  int get totalScanned => _prefs.getInt(_keyTotalScanned) ?? 0;
  Future<void> incrementTotalScanned() =>
      _prefs.setInt(_keyTotalScanned, totalScanned + 1);

  // ── Scan History ───────────────────────────────────────────────────────
  Future<void> saveScanResult(ScanResult result) async {
    await _resultsBox.put(result.id, result.toJsonString());
  }

  List<ScanResult> getAllResults() {
    return _resultsBox.values
        .map((s) {
          try {
            return ScanResult.fromJsonString(s);
          } catch (_) {
            return null;
          }
        })
        .whereType<ScanResult>()
        .toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
  }

  /// Returns results scanned today.
  List<ScanResult> getTodayResults() {
    final today = DateTime.now();
    return getAllResults().where((r) {
      return r.scannedAt.year == today.year &&
          r.scannedAt.month == today.month &&
          r.scannedAt.day == today.day;
    }).toList();
  }

  /// Safe rate this week (0.0 – 1.0).
  double getSafeRateThisWeek() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recent =
        getAllResults().where((r) => r.scannedAt.isAfter(weekAgo)).toList();
    if (recent.isEmpty) return 1.0;
    final safeCount = recent.where((r) => r.safetyLevel == SafetyLevel.safe).length;
    return safeCount / recent.length;
  }

  Future<void> deleteResult(String id) async {
    await _resultsBox.delete(id);
  }

  Future<void> clearAllResults() async {
    await _resultsBox.clear();
    await _prefs.setInt(_keyTotalScanned, 0);
  }

  Future<void> close() async {
    await _resultsBox.close();
  }
}
