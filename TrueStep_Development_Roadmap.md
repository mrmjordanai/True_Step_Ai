# TrueStep AI Visual Verification
## Development Roadmap & Implementation Checklist

**Version:** 1.0  
**Based on:** TrueStep PRD v4, UI/UX Spec v2  
**Platform:** Flutter (iOS, Android) + Firebase  
**Development Approach:** Test-Driven Development (TDD)

---

## Document Purpose

This roadmap provides Claude Code with actionable implementation guidance. Each phase contains:
- Specific tasks with completion checkboxes
- File paths referencing the established project structure
- Technical requirements and acceptance criteria
- TDD requirements (tests written BEFORE implementation)

---

## Project Structure Reference

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── spacing.dart
│   │   └── typography.dart
│   ├── utils/
│   └── extensions/
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── search/
│   ├── session/
│   ├── community/
│   ├── history/
│   ├── claims/
│   ├── settings/
│   └── paywall/
├── shared/
│   ├── widgets/
│   └── providers/
└── services/
    ├── ai_service.dart
    ├── camera_service.dart
    ├── voice_service.dart
    └── storage_service.dart
```

---

# PHASE 0: Project Foundation (Week 0) ✅ COMPLETED
**Goal:** Establish project infrastructure with all dependencies and core architecture
**Status:** Completed December 13, 2025

## 0.1 Project Initialization

### Tasks
- [x] Create new Flutter project: `flutter create truestep --org com.truestep --platforms=ios,android`
- [x] Configure minimum SDK versions (iOS 15+, Android API 26+)
- [x] Set up Git repository with `.gitignore` for Flutter
- [x] Create branch strategy: `main`, `develop`, `feature/*`, `release/*` ✅ *Completed Dec 13, 2025*

### Acceptance Criteria
- [x] Project builds successfully on both platforms
- [x] Git repository initialized with proper ignore rules

---

## 0.2 Dependencies Setup

### Tasks
- [x] Add all dependencies to `pubspec.yaml`
- [x] Run `flutter pub get`
- [x] Verify all packages resolve without conflicts

### pubspec.yaml Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # UI Components
  lottie: ^2.6.0
  shimmer: ^3.0.0
  flutter_svg: ^2.0.7
  
  # Camera & Media
  camera: ^0.10.5
  image_picker: ^1.0.4
  video_player: ^2.7.2
  
  # Audio
  flutter_sound: ^9.2.13
  speech_to_text: ^6.3.0
  flutter_tts: ^3.8.3
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_ai: ^0.1.0
  
  # ML
  ultralytics_yolo: ^0.0.4
  
  # Networking
  web_socket_channel: ^2.4.0
  dio: ^5.3.3
  
  # Payments
  purchases_flutter: ^6.6.0
  
  # Utilities
  permission_handler: ^11.0.1
  connectivity_plus: ^5.0.1
  shared_preferences: ^2.2.2
  hive_flutter: ^1.1.0
  go_router: ^12.0.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  mockito: ^5.4.0
  mocktail: ^1.0.0
```

### Acceptance Criteria
- [x] All 30+ packages install without version conflicts
- [x] `flutter analyze` passes with no errors

---

## 0.3 Firebase Configuration

### Tasks
- [x] Create Firebase project "truestep-prod"
- [x] Enable Authentication (Anonymous, Email, Apple, Google)
- [x] Create Firestore database in production mode
- [x] Enable Firebase Storage
- [x] Download and configure platform files:
  - [x] `google-services.json` → `android/app/`
  - [x] `GoogleService-Info.plist` → `ios/Runner/`
- [ ] Configure Firebase AI (Gemini integration) - *Deferred to Phase 1*

### Firestore Security Rules (Initial)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Sessions belong to users
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // Guides are publicly readable
    match /guides/{guideId} {
      allow read: if true;
      allow write: if false; // Admin only
    }
    
    // Community posts require authentication
    match /community/{postId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### Acceptance Criteria
- [x] Firebase console shows project configured
- [x] Anonymous auth works in test app
- [x] Firestore read/write operations succeed

---

## 0.4 Design System Implementation

### Tasks
- [x] Create `lib/core/constants/colors.dart`
- [x] Create `lib/core/constants/spacing.dart`
- [x] Create `lib/core/constants/typography.dart`
- [x] Create `lib/app/theme.dart`

### File: `lib/core/constants/colors.dart`
```dart
import 'package:flutter/material.dart';

abstract class TrueStepColors {
  // Backgrounds
  static const Color bgPrimary = Color(0xFF0A0A0A);
  static const Color bgSecondary = Color(0xFF121212);
  static const Color bgSurface = Color(0xFF1E1E1E);
  
  // Glass
  static const Color glassOverlay = Color(0x14FFFFFF); // 8% white
  static const Color glassBorder = Color(0x1FFFFFFF); // 12% white
  
  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF666666);
  
  // Traffic Light States
  static const Color sentinelGreen = Color(0xFF00E676);
  static const Color sentinelGreenGlow = Color(0x4D00E676); // 30%
  static const Color analysisYellow = Color(0xFFFFC400);
  static const Color analysisYellowGlow = Color(0x4DFFC400); // 30%
  static const Color interventionRed = Color(0xFFFF3D00);
  static const Color interventionRedGlow = Color(0x66FF3D00); // 40%
  
  // Accent
  static const Color accentBlue = Color(0xFF2979FF);
  static const Color accentPurple = Color(0xFF7C4DFF);
}
```

### Acceptance Criteria
- [x] Design tokens match UI/UX spec exactly
- [x] Theme applies consistently across test widgets
- [x] Dark mode is default

---

## 0.5 Core Architecture Setup

### Tasks
- [x] Implement Riverpod provider structure
- [x] Create base service abstractions ✅ *Completed Dec 13, 2025*
- [x] Set up Go Router navigation
- [x] Create error handling utilities ✅ *Completed Dec 13, 2025*

### File: `lib/app/routes.dart`
```dart
// Route constants and GoRouter configuration
// Screens: 34 total as per UI/UX spec
```

### Acceptance Criteria
- [x] Navigation between placeholder screens works
- [x] Deep linking configured for both platforms ✅ *Completed Dec 13, 2025*
- [x] Provider scope established at app root

---

# PHASE 1: "Sous-Chef" MVP (Weeks 1-8)
**Goal:** Culinary vertical with URL/text input, Gemini Flash verification, voice control, session recording

---

## 1.1 Shared Widgets Foundation

### Priority: HIGH | Est: 3 days

### Tasks
- [x] **TEST FIRST:** Write widget tests for GlassCard
- [x] Implement `lib/shared/widgets/glass_card.dart`
- [x] **TEST FIRST:** Write widget tests for PrimaryButton variants
- [x] Implement `lib/shared/widgets/primary_button.dart`
- [x] **TEST FIRST:** Write widget tests for LoadingIndicator
- [x] Implement `lib/shared/widgets/loading_indicator.dart`
- [x] Implement `lib/shared/widgets/traffic_light_badge.dart`

### GlassCard Implementation Reference
```dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsets padding;
  
  // Uses BackdropFilter with blur(20, 20)
  // Background: Colors.white.withOpacity(0.08)
  // Border: accentColor ?? Colors.white.withOpacity(0.12)
  // BorderRadius: 16dp
}
```

### Acceptance Criteria
- [x] GlassCard renders with correct blur and opacity
- [x] Buttons have 56dp height, 12dp border radius
- [x] All widgets pass accessibility contrast requirements
- [x] Widget tests achieve 100% coverage for shared widgets

---

## 1.2 Onboarding Flow (4 Screens) ✅ COMPLETED

### Priority: HIGH | Est: 5 days
**Status:** Completed December 14, 2025

### Screen 3.1: Welcome Carousel
**File:** `lib/features/onboarding/screens/welcome_screen.dart`

- [x] **TEST FIRST:** Write integration test for carousel navigation
- [x] Implement PageView with 3 cards
- [x] Card 1: "Your AI Repair Partner" with eye illustration
- [x] Card 2: "Visual Verification" with traffic light animation
- [x] Card 3: "Mistake Insurance" with shield icon
- [x] Page indicator dots at bottom
- [x] Skip button (top right)
- [x] "Get Started" CTA button
- [x] "Already have an account? Sign In" text link

### Screen 3.2: Permission Requests
**File:** `lib/features/onboarding/screens/permissions_screen.dart`

- [x] **TEST FIRST:** Write tests for permission state handling
- [x] Camera permission request with context explanation
- [x] Microphone permission request
- [x] Notification permission request
- [x] Handle "Not Now" with limitations warning modal ✅ *Completed Dec 14, 2025*
- [x] Track permission states in provider

### Screen 3.3: Account Creation
**File:** `lib/features/onboarding/screens/account_screen.dart`

- [x] **TEST FIRST:** Write tests for auth flow states
- [x] Apple Sign-In button (white bg, Apple icon)
- [x] Google Sign-In button (white bg, Google icon)
- [x] Email Sign-In button (outlined)
- [x] "Continue as Guest" ghost button
- [x] Terms/Privacy Policy footer with links ✅ *Completed Dec 14, 2025*
- [x] Implement `AuthProvider` with Riverpod

### Screen 3.4: First Task Suggestion
**File:** `lib/features/onboarding/screens/first_task_screen.dart`

- [x] **TEST FIRST:** Write navigation tests
- [x] 2x2 grid of suggestion cards
- [x] Cards: Cook Something 🍳, Fix Something 🔧, Scan My Device 📱, Just Explore 👀
- [x] Tap handling routes to appropriate flow

### Acceptance Criteria
- [x] Complete onboarding flow from splash to home ✅ *Verified Dec 14, 2025*
- [x] Permissions properly requested and stored ✅ *Verified Dec 14, 2025*
- [x] Anonymous auth creates Firebase user ✅ *Verified Dec 14, 2025*
- [x] Social auth (Apple/Google) functional *(Buttons present, show "Coming Soon" - full implementation deferred)*
- [x] All 4 screens match UI/UX spec designs ✅ *Verified Dec 14, 2025*

---

## 1.3 Home & Navigation (3 Screens)

### Priority: HIGH | Est: 4 days

### Screen 4.1: Home - The Briefing
**File:** `lib/features/home/screens/home_screen.dart`

- [ ] **TEST FIRST:** Write tests for Omni-Bar functionality
- [ ] Header with greeting, subscription badge, notification bell
- [ ] **Omni-Bar** (prominent glass pill):
  - [ ] Placeholder text: "Paste URL, describe task, or say 'Hey TrueStep'..."
  - [ ] Tap expands to input mode
  - [ ] URL detection auto-triggers ingestion
  - [ ] Voice activation integration
- [ ] Recent Sessions carousel (if any)
- [ ] Featured Guides section
- [ ] Quick Actions grid

### Screen 4.2: Bottom Navigation
**File:** `lib/app/widgets/bottom_nav.dart`

- [ ] **TEST FIRST:** Write navigation state tests
- [ ] 5 tabs: Search, Community, Quick+, History, Profile
- [ ] Central Quick+ button (FAB style)
- [ ] Active state with glow effect
- [ ] Badge indicators for notifications

### Screen 4.3: Search/Browse
**File:** `lib/features/search/screens/search_screen.dart`

- [ ] **TEST FIRST:** Write search query tests
- [ ] Search bar with voice input option
- [ ] Category filters (Culinary, DIY, etc.)
- [ ] Results list with guide cards
- [ ] Empty state handling

### Acceptance Criteria
- [ ] Bottom nav persists across main screens
- [ ] Omni-Bar accepts URL, text, and voice input
- [ ] Navigation state preserved correctly
- [ ] Search returns relevant guides

---

## 1.4 Guide Ingestion Service

### Priority: CRITICAL | Est: 5 days

### Tasks

#### VisualStateGraph Data Model
**File:** `lib/core/models/visual_state_graph.dart`

- [ ] **TEST FIRST:** Write serialization tests
- [ ] Define `VisualStateGraph` class with Freezed
- [ ] Define `GuideStep` class with:
  - `stepId`, `title`, `instruction`
  - `successCriteria` (what to visually verify)
  - `referenceImageUrl` (optional)
  - `estimatedDuration`
  - `warnings` list
  - `tools` required for this step
- [ ] JSON serialization/deserialization

#### URL Ingestion
**File:** `lib/services/ingestion_service.dart`

- [ ] **TEST FIRST:** Write URL parsing tests with mock HTML
- [ ] URL input detection in Omni-Bar
- [ ] Web scraping service (using dio)
- [ ] Gemini API call to parse scraped content
- [ ] Transform to VisualStateGraph
- [ ] Cache parsed guide in Firestore

#### Text/Voice Ingestion
- [ ] **TEST FIRST:** Write text parsing tests
- [ ] Natural language task description
- [ ] Gemini API call to generate VisualStateGraph
- [ ] Guide library search integration

### Firestore Guide Schema
```json
{
  "guideId": "string",
  "title": "string",
  "category": "culinary | diy",
  "sourceUrl": "string | null",
  "steps": [
    {
      "stepId": 1,
      "title": "string",
      "instruction": "string",
      "successCriteria": "string",
      "referenceImageUrl": "string | null",
      "estimatedDuration": 60,
      "warnings": ["string"],
      "tools": ["string"]
    }
  ],
  "totalDuration": 1800,
  "difficulty": "easy | medium | hard",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Acceptance Criteria
- [ ] URL ingestion works for recipe sites
- [ ] Text description generates valid guide
- [ ] VisualStateGraph validates correctly
- [ ] Guide stored in Firestore

---

## 1.5 Camera & Voice Services

### Priority: CRITICAL | Est: 7 days

### Camera Service
**File:** `lib/services/camera_service.dart`

- [ ] **TEST FIRST:** Write camera initialization tests
- [ ] Camera initialization with error handling
- [ ] ImageStream capture at configurable FPS
- [ ] Frame preprocessing (resize, format)
- [ ] Camera pause/resume for battery
- [ ] Torch control
- [ ] Front/back camera switching

### Voice Service
**File:** `lib/services/voice_service.dart`

- [ ] **TEST FIRST:** Write voice command recognition tests
- [ ] Speech-to-text initialization
- [ ] Wake word detection: "Hey TrueStep"
- [ ] Command recognition:
  - "Next step" / "Go back"
  - "Repeat" / "What's next"
  - "Pause" / "Resume"
  - "Stop" / "Cancel"
- [ ] Text-to-speech for instructions
- [ ] Audio ducking during TTS

### Voice Command Map
```dart
const Map<String, SessionCommand> voiceCommands = {
  'next': SessionCommand.nextStep,
  'next step': SessionCommand.nextStep,
  'go back': SessionCommand.previousStep,
  'back': SessionCommand.previousStep,
  'repeat': SessionCommand.repeatInstruction,
  'what\'s next': SessionCommand.previewNext,
  'pause': SessionCommand.pause,
  'resume': SessionCommand.resume,
  'stop': SessionCommand.stop,
  'help': SessionCommand.help,
};
```

### Acceptance Criteria
- [ ] Camera stream functional at 30fps
- [ ] Voice commands recognized with >90% accuracy
- [ ] TTS reads instructions clearly
- [ ] Battery impact acceptable (<15% per hour active use)

---

## 1.6 Session Flow (7 Screens) - Core Sentinel Loop

### Priority: CRITICAL | Est: 10 days

### Screen 6.1: Guide Preview
**File:** `lib/features/session/screens/guide_preview_screen.dart`

- [ ] **TEST FIRST:** Write navigation and data loading tests
- [ ] Guide title, source, duration estimate
- [ ] Step count and difficulty indicator
- [ ] Tools required list
- [ ] "Start Session" primary CTA
- [ ] "Save for Later" secondary action

### Screen 6.2: Calibration
**File:** `lib/features/session/screens/calibration_screen.dart`

- [ ] **TEST FIRST:** Write calibration flow tests
- [ ] Camera preview full screen
- [ ] Reference object prompt (coin for scale)
- [ ] Bounding box overlay for positioning
- [ ] "Calibration Complete" confirmation
- [ ] Skip option with accuracy warning

### Screen 6.3: Tool Audit
**File:** `lib/features/session/screens/tool_audit_screen.dart`

- [ ] **TEST FIRST:** Write tool detection tests
- [ ] Required tools checklist from guide
- [ ] YOLO-based tool detection (Tier 1)
- [ ] Manual "I have this" checkboxes
- [ ] Missing tool warnings
- [ ] "All Tools Ready" CTA

### Screen 6.4: Active Session (Traffic Light UI)
**File:** `lib/features/session/screens/active_session_screen.dart`

- [ ] **TEST FIRST:** Write state machine tests for Sentinel states
- [ ] **Traffic Light Header Widget:**
  - [ ] GREEN state: Eye icon + "Watching..." + pulse animation
  - [ ] YELLOW state: Waveform + "Verifying..." + processing animation
  - [ ] RED state: Stop hand + "STOP" + shake animation
- [ ] Current step instruction card
- [ ] Progress indicator (step X of Y)
- [ ] Voice command listening indicator
- [ ] Manual "Next Step" / "Previous Step" buttons
- [ ] Pause/Resume controls
- [ ] Exit session with confirmation

### Traffic Light State Machine
```dart
enum SentinelState {
  watching,    // GREEN - On-device tracking
  verifying,   // YELLOW - Gemini Flash verification
  intervention // RED - Error/danger detected
}

class SessionStateMachine {
  // GREEN: YOLO detects relevant activity
  // → YELLOW: Send frame to Gemini for verification
  // → GREEN: Step verified, advance
  // → RED: Error detected, show intervention
}
```

### Screen 6.5: Step Transition
**File:** `lib/features/session/widgets/step_transition_overlay.dart`

- [ ] **TEST FIRST:** Write animation tests
- [ ] Success checkmark animation (Lottie)
- [ ] "Step X Complete!" message
- [ ] Auto-advance countdown (3 seconds)
- [ ] Next step preview

### Screen 6.6: Intervention Modal
**File:** `lib/features/session/widgets/intervention_modal.dart`

- [ ] **TEST FIRST:** Write intervention scenario tests
- [ ] RED state full-screen overlay
- [ ] Issue description from AI
- [ ] Reference image comparison (if available)
- [ ] "I Fixed It" button → re-verify
- [ ] "Show Me How" button → detailed help
- [ ] "Skip This Step" with warning

### Screen 6.7: Session Completion
**File:** `lib/features/session/screens/completion_screen.dart`

- [ ] **TEST FIRST:** Write completion data tests
- [ ] Confetti animation (Lottie)
- [ ] Session summary stats:
  - Total time
  - Steps completed
  - Interventions triggered
  - AI confidence score
- [ ] "Share to Community" CTA
- [ ] "Save Recording" option
- [ ] "Done" returns to home

### Session Provider (State Management)
**File:** `lib/features/session/providers/session_provider.dart`

- [ ] **TEST FIRST:** Write comprehensive state transition tests
- [ ] Session lifecycle management
- [ ] Current step tracking
- [ ] Sentinel state machine
- [ ] Recording state
- [ ] Timer tracking
- [ ] Step verification results

### Acceptance Criteria
- [ ] Complete session flow from preview to completion
- [ ] Traffic light states transition correctly
- [ ] Voice commands work throughout session
- [ ] Interventions pause session appropriately
- [ ] Session data persists to Firestore

---

## 1.7 AI Service Integration (Gemini)

### Priority: CRITICAL | Est: 7 days

### Tier 2: Gemini Flash Verification
**File:** `lib/services/ai_service.dart`

- [ ] **TEST FIRST:** Write AI response parsing tests
- [ ] Firebase AI (Gemini) initialization
- [ ] Frame verification prompt engineering
- [ ] Success criteria matching logic
- [ ] Confidence score extraction
- [ ] Error/issue detection
- [ ] Intervention message generation

### Verification Prompt Template
```dart
const String verificationPrompt = '''
You are a visual verification agent for TrueStep.

Current Task Step: {stepTitle}
Success Criteria: {successCriteria}
Reference Description: {referenceDescription}

Analyze the provided image and determine:
1. Is the step completed successfully? (true/false)
2. Confidence score (0.0 to 1.0)
3. If not complete, what specific issue do you see?
4. Is there any safety concern? (true/false)

Respond in JSON format:
{
  "verified": boolean,
  "confidence": float,
  "issue": string | null,
  "safetyAlert": boolean,
  "suggestion": string | null
}
''';
```

### WebSocket Streaming (for Live API)
- [ ] **TEST FIRST:** Write WebSocket connection tests
- [ ] WebSocket connection to Gemini Live API
- [ ] Bi-directional audio streaming
- [ ] Frame batching (send every 2 seconds)
- [ ] Connection keep-alive
- [ ] Reconnection logic

### Acceptance Criteria
- [ ] Gemini Flash responds in <1 second
- [ ] Verification accuracy >85% on test set
- [ ] Safety alerts trigger immediately
- [ ] Graceful handling of API errors

---

## 1.8 Session Recording

### Priority: HIGH | Est: 4 days

### Recording Service
**File:** `lib/services/recording_service.dart`

- [ ] **TEST FIRST:** Write recording lifecycle tests
- [ ] Video recording from camera stream
- [ ] Compression settings (720p, 30fps, H.264)
- [ ] Background recording during session
- [ ] Pause/resume recording
- [ ] Generate 3-second verification clips per step
- [ ] Local storage during session
- [ ] Upload to Firebase Storage on completion

### Storage Schema
```
Firebase Storage Structure:
/recordings/{userId}/{sessionId}/
  ├── full_session.mp4
  └── clips/
      ├── step_1.mp4
      ├── step_2.mp4
      └── ...
```

### Session Firestore Document
**File:** `lib/core/models/session.dart`

```dart
@freezed
class Session with _$Session {
  factory Session({
    required String sessionId,
    required String userId,
    required String guideId,
    required String inputMethod, // 'url' | 'text' | 'voice' | 'image'
    required DateTime startedAt,
    DateTime? completedAt,
    required DateTime expiresAt, // startedAt + 30 days
    Recording? recording,
    required List<StepLog> stepLogs,
    required MistakeInsurance mistakeInsurance,
    CommunityShare? communityShare,
  }) = _Session;
}

@freezed
class Recording with _$Recording {
  factory Recording({
    required String fullSessionUrl,
    required int duration,
    required int sizeBytes,
    required int retentionDays, // 30
  }) = _Recording;
}
```

### Acceptance Criteria
- [ ] Full session recorded without dropped frames
- [ ] Verification clips generated per step
- [ ] Upload completes within 2 minutes of session end
- [ ] 30-day expiration metadata set correctly

---

## 1.9 MVP Polish & Testing

### Priority: HIGH | Est: 5 days

### Integration Testing
- [ ] End-to-end test: Onboarding → Home → Session → Completion
- [ ] Test URL ingestion with 10 different recipe sites
- [ ] Test voice commands in noisy environment
- [ ] Test session recording on both platforms
- [ ] Battery drain testing (1-hour session)
- [ ] Network interruption recovery testing

### Performance Optimization
- [ ] Profile frame processing pipeline
- [ ] Optimize Gemini API call frequency
- [ ] Implement frame dropping under load
- [ ] Memory leak detection and fixes
- [ ] Startup time optimization (<3 seconds)

### Bug Fixes & Edge Cases
- [ ] Handle camera permission revoked mid-session
- [ ] Handle microphone permission revoked
- [ ] Handle network loss during session
- [ ] Handle app backgrounding during session
- [ ] Handle low storage space

### Acceptance Criteria (MVP Launch)
- [ ] 500+ beta users recruited
- [ ] 85%+ task completion rate
- [ ] <3% false positive verification rate
- [ ] Crash-free rate >99%
- [ ] App Store / Play Store ready

---

# PHASE 2: "Mechanic" Alpha (Weeks 9-16)
**Goal:** Image input, Tier 1 YOLO gatekeeper, 30-day retention, DIY vertical

---

## 2.1 Image Input Ingestion

### Priority: HIGH | Est: 5 days

### Image Picker Integration
**File:** `lib/features/ingestion/screens/image_input_screen.dart`

- [ ] **TEST FIRST:** Write image processing tests
- [ ] Camera capture option
- [ ] Gallery picker option
- [ ] Image preprocessing (resize, compress)
- [ ] Multiple image support (e.g., broken item + model label)

### Image Analysis Service
**File:** `lib/services/image_analysis_service.dart`

- [ ] **TEST FIRST:** Write image recognition tests
- [ ] Gemini Vision API integration
- [ ] Device identification from photo
- [ ] Damage/issue detection
- [ ] Model/serial number OCR
- [ ] Ingredient recognition (culinary)
- [ ] Match to guide library

### Use Cases
```dart
enum ImageInputUseCase {
  brokenItem,      // AI identifies device, diagnoses issue
  modelLabel,      // OCR reads model number, finds exact guide
  physicalManual,  // OCR paper instructions → VisualStateGraph
  assembledRef,    // Photo of finished item as target state
  ingredients,     // Recipe suggestions based on visible items
}
```

### Acceptance Criteria
- [ ] Device identification accuracy >80%
- [ ] OCR extracts model numbers correctly
- [ ] Matched guides are relevant
- [ ] Processing time <5 seconds

---

## 2.2 Tier 1: YOLO Gatekeeper (On-Device ML)

### Priority: CRITICAL | Est: 8 days

### YOLO Model Integration
**File:** `lib/services/yolo_service.dart`

- [ ] **TEST FIRST:** Write detection accuracy tests
- [ ] YOLOv11-nano model integration via `ultralytics_yolo`
- [ ] CoreML export for iOS
- [ ] TensorFlow Lite for Android
- [ ] Custom model training for:
  - Hand detection
  - Common tool detection (screwdriver, wrench, etc.)
  - Cooking utensil detection
  - Safety hazard detection

### Gatekeeper Logic
```dart
class YOLOGatekeeper {
  // Returns true when meaningful activity detected
  // This triggers Tier 2 (Gemini) verification
  
  bool shouldTriggerVerification(List<Detection> detections) {
    // Hand in frame + relevant tool/object
    // Movement detected in ROI
    // State change from previous frame
  }
}
```

### Performance Targets
- [ ] <10ms inference time on-device
- [ ] 30fps processing without frame drops
- [ ] Battery usage <10% per hour (Tier 1 only)

### Model Classes (Initial)
```dart
const List<String> yoloClasses = [
  // Hands
  'hand_left', 'hand_right',
  
  // DIY Tools
  'screwdriver', 'wrench', 'pliers', 'hammer',
  'drill', 'soldering_iron', 'multimeter',
  
  // Cooking
  'knife', 'spatula', 'whisk', 'pan', 'pot',
  'cutting_board', 'measuring_cup',
  
  // Electronics
  'phone', 'laptop', 'tablet', 'battery',
  'screen', 'cable', 'connector',
  
  // Safety
  'fire', 'smoke', 'spill', 'sharp_edge',
];
```

### Acceptance Criteria
- [ ] Hand detection accuracy >95%
- [ ] Tool detection accuracy >85%
- [ ] False trigger rate <10%
- [ ] Runs smoothly on iPhone 12 / Pixel 6

---

## 2.3 DIY Vertical Enhancement

### Priority: HIGH | Est: 4 days

### iFixit Integration Research
- [ ] Document iFixit guide URL structure
- [ ] Test scraping iFixit guide pages
- [ ] Map iFixit step format to VisualStateGraph
- [ ] Handle iFixit image references

### DIY-Specific Features
- [ ] **TEST FIRST:** Write tool audit matching tests
- [ ] Enhanced tool audit with purchase links
- [ ] Part number extraction from guides
- [ ] Difficulty rating calibration for DIY
- [ ] Safety warning prominence for electronics

### Acceptance Criteria
- [ ] 100+ iFixit guides successfully ingested
- [ ] Tool audit matches DIY requirements
- [ ] Safety warnings display for battery/electrical steps

---

## 2.4 Data Retention Implementation

### Priority: HIGH | Est: 4 days

### 30-Day TTL System
**File:** `functions/src/cleanup.ts` (Firebase Functions)

- [ ] **TEST FIRST:** Write cleanup function tests
- [ ] Scheduled Cloud Function: `cleanupExpiredSessions`
- [ ] Runs daily at 3:00 AM UTC
- [ ] Query: WHERE `expiresAt` < NOW() AND `mistakeInsurance.evidencePreserved` == false
- [ ] Delete Storage files (full recording + clips)
- [ ] Update Firestore document (remove URLs, keep metadata)

### User Notification System
- [ ] 7-day warning email before expiry
- [ ] In-app notification 3 days before
- [ ] "Share to Community to preserve" CTA
- [ ] "Extend for Insurance" option (if eligible)

### Firestore Indexes
```javascript
// Required composite indexes for cleanup queries
{
  collectionGroup: "sessions",
  fields: [
    { fieldPath: "expiresAt", order: "ASCENDING" },
    { fieldPath: "mistakeInsurance.evidencePreserved", order: "ASCENDING" }
  ]
}
```

### Acceptance Criteria
- [ ] Cleanup function processes 1000+ sessions/run
- [ ] Storage costs remain predictable
- [ ] Users notified before deletion
- [ ] Insurance-preserved sessions retained correctly

---

## 2.5 Session History (2 Screens)

### Priority: MEDIUM | Est: 3 days

### Screen 8.1: Session History List
**File:** `lib/features/history/screens/history_list_screen.dart`

- [ ] **TEST FIRST:** Write list loading and filtering tests
- [ ] Chronological list of past sessions
- [ ] Filter by: All, Completed, In Progress
- [ ] Search by guide title
- [ ] Session cards showing:
  - Guide thumbnail
  - Title and date
  - Completion status
  - Recording availability badge
  - Days until expiry

### Screen 8.2: Session Detail
**File:** `lib/features/history/screens/session_detail_screen.dart`

- [ ] **TEST FIRST:** Write playback and claim navigation tests
- [ ] Full session playback (if recording available)
- [ ] Step-by-step verification log
- [ ] AI confidence scores per step
- [ ] "File Insurance Claim" CTA (if eligible)
- [ ] "Share to Community" CTA
- [ ] "Delete Recording" option

### Acceptance Criteria
- [ ] History loads within 2 seconds
- [ ] Video playback smooth
- [ ] Expiry countdown accurate
- [ ] All actions navigate correctly

---

# PHASE 3: Beta & Monetization (Weeks 17-24)
**Goal:** Stripe/RevenueCat integration, Mistake Insurance claims flow, paywall

---

## 3.1 RevenueCat Integration

### Priority: CRITICAL | Est: 5 days

### Setup
- [ ] Create RevenueCat project
- [ ] Configure iOS App Store Connect products
- [ ] Configure Google Play Console products
- [ ] Install `purchases_flutter` package

### Products Configuration
```dart
// Culinary Products
const String culinaryMonthly = 'truestep_culinary_monthly'; // $14.99
const String culinaryAnnual = 'truestep_culinary_annual';   // $99.99

// DIY Products (Consumable)
const String diySessionSingle = 'truestep_diy_session';     // $4.99
const String diySessionPack5 = 'truestep_diy_pack_5';       // $19.99
const String mistakeInsurance = 'truestep_insurance';       // $2.99 add-on
```

### Entitlement Service
**File:** `lib/services/entitlement_service.dart`

- [ ] **TEST FIRST:** Write entitlement state tests
- [ ] Check subscription status
- [ ] Track consumable session credits
- [ ] Gate premium features appropriately
- [ ] Handle subscription expiry gracefully
- [ ] Restore purchases flow

### Acceptance Criteria
- [ ] Subscriptions purchase and restore correctly
- [ ] Session credits decrement properly
- [ ] Premium features gated accurately
- [ ] Works offline with cached entitlements

---

## 3.2 Paywall Screens (2 Screens)

### Priority: HIGH | Est: 4 days

### Screen 11.1: Subscription Paywall (Culinary)
**File:** `lib/features/paywall/screens/culinary_paywall_screen.dart`

- [ ] **TEST FIRST:** Write paywall presentation tests
- [ ] Feature comparison: Free vs Pro
- [ ] Monthly/Annual toggle
- [ ] Price display with localization
- [ ] "Start Free Trial" CTA (if applicable)
- [ ] "Restore Purchases" link
- [ ] Terms and refund policy

### Screen 11.2: Session Purchase (DIY)
**File:** `lib/features/paywall/screens/diy_purchase_screen.dart`

- [ ] **TEST FIRST:** Write purchase flow tests
- [ ] Single session: $4.99
- [ ] 5-pack: $19.99 (20% savings badge)
- [ ] Mistake Insurance add-on: +$2.99
- [ ] Clear value proposition
- [ ] Purchase button with loading state

### Acceptance Criteria
- [ ] Paywalls appear at correct gates
- [ ] Purchases complete without errors
- [ ] Pricing displays correctly per region
- [ ] A/B test infrastructure ready

---

## 3.3 Mistake Insurance Claims Flow (5 Screens)

### Priority: HIGH | Est: 6 days

### Screen 9.1: Insurance Eligibility Check
**File:** `lib/features/claims/screens/eligibility_screen.dart`

- [ ] **TEST FIRST:** Write eligibility logic tests
- [ ] Check session has Mistake Insurance purchased
- [ ] Verify recording still available
- [ ] Display coverage terms
- [ ] "Start Claim" CTA if eligible

### Screen 9.2: Damage Documentation
**File:** `lib/features/claims/screens/damage_documentation_screen.dart`

- [ ] **TEST FIRST:** Write photo capture tests
- [ ] Photo capture of damaged item
- [ ] Multi-photo support
- [ ] Damage description text field
- [ ] Receipt/purchase proof upload (optional)

### Screen 9.3: Session Evidence Review
**File:** `lib/features/claims/screens/evidence_review_screen.dart`

- [ ] Verification clips playback
- [ ] Step where error occurred selection
- [ ] AI confidence display per step
- [ ] "This is where it went wrong" marker

### Screen 9.4: Claim Submission
**File:** `lib/features/claims/screens/claim_submission_screen.dart`

- [ ] Claim summary review
- [ ] Terms acceptance checkbox
- [ ] "Submit Claim" CTA
- [ ] Extend evidence retention to 90 days on submit

### Screen 9.5: Claim Status Tracking
**File:** `lib/features/claims/screens/claim_status_screen.dart`

- [ ] Claim status: Submitted → Under Review → Approved/Denied
- [ ] Timeline of claim events
- [ ] Payout information (if approved)
- [ ] Appeal option (if denied)

### Claims Firestore Schema
```json
{
  "claimId": "claim_xyz",
  "sessionId": "abc123",
  "userId": "user_xyz",
  "status": "submitted | under_review | approved | denied | appealed",
  "submittedAt": "timestamp",
  "damagePhotos": ["url1", "url2"],
  "damageDescription": "string",
  "claimedAmount": 50.00,
  "approvedAmount": null,
  "reviewerNotes": null,
  "resolvedAt": null
}
```

### Acceptance Criteria
- [ ] Claims submitted within 30-day window
- [ ] Evidence preserved on claim submission
- [ ] Admin review interface functional
- [ ] Payout tracking accurate

---

## 3.4 Free Tier Enforcement

### Priority: HIGH | Est: 3 days

### Session Limits
- [ ] **TEST FIRST:** Write limit enforcement tests
- [ ] Track free session count per month
- [ ] Display remaining sessions on home
- [ ] Soft paywall at limit (show paywall, allow dismiss once)
- [ ] Hard paywall after dismiss

### Gating Logic
```dart
class SessionGate {
  Future<GateResult> canStartSession(User user, Guide guide) async {
    if (user.hasProSubscription) return GateResult.allowed;
    if (guide.category == 'diy' && user.diyCredits > 0) {
      return GateResult.allowed;
    }
    if (guide.category == 'culinary') {
      final monthlyCount = await getMonthlySessionCount(user.id);
      if (monthlyCount < 3) return GateResult.allowed;
    }
    return GateResult.paywallRequired;
  }
}
```

### Acceptance Criteria
- [ ] Free users limited to 3 culinary sessions/month
- [ ] DIY sessions require purchase
- [ ] Paywall displays at appropriate times
- [ ] Premium users never see paywall

---

# PHASE 4: TrueStep Community (Weeks 25-32)
**Goal:** Video sharing platform, moderation, creator profiles

---

## 4.1 Community Feed (4 Screens)

### Priority: HIGH | Est: 6 days

### Screen 7.1: Community Feed
**File:** `lib/features/community/screens/community_feed_screen.dart`

- [ ] **TEST FIRST:** Write feed loading and pagination tests
- [ ] Infinite scroll video feed
- [ ] Category filter tabs (All, Culinary, DIY)
- [ ] Sort: Trending, Recent, Most Helpful
- [ ] Video card preview:
  - Thumbnail with play icon
  - Guide title
  - Creator display name
  - View count, likes, helpful votes
  - Duration badge

### Screen 7.2: Video Player
**File:** `lib/features/community/screens/video_player_screen.dart`

- [ ] **TEST FIRST:** Write playback control tests
- [ ] Full-screen video playback
- [ ] Playback controls (play/pause, seek, speed)
- [ ] Step markers on timeline
- [ ] Like button
- [ ] "Mark as Helpful" button
- [ ] Share button
- [ ] Report button

### Screen 7.3: Creator Profile
**File:** `lib/features/community/screens/creator_profile_screen.dart`

- [ ] Display name and avatar
- [ ] Bio/about section
- [ ] Stats: Videos shared, total views, helpful votes
- [ ] Video grid of their shares
- [ ] Follow button (future feature prep)

### Screen 7.4: Share to Community Modal
**File:** `lib/features/community/widgets/share_modal.dart`

- [ ] **TEST FIRST:** Write sharing flow tests
- [ ] Recording preview
- [ ] Edit title option
- [ ] Add tags
- [ ] Privacy notice (visible to all users)
- [ ] "Share" CTA
- [ ] Processing/upload indicator

### Acceptance Criteria
- [ ] Feed loads within 3 seconds
- [ ] Video playback smooth
- [ ] Interactions persist correctly
- [ ] Share upload completes reliably

---

## 4.2 Content Moderation

### Priority: HIGH | Est: 5 days

### AI Pre-Screening
**File:** `functions/src/moderation.ts`

- [ ] **TEST FIRST:** Write moderation classification tests
- [ ] Trigger on new community upload
- [ ] Gemini Vision safety analysis
- [ ] Auto-reject explicit content
- [ ] Flag borderline content for human review
- [ ] Auto-approve clean content

### Moderation Queue (Admin)
- [ ] Admin web dashboard (basic)
- [ ] Review flagged videos
- [ ] Approve/Reject actions
- [ ] Ban user capability
- [ ] Appeal handling

### Community Guidelines Enforcement
```dart
enum ModerationStatus {
  pending,     // Awaiting AI review
  autoApproved, // AI passed, visible
  flagged,     // Needs human review
  approved,    // Human approved
  rejected,    // Content removed
  appealed,    // User appealing rejection
}
```

### Acceptance Criteria
- [ ] <1% inappropriate content reaches feed
- [ ] Moderation queue turnaround <24 hours
- [ ] Appeals process functional
- [ ] Banned users cannot upload

---

## 4.3 Community Metrics & Analytics

### Priority: MEDIUM | Est: 3 days

### Engagement Tracking
- [ ] View count increment on play
- [ ] Like/unlike toggling
- [ ] "Helpful" votes per video
- [ ] Watch time tracking
- [ ] Share event tracking

### Creator Analytics (Future Premium Feature Prep)
- [ ] Total views dashboard
- [ ] Engagement rate calculation
- [ ] Top performing videos
- [ ] Viewer demographics (anonymized)

### Acceptance Criteria
- [ ] Metrics update in real-time
- [ ] Analytics display accurately
- [ ] No duplicate counting

---

## 4.4 Settings & Account (2 Screens)

### Priority: MEDIUM | Est: 3 days

### Screen 10.1: Settings
**File:** `lib/features/settings/screens/settings_screen.dart`

- [ ] **TEST FIRST:** Write settings persistence tests
- [ ] Account section: Email, linked accounts
- [ ] Subscription status and management
- [ ] Notification preferences
- [ ] Voice control settings (wake word on/off)
- [ ] Video quality preferences
- [ ] Storage usage display
- [ ] Clear cache option
- [ ] Privacy settings
- [ ] Help & Support link
- [ ] Legal: Terms, Privacy Policy, Licenses

### Screen 10.2: Account Management
**File:** `lib/features/settings/screens/account_screen.dart`

- [ ] Edit display name
- [ ] Change email
- [ ] Link/unlink social accounts
- [ ] Delete account (with confirmation)
- [ ] Export my data request

### Acceptance Criteria
- [ ] Settings persist across sessions
- [ ] Account deletion removes all user data
- [ ] Subscription management links work

---

# PHASE 5: Platform & Data (2027+)
**Goal:** SDK, B2B2C, research licensing, AR glasses

---

## 5.1 TrueStep SDK (Future)

### Scope
- [ ] Embeddable verification widget
- [ ] White-label options
- [ ] API documentation
- [ ] Sample integrations

---

## 5.2 B2B2C Partnerships (Future)

### Potential Partners
- [ ] iFixit official integration
- [ ] Appliance manufacturers
- [ ] Recipe platforms
- [ ] Trade schools

---

## 5.3 Research Data Licensing (Future)

### Dataset Preparation
- [ ] Anonymization pipeline
- [ ] Consent management
- [ ] Data export formats
- [ ] Licensing agreements

---

## 5.4 AR Glasses Support (Future)

### Platform Targets
- [ ] Apple Vision Pro
- [ ] Meta Quest
- [ ] Ray-Ban Meta

---

# ERROR & EDGE STATES (4 Screens)

## Error Screens Reference

### Screen 12.1: No Camera Permission
- Full-screen error state
- Explanation of why camera is needed
- "Open Settings" CTA
- "Continue Without Camera" (limited mode)

### Screen 12.2: No Internet Connection
- Offline indicator
- Cached content availability
- "Retry Connection" button
- Queue actions for sync

### Screen 12.3: AI Service Unavailable
- Graceful degradation message
- Manual mode option
- Retry with backoff
- Contact support link

### Screen 12.4: Session Recovery
- App crash recovery
- Resume from last verified step
- Recording recovery status
- "Resume Session" / "Start Over" options

---

# TESTING REQUIREMENTS SUMMARY

## Test Coverage Targets

| Layer | Coverage Target |
|-------|-----------------|
| Unit Tests (Services) | 90% |
| Unit Tests (Providers) | 85% |
| Widget Tests | 80% |
| Integration Tests | 70% |
| E2E Tests | Critical paths |

## Critical Path E2E Tests

1. [ ] Onboarding → First Session → Completion
2. [ ] URL Ingestion → Session → Community Share
3. [ ] Image Input → Guide Match → Session
4. [ ] Session → Insurance Claim → Submission
5. [ ] Purchase Flow → Session Access
6. [ ] Community Upload → Moderation → Feed Display

## Performance Benchmarks

| Metric | Target |
|--------|--------|
| App Launch | <3 seconds |
| Gemini Response | <1 second |
| YOLO Inference | <10ms |
| Video Upload | <2 minutes for 30-min session |
| Feed Load | <3 seconds |
| Battery (Active Session) | <15%/hour |

---

# LAUNCH CHECKLIST

## Pre-Launch (Week Before)

- [ ] All critical bugs resolved
- [ ] Performance benchmarks met
- [ ] App Store assets prepared (screenshots, description)
- [ ] Privacy policy and terms updated
- [ ] Analytics and crash reporting verified
- [ ] Beta tester feedback addressed
- [ ] Load testing completed

## Launch Day

- [ ] App Store submission approved
- [ ] Play Store submission approved
- [ ] Marketing materials live
- [ ] Support channels ready
- [ ] Monitoring dashboards active
- [ ] On-call rotation scheduled

## Post-Launch (Week 1)

- [ ] Monitor crash rates (<1%)
- [ ] Monitor API error rates
- [ ] Respond to user reviews
- [ ] Hotfix deployment ready
- [ ] Gather initial metrics
- [ ] Plan iteration based on feedback

---

*— End of Development Roadmap —*
