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
| 🔄 | **Auto Updates** | Built-in update checker that finds new GitHub releases |

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

Pre-built signed release APKs are generated for each [GitHub release](https://github.com/proabusaleh/calculatorplus/releases).

### Latest Release — v2.0.0

| Build | Size |
|---|---|
| **Universal APK** | ~81 MB |

> **Direct download:** [CalculatorPlus-v2.0.0.apk](https://github.com/proabusaleh/calculatorplus/releases/download/v2.0.0/CalculatorPlus-v2.0.0.apk)

### Update checking

Calculator Plus includes a built-in **update checker** (`UpdateService`). On launch it queries the
GitHub Releases API for the latest version. When a newer release is found, it shows an
**"Update Available"** dialog with the release notes and an **Update Now** button that downloads
the APK directly from GitHub. No app store needed.

To ship an update, just bump the version in `pubspec.yaml`, rebuild, and **create a new GitHub
release** with an attached `.apk` asset — users on older versions will be prompted automatically.

> The in-app source for this is `lib/services/update_service.dart` and `lib/widgets/update_dialog.dart`.

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
- **Updates** — [http](https://pub.dev/packages/http) + [url_launcher](https://pub.dev/packages/url_launcher) via GitHub Releases
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
│   ├── update_service.dart   # GitHub release update checker
│   └── app_info.dart         # Installed app version
├── theme/                    # App theming & color system
└── widgets/                  # Reusable UI widgets
    └── update_dialog.dart    # "Update Available" prompt
```

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">

Made with ❤️ with Flutter

</div>
