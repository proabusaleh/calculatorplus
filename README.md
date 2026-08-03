<div align="center">

<img src="assets/images/logo.png" alt="Calculator Plus" width="120"/>

# Calculator Plus

**A premium all-in-one scientific calculator with 100+ tools across physics, engineering, chemistry, mathematics, and more.**

Built with **Flutter** — beautiful, fast, and free.

[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-blue)](#download)
[![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter&logoColor=white)](#)
[![License](https://img.shields.io/badge/license-MIT-green)](#license)
[![Version](https://img.shields.io/badge/version-2.0.0-ff7043)](#download)

</div>

---

## ✨ Features

| | Tool | Description |
|---|---|---|
| 🧮 | **Basic Calculator** | Clean, lightning-fast everyday arithmetic |
| 🔬 | **Scientific Calculator** | Trigonometric, logarithmic, exponential & advanced functions |
| 📐 | **Algebra & Symbolic** | Equation solving, symbolic manipulation & factorization |
| 🧮 | **Linear Algebra** | Matrices, determinants, inverses & vector operations |
| 🔢 | **Number Theory** | Primes, GCD/LCM, modular arithmetic & more |
| 📊 | **Statistics** | Mean, median, mode, variance, distributions |
| 📈 | **Graphing** | Interactive 2D function plotting |
| 📏 | **Geometry** | Area, perimeter, volume & angle calculations |
| 🧊 | **3D Solids** | Surface area & volume for 3D shapes |
| ⚗️ | **Chemistry** | Molar mass, concentration, stoichiometry |
| 🔭 | **Physics & Engineering** | Kinematics, electrical, mechanical & signal tools |
| 🌍 | **Earth & Space** | Planetary & astronomical calculations |
| 💱 | **Unit Converter** | Length, mass, temperature, currency & more |
| 💻 | **Programmer Mode** | Binary / hex / octal conversions & bitwise ops |
| 💰 | **Financial** | Interest, loan, EMI & investment calculations |
| 📅 | **Date & Time** | Age, duration & calendar computations |
| 📖 | **Constants Library** | Physics & math constants at your fingertips |
| 🧠 | **Memory & History** | Store results, recall calculations, revisit history |
| 🌗 | **Themes & Haptics** | Dark/light modes, custom accents, haptic feedback |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `3.x`
- Android SDK / Xcode / Chrome (depending on your target)

### Run the app

```bash
# Install dependencies
flutter pub get

# Run on a connected device / emulator
flutter run

# Run on the web
flutter run -d chrome
```

### Run tests

```bash
flutter test
```

---

## 📦 Download

Pre-built signed release APKs are generated for each release.

### Latest Release — v2.0.0

| Build | ABI | Size | Best for |
|---|---|---|---|
| **Universal APK** | `armeabi-v7a + arm64-v8a + x86_64` | — | Install anywhere, maximum compatibility |
| **arm64-v8a APK** | `arm64-v8a` | — | Most modern Android phones |
| **armeabi-v7a APK** | `armeabi-v7a` | — | Older 32-bit devices |
| **x86_64 APK** | `x86_64` | — | Emulators & Chromebooks |

> **Tip:** Most users should grab the **arm64-v8a** build. Use the **Universal APK** if your device's architecture is unknown or you need maximum compatibility.

### Build it yourself

```bash
# Universal (all ABIs) release APK
flutter build apk --release

# Split APKs, one per ABI (smaller downloads)
flutter build apk --release --split-per-abi

# App Bundle for Play Store
flutter build appbundle --release
```

Outputs land in `build/app/outputs/flutter-apk/`.

---

## 🛠️ Tech Stack

- **Framework** — [Flutter](https://flutter.dev) 3.x with Dart 3
- **State Management** — [Provider](https://pub.dev/packages/provider)
- **Fonts** — [Google Fonts](https://pub.dev/packages/google_fonts)
- **Persistence** — [SharedPreferences](https://pub.dev/packages/shared_preferences)
- **Icons** — [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)

---

## 🗂️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (calculator, matrix, unit, ...)
├── providers/                # State management (theme, settings, memory)
├── screens/                  # 21 feature screens
├── services/                 # Domain logic & calculation engines
├── theme/                    # App theming & color system
└── widgets/                  # Reusable UI widgets
```

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">

Made with ❤️ with Flutter

</div>
