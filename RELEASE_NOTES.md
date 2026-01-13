# Vanguard v1.2.0: Advanced Ops Release

> **"Secure. Stealthy. Superior."**

This release introduces the highly anticipated **Advanced Ops** module, empowering field operatives with military-grade encryption tools, covert data sharing, and enhanced intelligence logging.

## 🚀 What's New in v1.2.0

### 🔐 Encrypted Mission Reports
-   **AES-256 PDF Export**: Generate professional mission reports containing tasks, notes, and intel.
-   **Military-Grade Encryption**: Secure your exports with a password using AES-256-GCM.
-   **Local Processing**: All PDF generation and encryption happens on-device.

### 🕵️ Dead Drop Sharing
-   **Offline Data Transfer**: Share sensitive data securely without a network connection.
-   **Encrypted QR Codes**: Generate compressed and encrypted QR codes for secure "optical" data transfer.
-   **Integrated Scanner**: Built-in Dead Drop Scanner to decrypt and read incoming payloads.
-   **Steganography Core**: Logic added for embedding data within images (UI coming in future update).

### 📸 Rich Notes
-   **Image Attachments**: You can now attach images to your field notes.
-   **Secure Vault Storage**: Attachments are stored within the app's secure sandbox.

### 🛠️ Improvements & Fixes
-   **Fixed**: Crash when exporting PDFs on Android 10+.
-   **Privacy**: Enhanced app security with stricter file handling.
-   **UI**: Added "Drop" shortcut for quick sharing from the Note Editor.

---

# Vanguard v1.1.0: First Official Release

> **"Orchestrate. Analyze. Secure."**

We are proud to announce the first major release of **Vanguard**. This release marks the transition to a fully realized, local-first executive dashboard designed specifically for Red Team leads and offensive security engineers.

## 🌟 Highlights

### 🌍 Global Threat Map
- **Real-Time Visualization**: A stunning 3D/2D dark-mode map that renders active cyber threats globally.
- **AI-Powered Entity Extraction**: An on-device NLP engine scans intelligence reports to pinpoint threat locations automatically.
- **Live Pulse Tracking**: Visual indicators for threat severity (Red = Critical, Cyan = Standard).

### 🎯 Privacy-First Intelligence Feed
- **Zero-Tracking Aggregation**: Fetches RSS/Atom feeds directly from client to source with no intermediate servers.
- **Categorized Intel**: Dedicated streams for Exploits, Malware, Mobile Security, and Dark Web Leaks.
- **Tactical UI**: Glassmorphic cards with priority coding for rapid scanning.

### 📊 Mission Control
- **Advanced Project Management**: Manage operations with interactive Kanban boards and Gantt charts.
- **Hierarchical Tasking**: Create complex operations with unlimited depth (Operation -> Objective -> Task -> Subtask).
- **Team Management**: define operatives and roles secure within your local environment.

### 🔐 Fortress Security
- **Encrypted Core**: All data is secured using SQLCipher (via Drift).
- **Hardware Authentication**: Biometric locking (Fingerprint/Face) support.
- **Secure Storage**: Critical keys are stored in the Android Keystore.

---

## 🚀 What's New in v1.1.0
- **Rebranding**: Complete migration from "Command Center" to "Vanguard".
- **Performance**: Optimized list rendering and map interactions for smooth 60fps performance on mid-range devices.
- **Codebase**: Removed legacy code and unused imports for a leaner application footprint.
- **Documentation**: Updated README and project structure.

## 📦 Binaries
- **Android**: `app-release.apk` (Attached below)

## � What's Next
- SSH/Terminal Integration ("Hacker Mode")
- Encrypted Mission Reports (PDF/JSON)
- Peer-to-Peer Encrypted Sync

---
*Created with ❤️ by the Dhruv Athaide*