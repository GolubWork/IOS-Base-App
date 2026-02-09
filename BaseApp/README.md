# LaughingDrops

iOS приложение для трекинга потребления воды с интеграцией веб-контента и аналитики.

## Описание

LaughingDrops — приложение для отслеживания ежедневного потребления воды с функциями:
- Трекинг воды с визуальным прогрессом
- Календарь истории потребления
- Графики статистики
- Достижения и мотивация
- Push-уведомления
- Веб-интеграция
- AppsFlyer аналитика
- Firebase Remote Config

## Технологии

- SwiftUI — UI фреймворк
- Firebase — Core, Messaging, RemoteConfig
- AppsFlyer — аналитика и атрибуция
- CocoaPods — менеджер зависимостей
- Fastlane — автоматизация CI/CD
- GitHub Actions — CI/CD

## Требования

- macOS 12.0+
- Xcode 14.0+
- iOS 11.0+
- Ruby 3.3+
- CocoaPods 1.15.2+

## Установка

### 1. Клонирование

```bash
git clone <repository-url>
cd Laughingdrops
```

### 2. Установка зависимостей

```bash
bundle install
pod install
```

**Важно:** CocoaPods зависимости устанавливаются автоматически через Fastlane при запуске CI/CD.

### 3. Настройка

1. Откройте `LaughingDrops.xcworkspace` (не `.xcodeproj`)
2. Добавьте `GoogleService-Info.plist` в корень проекта
3. Проверьте настройки в `AppConfig.swift`

### 4. Запуск

```bash
# Через Xcode: ⌘ + R
# Или через командную строку:
xcodebuild -workspace LaughingDrops.xcworkspace -scheme LaughingDrops build
```

## Структура проекта

```
LaughingDrops/
├── App/                  # Точка входа и делегаты
├── Game/                 # Основные экраны (WaterTracker, Calendar, Charts, Achievements)
├── Services/             # API, AppsFlyer, Firebase
├── ViewModels/           # AppViewModel
├── Views/                # UI компоненты
├── Utils/                # Логирование, хелперы
└── AppConfig.swift       # Конфигурация

notifications/            # Notification Extension
fastlane/                 # CI/CD конфигурация
```

## CI/CD

### GitHub Actions

Автоматический деплой через GitHub Actions (`.github/workflows/ios_single_flow.yml`).

**Процесс:**
1. Checkout кода
2. Установка Xcode 16.3 и Ruby 3.3
3. Установка CocoaPods (через Fastlane)
4. Синхронизация сертификатов (Match)
5. Сборка и загрузка в TestFlight

### Необходимые переменные

**Secrets:**
- `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY` — App Store Connect API
- `GH_PAT` — GitHub PAT для Match
- `MATCH_PASSWORD` — пароль сертификатов

**Variables:**
- `APPLE_TEAM_ID`, `BUNDLE_IDENTIFIER`, `XC_TARGET_NAME`
- `MATCH_GIT_URL` — репозиторий с сертификатами
- `LAST_UPLOADED_BUILD_NUMBER`

### Локальный деплой

```bash
# 1. Установите переменные окружения (см. выше)
# 2. Настройте Match (первый раз)
bundle exec fastlane match appstore

# 3. Деплой
bundle exec fastlane ios build_upload_testflight
```

## Конфигурация

### AppConfig.swift

```swift
let serverURL: String = "https://laughingdropspop.com/config.php"
let storeId: String = "6756708872"
let firebaseProjectId: String = "662865312172"
let appsFlyerDevKey: String = "zjmEk65LDPa3K8s4BWnpfA"
```

### Debug флаги

```swift
let isDebug: Bool = false           // Режим отладки
let isGameOnly: Bool = true         // Только игра (без веб)
let isWebOnly: Bool = false         // Только веб (без игры)
let isNoNetwork: Bool = false       // Симуляция отсутствия сети
```

## Зависимости

- `AppsFlyerFramework` — аналитика
- `Firebase/Core` — Firebase
- `Firebase/Messaging` — push-уведомления
- `Firebase/RemoteConfig` — удаленная конфигурация

Установка: `pod install` (или автоматически через Fastlane)

## Troubleshooting

### Ошибка: `no such module 'AppsFlyerLib'`

**Решение:**
```bash
pod install
# Открывайте .xcworkspace, а не .xcodeproj
```

### Ошибка: `ARCHIVE FAILED` в CI/CD

**Возможные причины:**
- Отсутствующие зависимости CocoaPods
- Неверные GitHub Secrets (Match, App Store Connect)
- Истекший `GH_PAT`
- Проблемы с сертификатами

**Решение:**
1. Проверьте GitHub Secrets и Variables
2. Убедитесь, что Match репозиторий доступен
3. Проверьте логи на ошибки

### Code Signing ошибки

```bash
bundle exec fastlane match appstore --force
```

### Firebase не работает

1. Проверьте наличие `GoogleService-Info.plist` в проекте
2. Убедитесь, что файл добавлен в Target Membership
3. Проверьте APNs сертификаты в Firebase Console

## Полезные ссылки

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Firebase iOS SDK](https://firebase.google.com/docs/ios/setup)
- [AppsFlyer iOS SDK](https://dev.appsflyer.com/hc/docs/ios-sdk-reference-appsflyerlib)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [iOS Code Signing](https://docs.fastlane.tools/codesigning/getting-started/)


