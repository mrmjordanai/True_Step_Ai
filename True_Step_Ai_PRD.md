# TRUESTEP
## AI Visual Verification
### Product Requirements Document

---

| Field | Value |
|-------|-------|
| **Version** | 4.0 |
| **Date** | December 12, 2025 |
| **Platform** | Flutter (iOS, Android) + Firebase |
| **Status** | Draft - Ready for Review |

---

## 1. Executive Summary

TrueStep is an AI-powered visual verification agent that bridges the gap between instructional content and physical task execution. Unlike traditional step-by-step guides or tutorial videos, TrueStep actively watches, understands, and guides users through complex physical tasks in real-time using advanced computer vision and large language models.

**Core Value Proposition:** *"Don't just show me how. Watch me do it."*

The core innovation is Visual State Verification: TrueStep doesn't simply play instructions sequentially. Instead, it monitors the user's progress through the device camera and only advances to the next step when it visually confirms the current step is complete. This creates a sentinel loop that catches mistakes before they become costly problems.

### 1.1 Product Vision

To become the trusted "second pair of eyes" for anyone performing hands-on tasks, from home cooks wanting perfect results to DIY enthusiasts tackling complex repairs. TrueStep represents the evolution from AI as a chatbot to AI as a true physical-world agent.

### 1.2 Target Launch Verticals

1. **Culinary ("Sous-Chef"):** High-frequency daily use case with distinct visual state changes (browning, boiling, emulsifying)
2. **DIY Repair ("Foreman"):** High-value use case where mistakes can cost hundreds of dollars

---

## 2. Competitive Analysis

The market for AI-assisted physical task guidance is emerging rapidly. Current solutions fall into two categories: Passive Guidance or Human Connection. TrueStep creates a third category: Active Verification.

### 2.1 Full Competitive Landscape

| Competitor | Model | Limitation | TrueStep Advantage |
|------------|-------|------------|-------------------|
| **iFixit FixBot** | AI Chatbot + Guides | Sequential guides. No real-time verification. | Active visual confirmation before advancing |
| **BILT** | 3D Interactive | No feedback loop. Doesn't verify completion. | Confirms physical state before proceeding |
| **YouTube/iFixit** | Passive Video/Text | Linear playback. Hard to pause with dirty hands. | Hands-free sentinel with error prevention |
| **Tinker/Frontdoor** | Human Video Call | Expensive ($40+/call). Availability issues. | AI available 24/7 at fraction of cost |
| **JigSpace** | AR Presentations | Static overlay. Doesn't understand changes. | State tracking understands sequence |

**Competitive Summary:** No current competitor offers Visual State Verification. TrueStep's sentinel loop architecture is a genuine whitespace opportunity.

---

## 3. User Flow & Features

### 3.1 Epic: Ingestion (The "Briefing")

**Goal:** Convert unstructured input (URL, Text, or Image) into a structured VisualStateGraph.

**Supported Input Methods:**

| Input Type | Example | Processing |
|------------|---------|------------|
| **URL** | iFixit guide, recipe blog | Scrape → Gemini parses into VisualStateGraph |
| **Text/Voice** | "Replace MacBook battery" | Search library → Generate VisualStateGraph |
| **Image** | Photo of broken item, model label | Gemini Vision identifies → Match guide |

#### Image Input Use Cases

- **Broken Item Photo:** AI identifies device, diagnoses issue, finds repair guide
- **Model/Serial Label:** Auto-lookup exact model specifications and guides
- **Physical Manual:** OCR paper instructions → interactive VisualStateGraph
- **Assembled Reference:** Photo of finished item as target state
- **Ingredient Photo:** Recipe suggestions based on visible ingredients

### 3.2 Epic: Setup (The "Stage")

- **Calibration UI:** Reference object (coin) for scale estimation
- **Tool Audit:** Tier 1 model scans for required tools
- **Environment Check:** Clean background verification

### 3.3 Epic: Execution (The "Sentinel Loop")

**The Traffic Light System:**

- **GREEN (On-Device):** Tracks hands/tools. Pause when inactive.
- **YELLOW (Gemini Live):** Streaming verification against success criteria.
- **RED (Intervention):** Wrong tool or danger detected. "STOP" alert.

### 3.4 Epic: Completion

- Generate completion summary with optional time-lapse
- Create verification log showing all steps confirmed
- Option to share session to TrueStep Community (see Section 6.4)

---

## 4. Technical Architecture

### 4.1 Frontend: Flutter (iOS/Android)

- **State Management:** Riverpod
- **Camera:** `camera` with custom ImageStream handler
- **Image Picker:** `image_picker` for photo ingestion
- **On-Device ML:** `ultralytics_yolo` with YOLOv11-nano
- **Audio:** `flutter_sound` for PCM 16kHz

### 4.2 Backend: Firebase Services

- **Auth:** Anonymous → Email/Apple Sign-in
- **Firestore:** `guides/`, `sessions/`, `community/` collections
- **Storage:** Session recordings, verification clips, community videos
- **Functions:** `ingestGuide`, `ingestImage`, `cleanupExpiredSessions` (30-day TTL)
- **Scheduled Jobs:** Daily cleanup of expired session recordings

### 4.3 Traffic Light Architecture

| Tier | Technology | Function | Latency |
|------|------------|----------|---------|
| **Tier 1 (Green)** | YOLOv11 via CoreML | Gatekeeper: Hand/tool detection | < 10ms |
| **Tier 2 (Yellow)** | Gemini 2.5 Flash Live | Verifier: Streaming analysis | 600-800ms |
| **Tier 3 (Red)** | Gemini 3 Pro + RAG | Reasoner: Deep analysis | 3-5 sec |

---

## 5. Data Model & Retention Policy

### 5.1 Sessions Collection (with Recording & TTL)

**Collection:** `sessions/{sessionId}`

```json
{
  "sessionId": "abc123",
  "userId": "user_xyz",
  "guideId": "macbook_m2_battery",
  "inputMethod": "image",
  "startedAt": "2026-01-15T10:30:00Z",
  "completedAt": "2026-01-15T11:15:00Z",
  "expiresAt": "2026-02-14T11:15:00Z",

  "recording": {
    "fullSessionUrl": "gs://bucket/recordings/abc123_full.mp4",
    "duration": 2700,
    "sizeBytes": 524288000,
    "retentionDays": 30
  },

  "stepLogs": [
    {
      "stepId": 1,
      "status": "VERIFIED",
      "verificationClipUrl": "gs://bucket/clips/abc123_step1.mp4",
      "timestamp": "2026-01-15T10:35:00Z",
      "aiConfidence": 0.94
    }
  ],

  "mistakeInsurance": {
    "eligible": true,
    "claimFiled": false,
    "evidencePreserved": false
  },

  "communityShare": {
    "shared": false,
    "sharedAt": null,
    "communityId": null
  }
}
```

### 5.2 Data Retention Policy

> **IMPORTANT:** All session recordings are automatically deleted 30 days after session completion to protect user privacy and manage storage costs.

| Data Type | Retention | Notes |
|-----------|-----------|-------|
| Full Session Recording | **30 days** | Auto-deleted via scheduled Cloud Function |
| Verification Clips (3s) | **30 days** | Used for Mistake Insurance claims |
| Session Metadata | **Indefinite** | Anonymized for analytics (no PII) |
| Community Shared Videos | **Indefinite*** | User opts-in; can delete anytime |
| Insurance Claim Evidence | **90 days** | Extended if claim filed before 30-day expiry |

#### Cleanup Implementation

- **Scheduled Function:** `cleanupExpiredSessions` runs daily at 3:00 AM UTC
- **Query:** WHERE `expiresAt` < NOW() AND `mistakeInsurance.evidencePreserved` == false
- **Action:** Delete Storage files, update Firestore document (remove URLs, keep metadata)
- **User Notification:** Email 7 days before expiry: "Your session recording will be deleted. Share to Community to preserve."

---

## 6. Business Model & Unit Economics

### 6.1 Pricing Strategy

#### Culinary - Freemium SaaS

- **Free:** 3 sessions/month, basic recipes
- **Pro ($14.99/mo):** Unlimited, masterclass modes, cloud recording

#### DIY - Pay-per-Guide + Mistake Insurance

- **Per-Session:** $4.99 per repair guide
- **Mistake Insurance:** Up to $100 reimbursement

### 6.2 Unit Economics

| Cost Component | 30 min Session |
|----------------|----------------|
| Tier 1 (CoreML on-device) | $0.00 |
| Tier 2 (Gemini Flash) | ~$0.05 |
| Tier 3 (Gemini Pro) | ~$0.02 |
| Storage (30-day recording) | ~$0.02 |
| **Total Cost** | **~$0.09** |
| **Revenue** | **$4.99** |
| **Gross Margin** | **>98%** |

### 6.3 Mistake Insurance

- **Evidence:** Full session recording + 3-second verification clips per step
- **Claim Window:** Must file within 30 days of session (before auto-deletion)
- **Evidence Preservation:** Filing claim extends retention to 90 days for review
- **Review Process:** Human reviewer watches clips to determine fault

### 6.4 TrueStep Community (Video Sharing Platform)

Users can opt-in to share their completed session recordings with the TrueStep Community. This creates a valuable library of real humans interacting with AI for DIY and culinary tasks.

#### Community Value Proposition

| Stakeholder | Value |
|-------------|-------|
| **Users (Creators)** | Recognition, tips/donations, preserve recordings beyond 30 days, help others |
| **Users (Viewers)** | See real repairs before attempting, learn from others' mistakes, build confidence |
| **TrueStep** | Unique training data, model improvement, marketing content, engagement |
| **Researchers** | Human-AI interaction dataset for physical tasks (potential licensing) |

#### Community Data Asset

Community videos represent a unique dataset: real humans performing physical tasks with AI guidance. This data is valuable for:

- **Model Training:** Improve visual verification accuracy with real-world examples
- **Error Pattern Analysis:** Identify common mistakes to create proactive warnings
- **Guide Improvement:** Find confusing steps based on user hesitation patterns
- **Research Licensing:** Potential revenue from academic/industry researchers studying human-AI collaboration
- **Marketing:** Real success stories for social proof

#### Community Firestore Schema

```json
{
  "communityId": "comm_abc123",
  "sessionId": "abc123",
  "userId": "user_xyz",
  "displayName": "FixItFrank",
  "guideId": "macbook_m2_battery",
  "videoUrl": "gs://bucket/community/comm_abc123.mp4",
  "thumbnailUrl": "gs://bucket/community/thumb_abc123.jpg",
  "sharedAt": "2026-01-15T12:00:00Z",
  "duration": 2700,
  "stats": {
    "views": 1234,
    "likes": 89,
    "helpful": 67
  },
  "tags": ["macbook", "battery", "successful"],
  "aiMetrics": {
    "stepsCompleted": 12,
    "interventions": 2,
    "avgConfidence": 0.91
  },
  "moderation": {
    "status": "approved",
    "reviewedAt": "2026-01-15T14:00:00Z"
  }
}
```

---

## 7. Risk Assessment & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Hallucination** | HIGH | Visual RAG: Compare to reference images, not guess |
| **Privacy (Recordings)** | MEDIUM | 30-day auto-deletion, clear consent UI, opt-in community |
| **Storage Costs** | MEDIUM | 30-day TTL limits storage growth; compressed video |
| **Community Moderation** | MEDIUM | AI pre-screening + human review before publishing |
| **Battery Drain** | MEDIUM | Black Screen Mode + Adaptive Frame Rate |
| **Latency** | LOW | WebSocket direct connection <1s |

---

## 8. Development Roadmap

| Phase | Timeline | Focus | Deliverables |
|-------|----------|-------|--------------|
| **Phase 1** | Weeks 1-8 | "Sous-Chef" MVP | URL + text input. Gemini Flash. Voice control. Session recording. |
| **Phase 2** | Weeks 9-16 | "Mechanic" Alpha | Image input. Tier 1 YOLO. 30-day retention. Verification clips. |
| **Phase 3** | Weeks 17-24 | Beta & Monetization | Stripe/RevenueCat. Mistake Insurance claims flow. |
| **Phase 4** | Weeks 25-32 | **TrueStep Community** | Video sharing platform. Moderation. Creator profiles. |
| **Phase 5** | 2027 | Platform & Data | TrueStep SDK. B2B2C. Research data licensing. AR glasses. |

---

## 9. Success Metrics

### 9.1 MVP (Week 8)

- 500+ beta users
- 85%+ task completion rate
- < 3% false positive rate

### 9.2 Business (Week 24)

- $50K ARR
- < 5% insurance claim rate
- NPS > 40

### 9.3 Community (Week 32)

- 10,000+ shared videos
- 20% of users share at least one session
- 500+ hours of human-AI interaction data
- 1 research partnership signed

---

*— End of Document —*
