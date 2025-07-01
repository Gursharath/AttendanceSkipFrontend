# 📊 Attendance Simulator App

A smart and beautiful Flutter app to **track class attendance**, **simulate skipping classes**, and see how your percentage changes — all **offline** using **Hive** for local storage.

---

## 🚀 Features

- ✅ Add multiple courses with total and attended classes
- 📉 See real-time attendance percentage for each course
- 🧮 Simulate skipping today’s class and watch your percentage drop!
- 🌙 Supports Dark & Light Themes
- 📦 Stores all data locally using Hive (no internet or backend required)
- 🎨 Modern, responsive, animated UI with Google Fonts and shadows

---

## 📸 Screenshots

| Home Screen                         | Add Course                          | Simulate Skipping                 |
|-------------------------------------|-------------------------------------|-----------------------------------|
| ![Home](assets/screens/home.png)   | ![Add](assets/screens/add.png)     | ![Simulate](assets/screens/sim.png) |

---

## 🧱 Tech Stack

- Flutter (Dart)
- Hive (Local Storage)
- Provider (State Management)
- Google Fonts
- Custom Dark/Light Themes

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.0.15
  provider: ^6.0.5
  google_fonts: ^6.2.0

dev_dependencies:
  build_runner: ^2.4.6
  hive_generator: ^2.0.1
