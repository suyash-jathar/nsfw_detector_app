import 'package:get/get.dart';
import '../../core/models/scan_result.dart';
import '../../core/services/storage_service.dart';

class HomeController extends GetxController {
  final _storage = Get.find<StorageService>();

  final RxList<ScanResult> recentScans = <ScanResult>[].obs;
  final RxInt todayCount = 0.obs;
  final RxDouble safeRateWeek = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  void loadStats() {
    final all = _storage.getAllResults();
    recentScans.assignAll(all.take(20).toList());
    todayCount.value = _storage.getTodayResults().length;
    safeRateWeek.value = _storage.getSafeRateThisWeek();
  }

  /// Total images ever scanned.
  int get totalEver => _storage.totalScanned;

  /// Protected reach estimate (fun stat).
  String get reachProtected {
    final t = totalEver;
    if (t < 10) return '—';
    final reach = t * 1200;
    if (reach >= 1000000) return '${(reach / 1000000).toStringAsFixed(1)}M';
    if (reach >= 1000) return '${(reach / 1000).toStringAsFixed(0)}K';
    return '$reach';
  }
}
