import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// The five output classes from the GantMan NSFW MobileNetV2 model.
/// Sorted alphabetically — drawings, hentai, neutral, porn, sexy.
enum NsfwClass { drawings, hentai, neutral, porn, sexy }

/// Overall safety verdict based on the model scores.
enum SafetyLevel { safe, risky, unsafe }

extension SafetyLevelX on SafetyLevel {
  String get label {
    return switch (this) {
      SafetyLevel.safe => 'Safe',
      SafetyLevel.risky => 'Risky',
      SafetyLevel.unsafe => 'Unsafe',
    };
  }

  String get description {
    return switch (this) {
      SafetyLevel.safe =>
        'This image looks fine. Safe to post on most platforms.',
      SafetyLevel.risky =>
        'This image may trigger content filters on some platforms.',
      SafetyLevel.unsafe =>
        'This image will likely be removed or result in account action.',
    };
  }

  String get platformWarning {
    return switch (this) {
      SafetyLevel.safe => 'No issues detected. Good to go!',
      SafetyLevel.risky =>
        'May receive limited reach on Instagram, TikTok, LinkedIn & YouTube.',
      SafetyLevel.unsafe =>
        'High risk of removal, shadowban or account suspension on all major platforms.',
    };
  }

  Color get color {
    return switch (this) {
      SafetyLevel.safe => AppColors.safe,
      SafetyLevel.risky => AppColors.risky,
      SafetyLevel.unsafe => AppColors.unsafe,
    };
  }

  Gradient get gradient {
    return switch (this) {
      SafetyLevel.safe => AppColors.safeGradient,
      SafetyLevel.risky => AppColors.riskyGradient,
      SafetyLevel.unsafe => AppColors.unsafeGradient,
    };
  }

  IconData get icon {
    return switch (this) {
      SafetyLevel.safe => Icons.check_circle_rounded,
      SafetyLevel.risky => Icons.warning_amber_rounded,
      SafetyLevel.unsafe => Icons.block_rounded,
    };
  }
}

class ScanResult {
  final String id;
  final String imagePath;
  final double drawings;
  final double hentai;
  final double neutral;
  final double porn;
  final double sexy;
  final DateTime scannedAt;

  const ScanResult({
    required this.id,
    required this.imagePath,
    required this.drawings,
    required this.hentai,
    required this.neutral,
    required this.porn,
    required this.sexy,
    required this.scannedAt,
  });

  SafetyLevel get safetyLevel {
    final unsafeScore = porn + hentai;
    if (unsafeScore >= 0.40) return SafetyLevel.unsafe;
    if (unsafeScore >= 0.20 || sexy >= 0.30) return SafetyLevel.risky;
    return SafetyLevel.safe;
  }

  /// Returns the dominant category label.
  String get dominantCategory {
    final scores = {
      'Drawings': drawings,
      'Hentai': hentai,
      'Neutral': neutral,
      'Porn': porn,
      'Sexy': sexy,
    };
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Returns scores as an ordered list of [label, percent] pairs.
  List<(String, double)> get orderedScores => [
    ('Neutral', neutral),
    ('Drawings', drawings),
    ('Sexy', sexy),
    ('Hentai', hentai),
    ('Porn', porn),
  ]..sort((a, b) => b.$2.compareTo(a.$2));

  Color categoryColor(String label) {
    return switch (label.toLowerCase()) {
      'drawings' => AppColors.chipDrawings,
      'hentai' => AppColors.chipHentai,
      'neutral' => AppColors.chipNeutral,
      'porn' => AppColors.chipPorn,
      'sexy' => AppColors.chipSexy,
      _ => AppColors.textSecondary,
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'drawings': drawings,
    'hentai': hentai,
    'neutral': neutral,
    'porn': porn,
    'sexy': sexy,
    'scannedAt': scannedAt.toIso8601String(),
  };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
    id: json['id'] as String,
    imagePath: json['imagePath'] as String,
    drawings: (json['drawings'] as num).toDouble(),
    hentai: (json['hentai'] as num).toDouble(),
    neutral: (json['neutral'] as num).toDouble(),
    porn: (json['porn'] as num).toDouble(),
    sexy: (json['sexy'] as num).toDouble(),
    scannedAt: DateTime.parse(json['scannedAt'] as String),
  );

  String toJsonString() => jsonEncode(toJson());
  factory ScanResult.fromJsonString(String s) =>
      ScanResult.fromJson(jsonDecode(s) as Map<String, dynamic>);

  ScanResult copyWith({
    String? id, String? imagePath, double? drawings, double? hentai,
    double? neutral, double? porn, double? sexy, DateTime? scannedAt,
  }) => ScanResult(
    id: id ?? this.id,
    imagePath: imagePath ?? this.imagePath,
    drawings: drawings ?? this.drawings,
    hentai: hentai ?? this.hentai,
    neutral: neutral ?? this.neutral,
    porn: porn ?? this.porn,
    sexy: sexy ?? this.sexy,
    scannedAt: scannedAt ?? this.scannedAt,
  );
}
