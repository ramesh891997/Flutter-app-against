# Store – Production-Quality Flutter Application

A scalable, maintainable, testable, and production-ready Flutter mobile application built with **Clean Architecture** and **Feature-First** structure, consuming the [DummyJSON](https://dummyjson.com) REST API.

---

## 📱 App Demo Video

- **App Demo Video**: [Watch Demo Video](https://drive.google.com/file/d/142as-pGUlcb5-ZIZ5tfoidAT6vQg-TCh/view?usp=sharing)

---

## 1. Project Overview

**Store** is an e-commerce catalog application designed to showcase senior-level mobile application engineering standards. It includes secure JWT-based authentication with auto-refresh, session persistence across cold boots, time-based localized user greetings, infinite-scroll product pagination, pull-to-refresh, shimmer skeleton loaders, detailed product inspection with multi-image gallery and Hero transitions, comprehensive error handling with offline/retry support, and full unit and widget test coverage.

### Key Capabilities

- **Authentication**: JWT authentication against `/auth/login`, secure credential persistence, 401 interceptor with automatic token refresh (`/auth/refresh`), session restoration on app restart, and secure logout.
- **Product Catalog**: Infinite scroll pagination (`skip` & `limit`), pull-to-refresh, shimmer skeleton loading states, end-of-list detection, lazy loading with `ListView.builder`, dynamic time-aware greetings ("Good morning", "Good afternoon", "Good evening"), and resilient state preservation on transient failures.
- **Product Detail**: Detailed specifications, responsive image gallery with Hero animations, price calculation with discount badges, and stock availability tracking.
- **Resilience**: Centralized Dio networking, sanitized logging (redacting passwords & tokens), typed domain exceptions, and user-friendly failure mappings.
- **Internationalization (i18n)**: All user-facing strings are decoupled from widgets and managed centrally in `AppLocalizations` (`lib/l10n/app_en.arb`).

---

## 2. Flutter & Dart Version Requirements

| Tool            | Version Requirement                   |
| --------------- | ------------------------------------- |
| **Flutter SDK** | `>= 3.38.4` (channel stable)          |
| **Dart SDK**    | `>= 3.10.3 < 4.0.0`                   |
| **Java JDK**    | JDK 17 or JDK 21 (for Android builds) |
| **Xcode**       | Xcode 15+ (for iOS builds)            |

---

## 3. Architecture Decisions

The application strictly adheres to **Clean Architecture** with a **Feature-First** packaging model.

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                    │
│      (Screens, Widgets, Riverpod StateNotifiers)        │
└───────────────────────────▲─────────────────────────────┘
                            │ (Calls UseCases / Reads State)
┌───────────────────────────┴─────────────────────────────┐
│                      Domain Layer                       │
│    (Business Entities, UseCases, Repository Contracts)  │
└───────────────────────────▲─────────────────────────────┘
                            │ (Implements Contracts)
┌───────────────────────────┴─────────────────────────────┐
│                      Data Layer                         │
│  (Data Sources, DTO Models / JSON, Repositories Impl)   │
└─────────────────────────────────────────────────────────┘
```

### Architectural Principles

1. **Single Responsibility (SRP)**: Each class has one distinct responsibility. DataSources fetch raw payloads; Repositories map DTOs to entities; UseCases encapsulate individual user actions; Notifiers manage immutable UI state.
2. **Open/Closed (OCP)**: Interfaces such as `ISecureStorageService`, `AuthRepository`, and `ProductRepository` allow new implementations without modifying existing business logic.
3. **Liskov Substitution (LSP)**: All repository implementations safely replace their domain abstract contracts.
4. **Interface Segregation (ISP)**: Minimal, focused interfaces preventing bloated consumer dependencies.
5. **Dependency Inversion (DIP)**: High-level domain logic never depends on low-level packages (such as Dio or FlutterSecureStorage). Both depend on domain abstractions.

---

## 4. Folder Structure

```text
lib/
├── main.dart                          # Application entry point
├── app/
│   ├── app.dart                       # MaterialApp.router configuration
│   ├── bootstrap.dart                 # Core service initialization & async app bootstrap
│   ├── router/
│   │   ├── app_router.dart            # GoRouter configuration & auth redirect guards
│   │   └── route_names.dart           # Centralized route path and name constants
│   └── theme/
│       ├── app_colors.dart            # Semantic color palette
│       ├── app_spacing.dart           # 8-point spatial system & radii
│       ├── app_text_styles.dart       # Material 3 typographic scale
│       └── app_theme.dart             # Centralized ThemeData definition
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart         # Base URL, endpoints, and timeouts
│   │   ├── app_constants.dart         # Storage keys and scroll thresholds
│   │   └── asset_constants.dart       # Centralized asset paths
│   ├── errors/
│   │   ├── app_exception.dart         # Typed infrastructure exceptions
│   │   └── failure.dart               # Domain & UI failure abstractions
│   ├── network/
│   │   ├── api_interceptor.dart       # Bearer token attachment & sanitized logging
│   │   ├── dio_client.dart            # Centralized Dio singleton provider
│   │   ├── network_exceptions.dart    # DioException to AppException translator
│   │   └── session_expired_provider.dart # Session expiry broadcast hook
│   ├── storage/
│   │   └── secure_storage_service.dart # ISecureStorageService contract & implementation
│   ├── utils/
│   │   ├── formatters.dart            # Currency, rating, and discount formatters
│   │   ├── time_utils.dart            # Localized time-of-day greeting resolver
│   │   └── validators.dart            # Form input validation rules
│   └── widgets/
│       ├── app_button.dart            # Primary and outlined action buttons with loading
│       ├── app_empty_view.dart        # Empty state screen illustration and action
│       ├── app_error_view.dart        # Error view with retry action
│       ├── app_loader.dart            # Adaptive loading indicator
│       ├── app_shimmer.dart           # Reusable shimmer animation controller
│       ├── app_svg_icon.dart          # Scalable vector icon with color filtering
│       └── app_text_field.dart        # Form input with validation and visibility toggle
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── auth_response_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── auth_session.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── splash_screen.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   │
│   └── products/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── product_remote_data_source.dart
│       │   ├── models/
│       │   │   └── product_model.dart
│       │   └── repositories/
│       │       └── product_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── paginated_products.dart
│       │   │   └── product.dart
│       │   ├── repositories/
│       │   │   └── product_repository.dart
│       │   └── usecases/
│       │       ├── get_product_details_usecase.dart
│       │       └── get_products_usecase.dart
│       └── presentation/
│           ├── providers/
│           │   ├── product_details_provider.dart
│           │   └── products_provider.dart
│           ├── screens/
│           │   ├── product_details_screen.dart
│           │   └── products_screen.dart
│           └── widgets/
│               ├── product_card.dart
│               ├── product_card_skeleton.dart
│               └── product_image.dart
│
└── l10n/
    ├── app_en.arb
    └── app_localizations.dart

assets/
└── icons/
    ├── back.svg
    ├── empty_state.svg
    ├── error.svg
    ├── logout.svg
    └── refresh.svg

test/
├── core/
│   ├── network/
│   │   └── network_exceptions_test.dart
│   ├── storage/
│   │   └── secure_storage_service_test.dart
│   └── utils/
│       ├── time_utils_test.dart
│       └── validators_test.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository_impl_test.dart
│   │   └── presentation/
│   │       ├── auth_provider_test.dart
│   │       ├── login_screen_test.dart
│   │       └── splash_screen_test.dart
│   └── products/
│       ├── data/
│       │   ├── product_model_test.dart
│       │   └── product_repository_impl_test.dart
│       └── presentation/
│           ├── product_details_provider_test.dart
│           ├── products_provider_test.dart
│           └── products_screen_test.dart
└── widgets/
    ├── app_button_test.dart
    ├── app_error_view_test.dart
    └── app_svg_icon_test.dart
```

---

## 5. State Management Choice & Reasoning

The project uses **Riverpod (`flutter_riverpod: ^2.6.1`)** for state management and dependency injection.

### Why Riverpod?

- **Compile-Time Safety**: No `ProviderNotFoundException` runtime errors.
- **Separation of Concerns**: UI widgets observe declarative states without managing asynchronous lifecycles.
- **Testability**: Riverpod containers allow seamless overriding of providers (`overrideWith` or `overrideWithValue`) during unit and widget tests without heavy setup.
- **Fine-Grained Rebuild Optimization**: Providers notify only widgets that watch specific state slices, preventing unnecessary widget tree rebuilding.

---

## 6. Dependency Injection Approach

Dependency injection is managed purely using Riverpod's declarative graph:

1. `dioClientProvider` depends on `secureStorageServiceProvider`.
2. `authRemoteDataSourceProvider` and `productRemoteDataSourceProvider` depend on `dioClientProvider`.
3. `authRepositoryProvider` and `productRepositoryProvider` depend on their respective data sources and secure storage.
4. Use cases depend on repository interfaces.
5. `authProvider` and `productsProvider` inject use cases and expose immutable state to the UI.

No third-party service locators (like `get_it`) are required, eliminating global mutable state.

---

## 7. API Integration

Integration is done with [DummyJSON](https://dummyjson.com):

- **Login**: `POST /auth/login` (body: `username`, `password`)
- **Token Refresh**: `POST /auth/refresh` (body: `refreshToken`)
- **Current User Profile**: `GET /auth/me`
- **Product List**: `GET /products?limit=15&skip=0`
- **Product Details**: `GET /products/{id}`

### Network Security & Error Handling

- **Timeouts**: 15s connect, receive, and send timeouts.
- **Logging Sanitization**: Sensitive authorization tokens, refresh tokens, and passwords in request headers and JSON bodies are redacted before logging.
- **Interception**: Bearer tokens are attached automatically to non-auth requests. 401 Unauthorized responses trigger automatic token refresh before replaying the initial request.

---

## 8. Authentication & Secure Token Storage

- **Storage Engine**: `flutter_secure_storage` using Android `EncryptedSharedPreferences` and iOS `KeychainAccessibility.first_unlock`.
- **Zero Plaintext Storage**: Tokens and sensitive user info are never stored in `SharedPreferences`.
- **Session Persistence**: On application cold boot, `bootstrap()` calls `authNotifier.restoreSession()`. If valid credentials exist, the app transitions directly to the product catalog without re-prompting login.
- **Session Expiration**: If both the access token and refresh token expire, the user session is invalidated and redirected to login with an informative banner.
- **Concurrency Protection**: Duplicate login requests while an existing request is in flight are prevented.

### Demo Test Credentials

- **Username**: `emilys`
- **Password**: `emilyspass`

_(A one-tap demo helper button is provided on the Login screen for rapid evaluation)._

---

## 9. Pagination Strategy

- **Mechanism**: Page-based cursor using `limit` and `skip` query parameters.
- **Trigger**: `ScrollController` listener detects when the user scrolls within 200 logical pixels (`AppConstants.paginationScrollThreshold`) of the bottom.
- **Duplicate Prevention**: Guard conditions in `ProductsNotifier.loadMore()` reject calls if `isLoadingMore` is true, if pull-to-refresh is in progress, or if `hasMore` is false.
- **End of List**: Detected when `skip + products.length >= total`. A discreet footer indicates the end of the catalog.
- **Failure Resilience**: If page $N$ fails, previously loaded items (pages $1 \dots N-1$) are preserved in the list, and a non-destructive floating SnackBar with a "Retry" button is displayed.

---

## 10. SVG Configuration

Vector assets are rendered via `flutter_svg: ^2.0.17` through a centralized `AppSvgIcon` widget:

```dart
AppSvgIcon(
  assetPath: AssetConstants.backIcon,
  size: 24,
  color: AppColors.textPrimary,
  semanticLabel: 'Back button',
)
```

- Icons are declared in `pubspec.yaml` under `flutter.assets: - assets/icons/`.
- Color tinting is implemented cleanly via `ColorFilter.mode(color, BlendMode.srcIn)`.
- Valid SVG files:
  - `assets/icons/back.svg`
  - `assets/icons/logout.svg`
  - `assets/icons/refresh.svg`
  - `assets/icons/error.svg`
  - `assets/icons/empty_state.svg`

---

## 11. Installation & Setup

1. **Clone the repository**:

   ```bash
   git clone <repo_url>
   cd flutter_demo_app
   ```

2. **Verify Flutter Environment**:

   ```bash
   flutter doctor
   ```

3. **Install Dependencies**:

   ```bash
   flutter pub get
   ```

---

## 12. How to Run on Android & iOS

### Running on Android

Ensure an Android Emulator or connected physical device is online:

```bash
flutter devices
flutter run -d android
```

### Running on iOS

Ensure CocoaPods dependencies are installed and target the iOS Simulator or connected iOS device (iOS 15.0+):

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

### Running on macOS Desktop

```bash
flutter run -d macos
```

---

## 13. Building the Release APK

To generate a standalone release APK for Android testing and distribution:

```bash
flutter build apk --release
```

- Output: [`build/app/outputs/flutter-apk/app-release.apk`](build/app/outputs/flutter-apk/app-release.apk)
- Checksum: [`build/app/outputs/flutter-apk/app-release.apk.sha1`](build/app/outputs/flutter-apk/app-release.apk.sha1)

For split architecture APKs (reducing file size to ~15MB each):

```bash
flutter build apk --release --split-per-abi
```

---

## 14. How to Run Tests

Run all unit, repository, provider, and widget tests:

```bash
flutter test
```

To run with coverage:

```bash
flutter test --coverage
```

---

## 15. How to Run Static Analysis & Formatting

### Static Analysis

```bash
flutter analyze
```

_(Configured with strict types, strict inference, and Flutter lints; passes with 0 issues)._

### Code Formatting

```bash
dart format --output=none --set-exit-if-changed .
```

To auto-format all code:

```bash
dart format .
```

---

## 16. Assumptions, Trade-offs & Limitations

1. **DummyJSON Token Lifecycle**: The DummyJSON authentication API issues short-lived JWT tokens. While the app fully implements `ApiInterceptor` automatic refresh logic using `/auth/refresh`, DummyJSON tokens are demo keys that may rotate periodically.
2. **Offline Caching**: Product images are cached to disk via `cached_network_image`. Full offline database caching (e.g. Isar/Drift) was omitted to keep the architecture clean and maintainable without adding unrequested database bloat.
3. **Localization**: Fully decoupled using `AppLocalizations` (`l10n/app_en.arb`) providing scalable internationalization across all user-facing screens and widgets.
