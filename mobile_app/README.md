# Data Labeling Support System - Flutter Mobile App

This is a complete Flutter mobile application for the Data Labeling Support System (DLSS), built with **Clean Architecture**, **Provider state management**, and **Dio HTTP client** for seamless integration with the ASP.NET Core backend.

## 🎯 Features

- **User Authentication**: Register, login, and logout with JWT tokens
- **Task Management**: View assigned annotation tasks with real-time status
- **Task Details**: Access task data items, labels, and guidelines
- **Task Actions**: Accept and start tasks directly from the mobile app
- **Secure Token Storage**: Tokens stored in Flutter Secure Storage
- **Responsive UI**: Material Design 3 with Tailwind-inspired colors matching the web app
- **Error Handling**: Comprehensive error states and user feedback
- **Loading States**: Shimmer skeleton loaders for smooth UX

## 📂 Project Structure

```
lib/
├── main.dart                      # App entry point
├── app.dart                       # Root widget with providers
├── core/
│   ├── constants/
│   │   ├── environment.dart       # API base URL & endpoints
│   │   └── app_constants.dart     # App-wide constants
│   ├── theme/
│   │   └── app_theme.dart         # Material Design 3 theme (matches web app)
│   └── utils/
│       └── logger.dart            # Logging utility
├── models/
│   ├── auth/
│   │   ├── login_request.dart
│   │   ├── register_request.dart
│   │   ├── auth_response.dart
│   │   └── user_profile.dart
│   ├── annotator/
│   │   ├── annotator_task.dart
│   │   ├── task_item.dart
│   │   ├── label.dart
│   │   └── annotation.dart
│   └── common/
│       ├── service_response.dart
│       └── api_error.dart
├── providers/
│   ├── auth_provider.dart         # Authentication state management
│   └── task_provider.dart         # Task list & detail state management
├── repositories/
│   ├── dio_client.dart            # HTTP client with interceptors
│   ├── auth_repository.dart       # Auth API calls
│   └── annotator_repository.dart  # Annotator API calls
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── annotator/
│       ├── task_list_screen.dart  # Product List equivalent
│       └── task_detail_screen.dart # Product Detail equivalent
├── widgets/
│   ├── custom_text_field.dart
│   ├── action_button.dart
│   ├── task_card.dart
│   ├── status_badge.dart
│   ├── loading_skeleton.dart
│   └── error_widget.dart
└── routes/
    └── app_routes.dart             # Route configuration
```

## 🚀 Quick Start

### Prerequisites
- Flutter 3.41.9+
- Dart 3.11.5+
- Android SDK (API 21+)
- Backend running on `http://localhost:5000`

### Installation & Run

```bash
# Install dependencies
flutter pub get

# Run on Android Emulator
flutter run

# Or on specific device
flutter run -d <device_id>
```

## 🤖 Android Emulator Setup

### Network Configuration
The Android Emulator accesses the host machine via `10.0.2.2`:
- Backend: `http://10.0.2.2:5000`
- Already configured in `lib/core/constants/environment.dart`

### Starting Emulator
```bash
emulator -avd Pixel_4_API_30

# Or via Android Studio: AVD Manager → Play button
```

### Manifest Configuration
The following permissions are already configured in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<application android:usesCleartextTraffic="true">
```

## 🎨 Features & Implementation

### Authentication Flow
1. User registers or logs in
2. JWT tokens stored securely
3. Tokens auto-included in all API requests
4. Auto-logout on invalid token

### Task Management
- **Task List**: ListView with lazy loading
- **Task Detail**: Shows data items, labels, and guideline
- **Task Actions**: Accept & Start buttons with state updates

### UI/UX
- Material Design 3 theme matching web app
- Skeleton loaders during data fetch
- Error states with retry functionality
- SafeArea + SingleChildScrollView prevent keyboard overflow

## 🧪 Testing

### Unit Tests
```bash
flutter test test/unit/auth_provider_test.dart
```

### Widget Tests
```bash
flutter test test/widget/login_screen_test.dart
```

### Run All Tests
```bash
flutter test
```

## 📡 API Integration

All API responses follow this structure:
```json
{
  "isSuccess": true,
  "data": { /* actual data */ },
  "message": "Success message",
  "errors": []
}
```

Key endpoints:
- `POST /api/auth/login` - Login
- `POST /api/auth/register` - Register
- `GET /api/annotator/tasks` - Get tasks
- `GET /api/annotator/tasks/{taskId}/items` - Get task items

## 📚 Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Clean Architecture & Design patterns
- [ANDROID_EMULATOR_GUIDE.md](ANDROID_EMULATOR_GUIDE.md) - Emulator setup & troubleshooting

## 🔐 Security

- JWT token storage via `flutter_secure_storage`
- Encrypted token persistence
- HTTPS ready for production
- Strict Dart null safety

## 🛠 Dependencies

- `provider: ^6.1.0` - State management
- `dio: ^5.4.0` - HTTP client  
- `flutter_secure_storage: ^9.2.2` - Secure storage
- `google_fonts: ^6.2.1` - Typography
- `shimmer: ^3.0.0` - Loading indicators

## 📊 State Management

The app uses **Provider** pattern:
- `AuthProvider`: Authentication state
- `TaskProvider`: Task list & detail state

Each provider manages its own state and notifies listeners on changes.

## ⚡ Performance

- Lazy loading for task lists (`ListView.builder`)
- Image caching for remote assets
- Interceptor pattern for HTTP efficiency
- Skeleton loaders during async operations

## 📦 Build & Release

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

## 🚨 Troubleshooting

- **Connection timeout**: Ensure backend is running on `http://localhost:5000`
- **Emulator slow**: Increase RAM in AVD settings to 2GB+
- **Keyboard overflow**: All forms wrapped in `SafeArea` + `SingleChildScrollView`

See [ANDROID_EMULATOR_GUIDE.md](ANDROID_EMULATOR_GUIDE.md) for detailed troubleshooting.

## 📝 Development Workflow

1. Edit code in `lib/`
2. Hot reload: Press 'r' in terminal
3. Full restart: Press 'R' in terminal
4. Run tests: `flutter test`
5. Format code: `dart format`

---

**Flutter Version**: 3.41.9 | **Dart Version**: 3.11.5
