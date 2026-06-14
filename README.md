# Guardian AI: Proactive Safety & Live Mapping Application

Guardian AI is a modern Flutter-based safety application designed for real-time tracking, proactive SOS alert management, and biometric monitoring. The application pairs with external wearable hardware (e.g., ESP32/nRF52-based smart straps and hubs) to automatically detect emergency conditions, such as panic levels, physical strap tampering, or manual triggers, and delivers localized context-aware safety guidance using standalone AI models.

---

## 🚀 Key Features

### 🛡️ Dynamic State-Driven Dashboard
The dashboard adapts instantly to the user's status across three specific modes:
*   **Safe Mode (`safe`)**: Green-themed interface indicating normal biometrics, secure strap connection, and options for quiet device pinging.
*   **Panic Mode (`panic`)**: Crimson-themed interface triggered by high stress, hardware button presses, or user request. It immediately starts recording audio, offers dialing shortcuts to nearest emergency stations, and details AI-driven survival guides.
*   **Tamper Mode (`tamper`)**: Orange-themed alert interface triggered if the wearable strap is forcibly removed or the sensor hub loses I2C connectivity.

### 🧠 Standalone AI Safety Advisor
*   Powered by **LLaMA 3.3-70b** via the Groq API.
*   Provides immediate, situation-specific survival instructions.
*   Supports multilingual output, responding in **English**, **Hindi**, or **Marathi** based on the emergency context.
*   Integrates **OpenStreetMap (OSM) via the Overpass API** to dynamically locate the nearest police station or hospital, including their name, address, and phone number.

### 📍 Live Tracking & Historical Tracing
*   Integrated leaflet maps via `flutter_map` displaying live location coordinates, accuracy parameters, and geofenced safe zones (Green Zones).
*   **Historical Tracing**: Displays a colored path segment showing the user's travel history for any selected calendar date, color-coded by time of day (Morning: Orange, Afternoon: Blue, Night: Purple).

### ⏺️ Audio "Black Box" Recording
*   Upon any SOS activation, the app utilizes the `record` package to quietly record ambient audio using high-quality AAC compression (`emergency_clip.m4a`) as local and cloud-syncable industrial evidence.

### 📶 Offline-First Resiliency & Sync
*   **Local Caching**: Uses SQLite (`sqflite`) to log GPS coordinates and SOS flags locally if cellular connection drops.
*   **Auto-Sync**: Listens to connectivity changes (`connectivity_plus`) and automatically uploads all cached offline logs to the cloud (Firebase/PHP bridge server) when network access returns.

---

## 📂 Architecture & File Structure

The project follows a clean, decoupled MVC/MVVM-like architecture using the **Provider** pattern:

*   **`lib/main.dart`**: Entrypoint of the app. Initializes Firebase, configures the state providers, and handles the handshake gating interface.
*   **`lib/models/`**
    *   [`biometrics.dart`](file:///d:/Hackthon/lib/models/biometrics.dart): Defines the data structure for Heart Rate, SpO2, stress percentages, and physical strap attachment status.
*   **`lib/state/`**
    *   [`dashboard_provider.dart`](file:///d:/Hackthon/lib/state/dashboard_provider.dart): Central application state engine. Manages IoT events, Firebase listeners, SOS triggers, and dynamic theme switching.
*   **`lib/screens/`**
    *   [`onboarding_screens.dart`](file:///d:/Hackthon/lib/screens/onboarding_screens.dart): Multi-step setup page for onboarding, device pairing, contact setup, and sensor calibration.
    *   [`main_wrapper_screen.dart`](file:///d:/Hackthon/lib/screens/main_wrapper_screen.dart): Bottom navigation wrapper housing the main tabs.
    *   [`dashboard_screen.dart`](file:///d:/Hackthon/lib/screens/dashboard_screen.dart): Dynamic dashboard showing biometric state widgets.
    *   [`map_tab_screen.dart`](file:///d:/Hackthon/lib/screens/map_tab_screen.dart): Tracing maps, manual location search, and date-based history views.
    *   [`ai_screen.dart`](file:///d:/Hackthon/lib/screens/ai_screen.dart): Conversational UI for the local LLaMA safety advisor.
    *   [`log_screen.dart`](file:///d:/Hackthon/lib/screens/log_screen.dart): Timeline view of all system, biometric, and panic events.
    *   [`settings_screen.dart`](file:///d:/Hackthon/lib/screens/settings_screen.dart): Profile settings, trusted contacts management, and manual device controls.
*   **`lib/services/`**
    *   [`ai_service.dart`](file:///d:/Hackthon/lib/services/ai_service.dart): Manages Groq API chat completions, OSM Overpass queries, and Exotel automated call dispatches.
    *   [`audio_service.dart`](file:///d:/Hackthon/lib/services/audio_service.dart): Handles recording/saving emergency audio clips.
    *   [`db_helper.dart`](file:///d:/Hackthon/lib/services/db_helper.dart): SQLite database setup and query helper.
    *   [`sync_service.dart`](file:///d:/Hackthon/lib/services/sync_service.dart): Automatically uploads SQLite backlogs to Firebase via a web bridge API.
*   **`lib/widgets/`**
    *   [`custom_map.dart`](file:///d:/Hackthon/lib/widgets/custom_map.dart): Decoupled mapping widget layer.
    *   [`dashboard_ui.dart`](file:///d:/Hackthon/lib/widgets/dashboard_ui.dart): Styling variables, common buttons, text fields, and theme definitions.

---

## 🛠️ Installation & Setup

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/moin08s/Guardian-app.git
    cd Guardian-app
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run Application**:
    ```bash
    flutter run
    ```

---

## 🔒 Security & Privacy
*   All biometric algorithms and thresholds are checked locally.
*   "Black-box" audio recording stays stored on-device and is only dispatched to your trusted contacts or your configured private bridge endpoint.
