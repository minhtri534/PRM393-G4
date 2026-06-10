# Android Emulator & Development Guide

## 🤖 Android Emulator Setup

### Creating an Emulator (if not already created)

1. **Open Android Studio**
   - Go to: AVD Manager → Create Virtual Device

2. **Select Device**
   - Recommend: Pixel 4 or Pixel 5 (standard 1080x1920)

3. **Select System Image**
   - Android API Level 30+ (API 34 recommended)
   - Google Play Edition (optional)

4. **Configure Settings**
   - RAM: 2048 MB (minimum)
   - VM Heap: 512 MB
   - Internal Storage: 2048 MB
   - SD Card: Optional (but helpful for storage)

### Starting the Emulator

**Via Android Studio:**
- Open AVD Manager
- Click the Play (▶) button next to your emulator
- Wait 30-60 seconds for full boot

**Via Command Line:**
```bash
emulator -avd <emulator_name>

# Example:
emulator -avd Pixel_4_API_30
```

**Check Running Emulators:**
```bash
adb devices
# Output:
# List of attached devices
# emulator-5554          device
```

## 🌐 Network Configuration

### Key Network Settings for Development

#### Android Emulator Network Stack
- The emulator has a virtual network interface
- Host machine is accessible via `10.0.2.2` (special alias)
- Emulator's own localhost (`127.0.0.1`) is **not** accessible from host

#### Default Ports (Android Emulator)
- Port 5000 (HTTP) → `10.0.2.2:5000`
- Port 5001 (HTTP) → `10.0.2.2:5001`
- Ports are forwarded automatically

### Backend URL Configuration

**Current Setup** (already configured):
```dart
// lib/core/constants/environment.dart
static const String baseUrl = 'http://10.0.2.2:5000';
```

This automatically:
- Routes to your host machine's `localhost:5000`
- Works with Android Emulator
- **Does NOT work with physical devices on same network**

## 🏃 Running the App

### Step 1: Start Backend
```bash
cd backend
dotnet run --launch-profile=http
# Starts on http://localhost:5000
```

### Step 2: Start Android Emulator
```bash
emulator -avd Pixel_4_API_30
# Wait for emulator to fully boot
```

### Step 3: Run Flutter App
```bash
cd mobile_app
flutter run

# Or specify device
flutter run -d emulator-5554

# Or run with verbose logging
flutter run -v
```

### Step 4: Test Login
- Email: any registered email from backend
- Password: corresponding password
- App should successfully authenticate and navigate to Task List

## 🔧 Troubleshooting

### Issue: "Failed to resolve host 10.0.2.2"
**Cause**: Backend not running
**Solution**:
```bash
# Start backend in separate terminal
cd backend
dotnet run --launch-profile=http
# Verify running on http://localhost:5000
```

### Issue: "Connection timed out"
**Cause**: Backend firewall blocking port 5000
**Solution**:
```bash
# Windows Firewall - Allow through
# Or test with:
curl http://localhost:5000/api/auth/login
# Should respond with 405 (Method Not Allowed) for GET
```

### Issue: "Connection refused"
**Cause**: Emulator can't reach host on 10.0.2.2
**Solution**:
```bash
# Verify emulator has internet access
# In emulator, open Chrome and visit any website
# If works, restart Flutter app
```

### Issue: Emulator extremely slow
**Cause**: Low RAM allocation
**Solution**:
```bash
# Close emulator
# Go to Android Studio → AVD Manager → Edit → Increase RAM to 2GB+
# Or disable animations:
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
```

### Issue: "Unable to boot emulator - QEMU process crashed"
**Solution**:
```bash
# Wipe emulator data
emulator -avd Pixel_4_API_30 -wipe-data

# Or delete and recreate emulator
rm -r ~/.android/avd/Pixel_4_API_30.avd
# Then create new one in Android Studio
```

## 📱 Testing on Physical Device

### Prerequisites
- Android device with API level 21+
- USB cable
- USB debugging enabled on device

### Enable USB Debugging
1. Go to: Settings → About Phone
2. Tap Build Number 7 times
3. Go to: Settings → Developer Options
4. Enable "USB Debugging"

### Connect Device
```bash
# Connect via USB cable
# Verify connection
adb devices

# Output should show:
# 192.168.1.100:5555    device  (wireless)
# or
# FA6AV1A03456         device  (USB)
```

### Update Configuration for Physical Device

**For device on same network:**

1. Find your machine's IP:
   ```bash
   # macOS
   ifconfig en0 | grep "inet "
   
   # Linux
   hostname -I
   
   # Windows
   ipconfig
   ```

2. Update `environment.dart`:
   ```dart
   // lib/core/constants/environment.dart
   static const String baseUrl = 'http://192.168.1.100:5000';
   // Replace 192.168.1.100 with your actual machine IP
   ```

3. Run app:
   ```bash
   flutter run
   ```

### Testing Checklist

- [ ] App launches without crash
- [ ] Login/Register flow works
- [ ] Can view task list
- [ ] Can view task details
- [ ] Can accept and start tasks
- [ ] Logout works correctly
- [ ] No network timeouts
- [ ] Images load properly

## 🖥 Desktop/Chrome Running (Optional)

### Enable Desktop Platforms
```bash
flutter config --enable-windows
flutter config --enable-macos
flutter config --enable-linux
```

### Run on Chrome (for quick testing)
```bash
flutter run -d chrome

# Useful for rapid iteration on UI
# But does NOT test all platform-specific features
```

## 📊 Performance Profiling

### CPU & Memory Profile
```bash
# While app is running
flutter run --profile

# Or attach to running app
flutter attach
```

### Check Frame Rate
```bash
# In Flutter console (when app running)
Press 's' for showPerformanceOverlay
# Shows FPS counter on screen
```

## 🐛 Debugging

### Hot Reload
```bash
# While app running, press 'r' in terminal
r → Hot reload (keeps state)
R → Full restart (clears state)
```

### Debug Console
```bash
# View logs in real-time
flutter logs

# Filter for your app only
flutter logs -s DLSS
```

### VS Code Debugging
```bash
# Set breakpoints in VS Code
# Run with debugger
flutter run

# Commands in Debug Console:
# Step over: F10
# Step into: F11
# Continue: F5
# Stop: Shift+F5
```

## 🔌 Advanced Network Debugging

### Proxy Traffic Through Charles/Fiddler

1. Set proxy in emulator:
   ```bash
   adb shell settings put global http_proxy 10.0.2.2:8888
   ```

2. View API traffic in proxy tool
3. Useful for debugging API integration issues

### View Network Logs
```bash
# Enable verbose logging
flutter run -v

# Look for lines like:
# 🔗 Request: POST /api/auth/login
# ✅ Response: 200 from /api/auth/login
```

## 📦 APK Management

### Build APK for Testing
```bash
flutter build apk --debug

# APK location: build/app/outputs/flutter-apk/app-debug.apk
```

### Install APK on Emulator/Device
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Uninstall App
```bash
adb uninstall com.dlss.mobile_app
```

## 🎯 Development Workflow

### Typical Session
```bash
# Terminal 1: Start backend
cd ../backend
dotnet run --launch-profile=http

# Terminal 2: Start emulator
emulator -avd Pixel_4_API_30

# Terminal 3: Run Flutter app
cd mobile_app
flutter run

# In Flutter console:
r  → Hot reload during development
R  → Full restart when needed
q  → Quit app
```

### Git Workflow
```bash
git add .
git commit -m "feat: add task detail screen"
git push origin main
```

## ✅ Checklist Before Deployment

- [ ] Backend running and tested
- [ ] Emulator starts without errors
- [ ] App loads and authenticates
- [ ] Task list displays correctly
- [ ] Task details load and render
- [ ] Status badges show correct colors
- [ ] Accept/Start buttons work
- [ ] Error handling works (test with backend down)
- [ ] Loading states display properly
- [ ] No console errors or warnings
- [ ] Tests pass (`flutter test`)
- [ ] Code formatted (`dart format`)

---

**Troubleshooting Additional Resources:**
- Flutter Docs: https://flutter.dev/docs
- Android Emulator: https://developer.android.com/studio/run/emulator
- Dio Package: https://pub.dev/packages/dio
