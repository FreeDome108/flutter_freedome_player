# 🌐 FreeDome Player - Особенности платформ

## 📱 Android

### Поддерживаемые функции:
- ✅ **3D рендеринг**: Полная поддержка через OpenGL ES
- ✅ **AR функциональность**: ARCore интеграция
- ✅ **VR режим**: Google Cardboard/Daydream поддержка
- ✅ **Comics просмотр**: Оптимизированный для touch навигации
- ✅ **Boranko эффекты**: Квантовые анимации и Z-depth
- ✅ **Dome проекция**: HTTP подключение к FreeDome Engine
- ✅ **Сенсоры**: Гироскоп, акселерометр для VR
- ✅ **Файловая система**: Доступ к локальным и assets файлам

### Специфичные возможности:
- **Intent handling**: Открытие файлов из других приложений
- **Background processing**: Предзагрузка контента
- **Hardware acceleration**: GPU ускорение для 3D
- **Camera permissions**: Автоматический запрос для AR

### Тестирование на Android:
```bash
# Запуск на конкретном устройстве
flutter run -d 2fa17dc4

# Сборка APK для тестирования
flutter build apk --debug
flutter install --debug
```

## 🍎 iOS

### Поддерживаемые функции:
- ✅ **3D рендеринг**: Metal API оптимизация
- ✅ **AR функциональность**: ARKit нативная интеграция
- ✅ **VR режим**: Поддержка VR гарнитур
- ✅ **Comics просмотр**: iOS нативные жесты
- ✅ **Boranko эффекты**: Core Animation интеграция
- ✅ **Dome проекция**: Network.framework для HTTP
- ✅ **Сенсоры**: Core Motion для VR навигации
- ✅ **Файловая система**: iOS sandbox совместимость

### Специфичные возможности:
- **ARKit tracking**: Продвинутое отслеживание объектов
- **Metal Performance Shaders**: Ускорение квантовых эффектов
- **Core Haptics**: Тактильная обратная связь
- **AVAudioEngine**: Пространственное аудио

### Тестирование на iOS:
```bash
# Запуск на устройстве
flutter run -d ios

# Сборка для App Store тестирования
flutter build ios --release
```

## 🖥️ macOS

### Поддерживаемые функции:
- ✅ **3D рендеринг**: Metal API на macOS
- ❌ **AR функциональность**: Не поддерживается
- ⚠️ **VR режим**: Ограниченная поддержка
- ✅ **Comics просмотр**: Клавиатурная навигация
- ✅ **Boranko эффекты**: Core Animation
- ✅ **Dome проекция**: Нативная HTTP интеграция
- ✅ **Файловая система**: Полный доступ к файлам
- ✅ **FreeDome Engine**: Прямое подключение

### Специфичные возможности:
- **Menu bar integration**: Нативные меню
- **Drag & Drop**: Перетаскивание файлов
- **Multiple windows**: Поддержка нескольких окон
- **Keyboard shortcuts**: Горячие клавиши

### Клавиатурные сокращения:
- `Cmd+O`: Открыть файл
- `Space`: Воспроизведение/пауза
- `Cmd+F`: Полноэкранный режим
- `Cmd+I`: Информация о контенте
- `Cmd+D`: Отправить в купол

## 🪟 Windows

### Поддерживаемые функции:
- ✅ **3D рендеринг**: DirectX/OpenGL
- ❌ **AR функциональность**: Не поддерживается
- ⚠️ **VR режим**: Windows Mixed Reality
- ✅ **Comics просмотр**: Mouse и keyboard навигация
- ✅ **Boranko эффекты**: DirectX шейдеры
- ✅ **Dome проекция**: WinHTTP API
- ✅ **Файловая система**: Windows файловые диалоги
- ✅ **FreeDome Engine**: TCP/UDP подключения

### Специфичные возможности:
- **File associations**: Ассоциации с типами файлов
- **Windows notifications**: Системные уведомления
- **Registry integration**: Сохранение настроек
- **Windows Mixed Reality**: VR гарнитуры

## 🐧 Linux

### Поддерживаемые функции:
- ✅ **3D рендеринг**: OpenGL через GTK
- ❌ **AR функциональность**: Не поддерживается
- ⚠️ **VR режим**: OpenVR поддержка
- ✅ **Comics просмотр**: GTK нативные элементы
- ✅ **Boranko эффекты**: OpenGL шейдеры
- ✅ **Dome проекция**: libcurl HTTP
- ✅ **Файловая система**: POSIX API
- ✅ **FreeDome Engine**: Unix sockets

### Специфичные возможности:
- **Package managers**: .deb, .rpm пакеты
- **Desktop integration**: .desktop файлы
- **D-Bus**: Системная интеграция
- **Multiple distributions**: Ubuntu, Fedora, Arch совместимость

## 🌐 Web

### Поддерживаемые функции:
- ✅ **3D рендеринг**: WebGL через model_viewer_plus
- ❌ **AR функциональность**: WebXR (экспериментально)
- ❌ **VR режим**: WebVR (устарело)
- ✅ **Comics просмотр**: Canvas API
- ✅ **Boranko эффекты**: CSS анимации + Canvas
- ✅ **Dome проекция**: WebSocket/HTTP API
- ✅ **Файловая система**: File API
- ✅ **FreeDome Engine**: WebSocket подключения

### Специфичные возможности:
- **Progressive Web App**: PWA возможности
- **Service Workers**: Кеширование контента
- **WebAssembly**: Ускорение вычислений
- **WebGL 2.0**: Продвинутые шейдеры

### Браузерная совместимость:
- ✅ **Chrome**: Полная поддержка
- ✅ **Firefox**: Полная поддержка
- ✅ **Safari**: Ограниченная WebGL поддержка
- ⚠️ **Edge**: Частичная поддержка
- ❌ **IE**: Не поддерживается

## 🎮 Платформенные элементы управления

### Мобильные (Android/iOS):
- **Touch**: Tap, swipe, pinch-to-zoom
- **Gestures**: Multi-touch для 3D навигации
- **Sensors**: Гироскоп для VR режима
- **Haptic feedback**: Тактильная обратная связь

### Десктопные (macOS/Windows/Linux):
- **Mouse**: Click, drag, scroll wheel
- **Keyboard**: Горячие клавиши
- **File dialogs**: Нативные диалоги выбора файлов
- **Menu bars**: Нативные меню приложения

### Web:
- **Mouse + Keyboard**: Стандартные веб элементы
- **Touch**: Поддержка touch устройств
- **File upload**: Drag & drop файлов
- **Fullscreen API**: Полноэкранный режим

## 🔧 Настройка для каждой платформы

### Android permissions (android/app/src/main/AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-feature android:name="android.hardware.camera.ar" android:required="false" />
```

### iOS permissions (ios/Runner/Info.plist):
```xml
<key>NSCameraUsageDescription</key>
<string>AR functionality requires camera access</string>
<key>NSMicrophoneUsageDescription</key>
<string>Audio recording for VR experiences</string>
```

### macOS entitlements:
```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

---

**Все платформы настроены и готовы к тестированию!** 🎉
