import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Handles all TFLite model loading, preprocessing, and inference.
class TFLiteService {
  static const String _modelAsset = 'assets/model/nsfw_detector_model.tflite';
  static const String _labelsAsset = 'assets/model/class_labels.txt';

  // Model input dimensions
  static const int _inputSize = 224;
  static const int _numChannels = 3;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<String> get labels => List.unmodifiable(_labels);

  /// Load the TFLite model and class labels from assets.
  Future<void> loadModel() async {
    try {
      // Load labels
      final labelsData = await rootBundle.loadString(_labelsAsset);
      _labels = labelsData
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      // Fallback labels (alphabetical order from GantMan model)
      if (_labels.isEmpty) {
        _labels = ['drawings', 'hentai', 'neutral', 'porn', 'sexy'];
      }

      // Load interpreter
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      _isLoaded = true;
    } catch (e) {
      _isLoaded = false;
      rethrow;
    }
  }

  /// Run inference on an image file path. Returns a map of label → probability.
  Future<Map<String, double>> runInferenceOnPath(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Could not decode image at $imagePath');
    return _runInference(image);
  }

  /// Run inference on raw bytes (e.g., from image picker).
  Future<Map<String, double>> runInferenceOnBytes(Uint8List bytes) async {
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Could not decode image from bytes');
    return _runInference(image);
  }

  Future<Map<String, double>> _runInference(img.Image image) async {
    if (_interpreter == null) {
      throw StateError('TFLite model is not loaded. Call loadModel() first.');
    }

    // ── 1. Resize to 224×224 ──────────────────────────────────────────────
    final resized = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    // ── 2. Build Float32 input tensor [1, 224, 224, 3], normalized 0–1 ───
    final inputBuffer = Float32List(_inputSize * _inputSize * _numChannels);
    int idx = 0;
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        inputBuffer[idx++] = pixel.r.toDouble() / 255.0;
        inputBuffer[idx++] = pixel.g.toDouble() / 255.0;
        inputBuffer[idx++] = pixel.b.toDouble() / 255.0;
      }
    }

    // ── 3. Reshape to [1, 224, 224, 3] ───────────────────────────────────
    final input = inputBuffer.reshape([1, _inputSize, _inputSize, _numChannels]);

    // ── 4. Prepare output buffer [1, 5] ──────────────────────────────────
    final numClasses = _labels.isNotEmpty ? _labels.length : 5;
    final outputBuffer = Float32List(numClasses);
    final output = outputBuffer.reshape([1, numClasses]);

    // ── 5. Run inference ─────────────────────────────────────────────────
    _interpreter!.run(input, output);

    // ── 6. Map results ───────────────────────────────────────────────────
    final results = <String, double>{};
    for (int i = 0; i < _labels.length; i++) {
      results[_labels[i]] = (output[0] as List)[i].toDouble();
    }
    return results;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
