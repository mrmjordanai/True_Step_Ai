# CLAUDE.md - True Step AI Project Guide

## Project Overview

**TrueStep** is an AI-powered visual verification agent that bridges the gap between instructional content and physical task execution. Unlike traditional tutorials, TrueStep actively watches, understands, and guides users through complex physical tasks in real-time using computer vision and large language models.

**Core Value Proposition:** *"Don't just show me how. Watch me do it."*

**Key Innovation:** Visual State Verification - TrueStep monitors user progress through the device camera and only advances to the next step when it visually confirms completion. This "sentinel loop" catches mistakes before they become costly problems.

---

## Tech Stack

### Frontend: Flutter (iOS/Android)
- **State Management:** Riverpod v2.4.0+
- **Camera:** `camera` package with ImageStream handler
- **On-Device ML:** YOLOv11-nano via `ultralytics_yolo`
- **Audio:** `flutter_sound` (PCM 16kHz), speech-to-text, text-to-speech
- **UI:** Lottie animations, glassmorphism design
- **Navigation:** Go Router v12.0.0+
- **Data:** Hive, SharedPreferences, Freezed, json_serializable
- **Payments:** RevenueCat (purchases_flutter v6.6.0+)

### Backend: Firebase
- **Auth:** Anonymous → Email/Apple/Google Sign-in
- **Database:** Firestore (production mode)
- **Storage:** Firebase Storage for recordings
- **Functions:** Guide ingestion, image analysis, scheduled cleanup
- **AI:** Firebase AI (Gemini 2.5 Flash, Gemini 3 Pro)

### AI/ML - "Traffic Light Architecture" (3-Tier)
- **Tier 1 (Green):** YOLOv11 via CoreML/TFLite - Hand/tool detection (<10ms)
- **Tier 2 (Yellow):** Gemini 2.5 Flash Live - Streaming verification (600-800ms)
- **Tier 3 (Red):** Gemini 3 Pro + RAG - Deep analysis, safety alerts (3-5s)

---

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart               # Root app widget
│   ├── routes.dart            # GoRouter navigation
│   └── theme.dart             # Design system
├── core/
│   ├── constants/
│   │   ├── colors.dart        # Color palette
│   │   ├── spacing.dart       # 8dp base unit system
│   │   └── typography.dart    # SF Pro font scales
│   ├── models/
│   │   ├── visual_state_graph.dart
│   │   ├── session.dart
│   │   └── guide.dart
│   ├── utils/
│   └── extensions/
├── features/
│   ├── onboarding/            # Welcome, Permissions, Account, First Task
│   ├── home/                  # Home/Briefing with Omni-Bar
│   ├── search/                # Guide discovery
│   ├── session/               # Preview, Calibration, Tool Audit, Active, Transition, Intervention, Completion
│   ├── community/             # Feed, Video Player, Creator Profile, Share
│   ├── history/               # Session List, Session Detail
│   ├── claims/                # Mistake Insurance claim flow
│   ├── settings/              # Settings, Account Management
│   └── paywall/               # Subscription, Upgrade Prompt
├── shared/
│   ├── widgets/
│   │   ├── glass_card.dart
│   │   ├── primary_button.dart
│   │   ├── loading_indicator.dart
│   │   └── traffic_light_badge.dart
│   └── providers/             # Shared Riverpod providers
└── services/
    ├── ai_service.dart        # Gemini integration
    ├── camera_service.dart    # Camera streaming & capture
    ├── voice_service.dart     # Speech-to-text, TTS, wake word
    ├── ingestion_service.dart # URL/text/image parsing
    ├── recording_service.dart # Video recording & compression
    ├── yolo_service.dart      # On-device ML inference
    └── storage_service.dart   # Firebase Storage uploads
```

---

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (Riverpod, Freezed, JSON)
dart run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run

# Static analysis
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test

# Build for release
flutter build ios
flutter build appbundle  # Android

# Firebase deploy
firebase deploy --only functions
```

---

## Design System

### Theme: Dark Mode Default
- **Background:** `#0A0A0A`
- **Surfaces:** `#1E1E1E`
- **Glassmorphism:** 20% opacity, 16px blur, 12% white borders

### Traffic Light Colors
- **Green (Success):** `#00E676` - Watching, verified
- **Yellow (Processing):** `#FFC400` - Analyzing, uncertain
- **Red (Alert):** `#FF3D00` - Danger, stop, intervention

### Spacing (8dp base)
- xs: 4dp | sm: 8dp | md: 16dp | lg: 24dp | xl: 32dp | xxl: 48dp

### Typography
- iOS: SF Pro Display/Text
- Android: Roboto

### Touch Targets
- Minimum: 48x48dp
- Button height: 56dp
- Border radius: 12dp

---

## Code Conventions

### File Naming
- Screens: `*_screen.dart`
- Widgets: `*_widget.dart`
- Providers: `*_provider.dart`
- Services: `*_service.dart`
- Models: `*.dart` (with Freezed)

### State Management
- Use `@riverpod` annotations with `riverpod_generator`
- Services → Providers → Widgets separation

### Data Models
- Freezed for immutable models
- JSON serialization via `json_serializable`

### Color References
```dart
TrueStepColors.sentinelGreen
TrueStepColors.processingYellow
TrueStepColors.alertRed
TrueStepColors.glassSurface
```

---

## Testing Strategy

### Coverage Targets
- Unit Tests (Services): 90%
- Unit Tests (Providers): 85%
- Widget Tests: 80%
- Integration Tests: 70%

### Test Structure
```
test/
├── unit/
│   ├── services/
│   └── providers/
├── widget/
│   ├── shared/
│   └── features/
└── integration/
```

### Approach
- **Test-Driven Development (TDD):** Write tests before implementation
- Use `mockito`/`mocktail` for mocking
- Critical E2E path: Onboarding → Session → Completion

---

## Core Features

### Guide Ingestion ("The Briefing")
- Accept: URL (iFixit, recipes), text, or image
- Parse into VisualStateGraph (steps with success criteria)
- Cache guides in Firestore

### Sentinel Loop (Traffic Light System)
- **GREEN:** On-device YOLO hand/tool tracking → gatekeeper
- **YELLOW:** Streaming Gemini analysis against success criteria
- **RED:** Intervention - wrong tool, danger, incomplete step
- Advance only when verified GREEN

### Voice Control
- Wake word: "Hey TrueStep"
- Commands: Next, Repeat, Help, Pause, Stop, Back
- Hands-free for messy/dirty hands scenarios

### Session Recording
- 720p, 30fps, H.264
- 3-second verification clips per step
- 30-day auto-delete (privacy)
- Firebase Storage backend

---

## Key Documentation Files

| File | Purpose |
|------|---------|
| `True_Step_Ai/True_Step_Ai_PRD.md` | Product Requirements Document |
| `True_Step_Ai/UI_UX_docs/TrueStep_UI_UX_Spec.md` | UI/UX Specifications |
| `True_Step_Ai/TrueStep_Development_Roadmap.md` | Development Phases |
| `True_Step_Ai/Future_Features/TrueStep_CoPilot_Feature_Spec.md` | Co-Pilot Feature Spec |

---

## Development Phases

| Phase | Focus | Key Deliverables |
|-------|-------|-----------------|
| **0** | Foundation | Flutter setup, Firebase, design system |
| **1** | "Sous-Chef" MVP | URL/text ingestion, Gemini Flash, voice, recording |
| **2** | "Mechanic" Alpha | Image input, YOLO, iFixit, 30-day TTL |
| **3** | Monetization | RevenueCat, paywall, Mistake Insurance |
| **4** | Community | Video sharing, moderation, Co-Pilot |
| **5** | Platform | Expert marketplace, B2B, AR glasses |

---

## Performance Guidelines

- Camera frame processing: 30fps target
- Gemini API calls throttled to reduce cost
- Adaptive video bitrate:
  - 3G: 400 kbps
  - 4G: 1 Mbps
  - WiFi: 2.5 Mbps
- YOLO inference: <10ms latency, <10% battery/hour

---

## Security & Privacy

- **Recording auto-delete:** 30 days (7-day warning)
- **User consent required** for community sharing
- **Firebase Security Rules:** Users access only their data
- **Camera/Mic:** Explicit permission with context
- **Auth flow:** Anonymous → upgrade to Email/Apple/Google

---

## Accessibility

- WCAG 2.1 AA compliance (4.5:1 contrast minimum)
- Colorblind support (icons + colors for traffic lights)
- Text scaling to 200%
- High contrast mode option
- Screen reader optimization
- 48x48dp minimum touch targets
- Respects "Reduce Motion" setting

---

## Error Handling

- Graceful degradation (manual mode if AI unavailable)
- Network reconnection logic
- Permission denied recovery flows
- Session crash recovery with resume
- User-facing messages in non-technical language

---

## Success Metrics

### MVP (Week 8)
- 500+ beta users
- 85%+ task completion rate
- <3% false positive verification rate

### Business (Week 24)
- $50K ARR
- <5% insurance claim rate
- NPS > 40

### Community (Week 32)
- 10,000+ shared videos
- 20% users share sessions
- Viral coefficient >1.0
