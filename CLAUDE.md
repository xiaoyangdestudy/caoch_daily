# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Coach Daily** (每日打卡应用) is a daily tracking application with Flutter frontend and Node.js/Express backend. Users can track workouts, meals, sleep, work focus, and daily reviews with cloud synchronization.

- **Frontend**: Flutter (iOS/Android/Web) with Riverpod state management
- **Backend**: Node.js + Express + SQLite (better-sqlite3)
- **Architecture**: Clean Architecture (Presentation/Application/Domain/Data layers)
- **Production Server**: http://111.230.25.80

## Development Commands

### Flutter (Client)

```bash
# Install dependencies
flutter pub get

# Run code generation (for Freezed/JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# Run app (development)
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# Build for production
flutter build apk              # Android
flutter build ios              # iOS
flutter build web              # Web
```

### Server (Backend)

```bash
# Navigate to server directory
cd server

# Install dependencies
npm install

# Development mode (with hot reload via nodemon)
npm run dev

# Production mode
npm start

# Test API health
curl http://111.230.25.80:3000/health
```

## High-Level Architecture

### Flutter App Structure

The Flutter app follows Clean Architecture with feature-based organization:

```
lib/
├── app/                    # App configuration
│   ├── bootstrap.dart      # App initialization
│   ├── router/             # go_router configuration
│   └── theme/              # Theme and design tokens
├── shared/                 # Shared resources
│   ├── providers/          # Global Riverpod providers
│   │   ├── api_provider.dart        # API client provider
│   │   └── preferences_provider.dart # SharedPreferences provider
│   ├── services/           # Shared services
│   │   ├── api_client.dart          # Dio HTTP client with auth
│   │   ├── local_store.dart         # Local data persistence
│   │   └── preferences_service.dart # User preferences
│   └── design/             # Design system components
└── features/               # Feature modules
    ├── auth/               # Authentication (login/register)
    ├── dashboard/          # Home dashboard
    ├── sports/             # Workout tracking
    ├── diet/               # Meal tracking
    ├── sleep/              # Sleep tracking
    ├── work/               # Work focus sessions
    ├── moments/            # Daily moments/highlights
    ├── review/             # Daily review
    ├── stats/              # Statistics and trends
    └── profile/            # User profile and settings
```

**Key Architectural Patterns:**
- **State Management**: Riverpod with StateNotifier for reactive state
- **Navigation**: go_router with ShellRoute for persistent bottom navigation
- **API Communication**: Dio client with automatic JWT token injection via interceptors
- **Data Flow**: Unidirectional - UI triggers actions → StateNotifier → Repository → API/Local storage
- **Offline Support**: Local-first approach with pending sync queue for offline operations

### Backend Structure

```
server/
├── src/
│   ├── config/
│   │   └── database.js          # SQLite database initialization
│   ├── middleware/
│   │   ├── auth.js              # JWT authentication middleware
│   │   └── errorHandler.js      # Global error handling
│   ├── routes/                  # API route handlers
│   │   ├── auth.js              # POST /api/auth/register, /login
│   │   ├── reviews.js           # Daily review CRUD
│   │   ├── workouts.js          # Workout record CRUD
│   │   ├── meals.js             # Meal record CRUD
│   │   ├── sleep.js             # Sleep record CRUD
│   │   ├── focus.js             # Focus session CRUD
│   │   └── sync.js              # Batch sync endpoints
│   ├── utils/
│   │   └── jwt.js               # JWT token utilities
│   └── index.js                 # Express app entry point
├── data/                        # SQLite database files
├── .env                         # Environment variables (dev)
├── .env.production              # Environment variables (production)
└── ecosystem.config.js          # PM2 process manager config
```

**Database Schema:**
- `users` - User accounts with bcrypt password hashing
- `review_entries` - Daily reviews with mood, highlights, plans
- `workout_records` - Exercise tracking (type, duration, distance, calories)
- `meal_records` + `food_items` - Meal tracking with nutritional data
- `sleep_records` - Sleep tracking (bedtime, wake time, quality)
- `focus_sessions` - Work focus sessions with targets and completion

**Authentication Flow:**
1. Client: POST credentials → `/api/auth/register` or `/api/auth/login`
2. Server: Validates → bcrypt password check → generates JWT
3. Server: Returns `{ token, userId }` with 30-day expiration
4. Client: Stores token in SharedPreferences
5. Client: ApiClient automatically injects token via Dio interceptor
6. Server: auth.js middleware validates JWT on protected routes

### Critical Implementation Details

**API Client (lib/shared/services/api_client.dart):**
- Initializes Dio with 30s timeout
- Auto-loads token from SharedPreferences on init
- Intercepts requests to inject `Authorization: Bearer <token>` header
- Handles 401 errors by clearing local token
- All features use this centralized client via `apiClientProvider`

**State Management Pattern:**
- Each feature has its own StateNotifier (e.g., `AuthNotifier`, `WorkoutNotifier`)
- StateNotifiers are provided via Riverpod providers
- UI widgets consume state via `ref.watch()` and trigger actions via `ref.read()`
- Async operations use `AsyncValue<T>` for loading/error/data states

**Data Synchronization:**
- Client writes data locally first (optimistic updates)
- Background sync worker pushes pending changes to server
- Conflict resolution: server-wins strategy with user notification
- `/api/sync/batch` endpoint handles bulk synchronization

**Environment Configuration:**
- Flutter: API base URL configured in providers (currently http://111.230.25.80:3000)
- Server: Environment variables in `.env` (PORT, JWT_SECRET, DB_PATH, ALLOWED_ORIGINS)
- Production deployment uses PM2 with ecosystem.config.js

## Common Development Patterns

### Adding a New Feature Module

1. Create feature directory under `lib/features/<feature_name>/`
2. Structure: `presentation/`, `application/` (state), `domain/` (models), `data/` (repository)
3. Add route in `lib/app/router/app_routes.dart`
4. Create StateNotifier for business logic
5. Use ApiClient for HTTP requests
6. Follow existing features as reference (e.g., `features/sports/`)

### Database Schema Changes

Server-side migrations are manual:
1. Update table definitions in `server/src/config/database.js`
2. Add migration SQL in `initDatabase()` function
3. Test locally, then deploy to production
4. Database automatically initializes missing tables on startup

### API Endpoint Changes

1. Add/modify route in `server/src/routes/<module>.js`
2. Update corresponding Flutter service/repository
3. Update DTOs/models if data structure changes
4. Use Freezed for Flutter models: `flutter pub run build_runner build`

### Testing API Endpoints

```bash
# Health check
curl http://111.230.25.80:3000/health

# Register user
curl -X POST http://111.230.25.80:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'

# Login
curl -X POST http://111.230.25.80:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'

# Authenticated request (replace TOKEN)
curl -X GET http://111.230.25.80:3000/api/workouts \
  -H "Authorization: Bearer TOKEN"
```

## Important Notes

- **Server Entry Point**: `server/src/index.js` (not `server.js` despite package.json reference)
- **Database Location**: `server/data/coach_daily.db` (auto-created if missing)
- **JWT Secret**: Must be at least 32 characters in production `.env`
- **CORS**: Server accepts all origins by default (`ALLOWED_ORIGINS=*`)
- **Rate Limiting**:
  - Auth endpoints: 10 requests per 15 minutes
  - General endpoints: 60 requests per minute
- **Server Deployment**: Server listens on `0.0.0.0` to accept external connections
- **Code Generation**: Run `flutter pub run build_runner build` after modifying Freezed models
- **Design System**: UI components in `lib/shared/design/` should be reused across features

## Documentation References

Additional documentation in repository:
- `软件架构.md` - Detailed architecture design (Chinese)
- `需求文档.md` - Product requirements (Chinese)
- `server/README.md` - Server-specific setup and API documentation
- `服务器部署配置文档.md` - Production deployment guide (Chinese)
- `开发部署工作流.md` - Development workflow (Chinese)
