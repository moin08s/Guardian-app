# 🛡️ Abhaya: Proactive Safety & Live Mapping System

**Abhaya** (अभय — *Fearlessness & Protection*) is an intelligent, proactive personal safety ecosystem built with Flutter. It integrates real-time GPS tracking, biometric stress sensing (Heart Rate, GSR, SpO2), hardware strap tamper detection, and localized standalone AI guidance to protect loved ones and deliver rapid emergency responses.

---

## 🌐 Live Web Demo
Experience the interactive Abhaya application directly in your browser:
👉 **[Live Working Demo on GitHub Pages](https://moin08s.github.io/Guardian-app/)**

---

## 🚀 Key Capabilities & Features

### 1. 🛡️ Dynamic Multi-State Security Dashboard
The user interface continuously adapts its security posture and visuals across 3 proactive states:
*   **Safe State (`safe`)**: Calming green aesthetic. Continuous background biometric monitoring (HR, Calm Index, SpO2, Battery), strap connectivity telemetry, and quiet testing tools.
*   **Panic State (`panic`)**: High-contrast crimson alert interface triggered by biometric spikes, manual requests, or hardware SOS button. Instantly launches background "Black Box" audio evidence recording, displays navigation hints to the nearest police station, and highlights direct-call emergency shortcuts.
*   **Tamper State (`tamper`)**: Warning alert mode activated if the wearable strap is forcefully disconnected (`STRAP_REMOVED_BY_FORCE`) or sensor I2C communication fails, preserving last known coordinates for emergency responders.

### 2. 🧠 Standalone AI Safety Advisor
*   Powered by **LLaMA 3.3-70b** via the Groq API.
*   Delivers instantaneous, context-aware survival strategies and de-escalation advice.
*   **Multilingual Support**: Real-time responses in **English**, **Hindi (हिंदी)**, or **Marathi (मराठी)**.
*   **OpenStreetMap (OSM) Integration**: Dynamically queries the Overpass API to locate the closest police station or hospital, identifying their name, address, and phone number based on current latitude and longitude.

### 3. 📍 Live Tracking & Historical Travel Paths
*   Interactive Leaflet mapping layer powered by `flutter_map` and OpenStreetMap tiles.
*   Displays real-time positioning, precision accuracy (`± 4 m`), and custom geofenced safe zones (*Green Zones*).
*   **Historical Timeline Playback**: Visualizes travel routes color-coded by time of day (Morning: Orange, Afternoon: Blue, Night: Purple) with an intuitive calendar date selector.

### 4. 🎙️ "Black Box" Evidence Recording
*   Upon any SOS trigger, the app quietly initiates audio recording with high-quality AAC compression (`emergency_clip.m4a`) via the `record` package to preserve critical forensic evidence.

### 5. 📶 Offline-First Resiliency & Cloud Sync
*   **Local Caching**: Logs telemetry and pending SOS flags in a local SQLite database (`sqflite`).
*   **Auto-Sync**: Automatically detects network restoration (`connectivity_plus`) and relays queued offline pings to the cloud.

---

## 📂 Project Architecture

```
lib/
├── main.dart                  # Application entry point with safe multi-platform initialization
├── models/
│   └── biometrics.dart        # Biometrics data model (HR, Stress, SpO2, Strap state)
├── screens/
│   ├── onboarding_screens.dart# 4-Step interactive setup (Pairing, Network, Zones, Calibration)
│   ├── main_wrapper_screen.dart# Bottom navigation router shell
│   ├── dashboard_screen.dart  # Dynamic status dashboard (Safe, Panic, Tamper)
│   ├── map_tab_screen.dart    # Live tracking, accuracy info, and date-based history
│   ├── ai_screen.dart         # Multi-lingual conversational AI advisor
│   ├── log_screen.dart        # Event timeline and audit log with category filters
│   └── settings_screen.dart   # Profile, trusted contacts, and device parameters
├── services/
│   ├── ai_service.dart        # Groq LLaMA 3.3 client & Overpass OSM emergency queries
│   ├── audio_service.dart     # Background emergency black-box audio recorder
│   ├── db_helper.dart         # Local SQLite storage (abhaya_sos.db)
│   └── sync_service.dart      # Network sync observer to relay offline alerts
├── state/
│   └── dashboard_provider.dart# Central reactive state engine (Provider pattern)
└── widgets/
    ├── custom_map.dart        # Reusable map layer with custom markers & geofences
    └── dashboard_ui.dart      # Consistent design system, colors, cards, and buttons
```

---

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.11.0)
- Android Studio / VS Code with Flutter extension
- An Android Device or Emulator (API 24+) or Modern Web Browser

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/moin08s/Guardian-app.git
   cd Guardian-app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on Connected Device / Emulator**:
   ```bash
   flutter run
   ```

4. **Run on Web Browser**:
   ```bash
   flutter run -d chrome
   ```

---

## 🔒 Privacy & Permissions
- All biometric thresholds and baseline calibrations are computed locally on-device.
- Audio recording only activates when SOS panic triggers are confirmed.
