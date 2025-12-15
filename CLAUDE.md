# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TrueStep** is an AI-powered visual verification agent for physical tasks. It watches users through the camera and guides them through complex tasks (cooking, repairs) using computer vision and LLMs.

**Core Innovation:** Visual State Verification via "Sentinel Loop" - monitors user progress and only advances to the next step when visually confirmed complete.

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (required after model/provider changes)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Static analysis
flutter analyze

# Run all tests
flutter test

# Run specific test file
flutter test test/widget/features/onboarding/permissions_screen_test.dart

# Run tests with coverage
flutter test --coverage

# Format code
dart format lib/

# Build for release
flutter build ios
flutter build appbundle
```

## Architecture

### Tech Stack
- **Frontend:** Flutter (iOS 15+/Android API 26+)
- **State Management:** Riverpod with `riverpod_generator`
- **Navigation:** Go Router
- **Backend:** Firebase (Auth, Firestore, Storage)
- **AI:** Firebase AI (Gemini), YOLOv11-nano for on-device ML

### AI "Traffic Light" System (3-Tier)
- **Tier 1 (Green):** YOLOv11 on-device - Hand/tool detection (<10ms)
- **Tier 2 (Yellow):** Gemini Flash - Streaming verification (600-800ms)
- **Tier 3 (Red):** Gemini Pro - Deep analysis, safety alerts (3-5s)

### Service Layer Pattern
Services extend `BaseService` which provides lifecycle management:
```dart
abstract class BaseService {
  Future<void> initialize();  // Call before use
  Future<void> dispose();     // Release resources
  void ensureInitialized();   // Throws if not init'd
}
```

### Key Directories
- `lib/features/` - Feature modules (onboarding, home, session, etc.)
- `lib/services/` - Business logic services (auth, camera, voice, AI)
- `lib/shared/widgets/` - Reusable UI components (GlassCard, PrimaryButton, TrafficLightBadge)
- `lib/core/constants/` - Design tokens (colors, spacing, typography)
- `lib/app/routes.dart` - All navigation routes

## Design System

### Theme: Dark Mode Default
- Background: `#0A0A0A`, Surfaces: `#1E1E1E`
- Glassmorphism: 20% opacity, 16px blur, 12% white borders

### Traffic Light Colors
```dart
TrueStepColors.sentinelGreen    // #00E676 - Watching, verified
TrueStepColors.analysisYellow   // #FFC400 - Analyzing
TrueStepColors.interventionRed  // #FF3D00 - Stop, danger
```

### Spacing (8dp base)
```dart
TrueStepSpacing.xs   // 4dp
TrueStepSpacing.sm   // 8dp
TrueStepSpacing.md   // 16dp
TrueStepSpacing.lg   // 24dp
TrueStepSpacing.xl   // 32dp
```

### Touch Targets
- Minimum: 48x48dp
- Button height: 56dp (`TrueStepSpacing.buttonHeight`)
- Border radius: 12dp (`TrueStepSpacing.radiusMd`)

## Code Conventions

### File Naming
- Screens: `*_screen.dart`
- Widgets: `*_widget.dart`
- Providers: `*_provider.dart`
- Services: `*_service.dart`

### State Management
- Use `@riverpod` annotations with code generation
- Pattern: Services → Providers → Widgets

### Data Models
- Use Freezed for immutable models
- JSON serialization via `json_serializable`

## Testing

### Test Structure
```
test/
├── helpers/
│   ├── mock_services.dart    # MockAuthService, MockPermissionService
│   ├── pump_app.dart         # Widget test helpers
│   └── test_helpers.dart
├── unit/
│   ├── services/
│   └── providers/
├── widget/
│   ├── shared/
│   └── features/
└── integration/
```

### Using Test Helpers
```dart
// Create mocks with default stubs
final mockAuth = createMockAuthService(isSignedIn: true, userId: 'test-user');
final mockPermission = createMockPermissionService(cameraGranted: true);
```

### TDD Approach
Write tests before implementation. Use `mocktail` for mocking.

## Key Documentation

| File | Purpose |
|------|---------|
| `TrueStep_Development_Roadmap.md` | Development phases & task checklist |
| `True_Step_Ai_PRD.md` | Product Requirements Document |
| `UI_UX_docs/TrueStep_UI_UX_Spec.md` | UI/UX Specifications |

## Development Status

Track progress in `TrueStep_Development_Roadmap.md`. Current status:
- **Phase 0:** ✅ Complete (Foundation)
- **Phase 1.1:** ✅ Complete (Shared Widgets)
- **Phase 1.2:** ✅ Complete (Onboarding Flow)
- **Phase 1.3:** ✅ Complete (Home & Navigation)
- **Phase 1.4+:** In Progress (Guide Ingestion, Camera & Voice, Session Flow)
