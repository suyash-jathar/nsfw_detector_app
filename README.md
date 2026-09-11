# SafeGuard — The Universal Image Guardian

A Flutter application that uses on-device AI to detect potentially explicit or NSFW content in images. Every scan runs entirely on your device — no internet connection, no cloud upload, no data collection.

---

## Table of Contents

- [What the App Does](#what-the-app-does)
- [How It Works](#how-it-works)
- [Features](#features)
- [Screens](#screens)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [AI Model](#ai-model)
- [Safety Classification](#safety-classification)
- [Permissions](#permissions)
- [Building & Running](#building--running)
- [Play Store Readiness](#play-store-readiness)
- [Known Limitations](#known-limitations)

---

## What the App Does

SafeGuard lets you scan any image (from your camera or photo library) and instantly receive an AI-powered verdict on whether the image is safe to post on social media platforms. It categorises images into five content classes and maps them to three safety levels, giving you actionable guidance about where the image can and can't be shared.

**Primary use case:** Content creators, social media managers, and parents who want to pre-screen images before posting to platforms like Instagram, TikTok, YouTube, LinkedIn or Twitter/X without having to upload anything to a third-party service.

---

## How It Works

1. User selects an image from the camera or gallery.
2. The image is resized to 224×224 pixels and normalised to [0, 1] float32.
3. The TFLite model runs inference locally and returns five probability scores.
4. Scores are mapped to one of three safety verdicts (Safe / Risky / Unsafe).
5. Results are displayed with a breakdown bar chart, verdict card, and platform compatibility grid.
6. If auto-save is enabled, the result is persisted locally to Hive.

---

## Features

### Core
- **100% on-device inference** — TFLite MobileNetV2 model, no internet required
- **Camera & gallery scanning** — pick a new photo or choose from your library
- **Five-class content analysis** — Neutral, Drawings, Sexy, Hentai, Porn with individual percentage bars
- **Three-tier safety verdict** — Safe / Risky / Unsafe with color-coded UI
- **Platform compatibility guide** — per-verdict guidance for Instagram, TikTok, YouTube, LinkedIn, Twitter/X
- **Scan history** — filterable list of all past scans with thumbnail, verdict, and swipe-to-delete
- **Share results** — share the image + full analysis breakdown via any installed share target
- **Auto-save toggle** — opt in/out of saving scan results locally
- **Clear history** — delete individual scans (swipe) or all at once

### UX & Design
- **Dark theme** throughout with glassmorphism cards and radial glow accents
- **Brand gradient** (purple → blue) used consistently for CTAs, FAB, and active states
- **Confetti animation** on Safe verdict
- **Haptic feedback** on all interactions (light / medium / success / error)
- **Animated progress bars** for per-class score breakdown
- **Smooth page transitions** with flutter_animate (fade + slide)
- **Elastic-out scale animations** on key entry points
- **4-page onboarding** with smooth page indicator, shown only once
- **Custom splash screen** that initialises services and routes accordingly

### Navigation
- **5-tab bottom nav shell** — Home, History, Scan (FAB centre), Tips, Settings
- **Glassmorphism bottom bar** with backdrop blur, active indicator dots, and scale animation on FAB
- **GoRouter** for type-safe, deep-link-ready navigation
- Result screen opens as a full-screen push outside the shell

---

## Screens

| Screen | Description |
|--------|-------------|
| **Splash** | Initialises StorageService and TFLiteService; routes to Onboarding (first run) or Home |
| **Onboarding** | 4 slides: What is SafeGuard, How it works, Privacy promise, Get started |
| **Home** | Dashboard — today's scan count, weekly safe-rate ring, recent scans row, scan CTA |
| **Scan** | Source picker (Camera / Gallery) with privacy note; processing overlay during inference |
| **Result** | Full-screen verdict — hero image, VerdictCard, animated score bars, platform grid, share button |
| **History** | Filterable (All / Safe / Risky / Unsafe) list with Dismissible swipe-to-delete |
| **Tips** | 10 expandable content safety tips, category-filtered |
| **Settings** | Auto-save toggle, scan stats, model info, clear history, share app, privacy policy |

---

## Tech Stack

| Category | Package | Version |
|----------|---------|---------|
| Framework | Flutter | SDK ^3.9.2 |
| State management | get (GetX) | ^4.6.6 |
| Navigation | go_router | ^14.2.0 |
| AI / Inference | tflite_flutter | ^0.12.1 |
| Image decoding | image | ^4.2.0 |
| Image picking | image_picker | ^1.1.2 |
| Local storage | hive_flutter | ^1.1.0 |
| Preferences | shared_preferences | ^2.3.0 |
| Permissions | permission_handler | ^11.3.0 |
| Animations | flutter_animate | ^4.5.0 |
| Confetti | confetti | ^0.7.0 |
| Fonts | google_fonts | ^6.2.0 |
| Page dots | smooth_page_indicator | ^1.1.0 |
| Sharing | share_plus | ^10.0.0 |
| IDs | uuid | ^4.4.0 |

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, service registration
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Full colour system + gradients
│   │   └── app_theme.dart             # ThemeData (dark)
│   ├── models/
│   │   └── scan_result.dart           # ScanResult, SafetyLevel, NsfwClass
│   ├── services/
│   │   ├── tflite_service.dart        # Model load, preprocessing, inference
│   │   └── storage_service.dart       # Hive box + SharedPreferences wrapper
│   ├── utils/
│   │   └── haptics.dart               # HapticFeedback helpers
│   └── widgets/
│       ├── animated_progress_bar.dart # Labelled score bar with animation
│       ├── glass_card.dart            # Reusable glassmorphism container
│       └── safety_badge.dart          # SafetyBadge pill + VerdictCard
├── presentation/
│   ├── navigation/
│   │   └── main_navigation.dart       # Bottom nav shell with glassmorphism bar
│   └── routes/
│       └── app_router.dart            # GoRouter config — all routes
└── features/
    ├── splash/
    │   └── splash_screen.dart
    ├── onboarding/
    │   └── onboarding_screen.dart
    ├── home/
    │   ├── home_screen.dart
    │   └── home_controller.dart
    ├── scan/
    │   ├── scan_screen.dart
    │   ├── scan_controller.dart       # Permission handling, inference orchestration
    │   └── result_screen.dart
    ├── history/
    │   ├── history_screen.dart
    │   └── history_controller.dart
    ├── tips/
    │   └── tips_screen.dart
    └── settings/
        ├── settings_screen.dart
        └── settings_controller.dart

assets/
└── model/
    ├── nsfw_detector_model.tflite     # GantMan NSFW MobileNetV2 model
    └── class_labels.txt               # drawings, hentai, neutral, porn, sexy
```

---

## AI Model

- **Architecture:** MobileNetV2 (quantised TFLite)
- **Source:** GantMan NSFW Model ([github.com/GantMan/nsfw_model](https://github.com/GantMan/nsfw_model))
- **Input:** 224×224×3 float32 tensor, pixel values normalised to [0.0, 1.0]
- **Output:** [1, 5] float32 tensor — probability for each of the five classes
- **Classes (alphabetical):** `drawings`, `hentai`, `neutral`, `porn`, `sexy`
- **Inference location:** Fully on-device via `tflite_flutter` (no network calls)
- **Supported ABIs:** `arm64-v8a`, `x86_64`

---

## Safety Classification

Scores from the model are mapped to `SafetyLevel` as follows:

| Condition | Verdict |
|-----------|---------|
| `neutral + drawings ≥ 0.7` | **Safe** |
| `porn ≥ 0.6` OR `hentai ≥ 0.6` | **Unsafe** |
| Everything else | **Risky** |

Each verdict comes with:
- A **color** (green / amber / red)
- A **description** ("Safe to post on most platforms" etc.)
- A **platform warning** (guidance for Instagram, TikTok, YouTube, LinkedIn, Twitter/X)

---

## Permissions

| Permission | Platform | Why |
|-----------|----------|-----|
| `CAMERA` | Android + iOS | Capture photos for scanning |
| `READ_EXTERNAL_STORAGE` (maxSdk 32) | Android ≤ 12 | Read photos from gallery |
| `READ_MEDIA_IMAGES` | Android 13 (API 33) | Read photos from gallery |
| `READ_MEDIA_VISUAL_USER_SELECTED` | Android 14+ (API 34+) | Partial photo library access |
| `NSCameraUsageDescription` | iOS | Camera access |
| `NSPhotoLibraryUsageDescription` | iOS | Photo library access |

**Android 13+:** `image_picker` uses the system photo picker — no runtime permission dialog is shown for gallery access.

Permissions use a friendly rationale dialog before the OS prompt, and an "Open Settings" dialog if permanently denied.

---

## Building & Running

### Prerequisites
- Flutter SDK ≥ 3.9.2
- Android Studio / Xcode for device/emulator
- A physical Android device is recommended for TFLite performance

### Run in debug mode
```bash
flutter pub get
flutter run
```

### Build release APK (for sideloading / testing)
```bash
flutter build apk --release
```

### Build release App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

> **Note:** You must configure a release signing keystore before a Play Store upload. See `android/app/build.gradle.kts` — the release build currently uses debug keys.

---

## Play Store Readiness

| Item | Status |
|------|--------|
| Core functionality | ✅ Complete |
| Permissions handling | ✅ Complete |
| Privacy (no cloud upload) | ✅ Complete |
| App icon | ❌ Still using Flutter default |
| Native splash screen | ❌ White flash on cold start |
| `applicationId` | ❌ Still `com.example.*` — must change |
| Release signing config | ❌ Using debug keys |
| Target SDK explicit (35) | ❌ Inherited from flutter default |
| IARC content rating declared | ❌ Required for Play Console submission |

---

## Known Limitations

- **Model accuracy is ~90–93%** on the original GantMan benchmark dataset. It can produce false positives on artistic/medical imagery and false negatives on subtly edited content.
- **No batch scanning** — only one image at a time.
- **No URL scanning** — images must be local (camera or gallery).
- **Large model size** — `nsfw_detector_model.tflite` adds ~20–25 MB to the app bundle.
- **iOS not fully tested** — permission flow and TFLite delegate are implemented but require physical device validation.
- Auto-save is enabled by default. If turned off, scan results are not stored and the History tab will remain empty.
