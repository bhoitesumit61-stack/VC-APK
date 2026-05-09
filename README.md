# VOXLINK APK Build

A Flutter voice calling app based on VOXLINK web app using LiveKit.

## Features
- Join voice calling rooms
- Real-time voice chat with LiveKit
- Microphone control
- User-friendly interface

## Build Status
Built automatically on GitHub Actions when pushing to `main` or `master` branch.

## Downloading the APK

1. Go to the **Actions** tab on GitHub
2. Click on the latest **Build and Release APK** workflow
3. Download the APK from the **Artifacts** section

## Local Development

### Prerequisites
- Flutter SDK (https://flutter.dev/docs/get-started/install)
- Android Studio + Android SDK
- Java Development Kit (JDK 11+)

### Build Commands

```bash
# Get dependencies
flutter pub get

# Build APK
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## Backend Setup

Update the backend URL in `lib/main.dart`:

```dart
const backendUrl = 'http://YOUR_BACKEND_URL:3000';
```

The app expects the backend to provide JWT tokens from the `/api/get-token` endpoint.

## LiveKit Configuration

Update LiveKit credentials in the backend:
- LIVEKIT_URL: Your LiveKit server URL
- LIVEKIT_API_KEY: Your API key
- LIVEKIT_API_SECRET: Your API secret