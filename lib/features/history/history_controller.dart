import 'package:get/get.dart';
import '../../core/models/scan_result.dart';
import '../../core/services/storage_service.dart';

class HistoryController extends GetxController {
  final _storage = Get.find<StorageService>();

  final RxList<ScanResult> results = <ScanResult>[].obs;
  final RxString filter = 'All'.obs;

  final filters = ['All', 'Safe', 'Risky', 'Unsafe'];

  @override
  void onInit() {
    super.onInit();
    loadResults();
  }

  void loadResults() {
    results.assignAll(_storage.getAllResults());
  }

  List<ScanResult> get filteredResults {
    if (filter.value == 'All') return results;
    return results.where((r) {
      return r.safetyLevel.label == filter.value;
    }).toList();
  }

  Future<void> deleteResult(String id) async {
    await _storage.deleteResult(id);
    loadResults();
  }

  Future<void> clearAll() async {
    await _storage.clearAllResults();
    loadResults();
  }
}
