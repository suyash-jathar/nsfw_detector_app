import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsfw_detector_app/presentation/routes/app_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/models/scan_result.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/tflite_service.dart';
import '../../core/utils/haptics.dart';

enum ScanState { idle, picking, processing, done, error }

class ScanController extends GetxController {
  final _tflite = Get.find<TFLiteService>();
  final _storage = Get.find<StorageService>();
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  final Rx<ScanState> state = ScanState.idle.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ScanResult?> lastResult = Rx<ScanResult?>(null);

  bool get isProcessing => state.value == ScanState.processing;

  /// Called when the Scan screen opens to warn proactively about denied permissions.
  Future<void> proactivePermissionCheck(BuildContext context) async {
    // Camera is always needed; check if it's permanently denied upfront.
    final cameraStatus = await Permission.camera.status;

    if (!context.mounted) return;
    if (cameraStatus.isPermanentlyDenied) {
      // ignore: use_build_context_synchronously
      await _showOpenSettingsDialog(true, context);
      return;
    }

    // For gallery: Android 13+ uses system photo picker (no permission needed).
    // For older Android / iOS, check photo library.
    if (Platform.isAndroid) {
      final osVersion = await _getAndroidOsVersion();
      if (osVersion >= 13) return; // system picker handles it
    }
    final photoPermission = _resolvePermission(ImageSource.gallery);
    final photoStatus = await photoPermission.status;
    if (photoStatus.isPermanentlyDenied && context.mounted) {
      // ignore: use_build_context_synchronously
      await _showOpenSettingsDialog(false, context);
    }
  }


  Future<void> pickAndScan(BuildContext context, ImageSource source) async {
    if (isProcessing) return;

    // Check model loaded
    if (!_tflite.isLoaded) {
      _setError('AI model is not loaded. Please restart the app.');
      return;
    }

    // Handle permission gracefully with friendly UI
    final canProceed = await _requestPermissionGracefully(source, context);
    if (!canProceed) return;

    state.value = ScanState.picking;

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (picked == null) {
        state.value = ScanState.idle;
        return;
      }

      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      await _processImage(picked, context);
    } catch (e) {
      _setError('Failed to pick image: $e');
    }
  }

  Future<void> _processImage(XFile picked, BuildContext context) async {
    state.value = ScanState.processing;
    await Haptics.light();

    try {
      final bytes = await picked.readAsBytes();
      final scores = await _tflite.runInferenceOnBytes(bytes);

      // Save image to app documents dir
      final savedPath = await _saveImage(bytes, picked.name);

      final result = ScanResult(
        id: _uuid.v4(),
        imagePath: savedPath,
        drawings: scores['drawings'] ?? 0.0,
        hentai: scores['hentai'] ?? 0.0,
        neutral: scores['neutral'] ?? 0.0,
        porn: scores['porn'] ?? 0.0,
        sexy: scores['sexy'] ?? 0.0,
        scannedAt: DateTime.now(),
      );

      // Auto-save if enabled
      if (_storage.autoSave) {
        await _storage.saveScanResult(result);
        await _storage.incrementTotalScanned();
      }

      lastResult.value = result;
      state.value = ScanState.done;

      await Haptics.success();

      // ignore: use_build_context_synchronously
      if (context.mounted) {
        context.push(AppRouter.result, extra: result);
        state.value = ScanState.idle;
      }
    } catch (e) {
      _setError('Analysis failed: ${e.toString()}');
      await Haptics.error();
    }
  }

  Future<String> _saveImage(Uint8List bytes, String originalName) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final scansDir = Directory('${docsDir.path}/scans');
    if (!await scansDir.exists()) await scansDir.create(recursive: true);

    final ext = originalName.contains('.')
        ? originalName.split('.').last
        : 'jpg';
    final fileName =
        'scan_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final file = File('${scansDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<bool> _requestPermissionGracefully(
      ImageSource source, BuildContext context) async {
    final isCamera = source == ImageSource.camera;

    // Android 13+ (OS version >= 13 = API 33+): image_picker uses the system
    // photo picker which handles media access internally — no runtime permission
    // needed for gallery. Camera still requires explicit permission on all versions.
    if (!isCamera && Platform.isAndroid) {
      final osVersion = await _getAndroidOsVersion();
      if (osVersion >= 13) return true;
    }

    final permission = _resolvePermission(source);
    var status = await permission.status;

    // Already granted / limited (partial photo access on Android 14+)
    if (status.isGranted || status.isLimited) return true;

    if (!context.mounted) return false;

    // Permanently denied — send user to Settings
    if (status.isPermanentlyDenied) {
      // ignore: use_build_context_synchronously
      await _showOpenSettingsDialog(isCamera, context);
      return false;
    }

    // First-time or soft-denied — show friendly rationale, then request
    // ignore: use_build_context_synchronously
    final shouldRequest = await _showPermissionRationaleDialog(isCamera, context);
    if (!shouldRequest) return false;

    status = await permission.request();
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied && context.mounted) {
      // ignore: use_build_context_synchronously
      await _showOpenSettingsDialog(isCamera, context);
    }
    return false;
  }

  /// Returns the Android OS version number (e.g. 13 for Android 13 / API 33).
  /// On non-Android platforms returns 0.
  Future<int> _getAndroidOsVersion() async {
    if (!Platform.isAndroid) return 0;
    try {
      // Platform.operatingSystemVersion returns the Android OS version string,
      // e.g. "13" for Android 13 (API 33). This is NOT the same as API level.
      return int.tryParse(
              Platform.operatingSystemVersion.split('.').first.trim()) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  /// Returns the correct runtime [Permission] for the given [source].
  /// Gallery on Android 12- needs READ_EXTERNAL_STORAGE; camera always needs CAMERA.
  Permission _resolvePermission(ImageSource source) {
    if (source == ImageSource.camera) return Permission.camera;
    // Android 12 and below — fall back to READ_EXTERNAL_STORAGE.
    // (Android 13+ gallery is handled before this is called.)
    if (Platform.isAndroid) return Permission.storage;
    return Permission.photos; // iOS
  }

  Future<bool> _showPermissionRationaleDialog(
      bool isCamera, BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isCamera
                  ? Icons.camera_alt_rounded
                  : Icons.photo_library_rounded,
              color: AppColors.brandStart,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${isCamera ? 'Camera' : 'Photo Library'} Access',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isCamera
              ? 'SafeGuard needs camera access to capture and analyze images. '
                  'Everything is processed 100% on-device — your photos never leave your phone.'
              : 'SafeGuard needs photo library access to analyze images. '
                  'Everything is processed 100% on-device — your photos never leave your phone.',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Not Now',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Allow Access',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showOpenSettingsDialog(bool isCamera, BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.risky,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Permission Required',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          isCamera
              ? 'Camera access has been denied. To scan images, please open Settings '
                  'and enable Camera access for SafeGuard.'
              : 'Photo library access has been denied. To scan images, please open '
                  'Settings and enable Photo Library access for SafeGuard.',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppSettings();
            },
            child: Text(
              'Open Settings',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _setError(String msg) {
    errorMessage.value = msg;
    state.value = ScanState.error;
  }

  void clearError() {
    errorMessage.value = '';
    state.value = ScanState.idle;
  }
}
