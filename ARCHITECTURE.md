# EIGHTOBADGE: Architecture & Engineering Reference

> Authoritative reference for every product, design, and engineering decision. Read this before writing code.

---

## Table of Contents

1. [Identity](#1-identity)
2. [Product Charter](#2-product-charter)
3. [Privacy Charter](#3-privacy-charter)
4. [Architecture](#4-architecture)
5. [Project Structure](#5-project-structure)
6. [Apple Technologies](#6-apple-technologies)
7. [Feature Specification](#7-feature-specification)
8. [Monetisation](#8-monetisation)
9. [Git & Commit Standards](#9-git--commit-standards)
10. [Code Standards](#10-code-standards)

---

## 1. Identity

| Field | Value |
|---|---|
| App Name | EIGHTOBADGE |
| Display Name (Marketing) | EIGHTOBADGE |
| Bundle ID (iOS) | com.devmustafatavasli.eightobadge |
| Bundle ID (watchOS) | com.devmustafatavasli.eightobadge.watchkitapp |
| Team ID | WX8U7ZR7K8 |
| Minimum iOS | 17.0 |
| Minimum watchOS | 10.0 |
| iPad | Not supported |
| macOS | Not supported |
| Swift Version | 6.0, strict concurrency |
| Xcode Version | 16+ |
| Target Release Version | 1.0.0 |

---

## 2. Product Charter

EIGHTOBADGE is a personal race companion for Hyrox athletes. It is not a social app, not a leaderboard, not a community. It is a tool for one athlete to understand their own performance: which stations cost them the most time, where their effort peaked, what their personal bests are, and how they're improving.

### Core principles

**1. Watch is the source of truth.** The athlete builds a workout on iPhone (standard Hyrox format or custom), then runs it on their Apple Watch. The Watch captures timing, heart rate, and effort. The iPhone shows history, analysis, and personal benchmarks — all derived from past Watch sessions.

**2. Hands-free during activity.** The system Double Tap gesture (`.handGestureShortcut(.primaryAction)`) advances to the next exercise and records the split. The athlete's hands are full; they don't fumble with their watch.

**3. Offline-first sync.** The Watch works without connectivity during a race. CloudKit syncs the data seamlessly once it returns online. No manual transfer, no network dependency during the race itself.

**4. Privacy-respecting HealthKit usage.** Heart rate is read from HealthKit on the device where it's recorded (Watch). Raw HealthKit records are never transferred between devices or to a server. Only the app's own computed values (avg/max HR per exercise) are stored and synced.

---

## 3. Privacy Charter

### Data at rest

- Workouts, exercise timing, and aggregated heart rate metrics are stored in SwiftData.
- SwiftData uses CloudKit encryption for iCloud sync; data is encrypted end-to-end to your iCloud account.
- No data is sent to any external server or third-party service.
- No analytics, no telemetry, no user tracking.

### HealthKit

- The app reads heart rate samples from the device's local HealthKit store during active workouts.
- Raw HealthKit data is never written to SwiftData, never synced, never exported.
- Only aggregated values (e.g., average HR for station 1, max HR during a run) are derived and stored in the app's own models.
- User grants or denies HealthKit access through standard iOS/watchOS permission flows. Revoking access stops heart rate capture but does not delete historical workouts.

### CloudKit

- The app uses a private CloudKit container for syncing across the user's own devices (iPhone, Watch).
- No public or shared databases. No data is visible to other users.
- Syncing is automatic and encrypted by CloudKit.

---

## 4. Architecture

### MVVM + Unidirectional Data Flow

```
View (SwiftUI)
  ↓
ViewModel (@Observable, @MainActor)
  ↓
UseCase (pure functions)
  ↓
Repository (protocol interface)
  ↓
SwiftData + CloudKit
```

- **Views**: SwiftUI, no business logic, every view ships a `#Preview`.
- **ViewModels**: `@Observable`, `@MainActor`, respond to user intent and fetch data via use cases.
- **UseCases**: Pure, stateless functions. Orchestrate repositories and model transformations. Examples: `CreateWorkoutUseCase`, `ComputeBenchmarksUseCase`, `RecordExerciseResultUseCase`.
- **Repositories**: Protocol-based, implement data access patterns. Examples: `WorkoutTemplateRepository`, `WorkoutSessionRepository`.
- **Persistence**: SwiftData with CloudKit sync via app group entitlement.

### State Management

- `@Observable` only. No `ObservableObject`, no Combine, no `NotificationCenter`.
- Dependency injection via an `AppContainer` injected into the SwiftUI `Environment`.
- No singletons except for platform services (HealthKit access, haptics).

### Navigation

- `NavigationStack` only. No `NavigationView`.
- Navigation state is driven by view models, not imperative sheet/fullScreenCover calls.

### Error Handling

- Typed `EighToBadgeError: LocalizedError` enum.
- Never `fatalError` in a production code path.
- Errors are surfaced to the user via alert or inline message, handled by view models.

### Swift 6 Concurrency

- `async/await` only. No completion handlers.
- `@MainActor` on view models.
- Structured concurrency via `Task`, `async let`, and task groups.
- Complete strict concurrency checking.

---

## 5. Project Structure

```
EighToBadge/
├── EighToBadge/                      # iOS app target
│   ├── Sources/
│   │   ├── App/
│   │   ├── Features/
│   │   │   ├── Workouts/
│   │   │   ├── Create/
│   │   │   ├── Benchmarks/
│   │   │   ├── Settings/
│   │   │   └── Details/
│   │   ├── Components/
│   │   └── EighToBadgeApp.swift
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   └── PrivacyInfo.xcprivacy
│   ├── EighToBadge.entitlements
│   └── Info.plist
│
├── EighToBadgeWatch/                 # watchOS app target
│   ├── Sources/
│   │   ├── App/
│   │   ├── Features/
│   │   │   ├── WorkoutList/
│   │   │   ├── ActiveWorkout/
│   │   │   └── Summary/
│   │   └── EighToBadgeWatchApp.swift
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   └── PrivacyInfo.xcprivacy
│   ├── EighToBadgeWatch.entitlements
│   └── Info.plist
│
├── EighToBadgeCore/                  # Shared SPM package
│   ├── Sources/EighToBadgeCore/
│   │   ├── Models/
│   │   │   ├── WorkoutTemplate.swift
│   │   │   ├── WorkoutSession.swift
│   │   │   └── ExercisePlan.swift
│   │   ├── Repositories/
│   │   │   ├── WorkoutTemplateRepository.swift
│   │   │   └── WorkoutSessionRepository.swift
│   │   ├── UseCases/
│   │   │   ├── CreateWorkoutUseCase.swift
│   │   │   ├── RecordSessionUseCase.swift
│   │   │   └── ComputeBenchmarksUseCase.swift
│   │   ├── Services/
│   │   │   ├── HealthKitService.swift
│   │   │   └── CloudKitService.swift
│   │   ├── Error/
│   │   │   └── EighToBadgeError.swift
│   │   └── EighToBadgeCore.swift
│   ├── Tests/EighToBadgeCoreTests/
│   └── Package.swift
│
├── project.yml                       # XcodeGen config
├── ARCHITECTURE.md                   # This file
├── .gitignore
└── .git/
```

---

## 6. Apple Technologies

- **SwiftData**: App-level persistence, modeled as `@Model` types, automatic CloudKit sync via private container.
- **CloudKit**: Transparent sync of SwiftData models across the user's devices (iPhone, Watch). Private container, no shared/public database.
- **HealthKit**: Read-only access to heart rate (HKQuantityTypeIdentifierHeartRate) on each device. No writing to HealthKit. No syncing raw data.
- **SwiftUI**: All UI, iOS and watchOS.
- **Swift Testing**: Unit tests for use cases, repositories, and model logic.
- **Foundation**: Date, UUID, Locale for i18n (if needed).

---

## 7. Feature Specification

### v1.0.0 (Current)

#### iPhone

- **Workouts Tab**: List of past sessions (cards: name, date, total time, avg HR). Create button.
- **Create Flow**:
  - Step 1: Choose template (Standard Hyrox / Custom).
  - Step 2: Add and reorder exercises (drag reorder). Per-exercise: distance, reps, weight (context-aware).
  - Step 3: Review and save.
- **Benchmarks Tab**: Personal bests grouped by Runs and Stations. Progress toward arbitrary goal (optional visual).
- **Workout Detail**: Ring visualization (effort/avg HR/pace). Splits list (per exercise time, HR zone, pace).
- **Exercise Detail**: HR zone breakdown for one station.
- **Settings Tab**: HealthKit permission toggle, units (km/miles), appearance (light/dark/system).

#### watchOS

- **Workout List**: Templates synced from iPhone.
- **Active Workout**: Large timer display, progress ring, current exercise name, live heart rate (if available). Double Tap advances to next exercise or finishes. Manual tap fallback.
- **Summary Screen**: Total time, avg HR, PB indicator (if this session beat a previous best).

### v2.0+ (Explicitly deferred, not documented here)

Post-1.0 work — not part of this build.

---

## 8. Monetisation

**Free**, no in-app purchase, no subscription. The app is a personal fitness tool for the athlete, not a platform or service.

---

## 9. Git & Commit Standards

### Branches

- `main`: Protected. Receives tags and releases only (`git tag v1.0.0 && git push --tags`).
- `develop`: Integration branch. Feature and fix branches branch from here.
- Feature branches: `feature/<slice>` (e.g., `feature/workout-create-flow`).
- Fix branches: `fix/<short-name>` (e.g., `fix/healthkit-permissions`).
- Chore branches: `chore/<short-name>` (e.g., `chore/scaffold`).

### Commit message format

Conventional Commits:

```
<type>(<scope>): <subject>
<blank line>
<body (optional)>
```

- **Type**: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`, `style`, `revert`, `ci`.
- **Scope**: `core`, `ios`, `watch`, `models`, `ui`, `health`, `sync`, etc.
- **Subject**: lowercase, present tense, no trailing period, ≤72 characters.
- **Body**: if needed, explain the motivation and any subtle changes. Keep concise.

### Examples

```
feat(models): add workout template with drag-reorder exercises
fix(watch): correct heart rate reading during active session
refactor(core): extract benchmark computation into use case
test(repositories): add swiftdata persistence tests
```

---

## 10. Code Standards

### Style

- Swift 6, strict concurrency enabled.
- No AI assistant attribution anywhere in code or comments.
- No emojis in code or documentation.
- Comments only explain non-obvious "why" — never restate what the code does.

### File structure

- **Max 500 lines per file** (match DepartureKit convention).
- Every Swift file begins with a header:
  ```swift
  // WorkoutTemplate.swift
  // EighToBadgeCore
  //
  // Model representing a workout template with exercises.
  //
  // Created by [Author] on YYYY-MM-DD.
  // Copyright © 2026. All rights reserved.
  ```
- Alphabetic order within sections (imports, then structs/classes/enums).

### Testing

- Swift Testing (`import Testing`) for all unit tests.
- Test data uses in-memory SwiftData containers, no real database.
- No UI tests in v1 — QA via manual simulator/device runs.

### Code review

- All changes land on `develop` via pull request.
- Self-review before pushing (git diff to verify intent).
- Tests must pass locally before push.

