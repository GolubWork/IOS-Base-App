# BaseProject

Базовый шаблон iOS-приложения на SwiftUI с веб-интеграцией, аналитикой и заготовкой под игровой режим. Сборка и деплой через Fastlane и GitHub Actions. Используйте этот репозиторий как стартовую точку для своего проекта (YourProject).

## Возможности

- **Старт приложения:** первый запуск, загрузка, проверка сети, запрос push-уведомлений
- **Режим Game:** экран-заглушка для вашего контента (игры, табы и т.д.)
- **Веб-режим:** отображение контента по URL
- **Инфраструктура:** AppsFlyer, Firebase (Core, Messaging, Remote Config), push-токены, Match (подпись)

## Стек

- **SwiftUI** — UI
- **Firebase** — Core, Messaging, Remote Config
- **AppsFlyer** — аналитика и атрибуция
- **CocoaPods** — зависимости
- **Fastlane** — сборка и загрузка в TestFlight
- **GitHub Actions** — CI

## Требования

- macOS 12+
- Xcode 14+ (рекомендуется 16.x)
- iOS 16.0+ (деплой таргет из Podfile)
- Ruby 3.3+
- Bundler, CocoaPods 1.16+

## Установка

```bash
git clone <repository-url>
cd <имя-репозитория>
bundle install
bundle exec pod install
```

Открыть **`BaseProject.xcworkspace`** (не `.xcodeproj`; workspace создаётся после `pod install`). Добавить `GoogleService-Info.plist` в корень проекта при использовании Firebase.

Конфигурация сборки: `App/BuildConfiguration.swift`, xcconfig в `Resources/Configurations/` (Debug, Staging, Release).

## Запуск

В Xcode: схема **BaseProject** → Run (⌘R).  
Или из терминала:

```bash
xcodebuild -workspace BaseProject.xcworkspace -scheme BaseProject -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Архитектура

Clean Architecture: зависимости направлены к Domain, слой Domain не зависит от UI и конкретных реализаций.

- **Domain** (Core/Domain, Features/*/Domain): сущности, протоколы репозиториев и use cases
- **Data** (Core/Data, Features/*/Data): реализации репозиториев и data sources
- **Presentation** (Core/Presentation, Features/*/Presentation): ViewModels и Views
- **Infrastructure**: конфигурация, DI (`DependencyContainer`), логгер

Контейнер зависимостей создаётся в **AppDelegate** при старте и передаётся в SwiftUI через `environment(\.dependencyContainer, container)`. Тесты могут подменить контейнер через `AppDependencies.containerForTesting` до запуска приложения.

Подробно: [Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md). Как расширять проект: [Docs/EXTENDING.md](Docs/EXTENDING.md).

## Структура проекта

```
<корень репозитория>/
├── App/                    # Точка входа: BaseProject, AppDelegate, AppDependencies, BuildConfiguration
├── Core/                   # Общий Domain, Data, Presentation
│   ├── Domain/
│   ├── Data/
│   └── Presentation/       # RootView, LoadingView, MainTabView, GameWindow, WebWindow, экраны ошибок
├── Features/
│   ├── AppInitialization/  # Инициализация (use case, состояние приложения)
│   ├── Analytics/         # AppsFlyer
│   ├── Networking/        # Server API
│   ├── Notifications/     # FCM, push-токены
│   └── WebView/           # Протоколы веб-контента
├── Infrastructure/        # Configuration, DI, Logging, OrientationLock
├── Resources/             # Assets, xcconfig, Preview Content
├── BaseProject.xcodeproj/  # Файлы проекта Xcode
├── fastlane/
│   ├── Fastfile           # Точка входа: before_all, import лейнов
│   ├── lanes/ios.rb       # Лейны: build_for_testflight, upload_testflight_only, build_upload_testflight
│   └── MatchFile          # Match (git_url, app_identifier)
├── notifications/         # Notification Service Extension
└── .github/workflows/     # iOS: full build+upload, build-only
```

## CI/CD

Два workflow (ручной запуск: workflow_dispatch):

1. **`ios_single_flow.yml`** — полный цикл: сборка IPA (match, подпись) и загрузка в TestFlight. Этапы разнесены по jobs, чтобы при падении загрузки можно было перезапустить только job «Upload to TestFlight».
2. **`ios_build_only.yml`** — только сборка IPA (без загрузки); артефакт с IPA доступен в run.

Перезапуск: в Actions → выбранный run → **Re-run job** для нужного job.

### Secrets (GitHub → Settings → Secrets and variables → Actions)

- `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY` — App Store Connect API
- `GH_PAT` — GitHub PAT для доступа к репозиторию Match
- `MATCH_PASSWORD` — пароль для сертификатов Match

### Variables

- `APPLE_TEAM_ID`, `BUNDLE_IDENTIFIER`, `XC_TARGET_NAME` (для основного таргета — **BaseProject**)
- `MATCH_GIT_URL` — репозиторий с сертификатами (git)
- `LAST_UPLOADED_BUILD_NUMBER` — последний загруженный номер сборки (обновляется после успешного upload)
- `APPLE_APP_ID` — числовой Apple ID приложения (для upload_to_testflight)

### Локальный деплой

```bash
# Переменные окружения должны быть заданы (см. выше)
bundle exec fastlane match appstore   # при первой настройке
bundle exec fastlane ios build_upload_testflight
```

Отдельные этапы:  
`build_for_testflight` — только сборка (пишет `ipa_path.txt`, `build_number.txt`);  
`upload_testflight_only` — загрузка по пути к IPA (опция `ipa_path:` или `ENV["IPA_PATH"]`).

## Конфигурация приложения

- **BuildConfiguration** (`App/BuildConfiguration.swift`): текущая конфигурация (Debug/Staging/Release).
- **AppConfiguration** (`Infrastructure/Configuration/`): URL сервера, Store ID, Firebase, AppsFlyer — из Info.plist (xcconfig → `INFOPLIST_KEY_*`). Секреты не хранить в коде; в CI — через Variables/Secrets.
- **xcconfig:** `Resources/Configurations/Debug.xcconfig`, `Staging.xcconfig`, `Release.xcconfig`.

## Зависимости (CocoaPods)

- `AppsFlyerFramework`
- `Firebase/Core`, `Firebase/Messaging`, `Firebase/RemoteConfig`

Установка: `bundle exec pod install`. Gemfile: Fastlane + CocoaPods + xcodeproj (для лейнов и подов).

## Частые проблемы

- **Нет модуля AppsFlyer / Firebase** — открыть `BaseProject.xcworkspace`, выполнить `bundle exec pod install`.
- **Ошибки подписи в CI** — проверить Secrets/Variables, доступ к репозиторию Match, при необходимости пересоздать сертификаты: `bundle exec fastlane match appstore --force`.
- **Firebase не инициализируется** — проверить наличие и Target Membership у `GoogleService-Info.plist`, настройки в Firebase Console и APNs.
- **IDE / Git не показывает изменения** — открыть проект от корня репозитория (где лежит `.git`). Подробнее: [Docs/TROUBLESHOOTING.md](Docs/TROUBLESHOOTING.md).

## Ссылки

- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [Firebase iOS](https://firebase.google.com/docs/ios/setup)
- [AppsFlyer iOS](https://dev.appsflyer.com/hc/docs/ios-sdk-reference-appsflyerlib)
- [Fastlane](https://docs.fastlane.tools/)
- [Code Signing (Fastlane)](https://docs.fastlane.tools/codesigning/getting-started/)
