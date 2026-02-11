# Руководство по расширению проекта

Это пошаговое руководство описывает, как добавлять новый функционал в BaseProject вручную: без использования ИИ и без обязательного использования командной строки (кроме установки зависимостей). Все шаги можно выполнить в Xcode и проводнике (Finder).

---
1. Сделайте дубликат проекта и работайте в нем, либо создайте новую ветку в гите и запуште проект туда


## 1. Убедиться, что в проекте два таргета (основное приложение и Notification)

Перед расширением проекта проверьте, что в Xcode в навигаторе проекта (левая панель) в секции **TARGETS** отображаются **два таргета**:

1. **BaseProject** — основное приложение (иконка приложения).
2. **notifications** — расширение для уведомлений (иконка колокольчика).

Если одного из таргетов нет, добавьте его через File → New → Target… (например, Notification Service Extension для таргета notifications).

![Таргеты проекта: BaseProject и notifications](images/project-targets.png)

---

## 2. Signing: Team и Bundle Identifier (основное приложение и Notification)

Для сборки и установки приложения на устройство или отправки в App Store нужно настроить подпись (Signing) для **обоих** таргетов: указать **Team** и **Bundle Identifier**.

### Таргет BaseProject (основное приложение)

1. В левой панели Xcode выберите таргет **BaseProject** (в секции TARGETS).
2. Откройте вкладку **General**
3. В поле **Display Name** укажите отображаемое имя приложения
4. В поле **Bundle Identifier** укажите идентификатор приложения
5. Откройте вкладку **Signing & Capabilities**.
6. Включите **Automatically manage signing**.
7. В поле **Team** выберите вашу команду разработки (Apple Developer account).
8. В поле **Bundle Identifier** укажите идентификатор приложения (например, `com.yourcompany.yourapp`).

![Signing для таргета BaseProject: Team и Bundle Identifier](images/signing-baseproject-1.png)
![Signing для таргета BaseProject: Team и Bundle Identifier](images/signing-baseproject.png)

### Таргет notifications (расширение уведомлений)

1. В левой панели выберите таргет **notifications** (в секции TARGETS).
2. Откройте вкладку **Signing & Capabilities**.
3. Включите **Automatically manage signing**.
4. В поле **Team** выберите **ту же команду**, что и для BaseProject.
5. В поле **Bundle Identifier** укажите идентификатор расширения — он должен быть **поддоменом** основного приложения (например, `com.yourcompany.yourapp.notifications`).

![Signing для таргета notifications: Team и Bundle Identifier](images/signing-notifications.png)

Если после настройки Xcode показывает предупреждения о provisioning profile (например, «No profiles for '…' were found» или «Your team has no devices»), 
это нормально, ничего не делаем.
---

## 3. Переименование проекта и таргета

### Переименование названия проекта

1. В **Project Navigator** (левая панель) один раз кликни по иконке проекта (синяя иконка с именем, например BaseProject), чтобы выделить сам проект, а не таргет.
2. Справа в окне (Inspector) поменяй имя в поле **Name** в секции Identity and Type.
3. Xcode спросит: *"Rename project content items?"* — лучше выбрать **Rename**, чтобы заодно переименовались папка, схема и т.п.

![Rename: Project](images/rename-project.png)

### Переименование таргета

1. В **Project Navigator** в секции **TARGETS** выбери нужный таргет (например, BaseProject или notifications).
2. Один раз кликни по нему, затем ещё раз медленно кликни по имени (или нажми Enter) — имя станет редактируемым.
3. Введи новое имя и нажми **Enter**.

### Переименование Sheme

Дополнить


### Синхронизация подов после переименования

После переименования проекта или таргета нужно обновить поды, чтобы sandbox совпадал с `Podfile.lock`:

1. Закройте проект
2. Откройте ваш проект `.xcodeproj` при помощи вашей IDE (не xcode)
3. Замените поле objectVersion = XX на objectVersion = 77, сохраните, закройте

![Pod Install-stage-1](images/install-stage-1.png)
4. Откройте терминал и перейдите в **корень проекта** (папка, где лежат `Podfile`, `Podfile.lock` и `.xcodeproj`).

![Pod Install-stage-2](images/install-stage-2.png)
5. Выполните **`bundle exec pod install`** (если в проекте используется Bundler; иначе — `pod install`).

![Pod Install-stage-3](images/install-stage-3.png)
6. После успешного завершения откройте в Xcode файл **`.xcworkspace`** (а не `.xcodeproj`) и соберите проект.

![Pod Install-stage-4](images/install-stage-4.png)


Это обязательный этап после переименования: без него сборка может завершиться с ошибкой *"The sandbox is not in sync with the Podfile.lock"* (подробнее см. [TROUBLESHOOTING.md](TROUBLESHOOTING.md)).

---

## 4. Где что лежит

| Что добавлять | Куда класть |
|---------------|-------------|
| Новая бизнес-сущность (модель данных) | `Features/<ИмяФичи>/Domain/Entities/` или `Core/Domain/Entities/` |
| Протокол репозитория или use case | `Features/<ИмяФичи>/Domain/` или `Core/Domain/` |
| Реализация репозитория, работа с сетью/БД | `Features/<ИмяФичи>/Data/` или `Core/Data/` |
| ViewModel и экраны (SwiftUI) | `Features/<ИмяФичи>/Presentation/` или `Core/Presentation/` |
| Регистрация зависимостей (DI) | `Infrastructure/DI/DependencyContainer.swift`, `App/AppDependencies.swift` |
| Конфигурация (URL, ключи) | `Infrastructure/Configuration/`, xcconfig в `Resources/Configurations/` |

Правило: **Domain** не знает о UI и о конкретных реализациях. **Data** реализует протоколы из Domain. **Presentation** использует только протоколы (use cases, репозитории), которые передаются через контейнер зависимостей.

### 4.1. Заполнение полей в Resources/Configurations

Параметры сборки (URL сервера, идентификаторы магазина, Firebase, AppsFlyer и т.п.) задаются в xcconfig-файлах в папке **`Resources/Configurations/`**: `Debug.xcconfig`, `Staging.xcconfig`, `Release.xcconfig`. Значения из xcconfig подставляются в Build Settings и через `INFOPLIST_KEY_*` — в Info.plist; приложение читает их через `AppConfiguration` (см. `Infrastructure/Configuration/AppConfiguration.swift`).

**Что заполнить в каждом xcconfig (подставьте свои значения):**

| Переменная | Описание |
|------------|----------|
| `SERVER_URL` | URL конфигурационного сервера (например, `https://your-server.com/config.php`) |
| `STORE_ID` | Идентификатор приложения в App Store (числовой, без префикса `id`) |
| `FIREBASE_PROJECT_ID` | Идентификатор проекта Firebase |
| `APPSFLYER_DEV_KEY` | Dev Key из кабинета AppsFlyer |

В каждом файле уже есть строки для подстановки в Info.plist:

```
INFOPLIST_KEY_SERVER_URL = $(SERVER_URL)
INFOPLIST_KEY_STORE_ID = $(STORE_ID)
INFOPLIST_KEY_FIREBASE_PROJECT_ID = $(FIREBASE_PROJECT_ID)
INFOPLIST_KEY_APPSFLYER_DEV_KEY = $(APPSFLYER_DEV_KEY)
```

Их не нужно удалять: они передают значения в Bundle, откуда их читает `AppConfiguration`.

### 4.2. Замена GoogleService-Info.plist

В корне проекта лежит **`GoogleService-Info.plist`** — конфигурация Firebase (Cloud Messaging для push-уведомлений, Analytics и т.д.). 
В базовом репозитории он содержит данные примера; при создании своего приложения его нужно удалить этот и добавить ваш.

---

## 5. Пример: добавление фичи «Менеджер паролей» (PasswordManager)

Ниже — полный цикл добавления фичи генератора и хранилища паролей: сущность, репозиторий, use cases (включая удаление), экраны генерации и списка. В примере сразу заложена базовая доработка UI: экран **Generator** — слайдер длины 4–32, чекбоксы «С цифрами / заглавными / малыми буквами», контент по центру; экран **Passwords** — название и сам сохранённый пароль в каждой ячейке и кнопка удаления. Команды в терминале приведены только там, где без них не обойтись (установка подов); остальное делается в Xcode.

### Шаг 1. Создать папки для фичи

1. В Finder откройте корень проекта (там, где лежат папки `App`, `Core`, `Features`).
2. В папке `Features` создайте папку `PasswordManager`.
3. Внутри `PasswordManager` создайте папки: `Domain`, `Data`, `Presentation`.
4. При необходимости внутри `Domain` создайте подпапку `Entities`.

В итоге структура должна быть такой:

```
Features/
  PasswordManager/
    Domain/       (здесь — протоколы, сущности и use cases)
    Data/         (здесь — реализация репозитория и локальное хранение)
    Presentation/ (здесь — ViewModel и экраны)
```

### Шаг 2. Domain: сущность и протоколы

1. В Xcode в навигаторе откройте `Features` → `PasswordManager` → `Domain`.
2. File → New → EmptyFile… → Имя: `Password.swift`. Сохраните в `Features/PasswordManager/Domain/`.
3. Опишите сущность, репозиторий и все use cases в одном файле (или разбейте на отдельные файлы):

```swift
import Foundation

/// Domain entity for a saved password record.
struct Password: Equatable {
    let id: UUID
    var title: String
    var value: String
    var createdAt: Date
}
```
```swift
import Foundation

/// Repository protocol for passwords. Domain layer only; implementation is in Data.
protocol PasswordRepositoryProtocol: AnyObject {
    func getAll() async throws -> [Password]
    func save(_ password: Password) async throws
    func delete(id: UUID) async throws
}
```

```swift
import Foundation

/// Use case: generate password with separate flags for digits, uppercase, lowercase.
protocol GeneratePasswordUseCaseProtocol {
    func execute(length: Int, useDigits: Bool, useUppercase: Bool, useLowercase: Bool) -> String
}
```

```swift
import Foundation

/// Use case: save a password.
protocol SavePasswordUseCaseProtocol {
    func execute(title: String, value: String) async throws
}
```

```swift
import Foundation

/// Use case: get all saved passwords.
protocol GetPasswordsUseCaseProtocol {
    func execute() async throws -> [Password]
}
```

```swift
import Foundation

/// Use case: delete a saved password.
protocol DeletePasswordUseCaseProtocol {
    func execute(id: UUID) async throws
}
```

### Шаг 3. Data: реализация репозитория и use cases

1. Путь: `Features/PasswordManager/Data/`.
2. File → New → EmptyFile… → Имя: `PasswordLocalDataSource.swift`. Реализуйте хранение (например, в памяти или UserDefaults/Keychain):

```swift
import Foundation

/// Local storage for passwords. In production consider Keychain.
final class PasswordLocalDataSource {
    private var items: [Password] = []

    func getAll() -> [Password] { items }
    func save(_ password: Password) { items.append(password) }
    func delete(id: UUID) { items.removeAll { $0.id == id } }
}
```

3. Создайте файл `PasswordRepository.swift` в той же папке — реализация протокола из Domain:

```swift
import Foundation

final class PasswordRepository: PasswordRepositoryProtocol {
    private let dataSource: PasswordLocalDataSource

    init(dataSource: PasswordLocalDataSource) {
        self.dataSource = dataSource
    }

    func getAll() async throws -> [Password] {
        dataSource.getAll()
    }

    func save(_ password: Password) async throws {
        dataSource.save(password)
    }

    func delete(id: UUID) async throws {
        dataSource.delete(id: id)
    }
}
```

4. Реализуйте use cases в `Features/PasswordManager/Data/` — отдельные файлы: 
5. `GeneratePasswordUseCase.swift`, `SavePasswordUseCase.swift`, `GetPasswordsUseCase.swift`, `DeletePasswordUseCase.swift`:

**GeneratePasswordUseCase.swift:**

```swift
import Foundation

final class GeneratePasswordUseCase: GeneratePasswordUseCaseProtocol {
    func execute(length: Int, useDigits: Bool, useUppercase: Bool, useLowercase: Bool) -> String {
        var charset = ""
        if useLowercase { charset += "abcdefghijklmnopqrstuvwxyz" }
        if useUppercase { charset += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
        if useDigits { charset += "0123456789" }
        if charset.isEmpty { charset = "abcdefghijklmnopqrstuvwxyz" }
        return String((0..<length).compactMap { _ in charset.randomElement() })
    }
}
```

**SavePasswordUseCase.swift:**

```swift
import Foundation

final class SavePasswordUseCase: SavePasswordUseCaseProtocol {
    private let repository: PasswordRepositoryProtocol
    init(repository: PasswordRepositoryProtocol) { self.repository = repository }
    func execute(title: String, value: String) async throws {
        let password = Password(id: UUID(), title: title, value: value, createdAt: Date())
        try await repository.save(password)
    }
}
```

**GetPasswordsUseCase.swift** 

```swift
import Foundation

final class GetPasswordsUseCase: GetPasswordsUseCaseProtocol {
    private let repository: PasswordRepositoryProtocol
    init(repository: PasswordRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> [Password] {
        try await repository.getAll()
    }
}
```

**DeletePasswordUseCase.swift:**

```swift
import Foundation

final class DeletePasswordUseCase: DeletePasswordUseCaseProtocol {
    private let repository: PasswordRepositoryProtocol
    init(repository: PasswordRepositoryProtocol) { self.repository = repository }
    func execute(id: UUID) async throws { try await repository.delete(id: id) }
}
```

### Шаг 4. Presentation: ViewModel и экраны

1. В `Features/PasswordManager/Presentation/` создайте `PasswordGeneratorViewModel.swift` (слайдер длины 4–32, чекбоксы «С цифрами / заглавными / малыми», контент по центру):

```swift
import Foundation
import Combine

@MainActor
final class PasswordGeneratorViewModel: ObservableObject {
    @Published var generatedPassword: String = ""
    @Published var title: String = ""
    @Published private(set) var errorMessage: String?
    @Published var length: Double = 16
    @Published var useDigits = true
    @Published var useUppercase = true
    @Published var useLowercase = true

    private let generateUseCase: GeneratePasswordUseCaseProtocol
    private let saveUseCase: SavePasswordUseCaseProtocol

    init(generateUseCase: GeneratePasswordUseCaseProtocol, saveUseCase: SavePasswordUseCaseProtocol) {
        self.generateUseCase = generateUseCase
        self.saveUseCase = saveUseCase
    }

    func generate() {
        let len = Int(length)
        generatedPassword = generateUseCase.execute(length: len, useDigits: useDigits, useUppercase: useUppercase, useLowercase: useLowercase)
    }

    func save() async {
        guard !title.isEmpty, !generatedPassword.isEmpty else { return }
        errorMessage = nil
        do {
            try await saveUseCase.execute(title: title, value: generatedPassword)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

2. Создайте `PasswordListViewModel.swift` (список с возможностью удаления):

```swift
import Foundation
import Combine

@MainActor
final class PasswordListViewModel: ObservableObject {
    @Published private(set) var passwords: [Password] = []
    @Published private(set) var isLoading = false
    private let getPasswordsUseCase: GetPasswordsUseCaseProtocol
    private let deletePasswordUseCase: DeletePasswordUseCaseProtocol

    init(getPasswordsUseCase: GetPasswordsUseCaseProtocol, deletePasswordUseCase: DeletePasswordUseCaseProtocol) {
        self.getPasswordsUseCase = getPasswordsUseCase
        self.deletePasswordUseCase = deletePasswordUseCase
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        passwords = (try? await getPasswordsUseCase.execute()) ?? []
    }

    func delete(id: UUID) async {
        do {
            try await deletePasswordUseCase.execute(id: id)
            await load()
        } catch { }
    }
}
```

3. Создайте SwiftUI-экраны `PasswordGeneratorView.swift` и `PasswordListView.swift` в той же папке (генератор: слайдер 4–32, Toggle для цифр/заглавных/малых, контент по центру; список: название, пароль с копированием по нажатию, кнопка удаления — см. шаг 4.1). 
4. **Базовый подход к фону в режиме игры:** фон `gameBackground` рисуется **внутри каждого экрана** (ZStack с картинкой снизу и контентом сверху), а не в RootView; у List — `.scrollContentBackground(.hidden)` и `.listRowBackground(Color.clear)`:

```swift
import SwiftUI
import UIKit

struct PasswordGeneratorView: View {
    @StateObject private var viewModel: PasswordGeneratorViewModel

    init(viewModel: PasswordGeneratorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                    Text(viewModel.generatedPassword.isEmpty ? "Нажмите «Сгенерировать»" : viewModel.generatedPassword)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    TextField("Название", text: $viewModel.title)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)

                    Text("Длина: \(Int(viewModel.length))")
                        .font(.subheadline)
                    Slider(value: $viewModel.length, in: 4...32, step: 1)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        CheckboxRow(title: "С цифрами", isOn: $viewModel.useDigits)
                        CheckboxRow(title: "С заглавными буквами", isOn: $viewModel.useUppercase)
                        CheckboxRow(title: "С малыми буквами", isOn: $viewModel.useLowercase)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 12) {
                        Button("Сгенерировать") { viewModel.generate() }
                        Button("Сохранить") { Task { await viewModel.save() } }
                    }
                if let msg = viewModel.errorMessage {
                    Text(msg).foregroundStyle(.red).font(.caption)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Checkbox row
private struct CheckboxRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: isOn ? "checkmark.square.fill" : "square")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(isOn ? Color.accentColor : Color.primary)
                .frame(width: 28, height: 28)
            Text(title)
                .font(.system(size: 17))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 44)
        .contentShape(Rectangle())
        .onTapGesture {
            isOn.toggle()
        }
    }
}

```

```swift
import SwiftUI
import UIKit

struct PasswordListView: View {
    @StateObject private var viewModel: PasswordListViewModel

    init(viewModel: PasswordListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.passwords, id: \.id) { p in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(p.title)
                        .font(.headline)
                    Text(p.value)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIPasteboard.general.string = p.value
                        }
                }
                Spacer()
                Button(role: .destructive) {
                    Task { await viewModel.delete(id: p.id) }
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .task { await viewModel.load() }
    }
}

```

### Шаг 4.1. Функционал экрана Passwords: копирование и удаление

В экране списка паролей (Passwords) заложено два действия:

- **Нажатие на пароль** — строка с паролем копируется в буфер обмена (clipboard). Пользователь может вставить пароль в другое приложение или поле (например, в браузере или форме входа). Реализация: у `Text(p.value)` добавлен `.onTapGesture { UIPasteboard.general.string = p.value }`; для корректной области нажатия используется `.contentShape(Rectangle())`. В начале файла с View нужен `import UIKit` (для `UIPasteboard`).
- **Нажатие на красную кнопку «мусорки»** — соответствующий пароль удаляется из хранилища, список обновляется. Реализация: кнопка с `Image(systemName: "trash")` и `role: .destructive` вызывает `viewModel.delete(id: p.id)`.

Итого: по нажатию на сам пароль — копирование, по нажатию на иконку корзины — удаление.

### Шаг 5. DI: зарегистрировать зависимости и передать во View

1. Откройте `Infrastructure/DI/DependencyContainer.swift`.
2. В протокол `DependencyContainer` добавьте свойства:

```swift
var passwordRepository: PasswordRepositoryProtocol { get }
var generatePasswordUseCase: GeneratePasswordUseCaseProtocol { get }
var savePasswordUseCase: SavePasswordUseCaseProtocol { get }
var getPasswordsUseCase: GetPasswordsUseCaseProtocol { get }
var deletePasswordUseCase: DeletePasswordUseCaseProtocol { get }
```
![DI DependencyContainer](images/di-dependencycontainer.png)


3. В классе `DefaultDependencyContainer` добавьте те же поля и параметры инициализатора (типы параметров — протоколы или конкретные классы; имя параметра для списка — **getPasswordsUseCase**, тип — **GetPasswordsUseCase**). В теле `init` присвойте все пять свойств, в том числе `self.getPasswordsUseCase = getPasswordsUseCase` и `self.deletePasswordUseCase = deletePasswordUseCase`.

![DI DependencyContainer](images/di-default-dependencyContainer.png)
4. Откройте `App/AppDependencies.swift`.
5. В методе `makeDefaultContainer()` создайте все зависимости и передайте в контейнер (включая **DeletePasswordUseCase** и правильный лейбл **getPasswordsUseCase:**):

```swift
let passwordDataSource = PasswordLocalDataSource()
let passwordRepository = PasswordRepository(dataSource: passwordDataSource)
let generatePasswordUseCase = GeneratePasswordUseCase()
let savePasswordUseCase = SavePasswordUseCase(repository: passwordRepository)
let getPasswordsUseCase = GetPasswordsUseCase(repository: passwordRepository)
let deletePasswordUseCase = DeletePasswordUseCase(repository: passwordRepository)

return DefaultDependencyContainer(
    configuration: configuration,
    analyticsRepository: analyticsRepository,
    networkRepository: networkRepository,
    conversionDataRepository: conversionDataRepository,
    fcmTokenDataSource: fcmTokenLocalDataSource,
    initializeAppUseCase: initializeAppUseCase,
    pushTokenProvider: pushTokenProvider,
    logger: logger,
    logStorage: logStorage,
    passwordRepository: passwordRepository,
    generatePasswordUseCase: generatePasswordUseCase,
    savePasswordUseCase: savePasswordUseCase,
    getPasswordsUseCase: getPasswordsUseCase,
    deletePasswordUseCase: deletePasswordUseCase
)
```
![DI MakeDefaultContainer](images/di-makeDefaultContainer.png)

6. В том месте, где показываются экраны PasswordManager (например, в `MainTabView`), контейнер из Environment имеет тип опциональный (`DependencyContainer?`), поэтому его нужно развернуть; для списка паролей передайте также **deletePasswordUseCase**.

### Шаг 6. Добавить экраны в навигацию

Если в приложении используется `MainTabView` или список вкладок:

1. Откройте файл, где объявляются вкладки (например, `Core/Presentation/Views/MainTabView.swift`).
2. Контейнер из `@Environment(\.dependencyContainer)` имеет тип `DependencyContainer?` — его нужно развернуть. При создании `PasswordListViewModel` передайте и **getPasswordsUseCase**, и **deletePasswordUseCase**. Пример целиком:

```swift
import SwiftUI

struct MainTabView: View {
    @Environment(\.dependencyContainer) private var container

    var body: some View {
        guard let container else {
            return AnyView(EmptyView())
        }
        let generatorVM = PasswordGeneratorViewModel(
            generateUseCase: container.generatePasswordUseCase,
            saveUseCase: container.savePasswordUseCase
        )
        let listVM = PasswordListViewModel(
            getPasswordsUseCase: container.getPasswordsUseCase,
            deletePasswordUseCase: container.deletePasswordUseCase
        )

        return AnyView(
            TabView {
                PasswordGeneratorView(viewModel: generatorVM)
                    .tabItem { Label("Generator", systemImage: "key") }
                PasswordListView(viewModel: listVM)
                    .tabItem { Label("Passwords", systemImage: "list.bullet") }
            }
        )
    }
}
```

После сохранения файлов проект должен собираться. Запустите приложение и проверьте экраны: генератор (слайдер 4–32, чекбоксы, контент по центру) и список паролей (название, пароль, кнопка удаления).

**Фон в режиме игры (база):** в `RootView` для `.game` показывается только `MainTabView()` — без общего ZStack с картинкой. Фон `gameBackground` рисуется **внутри каждого экрана** (как в примерах выше в шаге 3): ZStack с `Image("gameBackground")` и `.ignoresSafeArea(.container, edges: .all)`, контент сверху. Для List — `.scrollContentBackground(.hidden)` и `.listRowBackground(Color.clear)`. Новые экраны в режиме игры делайте по той же схеме.

![Result Screen 1](images/result-1.png)
![Result Screen 2](images/result-2.png)




## Дебаг

В Infrastructure -> Configuration -> AppConfiguration

Есть параметры для дебага в том числе:
1. isDebug: Bool = false,
2. isGameOnly: Bool = true, -- Отображает только игровой режим
3. isWebOnly: Bool = false, -- Отображает только WebView режим
4. isNoNetwork: Bool = false, -- Отображает только экран No Network Connection
5. isAskNotifications: Bool = false, -- Отображает только экран запроса уведомлений
6. isInfinityLoading: Bool = false, -- Отображает только экран бесконечной загрузки

---

## 6. Добавление нового экрана без новой фичи

Если экран логически относится к уже существующей фиче (например, к WebView или AppInitialization):

- **ViewModel и View** можно положить в `Core/Presentation/` или в `Features/<СуществующаяФича>/Presentation/`.
- Зависимости (use case или репозиторий) берите из контейнера и передавайте во ViewModel в `init`. Не создавайте репозитории или use cases прямо во View.

---

## 7. Добавление нового Use Case

Use case — это сценарий использования (например, «получить конфиг», «сохранить токен»). Обычно он вызывает один или несколько репозиториев и возвращает результат в виде доменной модели.

1. **Domain:** в подходящей фиче (например, `Features/PasswordManager/Domain/`) создайте протокол:

```swift
protocol SavePasswordUseCaseProtocol {
    func execute(title: String, value: String) async throws
}
```

2. **Data:** создайте класс, реализующий этот протокол и использующий `PasswordRepositoryProtocol`:

```swift
final class SavePasswordUseCase: SavePasswordUseCaseProtocol {
    private let repository: PasswordRepositoryProtocol
    init(repository: PasswordRepositoryProtocol) {
        self.repository = repository
    }
    func execute(title: String, value: String) async throws {
        let password = Password(id: UUID(), title: title, value: value, createdAt: Date())
        try await repository.save(password)
    }
}
```

3. **DI:** в `DependencyContainer` и `DefaultDependencyContainer` добавьте `var savePasswordUseCase: SavePasswordUseCaseProtocol { get }`, создайте use case в `AppDependencies.makeDefaultContainer()` (на основе `passwordRepository`) и передайте в контейнер.

4. **Presentation:** во ViewModel внедрите `SavePasswordUseCaseProtocol` и вызывайте `execute(title:value:)` вместо прямого вызова репозитория, чтобы экран знал только о сценарии «сохранить пароль», а не о деталях хранения.

---

## 8. Структура папок (кратко)

- **App** — точка входа, AppDelegate, сборка DI.
- **Core** — общий Domain, Data, Presentation (то, что не привязано к одной фиче).
- **Features/<ИмяФичи>** — Domain (сущности, протоколы), Data (реализации), Presentation (ViewModel, Views).
- **Infrastructure** — конфигурация, DI, логирование.
- **Resources** — ассеты, xcconfig, Preview Content.

Новые Swift-файлы, созданные в этих папках, должны быть добавлены в таргет **BaseProject** (и при необходимости в таргет расширения, если код используется там). При использовании File System Synchronized Groups файлы под папками `App`, `Core`, `Features`, `Infrastructure`, `Resources` подхватываются автоматически.

---

## 9. Частые моменты

- **«Cannot find type X in scope»** — проверьте, что файл с типом входит в тот же таргет (BaseProject), что и файл, который его использует.
- **Циклические зависимости** — Domain не должен импортировать Data или Presentation. Data не должен импортировать Presentation.
- **Тесты** — для тестирования ViewModel создайте мок-реализацию протокола репозитория или use case и передайте её во ViewModel; для тестирования всего приложения можно подменить контейнер через `AppDependencies.setContainerForTesting(_:)` до запуска UI.

Более общее описание слоёв и правил зависимостей — в [ARCHITECTURE.md](ARCHITECTURE.md).
