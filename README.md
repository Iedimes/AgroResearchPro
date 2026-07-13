# AgroResearch Pro

Advanced agricultural research platform with disease assessment, trial management, and lab results.

## Overview

AgroResearch Pro is a comprehensive mobile application designed to support agricultural research and field trials. It provides tools for disease assessment, trial management, lab result processing, weather monitoring, market price tracking, and user management.

## Features

- **Disease Assessment**: AI-powered plant disease detection with image upload and analysis
- **Trial Management**: Efficient management of field trials with observations and data tracking
- **Lab Results**: Processing and analysis of lab test results
- **Weather Analysis**: Real-time weather monitoring and forecasting
- **Market Prices**: Crop market price tracking and analysis
- **User Management**: Secure authentication and profile management
- **Offline Sync**: Local storage with Firebase synchronization
- **Multi-language Support**: English, Spanish, and French

## Architecture

The application follows a clean architecture with the following structure:

```
lib/
├── core/
│   ├── router/           # Navigation configuration
│   ├── theme/            # App themes (light/dark)
│   └── localization/     # Multi-language support
├── features/
│   ├── disease_assessment/
│   ├── trial_management/
│   ├── lab_results/
│   ├── weather_analysis/
│   ├── market_prices/
│   └── user_profile/
│       ├── models/      # Data models
│       ├── services/    # Business logic
│       ├── ui/         # UI components
│       └── widgets/     # Reusable widgets
├── services/
│   ├── firebase_service.dart     # Firebase integration
│   ├── local_storage_service.dart # Local storage (Hive)
│   ├── api_service.dart          # REST API communication
│   └── sync_provider.dart        # Data synchronization
├── widgets/
│   ├── loading_widget.dart        # Loading indicators
│   └── empty_state_widget.dart    # Empty state displays
└── models/                      # Base data models
```

## Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Riverpod**: State management
- **Go Router**: Navigation
- **Material Design**: UI components

### Backend
- **Firebase**: Core platform services
  - Firestore: NoSQL database
  - Storage: File storage
  - Auth: User authentication
  - Realtime Database: Sync data
  - Cloud Messaging: Push notifications

### Development Tools
- **Dart**: Programming language
- **JSON Serialization**: Data handling
- **Hive**: Local database
- **Shared Preferences**: Local storage

## Development Setup

### Prerequisites
- Flutter 3.0 or higher
- Dart SDK
- Android Studio / VS Code
- Xcode (for iOS development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/agro-research-pro.git
cd agro-research-pro
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Firebase:
   - Go to the [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Add Android, iOS, and Web apps
   - Download `google-services.json` (Android), `GoogleService-Info.plist` (iOS), and `firebase-config.js` (Web)
   - Place these files in the respective platform directories

4. Run the app:
```bash
flutter run
```

## Project Structure

### Flutter Files

#### `lib/main.dart`
Entry point of the application. Initializes the app and sets up routing.

#### `lib/app.dart`
Home screen with feature navigation.

#### `lib/core/router/router.dart`
Navigation configuration using Go Router with protected routes.

#### `lib/core/theme/app_theme.dart`
Light and dark theme definitions.

### Features

Each feature has its own dedicated directory with:
- `models/`: Data classes with JSON serialization
- `services/`: Business logic and API integration
- `ui/`: Screens and widgets
- `widgets/`: Reusable components

### Core Services

#### `lib/services/firebase_service.dart`
Firebase integration including:
- Authentication (email/password)
- Image upload to Storage
- CRUD operations for assessments
- Offline sync management

#### `lib/services/local_storage_service.dart`
Local storage using Hive for offline data persistence.

#### `lib/services/api_service.dart`
REST API client for external data sources.

#### `lib/services/sync_provider.dart`
Manages synchronization between local and remote data.

### Common Widgets

#### `lib/widgets/loading_widget.dart`
Standard loading indicator with message.

#### `lib/widgets/empty_state_widget.dart`
Display when no data is available.

## Usage

### Disease Assessment
1. Navigate to Disease Assessment from the home screen
2. Enter plant details (name, location, type)
3. Describe symptoms
4. Upload plant images
5. Submit assessment for analysis

### Trial Management
1. View all trials from the Trials screen
2. Add new trials with crop type, variety, and timeline
3. Record observations during trials
4. Update trial status (active/completed/cancelled)

### Lab Results
1. Add new lab results
2. Select test type (pathogen, nutrient, pesticide, etc.)
3. Enter test results
4. View and compare with historical data

### User Profile
1. View and edit personal information
2. Change password
3. Update notification preferences
4. Manage account settings

## Configuration

### Android
- `android/app/src/main/res/values/strings.xml`: App strings
- `android/app/src/main/AndroidManifest.xml`: Permissions and components

### iOS
- `ios/Runner/Info.plist`: App configuration
- `ios/Runner/Assets.xcassets/`: App icons and launch screens

### Web
- `web/index.html`: Web app configuration
- `web/manifest.json`: PWA manifest

## Testing

Run tests with:
```bash
flutter test
```

For integration tests:
```bash
flutter drive
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues, please open an issue on GitHub. For support, contact your project administrator.
