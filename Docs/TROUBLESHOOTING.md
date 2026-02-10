# Устранение неполадок

## Требования к окружению

Для локальной сборки и CI необходимо:

- **macOS** — 12+
- **Xcode** — 14+ (рекомендуется 16.x)
- **Целевая версия iOS** — 16.0 (из Podfile)
- **Ruby** — 3.3+
- **Bundler** — для установки гемов
- **CocoaPods** — 1.16+

---

## Частые проблемы (Этап → Ошибка → Решение)

### Bundler — платформа не указана в lockfile

- **Этап:** `bundle install` (в CI, например в job сборки IPA).
- **Ошибка:**
  ```
  Your bundle only supports platforms ["x86_64-darwin"] but your local platform is
  arm64-darwin-23. Add the current platform to the lockfile with
  `bundle lock --add-platform arm64-darwin-23` and try again.
  Error: The process '.../bundle' failed with exit code 16
  ```
- **Решение:** На любой машине выполните `bundle lock --add-platform arm64-darwin-23`, закоммитьте обновлённый `Gemfile.lock`. При необходимости добавьте обе платформы: `bundle lock --add-platform x86_64-darwin` и `bundle lock --add-platform arm64-darwin-23`. После этого перезапустите workflow.

### Bundler — пустые CHECKSUMS в lockfile

- **Этап:** `bundle install` (в CI).
- **Ошибка:**
  ```
  Your lockfile has an empty CHECKSUMS entry for "rake", but can't be updated
  because frozen mode is set.
  ...
  Error: The process '.../bundle' failed with exit code 16
  ```
- **Решение:** Локально выполните `bundle lock --add-checksums` или `bundle install` (с доступом в сеть), закоммитьте обновлённый `Gemfile.lock`. В CI не отключайте frozen mode. Перезапустите workflow.

### CocoaPods / Xcodeproj — object version 70 или 71 (pod install / Generating Pods project)

- **Этап:** Локально **`bundle exec pod install`** или сборка IPA в CI (CocoaPods, «Generating Pods project»).
- **Ошибка:**
  ```
  ArgumentError - [Xcodeproj] Unable to find compatibility version string for object version `71`.
  ...
  [!] Oh no, an error occurred.
  ```
  (Аналогично для `70`.)
- **Причина:** Проект сохранён в Xcode в формате с object version 70/71, а гем xcodeproj (1.27.x), который использует CocoaPods, не знает эту версию и падает при генерации проекта Pods.
- **Решение:**
  1. Откройте в редакторе файл **`<ИмяПроекта>.xcodeproj/project.pbxproj`** (основной проект, например `IceVaultProject.xcodeproj` или `BaseProject.xcodeproj`) в корне проекта, где лежит Podfile.
  2. В начале файла найдите строку `objectVersion = 71;` (или `70`) и замените на **`objectVersion = 77;`**.
  3. Сохраните файл и снова выполните **`bundle exec pod install`** в корне проекта.

  Альтернатива: в Xcode откройте основной проект → выберите синюю иконку проекта в навигаторе → справа в File Inspector (⌘⌥1) в блоке **Project Document** выберите формат проекта, соответствующий Xcode 15/16 (если есть выбор). После этого при необходимости вручную поправьте `objectVersion` в `project.pbxproj` на `77`.

### CocoaPods — The sandbox is not in sync with the Podfile.lock

- **Этап:** Открытие проекта в Xcode, сборка (Build) или запуск приложения.
- **Ошибка:**
  ```
  The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.
  ```
- **Причина:** Папка `Pods` или файлы в ней не соответствуют версиям подов, зафиксированным в `Podfile.lock` (например, после клонирования репозитория, смены ветки или ручного изменения `Podfile`/`Podfile.lock`).
- **Решение:**
  1. В терминале перейдите в корень проекта (туда, где лежат `Podfile` и `Podfile.lock`).
  2. Выполните **`bundle exec pod install`** (при использовании Bundler в проекте — предпочтительно; иначе просто `pod install`).
  3. После успешного завершения снова соберите проект в Xcode (⌘B) или откройте workspace: **открывайте именно `.xcworkspace`**, а не `.xcodeproj`, иначе поды могут не подхватиться.

  Если ошибка не исчезает: выполните **`bundle exec pod deintegrate`**, затем снова **`bundle exec pod install`**. Убедитесь, что версия CocoaPods актуальна: **`bundle exec pod --version`** (рекомендуется 1.16+).

### Сборка — Framework 'AppsFlyerLib' not found (linker)

- **Этап:** Сборка приложения или расширения в Xcode (Link Binary With Libraries).
- **Ошибка:**
  ```
  Framework 'AppsFlyerLib' not found
  Linker command failed with exit code 1 (use -v to see invocation)
  ```
- **Причина:** Линкер не находит фреймворк AppsFlyer (под `AppsFlyerFramework` в Podfile). Чаще всего — сборка ведётся из `.xcodeproj` вместо `.xcworkspace`, либо кэш/настройки Xcode не соответствуют текущему состоянию подов.
- **Решение:**
  1. **Всегда открывайте проект через `.xcworkspace`** (например, `BaseProject.xcworkspace` или `IceVaultProject.xcworkspace`), а не через `.xcodeproj`. Иначе поды не участвуют в сборке.
  2. В терминале из **корня проекта** выполните **`bundle exec pod install`** (или `pod install`). Дождитесь сообщения «Pod installation complete».
  3. В Xcode: **Product → Clean Build Folder** (⇧⌘K), затем соберите снова (⌘B).
  4. Если ошибка остаётся: выполните **`bundle exec pod deintegrate`**, затем снова **`bundle exec pod install`**, закройте Xcode, откройте снова **`.xcworkspace`** и соберите проект.
  5. Убедитесь, что в **Build Settings** таргета, который падает (основное приложение или notifications), нет ручного **Other Linker Flags** с `-framework AppsFlyerLib` без корректного пути к подам; линковку обеспечивает CocoaPods через скрипт «Embed Pods Frameworks» и xcconfig.

### Xcode — в .xcworkspace виден только проект Pods, файлы основного проекта не отображаются

- **Ситуация:** Открыли `.xcworkspace`; в навигаторе слева виден проект **Pods**, но у основного проекта (BaseProject / IceVaultProject и т.п.) не видно папок и файлов (App, Core, Features и т.д.).
- **Причина:** Часто — некорректная или «сбитая» ссылка на основной проект в workspace, либо Xcode не подгрузил группы (в т.ч. File System Synchronized Root Groups).
- **Решение:**
  1. **Открывать workspace из корня проекта:** Закройте Xcode. В Finder откройте папку, где лежат `Podfile`, `Podfile.lock`, основной `.xcodeproj` и созданный CocoaPods'ом `.xcworkspace`. Дважды кликните именно по **`.xcworkspace`** (не по .xcodeproj), чтобы открыть проект из правильной директории.
  2. **Проверить основной проект в навигаторе:** В левой панели (Project Navigator) должен быть корень workspace, под ним — два проекта: основной (синяя иконка) и **Pods**. Кликните по **синей иконке основного проекта** (имя приложения). Разверните его — под ним должны быть группы (App, Core, Features, …). Если группы свёрнуты, раскройте треугольник слева от названия проекта.
  3. **Если основной проект отображается, но группы пустые или красные:** В меню Xcode: **File → Add Files to "<Имя workspace>"…** → выберите ваш **`.xcodeproj`** (он должен лежать в той же папке, что и .xcworkspace) → добавьте. Если проект уже есть в списке с восклицательным знаком или сломанной ссылкой, удалите его из workspace (правый клик → Delete, выбрать «Remove Reference»), затем снова добавьте через File → Add Files.
  4. **Проверить через .xcodeproj:** Закройте workspace и откройте **только** `.xcodeproj`. Если в нём все файлы видны — проблема в ссылке workspace на проект. Снова откройте `.xcworkspace` и при необходимости передобавьте основной проект по шагу 3.
  5. **Не перемещать .xcworkspace:** Файл `.xcworkspace` должен оставаться **в одной папке** с `.xcodeproj` и с папками App, Core, Features и т.д. Не копируйте только workspace в другое место — открывайте его из корня проекта.

### Сборка IPA — App Store Connect API key: invalid curve name

- **Этап:** Сборка IPA → lane Fastlane после CocoaPods (например, при использовании Match или шагов TestFlight, требующих ключ ASC).
- **Ошибка:**
  ```
  invalid curve name (OpenSSL::PKey::ECError)
  .../spaceship/lib/spaceship/connect_api/token.rb:71:in `initialize'
  ```
- **Решение:**
  1. В GitHub в настройках workflow ожидаются секреты с именами **`APPSTORE_KEY_ID`**, **`APPSTORE_ISSUER_ID`**, **`APPSTORE_P8`** (Settings → Secrets and variables → Actions). Если вы создали секреты `ASC_KEY_ID` / `ASC_KEY` и т.п., переменные окружения могут быть пустыми, и OpenSSL выдаст «invalid curve name».
  2. Убедитесь, что секреты называются именно: APPSTORE_KEY_ID, APPSTORE_ISSUER_ID, APPSTORE_P8 (либо что в workflow они маппятся в ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY).

### Сборка IPA — Match: ошибка клонирования репозитория сертификатов

- **Этап:** Сборка IPA → lane `build_for_testflight` → шаг **match** (клонирование репозитория с сертификатами).
- **Возможные ошибки (обе устраняются настройкой секретов и переменных):**

  1. **Пустой URL:**
     ```
     fatal: The empty string is not a valid path
     Error cloning certificates git repo...
     git clone '' ...
     ```
  2. **Репозиторий не найден (неверный формат URL):**
     ```
     fatal: repository 'YourOrg/YourProject-Certificates' does not exist
     ...
     ```

- **Решение:** В настройках репозитория GitHub **Settings → Secrets and variables → Actions** добавьте:

  1. **Секрет** `GH_PAT` — GitHub Personal Access Token с доступом на чтение к репозиторию Match.
  2. **Переменную** `MATCH_GIT_URL` — полный HTTPS-URL репозитория с сертификатами (например, `https://github.com/YourOrg/YourProject-Certificates.git`).  
     Короткий вид `owner/repo` в `fastlane/MatchFile` может нормализоваться в `https://github.com/owner/repo.git`; если ошибка «repository does not exist» остаётся — укажите полный URL и проверьте, что репозиторий существует и у `GH_PAT` есть к нему доступ.

  Без `MATCH_GIT_URL` (или при пустом значении) будет «empty string is not a valid path». Без `GH_PAT` клонирование не пройдёт по авторизации. После исправления перезапустите workflow.

### Сборка IPA — Match: '' is not a valid filter (Apple Developer Portal)

- **Этап:** Сборка IPA → lane `build_for_testflight` → шаг **match** (после клонирования репозитория, при проверке с Apple Developer Portal).
- **Ошибка:**
  ```
  An error occurred while verifying your certificates and profiles with the Apple Developer Portal.
  A parameter has an invalid value - '' is not a valid filter
  ```
  В выводе match может быть видно `app_identifier | ["", ".notifications"]` (первый элемент пустой).
- **Причина:** Переменные **`BUNDLE_IDENTIFIER`** и часто **`APPLE_TEAM_ID`** не заданы в репозитории, поэтому Match отправляет в API Apple пустой фильтр.
- **Решение:** В GitHub **Settings → Secrets and variables → Actions → Variables** задайте:
  - **`BUNDLE_IDENTIFIER`** — bundle ID приложения (например, `com.yourcompany.BaseProject`).
  - **`APPLE_TEAM_ID`** — Apple Team ID (10 символов).

  Убедитесь, что шаг сборки получает эти переменные (через `env` на уровне workflow или шага). Перезапустите workflow после добавления переменных.

### Сборка IPA — подпись не применена к основному таргету / отсутствует ipa_path.txt

- **Этап:** Сборка IPA → lane `build_for_testflight` (после Match, при `update_code_signing_settings` или «Prepare IPA for artifact»).
- **Ошибки:**
  - В выводе lane: `targets | []` (пусто), «None of the specified targets has been modified», затем Xcode падает с «No profile for team …» или «No Accounts».
  - На следующем шаге: `cat: ipa_path.txt: No such file or directory`.
- **Причина:** В репозитории не задана переменная **`XC_TARGET_NAME`**, поэтому lane не знает, к какому таргету применять настройки подписи, и путь к IPA может не записываться.
- **Решение:** В GitHub **Settings → Secrets and variables → Actions → Variables** добавьте переменную **`XC_TARGET_NAME`** со значением **`BaseProject`** (имя схемы и основного таргета приложения). Перезапустите workflow.

### Fastlane — Fastfile not found at lanes/ios

- **Этап:** Шаг CI, в котором запускается Fastlane (например, `bundle exec fastlane build_for_testflight`).
- **Ошибка:**
  ```
  [!] Could not find Fastfile at path '.../fastlane/./lanes/ios'
  Error: Process completed with exit code 1.
  ```
- **Решение:** В `fastlane/Fastfile` должен быть импорт с расширением: `import "./lanes/ios.rb"`. Запускайте Fastlane из корня репозитория; вызывайте lane по имени (например, `bundle exec fastlane build_for_testflight`), а не `fastlane ios ...`. В GitHub Actions для шага укажите `working-directory` на корень репозитория. Перезапустите workflow.

### Сборка IPA — Match: достигнут лимит Distribution-сертификатов

- **Этап:** Сборка IPA → lane `build_for_testflight` → шаг **match** (создание или проверка Distribution-сертификата в Apple).
- **Ошибка:**
  ```
  Could not create another Distribution certificate, reached the maximum number of available Distribution certificates.
  (Apple API: "You already have a current Distribution certificate or a pending certificate request.")
  ```
- **Причина:** В аккаунте Apple Developer исчерпан лимит Distribution-сертификатов для команды, либо уже есть текущий (или ожидающий) сертификат, а Match пытается создать ещё один.
- **Решение:** **Освободите слоты сертификатов в аккаунте Apple Developer.**  
  1. Откройте [Apple Developer Portal](https://developer.apple.com/account) → **Certificates, Identifiers & Profiles** → **Certificates**.  
  2. Найдите **Distribution** (Apple Distribution) сертификаты своей команды и **отзовите (Revoke)** те, которые больше не нужны (или были созданы для других приложений/команд). У Apple ограниченное число Distribution-сертификатов на команду (например, 3); отзыв освобождает слот.  
  3. При необходимости отзовите неиспользуемые **Development** сертификаты.  
  4. Если в git-репозитории Match уже есть рабочие сертификаты и профили для этого приложения, можно запускать Match в режиме **readonly**, чтобы не создавать новые сертификаты.  
  После отзыва перезапустите workflow. Для нового репозитория Match после очистки создаст новый Distribution-сертификат.

### IDE / Git — не отображаются изменения (например, в Rider)

- **Этап:** Локальная работа в Rider (или другой IDE) с VCS.
- **Ошибка:** Git не показывает изменения; корень репозитория определяется неверно.
- **Решение:** Открывайте в IDE родительскую папку (ту, в которой лежит проект), чтобы корнем был каталог с `.git`. Либо в Rider: Settings → Version Control → добавьте каталог с `.git` как VCS root. При необходимости выполните File → Synchronize или Invalidate Caches / Restart.

---

## CI (GitHub Actions)

**Секреты** (Settings → Secrets and variables → Actions → Secrets; имена должны совпадать с теми, что ожидает workflow):

- `APPSTORE_KEY_ID` — ID ключа App Store Connect API (в env как ASC_KEY_ID)
- `APPSTORE_ISSUER_ID` — issuer ID App Store Connect (в env как ASC_ISSUER_ID)
- `APPSTORE_P8` — содержимое .p8 ключа App Store Connect, **в Base64** (в env как ASC_KEY)
- `GH_PAT` — GitHub PAT для доступа к репозиторию Match
- `MATCH_PASSWORD` — пароль для сертификатов Match. **Необязательно:** если не задан, используется пустой пароль; это возможно только если репозиторий Match был создан (или перешифрован) с пустым паролем.

**Переменные** (Settings → Secrets and variables → Actions → Variables):

- `APPLE_TEAM_ID`
- `BUNDLE_IDENTIFIER`
- **`XC_TARGET_NAME`** — **обязательна.** Установите значение **`BaseProject`** (имя схемы и основного таргета приложения). При отсутствии или пустом значении job сборки IPA может завершиться с ошибкой: подпись не применится к основному таргету (`targets | []`) и может отсутствовать `ipa_path.txt`. См. подраздел выше.
- `MATCH_GIT_URL` — URL репозитория сертификатов Match
- `LAST_UPLOADED_BUILD_NUMBER` — последний загруженный номер сборки (обновляется после загрузки)
- `APPLE_APP_ID` — числовой Apple ID приложения (для upload_to_testflight)

---

## Прочее

### Сборка и подпись

*(Добавляйте сюда конкретные ошибки и решения по мере появления: этап → ошибка → решение.)*

### Загрузка в TestFlight

*(Добавляйте сюда конкретные ошибки и решения по мере появления: этап → ошибка → решение.)*

### Match / сертификаты

- **Пустой пароль (секрет MATCH_PASSWORD не задан):** В lane задаётся `MATCH_PASSWORD = ""`, и применяется патч, чтобы гем Match принимал пустой пароль при шифровании. Расшифровка и шифрование сработают только если репозиторий сертификатов был создан с пустым паролем (например, `fastlane match appstore` и Enter при запросе пароля). Чтобы перевести существующий репозиторий на пустой пароль: `fastlane match change_password` и укажите новый пароль пустым. Секрет `MATCH_PASSWORD` в GitHub Actions можно не задавать.

*(Добавляйте другие ошибки и решения по мере появления.)*

### Firebase / GoogleService

*(Добавляйте сюда конкретные ошибки и решения по мере появления: этап → ошибка → решение.)*
