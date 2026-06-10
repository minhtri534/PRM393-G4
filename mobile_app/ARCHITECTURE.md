# Flutter Mobile App - Architecture & Implementation Guide

## 🏗 Clean Architecture Overview

This Flutter app follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────┐
│      UI Layer (Screens/Widgets)     │ ← User Interface
├─────────────────────────────────────┤
│    State Management (Providers)      │ ← Business Logic & State
├─────────────────────────────────────┤
│     Repository Layer (Services)      │ ← Data Abstraction
├─────────────────────────────────────┤
│         Data Sources (APIs)          │ ← External Services
└─────────────────────────────────────┘
```

## 📱 Layers Explained

### 1. **UI Layer** (`screens/` & `widgets/`)
- **Responsibility**: Render UI and handle user interactions
- **Dependencies**: Depends on Providers (state management)
- **Examples**:
  - `LoginScreen`: Handles login form and validation
  - `TaskListScreen`: Displays list of tasks with refresh capability
  - `TaskDetailScreen`: Shows task details with action buttons

### 2. **State Management Layer** (`providers/`)
- **Responsibility**: Manage app state and coordinate between UI and business logic
- **Framework**: Provider package
- **Key Providers**:
  - `AuthProvider`: Manages auth state (login, register, logout)
  - `TaskProvider`: Manages task list and detail state

### 3. **Repository Layer** (`repositories/`)
- **Responsibility**: Abstract data sources and API calls
- **Components**:
  - `DioClient`: HTTP client with interceptors
  - `AuthRepository`: Auth-related API calls
  - `AnnotatorRepository`: Annotator task-related API calls

### 4. **Data Source Layer**
- **External APIs**: Backend ASP.NET Core API
- **Local Storage**: Flutter Secure Storage for tokens

## 🔄 Data Flow Example: Login

```
User enters credentials
        ↓
[LoginScreen] calls authProvider.login()
        ↓
[AuthProvider] calls authRepository.login()
        ↓
[AuthRepository] calls dioClient.post()
        ↓
[DioClient] sends HTTP request to backend
        ↓
[Backend] validates credentials, returns AuthResponse
        ↓
[AuthRepository] stores token in secure storage
        ↓
[AuthProvider] updates state to authenticated
        ↓
[LoginScreen] listens to state changes, navigates to tasks
```

## 🎯 State Management Pattern

### Provider Pattern Used

```dart
// In screen
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (authProvider.isLoading) {
      return LoadingWidget();
    }
    if (authProvider.state == AuthState.error) {
      return ErrorWidget();
    }
    return LoadedWidget();
  },
)
```

### State Enum Pattern

```dart
enum AuthState { initial, loading, authenticated, unauthenticated, error }
enum TaskState { initial, loading, loaded, error }
```

## 🌐 API Integration

### Request/Response Flow

```
[App] → [Dio Interceptor] → [Backend API] → [Response Interceptor] → [App]
                    ↓
            Add JWT Token to headers
```

### Error Handling Strategy

```dart
try {
  // API call
} on ApiError catch (e) {
  // Handle API-specific errors
  state = error;
  errorMessage = e.message;
} catch (e) {
  // Handle generic errors
  state = error;
  errorMessage = AppConstants.errorGeneric;
}
```

## 📋 Model Mapping (C# → Dart)

| C# Class | Dart Class | Key Methods |
|----------|-----------|------------|
| `LoginRequest` | `LoginRequest` | `toJson()` |
| `AuthResponse` | `AuthResponse` | `fromJson()`, `toJson()` |
| `AnnotatorTaskSummaryResponse` | `AnnotatorTask` | `fromJson()`, `toJson()` |
| `TaskItemResponse` | `TaskItem` | `fromJson()`, `toJson()` |
| `LabelResponse` | `Label` | `fromJson()`, `toJson()` |
| `ServiceResponse<T>` | `ServiceResponse<T>` | `fromJson()` |

## 🎨 UI Component Hierarchy

```
MyApp (Theme + Providers)
├── SplashScreen
├── AuthScreen
│   ├── LoginScreen
│   │   ├── CustomTextField (Email)
│   │   ├── CustomTextField (Password)
│   │   └── ActionButton (Sign In)
│   └── RegisterScreen
│       ├── CustomTextField (Full Name)
│       ├── CustomTextField (Email)
│       ├── CustomTextField (Password)
│       └── ActionButton (Create Account)
└── AnnotatorScreen
    ├── TaskListScreen
    │   └── TaskCard
    │       └── StatusBadge
    └── TaskDetailScreen
        ├── TaskHeader (Card)
        ├── TaskItems (ListView)
        ├── Labels (Wrap)
        └── ActionButtons
```

## 🧪 Testing Strategy

### Unit Tests (Auth Provider)
- Test login/register/logout state transitions
- Test error state handling
- Test token management

### Widget Tests (Login Screen)
- Test UI element presence
- Test form validation
- Test navigation
- Test overflow prevention (SafeArea + ScrollView)

## 🔐 Security Practices

1. **Token Storage**: Encrypted via `flutter_secure_storage`
2. **JWT Authorization**: Tokens auto-included via interceptor
3. **HTTPS for Production**: Use HTTPS in production environment
4. **Null Safety**: Strict Dart null safety prevents runtime errors

## ⚡ Performance Optimizations

1. **Lazy Loading**: TaskListScreen uses `ListView.builder`
2. **Caching**: Images cached via `cached_network_image`
3. **Interceptors**: Single HTTP client instance reused
4. **Skeleton Loaders**: Shimmer effect during loading

## 🔄 Routing Strategy

```dart
AppRoutes.generateRoute(settings) {
  switch (settings.name) {
    case '/login': → LoginScreen
    case '/register': → RegisterScreen
    case '/tasks': → TaskListScreen
    case '/task-detail': → TaskDetailScreen(taskId)
  }
}
```

## 📊 State Lifecycle

### AuthProvider Lifecycle
```
Initial → Loading → Authenticated ┐
    ↓         ↓          ↓         │
   Error ← Error ← Unauthenticated
```

### TaskProvider Lifecycle
```
Initial → Loading → Loaded
   ↓         ↓        ↓
  Error ← Error ← Error
```

## 🛠 Adding New Features

### Step 1: Create Model
```dart
// lib/models/annotator/new_model.dart
class NewModel {
  final String id;
  // ... properties
  
  factory NewModel.fromJson(Map<String, dynamic> json) { }
  Map<String, dynamic> toJson() { }
}
```

### Step 2: Add API Method
```dart
// lib/repositories/annotator_repository.dart
Future<List<NewModel>> getNewData() async {
  final response = await _dioClient.get(endpoint);
  // Parse and return
}
```

### Step 3: Add Provider Method
```dart
// lib/providers/task_provider.dart
Future<void> fetchNewData() async {
  _state = TaskState.loading;
  notifyListeners();
  // Call repository and update state
}
```

### Step 4: Create Screen/Widget
```dart
// lib/screens/new_screen.dart
Consumer<TaskProvider>(
  builder: (context, provider, _) {
    // Use provider data to build UI
  },
)
```

### Step 5: Add Route
```dart
// lib/routes/app_routes.dart
case '/new-route':
  return MaterialPageRoute(builder: (_) => NewScreen());
```

## 📈 Debugging

### Enable Logging
```dart
// DioClient automatically logs all requests/responses
// Check console output for API calls
```

### State Debugging
```dart
// Provider DevTools extension available
// Run: flutter run -t lib/main.dart --enable-devtools
```

## 🚀 Deployment

### Build for Release
```bash
flutter build apk --release
```

### Update Configuration for Production
```dart
// lib/core/constants/environment.dart
static const String baseUrl = 'https://api.production.com';
```

---

This architecture ensures:
- ✅ **Testability**: Each layer can be tested independently
- ✅ **Maintainability**: Clear separation of concerns
- ✅ **Scalability**: Easy to add new features
- ✅ **Reusability**: Components can be reused across screens
