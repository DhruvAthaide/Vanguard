# 🛡️ Vanguard

> **A sophisticated, local-first executive command center for cybersecurity leaders and development teams**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-5.0+-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://www.android.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

## 📋 Overview

**Vanguard** is a purpose-built Flutter application designed specifically for cybersecurity professionals managing cybersecurity operations and development. By prioritizing privacy and security through a local-first architecture, Vanguard ensures that sensitive tactical data, exploit payloads, and project roadmaps remain encrypted and stored exclusively on your Android device.

### Why Vanguard?

- 🔐 **Zero Cloud Dependencies** - All data stays on your device, encrypted at rest
- 🎯 **Mission-Critical Intelligence** - Aggregated cybersecurity news segmented by threat category
- 📊 **Enterprise Project Management** - Deep task hierarchies with team assignments
- 📈 **Visual Timeline Analytics** - Priority-coded Gantt charts for operation oversight
- 🎨 **Modern Glassmorphic UI** - Cyberpunk-inspired design with smooth animations
- 🔒 **Biometric Security** - Hardware-backed authentication for device access

---

## ✨ Core Features

### 🎯 Intelligence Feed
```
📡 Real-time threat intelligence aggregation
🔍 Categorized by: Exploits, Malware, Mobile Security, Threat Intel, Leaks
🎨 Glassmorphic cards with priority-based color coding
⚡ Fast, local filtering and search
```

### 📊 Project Command Center
```
🗂️ Hierarchical task/subtask structure (unlimited depth)
👥 Team member assignment and tracking
🎯 Priority levels: Low, Medium, High, Critical
📅 Start dates, deadlines, and status tracking
🔄 Kanban board view + Tree view
📈 Real-time progress tracking
```

### 📅 Mission Timeline
```
📊 Dynamic Gantt-style timeline visualization
🎨 Priority-coded project bars with status indicators
⚠️ Overdue detection with pulsing alerts
📍 "Today" marker with visual highlight
🔍 Adjustable zoom levels for timeline granularity
```

### 🔐 Security Architecture
```
🗄️ Encrypted SQLite database (Drift ORM)
🔐 Hardware-backed biometric authentication
🚫 No network calls, no telemetry, no cloud sync
📱 Android 5.0+ with native security features
🔒 Secure local storage in app sandbox
```

---

## 🏗️ Technical Architecture

### Technology Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.0+ |
| **Language** | Dart 3.0+ |
| **Database** | SQLite + Drift ORM |
| **State Management** | Riverpod 2.0 |
| **UI Components** | Custom glassmorphic widgets |
| **Icons** | Lucide Icons |
| **Typography** | Google Fonts (Inter, Roboto Mono) |
| **Animations** | Custom AnimationControllers + Staggered Animations |

### Project Structure

```
lib/
├── core/
│   ├── theme/
│   │   └── cyber_theme.dart          # Cyberpunk color palette & theme
│   └── constants/
├── database/
│   ├── app_database.dart             # Drift database configuration
│   ├── tables.dart                   # Database schema definitions
│   └── project_dao.dart              # Data access layer
├── providers/
│   ├── project_provider.dart         # State management for projects
│   └── intel_provider.dart           # State management for intel feed
├── views/
│   ├── intel/
│   │   ├── intel_feed_screen.dart    # Main intelligence feed
│   │   ├── intel_card.dart           # Glassmorphic threat cards
│   │   └── intel_category_bar.dart   # Category filter chips
│   ├── projects/
│   │   ├── projects_screen.dart      # Project list view
│   │   ├── project_detail_screen.dart # Task management interface
│   │   └── widgets/
│   │       ├── cyber_project_card.dart
│   │       ├── cyber_kanban_board.dart
│   │       ├── cyber_task_tree.dart
│   │       ├── task_editor_sheet.dart
│   │       └── add_project_sheet.dart
│   └── timeline/
│       ├── timeline_screen.dart      # Gantt chart view
│       └── widgets/
│           ├── timeline_header.dart
│           ├── timeline_project_bar.dart
│           └── timeline_legend.dart
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (Android 5.0+)
- Dart 3.0+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/DhruvAthaide/Vanguard.git
   cd Vanguard
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Drift database code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Building for Production

```bash
# Build release APK
flutter build apk --release

# Build app bundle for Play Store
flutter build appbundle --release
```

---

## 🎨 Design System

### Color Palette (Cyber Theme)

| Color | Hex Code | Usage |
|-------|----------|-------|
| **Primary (Cyan)** | `#38BDF8` | Accent color, CTAs, highlights |
| **Danger (Red)** | `#EF4444` | Critical alerts, overdue items |
| **Success (Green)** | `#10B981` | Completed tasks, success states |
| **Background** | `#0A0E1A` | Main background |
| **Surface** | `#1A1F2E` | Cards, elevated surfaces |
| **Glass** | `rgba(255,255,255,0.05)` | Glassmorphic overlays |

### UI Components

- **Glassmorphism**: Frosted glass effect with backdrop blur
- **Animations**: Smooth transitions, staggered list animations, pulse effects
- **Typography**: Inter for UI text, Roboto Mono for technical content
- **Icons**: Lucide Icons for modern, consistent iconography

---

## 📊 Key Workflows

### Creating a Project

1. Navigate to **Projects** screen
2. Tap **+ New Operation** button
3. Enter operation name, description, and deadline
4. Tap **Commence Operation**

### Managing Tasks

1. Open project from list
2. Tap **Add Objective** FAB
3. Configure task details:
    - Title & description
    - Start date & deadline
    - Status (To Do, In Progress, Review, Done)
    - Threat level (0-3)
    - Assign team member
4. Tap **Deploy Objective**

### Creating Subtasks

1. Open task in tree view
2. Long-press or tap context menu
3. Select **Add Sub-Objective**
4. Configure subtask details

### Viewing Timeline

1. Navigate to **Timeline** screen from Projects
2. View Gantt chart with all operations
3. Use **+/-** buttons to zoom timeline
4. Tap project bar to view details

---

## 🔒 Security Features

### Data Protection

- **Encryption at Rest**: SQLite database encrypted using platform security
- **No Cloud Sync**: All data stored locally in app sandbox
- **Secure Storage**: Android keystore for sensitive operations
- **Biometric Auth**: Fingerprint/Face unlock support (planned)

### Privacy First

- ❌ No network calls to external servers
- ❌ No telemetry or analytics
- ❌ No third-party SDKs
- ✅ 100% offline functionality
- ✅ Full user data ownership

---

## 🛣️ Roadmap

### Phase 1: Core Foundation ✅
- [x] Database schema & ORM setup
- [x] Project & task management
- [x] Intelligence feed UI
- [x] Timeline visualization
- [x] Glassmorphic design system

### Phase 2: Enhanced Features 🚧
- [ ] Biometric authentication
- [ ] File attachments for tasks
- [ ] Markdown notes with syntax highlighting
- [ ] Export/import functionality
- [ ] Dark/Light theme toggle
- [ ] Custom tag colors

### Phase 3: Advanced Capabilities 🔮
- [ ] Encrypted backup/restore
- [ ] Advanced filtering & search
- [ ] Custom dashboard widgets
- [ ] Notification system
- [ ] Multi-device sync (encrypted P2P)
- [ ] iOS support

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed
- Maintain the glassmorphic design language

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📧 Contact

**Project Maintainer**: [Your Name]
- GitHub: [@DhruvAthaide](https://github.com/DhruvAthaide)
- Email: athaidedhruv@gmail.com

---

<div align="center">
  <p><strong>Built with ❤️ for the cybersecurity community</strong></p>
  <p>
    <a href="#-vanguard">Back to top ↑</a>
  </p>
</div>