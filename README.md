# 🛡️ Vanguard

> **A sophisticated, local-first executive dashboard for cybersecurity leaders and development teams**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-5.0+-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://www.android.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

## 📋 Overview

**Vanguard** is a high-performance cyber-tactical dashboard designed for Red Team leads and offensive security engineers. It combines a military-grade project management suite with a real-time, privacy-preserving threat intelligence visualization engine.

Built with a **Local-First** philosophy, Vanguard ensures that your mission data, exploit chains, and operatives' details never leave your device.

---

## ✨ Key Features

### 🌍 Global Threat Map
*   **Real-Time Visualization**: 3D/2D dark-mode map rendering active cyber threats globally.
*   **Entity Extraction**: On-device NLP engine scans intelligence reports to pinpoint threat locations (e.g., "Ransomware attack in Germany" places a marker on Germany).
*   **Live Pulse Tracking**: Animated indicators show threat severity (Red = Critical, Cyan = Standard).

### 🎯 Privacy-Preserving Intel Feed
*   **Zero-Tracking Aggregation**: Fetches RSS/Atom feeds directly from client to source. No intermediate servers.
*   **Categorized Intelligence**: Exploits, Malware, Mobile Security, Dark Web Leaks.
*   **Tactical Cards**: Glassmorphic UI with priority coding.

### 📊 Mission Control (Kanban & Gantt)
*   **Timeline**: Interactive Gantt chart for tracking long-term operations.
*   **Hierarchical Tasks**: Unlimited depth (Operation -> Objective -> Task -> Subtask).
*   **Team Management**: Assign operatives with specialized roles.

### 🔐 Fortress Security
*   **Encrypted Core**: SQLCipher-encrypted database (Drift).
*   **Hardware Auth**: Biometric locking (Fingerprint/Face).
*   **Secure Storage**: Android Keystore for encryption keys.

---

## 🏗️ Architecture

Vanguard uses a modern, scalable Flutter architecture optimized for performance (60fps on mid-range devices).

### Tech Stack
*   **Core**: Flutter 3.x, Dart 3.x
*   **State**: Riverpod 2.5 (Reactive Caching)
*   **Data**: Drift (SQLite abstraction), Flutter Secure Storage
*   **Maps**: `flutter_map` + `latlong2` (OpenStreetMap with custom Dark Matrix tiles)
*   **UI**: Custom Glassmorphism System, Staggered Animations

### Performance Optimizations
*   **Repaint Boundaries**: Isolates heavy animated backgrounds from list scrolling.
*   **Isolate Parsing**: Offloads XML/RSS parsing to background threads to prevent UI jank.
*   **Lazy Rendering**: `ListView.builder` and map marker clustering (planned) for memory efficiency.

---

## 🚀 Getting Started

1.  **Clone & Install**
    ```bash
    git clone https://github.com/DhruvAthaide/Vanguard.git
    cd Vanguard
    flutter pub get
    ```

2.  **Generate Code** (Drift/Riverpod)
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

3.  **Run**
    ```bash
    flutter run
    ```

---

## 🛣️ Roadmap

### Phase 1: Foundation ✅
- [x] Secure Local Database
- [x] Project Management System
- [x] Glassmorphic UI System

### Phase 2: Intelligence & Visualization ✅
- [x] Real-time RSS/Atom Feed
- [x] Global Threat Map (Geo-Tagging)
- [x] Performance Optimization (60fps)

### Phase 3: Advanced Ops (Coming Soon) 🚧
- [ ] SSH/Terminal Integration ("Hacker Mode")
- [ ] Export Encrypted Mission Reports (PDF/JSON)
- [ ] Peer-to-Peer Encrypted Sync (Mesh Network)
- [ ] On-Device Intel Synthesis (Local LLM)
- [ ] Encrypted "Dead Drop" Sharing (QR/Steganography)

---

## 🤝 Contribution
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## 📝 License
[MIT](LICENSE)