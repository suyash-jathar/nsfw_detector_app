import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/tflite_service.dart';

class SettingsController extends GetxController {
  final _storage = Get.find<StorageService>();
  final _tflite = Get.find<TFLiteService>();

  final RxBool autoSave = true.obs;

  @override
  void onInit() {
    super.onInit();
    autoSave.value = _storage.autoSave;
  }

  Future<void> setAutoSave(bool value) async {
    autoSave.value = value;
    await _storage.setAutoSave(value);
  }

  Future<void> clearHistory() async {
    await _storage.clearAllResults();
  }

  int get totalScanned => _storage.totalScanned;
  bool get modelLoaded => _tflite.isLoaded;
  String get modelVersion => 'MobileNetV2 • 224×224';
  List<String> get classLabels => _tflite.labels;
}
