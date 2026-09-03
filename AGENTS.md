# Project Guidelines & Architecture (AGENTS.md)

This file contains the strict architectural rules and guidelines for building both the Flutter Frontend and FastAPI Backend for the Video Streaming App. **I MUST read and follow these rules before writing any code.**

## 1. General Rules (CRITICAL)
- **Max Lines Per File:** NO FILE should exceed **120 lines of code**. If a file gets close to 120 lines, it must be broken down into smaller components, mixins, or helper files immediately.
- **Custom Over Defaults:** Never use default Flutter Text, Button, TextField directly in the UI. Always use the predefined custom widgets (e.g., `CustomText`, `CustomButton`).

## 2. Flutter Frontend (Clean Architecture)

The Flutter project must follow a strict Clean Architecture pattern using **GetX** for state management, **Dio** for networking, **Hive** for local storage, and **ScreenUtil** for responsive design.

### Directory Structure
```text
lib/
├── core/               # App-wide constants, themes, network clients, errors
│   ├── network/        # NetworkCaller.dart (Dio wrapper)
│   ├── theme/          # colors.dart, text_styles.dart, app_theme.dart
│   └── utils/          # helpers, formatters
├── data/               # Data layer (models, data sources, repositories impl)
│   ├── models/         # DTOs and serialization
│   ├── datasources/    # Remote (API) and Local (Hive) data sources
│   └── repositories/   # Implementation of domain repository interfaces
├── domain/             # Business logic layer (entities, repositories, usecases)
│   ├── entities/       # Pure Dart objects
│   ├── repositories/   # Interfaces for repositories
│   └── usecases/       # Single-responsibility use cases
├── presentation/       # UI and State Management (GetX)
│   ├── controllers/    # GetX Controllers
│   └── screens/        # UI Pages (Home, Reels, Browser)
└── widgets/            # Reusable custom UI components
    ├── custom_button.dart
    ├── custom_text.dart
    ├── custom_textfield.dart
    └── custom_searchfield.dart
```

### Core Libraries & Usage
- **State Management (GetX):** Use GetX for dependency injection (`Get.put`, `Get.lazyPut`), route management (`Get.to`), and reactive state management (`Rx`).
- **Networking (Dio):** All API calls must pass through `NetworkCaller.dart`.
- **Local Database (Hive):** Use Hive for caching user preferences, history, and light metadata.
- **Responsiveness (ScreenUtil):** Use `.w`, `.h`, `.sp`, `.r` for all sizes, paddings, and fonts. Never use hardcoded double values for dimensions.

### Network Layer (`NetworkCaller`)
Create a singleton/wrapper class around Dio that handles:
- `GET`, `POST`, `PUT`, `DELETE` methods.
- Global Error Handling (Timeouts, 500s, 404s).
- Loading states (optional overlay).
- Token injection (Interceptors).
Controllers should only call `await NetworkCaller.get('/endpoint')` and handle the specific success/failure response.

### UI Components (Widgets)
Create custom widgets for:
- `CustomText`: Wraps `Text` with `ScreenUtil` fonts and `app_theme` colors.
- `CustomButton`: Standardized button with loading state support.
- `CustomTextField` & `CustomSearchField`: Standardized input fields with theming.

## 3. Python Backend (FastAPI Clean Architecture)

The FastAPI backend must also follow a modular, clean architecture approach, preventing monolithic `main.py` files.

### Directory Structure
```text
backend/
├── app/
│   ├── api/            # Route handlers (Controllers)
│   │   ├── v1/         
│   │   └── dependencies.py
│   ├── core/           # Config, security, logging
│   │   └── config.py
│   ├── domain/         # Pydantic schemas (Entities) & Interfaces
│   │   └── schemas.py
│   ├── services/       # Business logic (e.g., yt-dlp scraping logic)
│   │   └── video_service.py
│   ├── infrastructure/ # Database, Redis, External APIs
│   │   └── redis_client.py
│   └── main.py         # App entry point (Keep under 50 lines)
├── requirements.txt
└── .env
```

### Backend Rules
- **Route Handlers:** Controllers (`api/`) should only receive requests and return responses. They must NOT contain business logic.
- **Services:** All scraping logic (`yt-dlp`), cache checks, and URL resolving happen in the `services/` layer.
- **Infrastructure:** Redis connection and third-party API clients live in `infrastructure/`.
- **Max Lines:** The 120-line rule applies to Python files as well.

## 4. Execution Workflow (Reminders for Agent)
- Always check this `AGENTS.md` file before starting a new feature.
- Verify file lengths frequently. If approaching 100 lines, prepare to refactor.
- Ensure all Flutter UI elements use `ScreenUtil` and Custom Widgets.
- Ensure the `force_refresh=true` logic for expired HLS streams is implemented correctly in both Flutter (Video Controller) and FastAPI (Redis cache bypass).
