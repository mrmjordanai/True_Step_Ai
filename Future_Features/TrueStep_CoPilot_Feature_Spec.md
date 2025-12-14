# TrueStep Co-Pilot Feature Specification
## Remote Assistance & Collaborative Sessions

**Version:** 1.0  
**Status:** Proposed Feature  
**Target Phase:** Phase 4-5 (Weeks 25-40)  
**Dependencies:** Community Platform, Real-time Infrastructure  

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [User Research & Use Cases](#2-user-research--use-cases)
3. [Feature Overview](#3-feature-overview)
4. [Technical Architecture](#4-technical-architecture)
5. [Data Model](#5-data-model)
6. [User Flows](#6-user-flows)
7. [UI/UX Specifications](#7-uiux-specifications-12-screens)
8. [Business Model Integration](#8-business-model-integration)
9. [Risk Assessment](#9-risk-assessment)
10. [Competitive Analysis](#10-competitive-analysis)
11. [Success Metrics](#11-success-metrics)
12. [Rollout Strategy](#12-rollout-strategy)
13. [PRD Integration](#13-prd-integration-additions)
14. [Future Roadmap](#14-future-roadmap)

---

## 1. Executive Summary

### What is Co-Pilot?

TrueStep Co-Pilot enables users to invite another person to join their active session in real-time. The helper can see the user's camera feed, hear/speak with them, draw annotations on screen, and provide guidance alongside (or instead of) the AI.

### Why Build This?

| Strategic Value | Description |
|-----------------|-------------|
| **Viral Growth** | Every invite is a potential new user acquisition |
| **Competitive Moat** | No competitor offers real-time collaborative repair/cooking |
| **Retention** | Social features increase engagement and stickiness |
| **Revenue Potential** | Future paid expert marketplace |
| **Data Value** | Human-AI collaboration data is uniquely valuable |

### The Tagline

> "Stuck? Get a second pair of eyes—human or AI."

---

## 2. User Research & Use Cases

### Primary Use Cases

#### Use Case 1: Family Tech Support
**Persona:** College student (Alex, 20) fixing laptop, Parent (Mom, 52) watching remotely

**Scenario:**
- Alex starts MacBook battery replacement
- Gets nervous at Step 8 (disconnecting display cable)
- Taps "Get Help" → Sends link to Mom via text
- Mom joins on her iPhone, sees Alex's workspace
- Mom: "Sweetie, you're pulling too hard. Wiggle it gently."
- Alex completes repair with Mom's encouragement
- Both feel connected despite distance

**Value:** Emotional support + practical guidance + family bonding

---

#### Use Case 2: Expert Rescue
**Persona:** DIY beginner (Jordan, 35) stuck, Community expert (FixItFrank, 28)

**Scenario:**
- Jordan attempting PS5 SSD upgrade
- AI verification says "UNCERTAIN" three times at Step 5
- Jordan frustrated, taps "Find Expert Help"
- Sees FixItFrank is online, has 4.9★ rating, specializes in PlayStation
- Requests help, Frank accepts
- Frank: "I see the issue—your thermal pad is misaligned. Let me draw where it should go."
- Frank draws annotation on Jordan's screen
- Jordan fixes it, completes repair
- Jordan tips Frank $5, leaves 5★ review

**Value:** Expert knowledge transfer + community building + monetization

---

#### Use Case 3: Cooking Together Apart
**Persona:** Two friends (Sam & Pat) in different cities

**Scenario:**
- Sam starts "Perfect Risotto" guide
- Invites Pat to cook along together
- Both have TrueStep running, but Sam is "host"
- They chat while cooking, Pat watches Sam's technique
- AI monitors Sam's pot, alerts both when stirring needed
- They "eat together" on video call after

**Value:** Social experience + shared activity + fun

---

#### Use Case 4: Teaching & Training
**Persona:** Repair shop owner (Maria) training new employee (Dev)

**Scenario:**
- Dev is at the shop, Maria is at home
- Dev starts iPhone screen repair with TrueStep
- Maria joins as "Instructor" with elevated permissions
- Maria can pause session, add notes, control step advancement
- Dev learns proper technique with expert oversight
- Session recording saved for future training

**Value:** Scalable training + quality assurance + documentation

---

#### Use Case 5: Accessibility Assistance
**Persona:** User with low vision (Taylor) + sighted helper (friend)

**Scenario:**
- Taylor wants to repair headphones but struggles to see small screws
- Friend joins Co-Pilot session remotely
- Friend: "The screw is at 2 o'clock position, about half inch from edge"
- Friend draws circle around target area
- Taylor completes repair with friend's visual assistance

**Value:** Accessibility + independence + inclusion

---

### User Research Questions (For Validation)

1. How often do you ask someone for help during a repair?
2. Would you video call someone while doing a hands-on task?
3. Would you pay $5-10 for live expert help if stuck?
4. Would you help strangers with repairs for tips/reputation?
5. What concerns would you have letting someone see your workspace?

---

## 3. Feature Overview

### 3.1 Session Modes

| Mode | Description | AI Role | Helper Permissions |
|------|-------------|---------|-------------------|
| **Assist** | Helper watches and advises | Primary verifier | Voice, text, annotations |
| **Takeover** | Helper has full control | Backup/safety net | Full control + step advancement |
| **Teaching** | Roles reversed; helper does, user watches | Monitors helper's work | N/A (helper is maker) |
| **Spectate** | View-only (for community streams) | Normal operation | View only, can react |

### 3.2 Helper Types

| Type | How They Join | Permissions | Cost |
|------|---------------|-------------|------|
| **Friend/Family** | Direct invite link | Configurable by user | Free |
| **Community Helper** | Browse available experts | Standard assist | Free (tips optional) |
| **Verified Expert** | Request from profile | Full assist + premium features | Paid (future) |
| **TrueStep Support** | Escalation from AI | Takeover capable | Included in Pro |

### 3.3 Core Capabilities

**For Maker (Session Host):**
- Invite helpers via link (SMS, WhatsApp, email, QR)
- Accept/reject join requests
- Grant/revoke permissions in real-time
- Mute, pause, or remove helper
- Continue with AI only at any time

**For Helper:**
- See live camera feed (maker's workspace)
- Voice communication (WebRTC)
- Text chat (with timestamps)
- Draw annotations on screen (temporary)
- Request "Show me closer" (zoom request)
- View current step and AI status
- Suggest actions (maker confirms)

**AI During Co-Pilot:**
- Continues monitoring in background
- Alerts both maker and helper of issues
- Can be "paused" if helper takes over
- Logs all human interventions for insurance

---

## 4. Technical Architecture

### 4.1 Technology Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| **Real-time Video** | WebRTC (via Agora/Twilio) | Low latency, peer-to-peer |
| **Signaling** | Firebase Realtime Database | Already in stack, real-time sync |
| **Voice/Audio** | WebRTC audio channel | Bundled with video |
| **Text Chat** | Firestore + listeners | Persistent, queryable |
| **Annotations** | Canvas overlay + sync | Local render, sync coordinates |
| **Deep Links** | Firebase Dynamic Links | Cross-platform, deferred deep link |
| **Web Viewer** | Flutter Web / React | For non-app helpers |
| **Push Notifications** | FCM | Invite delivery |

### 4.2 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        TrueStep Cloud                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  Firebase   │  │   Agora/    │  │    Gemini AI Service    │  │
│  │  Realtime   │  │   Twilio    │  │  (Continues monitoring) │  │
│  │  Database   │  │   (WebRTC)  │  │                         │  │
│  └──────┬──────┘  └──────┬──────┘  └────────────┬────────────┘  │
│         │                │                      │               │
└─────────┼────────────────┼──────────────────────┼───────────────┘
          │                │                      │
          │    Signaling   │   Video/Audio        │   AI Alerts
          │                │                      │
    ┌─────┴─────┐    ┌─────┴─────┐          ┌─────┴─────┐
    │           │    │           │          │           │
    │  Maker    │◄──►│  Helper   │          │  Both     │
    │  (Host)   │    │  (Guest)  │          │  Receive  │
    │           │    │           │          │           │
    └───────────┘    └───────────┘          └───────────┘
         │                │
         │ Camera Feed    │ Sees Feed
         │ (Source)       │ (Viewer)
         ▼                ▼
    ┌─────────────────────────────────┐
    │      Shared Session State       │
    │  - Current step                 │
    │  - AI status                    │
    │  - Annotations                  │
    │  - Chat messages                │
    │  - Permissions                  │
    └─────────────────────────────────┘
```

### 4.3 Latency Requirements

| Interaction | Target Latency | Acceptable |
|-------------|----------------|------------|
| Video feed | < 300ms | < 500ms |
| Voice audio | < 150ms | < 300ms |
| Annotations | < 100ms | < 200ms |
| Chat messages | < 500ms | < 1000ms |
| AI alerts | < 1000ms | < 2000ms |

### 4.4 Bandwidth Considerations

| Quality | Video Bitrate | Audio | Total |
|---------|---------------|-------|-------|
| Low (3G) | 400 kbps | 32 kbps | ~450 kbps |
| Medium (4G) | 1 Mbps | 64 kbps | ~1.1 Mbps |
| High (WiFi) | 2.5 Mbps | 128 kbps | ~2.6 Mbps |

**Adaptive Bitrate:** Auto-adjusts based on network conditions.

### 4.5 Web Viewer (No App Required)

For viral growth, helpers without the app can join via web browser:

**Capabilities:**
- View live camera feed ✓
- Voice/text chat ✓
- See current step ✓
- Basic annotations ✓

**Limitations:**
- Cannot be session host
- Lower video quality
- No AI features
- Prompt to download app

**Technology:** Flutter Web or lightweight React app

---

## 5. Data Model

### 5.1 Session Document Updates

```json
// sessions/{sessionId} - Additional fields
{
  "sessionId": "abc123",
  // ... existing fields ...
  
  "coPilot": {
    "enabled": true,
    "mode": "assist",  // assist | takeover | teaching | spectate
    
    "invite": {
      "code": "TS-XK7M9P",
      "url": "https://truestep.app/join/TS-XK7M9P",
      "createdAt": "2026-01-15T10:30:00Z",
      "expiresAt": "2026-01-15T14:30:00Z",  // 4 hour expiry
      "maxHelpers": 1,  // Future: multi-helper
      "shareMethod": "sms"  // sms | whatsapp | email | qr | link
    },
    
    "helper": {
      "userId": "helper_xyz",
      "displayName": "FixItFrank",
      "avatarUrl": "https://...",
      "joinedAt": "2026-01-15T10:45:00Z",
      "connectionStatus": "connected",  // connected | reconnecting | disconnected
      "isVerifiedExpert": true,
      "permissions": {
        "canVoiceChat": true,
        "canTextChat": true,
        "canAnnotate": true,
        "canAdvanceSteps": false,
        "canPauseSession": false,
        "canAccessRecording": false
      }
    },
    
    "stats": {
      "totalDuration": 1823,  // seconds helper was connected
      "messagesCount": 24,
      "annotationsCount": 7,
      "aiOverrides": 1
    },
    
    "endReason": null  // completed | maker_ended | helper_left | timeout | error
  }
}
```

### 5.2 Chat Messages Collection

```json
// sessions/{sessionId}/coPilotChat/{messageId}
{
  "messageId": "msg_001",
  "senderId": "helper_xyz",
  "senderName": "FixItFrank",
  "senderRole": "helper",  // maker | helper | system | ai
  "type": "text",  // text | annotation | voice_transcript | system
  "content": "Try wiggling the connector gently",
  "timestamp": "2026-01-15T10:47:23Z",
  "readBy": ["user_abc"],
  
  // For annotations
  "annotation": {
    "type": "circle",  // circle | arrow | freehand | highlight
    "coordinates": { "x": 0.45, "y": 0.62, "radius": 0.08 },
    "color": "#FF3D00",
    "duration": 5000  // ms to display
  }
}
```

### 5.3 Helper Availability (For Expert Matching)

```json
// users/{userId}/helperProfile
{
  "userId": "helper_xyz",
  "displayName": "FixItFrank",
  "isAvailable": true,
  "availableUntil": "2026-01-15T18:00:00Z",
  "specialties": ["macbook", "iphone", "playstation"],
  "languages": ["en", "es"],
  "rating": 4.9,
  "totalSessions": 127,
  "responseRate": 0.94,
  "avgResponseTime": 45,  // seconds
  "hourlyRate": null,  // null = free/tips only
  "verified": true,
  "badges": ["top_helper", "100_sessions"]
}
```

### 5.4 Help Requests Queue

```json
// helpRequests/{requestId}
{
  "requestId": "req_001",
  "sessionId": "abc123",
  "makerId": "user_abc",
  "makerName": "Alex",
  "guideId": "macbook_m2_battery",
  "guideName": "MacBook Air M2 Battery",
  "currentStep": 8,
  "urgency": "normal",  // normal | stuck | emergency
  "message": "Connector won't budge, AI keeps saying uncertain",
  "requestedAt": "2026-01-15T10:44:00Z",
  "expiresAt": "2026-01-15T10:54:00Z",  // 10 min expiry
  "status": "pending",  // pending | accepted | expired | cancelled
  "targetHelper": null,  // null = open to community
  "acceptedBy": null
}
```

---

## 6. User Flows

### 6.1 Flow: Invite Friend/Family

```
┌─────────────────┐
│ Active Session  │
│ (User is stuck) │
└────────┬────────┘
         │ Taps "?" or "Get Help"
         ▼
┌─────────────────┐
│  Help Options   │
│  Modal          │
│                 │
│ • Invite Friend │ ◄── User selects
│ • Find Expert   │
│ • Ask AI Again  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Share Method   │
│                 │
│ • Text Message  │ ◄── User selects
│ • WhatsApp      │
│ • Copy Link     │
│ • Show QR Code  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│  Link Sent!     │     │  Friend's Phone │
│                 │────►│  Receives Link  │
│  Waiting for    │     │                 │
│  [Name] to join │     └────────┬────────┘
└────────┬────────┘              │
         │                       │ Taps link
         │                       ▼
         │              ┌─────────────────┐
         │              │  Join Screen    │
         │              │  (App or Web)   │
         │              │                 │
         │              │ "Alex invited   │
         │              │  you to help    │
         │              │  with MacBook   │
         │              │  Battery Repair"│
         │              │                 │
         │              │ [Join Session]  │
         │              └────────┬────────┘
         │                       │
         │◄──────────────────────┘
         │     Helper joins
         ▼
┌─────────────────┐
│  Co-Pilot Mode  │
│  Active!        │
│                 │
│ Both see feed   │
│ Voice connected │
│ AI still active │
└─────────────────┘
```

### 6.2 Flow: Find Community Expert

```
┌─────────────────┐
│ Active Session  │
│ (AI uncertain)  │
└────────┬────────┘
         │ Taps "Get Help" → "Find Expert"
         ▼
┌─────────────────────────────┐
│   Available Experts         │
│                             │
│  🟢 FixItFrank              │
│     ★★★★★ 4.9 (127 helps)   │
│     MacBook, iPhone         │
│     "Usually responds <1m"  │
│     [Request Help]          │
│                             │
│  🟢 RepairQueen             │
│     ★★★★☆ 4.7 (89 helps)    │
│     All Apple devices       │
│     [Request Help]          │
│                             │
│  🟡 TechDadSteve            │
│     ★★★★★ 5.0 (34 helps)    │
│     "Busy - 5min wait"      │
│     [Request Help]          │
└─────────────┬───────────────┘
              │ User taps "Request Help"
              ▼
┌─────────────────────────────┐
│   Waiting for Expert        │
│                             │
│   Requesting FixItFrank...  │
│   ◯◯◯ (animated)            │
│                             │
│   "Usually responds in <1m" │
│                             │
│   [Cancel Request]          │
└─────────────┬───────────────┘
              │
              │ Expert accepts
              ▼
┌─────────────────────────────┐
│   FixItFrank is joining!    │
│                             │
│   Connecting...             │
│                             │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│   Co-Pilot Active           │
│                             │
│   FixItFrank connected      │
│   "Hey! I see the issue..." │
└─────────────────────────────┘
```

### 6.3 Flow: Helper Receives Request (Expert Side)

```
┌─────────────────┐
│ Expert is using │
│ TrueStep or     │
│ has app open    │
└────────┬────────┘
         │ Push notification
         ▼
┌─────────────────────────────┐
│  🔔 Help Request            │
│                             │
│  Alex needs help with       │
│  MacBook Air M2 Battery     │
│  Step 8 of 24               │
│                             │
│  "Connector won't budge"    │
│                             │
│  [Accept]  [Decline]        │
│                             │
│  Expires in 9:45            │
└─────────────┬───────────────┘
              │ Taps "Accept"
              ▼
┌─────────────────────────────┐
│  Joining Alex's session...  │
│                             │
│  • Requesting camera access │
│  • Connecting audio         │
│  • Loading session state    │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│  Co-Pilot Mode (Helper View)│
│                             │
│  Live feed from Alex        │
│  Step 8: Disconnect cable   │
│  AI Status: Uncertain       │
│                             │
│  [Draw] [Mute] [End Help]   │
└─────────────────────────────┘
```

### 6.4 Flow: AI Override During Co-Pilot

```
┌─────────────────────────────┐
│  Co-Pilot Active            │
│  Helper advising user       │
└─────────────┬───────────────┘
              │
              │ AI detects issue
              ▼
┌─────────────────────────────┐
│  ⚠️ AI ALERT                │
│                             │
│  "Wrong tool detected.      │
│   Phillips #00 needed,      │
│   but using Pentalobe"      │
│                             │
│  Shown to BOTH maker        │
│  and helper                 │
└─────────────┬───────────────┘
              │
    ┌─────────┴─────────┐
    ▼                   ▼
┌─────────┐       ┌─────────────┐
│ Helper  │       │   Maker     │
│ Options │       │   Options   │
│         │       │             │
│[Agree]  │       │ [Stop &     │
│[I see   │       │  Check]     │
│ why AI  │       │             │
│ is      │       │ [Trust      │
│ wrong]  │       │  Helper]    │
└────┬────┘       └──────┬──────┘
     │                   │
     │ Helper clicks     │
     │ "I see why AI     │
     │  is wrong"        │
     ▼                   │
┌─────────────┐          │
│ Override    │          │
│ Reason      │          │
│             │          │
│ "This is    │          │
│ actually    │          │
│ the right   │          │
│ driver for  │          │
│ this model" │          │
│             │          │
│ [Submit]    │          │
└──────┬──────┘          │
       │                 │
       ▼                 │
┌─────────────┐          │
│ Maker sees: │          │
│             │◄─────────┘
│ "Helper     │ Maker must confirm
│ disagrees   │
│ with AI"    │
│             │
│ Reason shown│
│             │
│ [Continue   │
│ with Helper │
│ Advice]     │
│             │
│ [Follow AI] │
└──────┬──────┘
       │
       │ Decision logged
       │ for insurance
       ▼
┌─────────────┐
│ Session     │
│ continues   │
└─────────────┘
```

---

## 7. UI/UX Specifications (12 Screens)

### Screen 7.1: Get Help Modal

**Trigger:** Tap "?" button or "Get Help" during active session

**Layout:**
- Bottom sheet modal (60% height)
- Glassmorphism background
- Draggable to dismiss

**Elements:**

**Header:**
- Title: "Need a Hand?"
- Subtitle: "Get help from a friend or expert"
- Close (X) button

**Option Cards (Stacked):**

**Card 1: "Invite Someone"**
- Icon: Person with plus
- Title: "Invite Friend or Family"
- Subtitle: "Send a link to someone you know"
- Chevron right

**Card 2: "Find Expert"**
- Icon: Star badge
- Title: "Find a Community Expert"
- Subtitle: "Get help from experienced makers"
- Badge: "3 available now" (dynamic)
- Chevron right

**Card 3: "Ask AI Again"**
- Icon: Sparkle/AI
- Title: "Let AI Try Again"
- Subtitle: "Get a fresh analysis of current step"
- No chevron (immediate action)

**Footer:**
- Text: "Helpers can see your camera feed"
- Link: "Learn about privacy"

---

### Screen 7.2: Invite Method Selector

**Purpose:** Choose how to send invite

**Layout:**
- Full sheet or new screen
- Grid of share options

**Elements:**

**Header:**
- Back button
- Title: "Send Invite"
- Subtitle: "Choose how to invite your helper"

**Share Options Grid (2x3):**

| Option | Icon | Action |
|--------|------|--------|
| Text Message | 💬 | Opens SMS with pre-filled link |
| WhatsApp | WhatsApp logo | Opens WhatsApp share |
| Copy Link | 🔗 | Copies to clipboard |
| Email | ✉️ | Opens email compose |
| QR Code | QR icon | Shows QR code screen |
| More... | ••• | System share sheet |

**Invite Link Preview:**
- Glass card showing the link
- Link text: "truestep.app/join/TS-XK7M9P"
- Expiry notice: "Link expires in 4 hours"

**Bottom:**
- Ghost button: "Cancel"

---

### Screen 7.3: QR Code Display

**Purpose:** In-person invite via QR scan

**Layout:**
- Centered QR code
- Instructions

**Elements:**

**Header:**
- Back button
- Title: "Scan to Join"

**QR Code:**
- Large QR code (250x250dp)
- White background for scannability
- TrueStep logo in center of QR

**Instructions:**
- "Have your helper scan this code"
- "They'll join your session instantly"

**Helper Status:**
- "Waiting for someone to scan..."
- Animated dots

**Link Fallback:**
- "Or share this link:"
- Copyable link text
- Copy button

---

### Screen 7.4: Waiting for Helper

**Purpose:** Loading state while waiting for helper to join

**Layout:**
- Overlay on active session
- Semi-transparent background

**Elements:**

**Card (Centered):**
- Title: "Invite Sent!"
- Subtitle: "Waiting for [Name/Someone] to join..."
- Animated waiting indicator (pulsing dots)
- Sent via indicator: "via Text Message"
- Time waiting: "Sent 45 seconds ago"

**Actions:**
- "Resend Invite"
- "Cancel" (returns to solo session)

**Background:**
- Session continues (AI still monitoring)
- Slightly dimmed

---

### Screen 7.5: Helper Join Screen (Helper's View)

**Purpose:** What helper sees when they tap invite link

**Layout:**
- Full screen
- Can be in-app or web

**Variants:**

**If helper has app:**
- Deep link opens app directly
- Shows join confirmation

**If helper doesn't have app:**
- Web page with app store links
- "Join via Web" option (limited features)

**Elements:**

**Header:**
- TrueStep logo

**Invitation Card:**
- Inviter avatar
- "[Name] invited you to help"
- Task: "MacBook Air M2 Battery Replacement"
- Current progress: "Step 8 of 24"
- Preview thumbnail (if available)

**Permissions Notice:**
- "You'll be able to:"
- • See their camera feed
- • Talk and chat with them
- • Draw on their screen
- • See AI suggestions

**Privacy Assurance:**
- "Your camera won't be shared"
- "You can leave anytime"

**Actions:**
- Primary: "Join Session"
- Ghost: "Decline"

**If no app - Additional:**
- "Get the TrueStep App"
- App Store / Play Store buttons
- "Continue on Web (limited)" link

---

### Screen 7.6: Co-Pilot Active (Maker's View)

**Purpose:** Main session screen with helper connected

**Layout:**
- Same as regular active session
- Additional helper presence UI
- Chat/annotation overlay

**Modifications to Active Session Screen:**

**Helper Presence Indicator (Top Right):**
- Helper avatar (40dp circle)
- Green dot indicating connected
- Name label: "FixItFrank"
- Tap to open helper options

**Voice Status (Below header):**
- If voice active: Waveform animation
- Mute indicator if muted
- "Voice connected" label

**Annotation Layer:**
- Transparent overlay on camera feed
- Shows helper's drawings
- Drawings fade after 5 seconds
- Color: Helper's chosen color (default red)

**Chat Bubble (Bottom left, above instruction card):**
- Shows most recent message
- Tap to expand full chat
- Unread count badge

**Instruction Card Modification:**
- Now shows: "AI + FixItFrank are watching"
- Or: "FixItFrank is guiding (AI paused)"

**Quick Actions (Swipe up) - Additional:**
- "Helper Settings"
- "Remove Helper"
- "Switch to AI Only"

---

### Screen 7.7: Co-Pilot Active (Helper's View)

**Purpose:** What helper sees during active help

**Layout:**
- Full screen video of maker's camera
- Overlay controls
- Different from maker's view

**Elements:**

**Video Feed:**
- Full screen, maker's camera
- Pinch to zoom
- Double-tap to fit

**Header Overlay:**
- Maker's name: "Helping Alex"
- Session: "MacBook Battery • Step 8/24"
- Connection quality indicator
- Duration: "Connected 5:23"

**AI Status Bar:**
- Shows current AI state (Green/Yellow/Red)
- "AI says: Watching..." or "AI says: Uncertain"
- Tap for AI details

**Current Step Card (Collapsible):**
- Step instruction text
- Success criteria
- Reference image thumbnail

**Drawing Tools (Bottom):**
- Color picker (small palette)
- Pen tool (freehand)
- Circle tool
- Arrow tool
- Clear all button

**Communication Bar:**
- Microphone toggle (with waveform when active)
- Text chat button (opens chat panel)
- "Request Closer Look" button

**End Session:**
- "End Help" button
- Confirmation required

---

### Screen 7.8: Chat Panel

**Purpose:** Text communication during Co-Pilot

**Layout:**
- Slide-up panel (70% height)
- Standard chat UI

**Elements:**

**Header:**
- "Chat with [Name]"
- Minimize button
- Close button

**Message List:**
- Messages with timestamps
- Sender indicated (avatar + name)
- System messages styled differently
- AI alerts shown in chat as system messages

**Message Types:**

*Text Message:*
- Standard chat bubble
- Sender info
- Timestamp

*Annotation Shared:*
- "Drew on screen" with thumbnail
- Tap to highlight that annotation

*AI Alert:*
- Yellow/red background
- "⚠️ AI detected: Wrong tool"
- Both users see this

*System Message:*
- "FixItFrank joined the session"
- "Step 8 marked complete"

**Input Area:**
- Text field
- Send button
- Quick responses: "Got it", "Show me", "Try again"

---

### Screen 7.9: Find Expert Browser

**Purpose:** Browse available community experts

**Layout:**
- List view with filters
- Search capability

**Elements:**

**Header:**
- Back button
- Title: "Find Expert Help"
- Filter button

**Search Bar:**
- "Search by name or specialty"

**Filter Chips:**
- "Available Now" (default on)
- "Verified" 
- "4+ Stars"
- "Free Help"

**Expert Cards:**

Each card shows:
- Avatar (60dp)
- Online indicator (green/yellow/grey dot)
- Display name
- Verification badge (if verified)
- Rating: ★ 4.9 (127 sessions)
- Specialties: "MacBook, iPhone, PlayStation"
- Response info: "Usually responds in <1 min"
- Status: "Available" / "Busy (5 min wait)" / "Offline"
- Action: "Request Help" button

**Empty State (No Available Experts):**
- "No experts available right now"
- "Try inviting a friend instead"
- "Check back in a few minutes"
- Option to post public help request

---

### Screen 7.10: Expert Profile

**Purpose:** Detailed view of potential helper

**Layout:**
- Profile detail page
- Request help CTA

**Elements:**

**Header:**
- Cover image (blurred repair photo)
- Back button
- Share button

**Profile Section:**
- Large avatar (100dp)
- Name + verification badge
- Bio: "Fixing things since 2018. Happy to help!"
- Location: "San Francisco, CA" (optional)
- Languages: "English, Spanish"

**Stats Row:**
- Help Sessions: 127
- Success Rate: 98%
- Avg Response: <1 min
- Rating: 4.9 ★

**Specialties:**
- Tags: MacBook, iPhone, iPad, PlayStation, Xbox

**Badges:**
- 🏆 Top Helper
- ✅ Verified Expert
- 💯 100 Sessions
- ⚡ Fast Responder

**Reviews Section:**
- "Recent Reviews"
- Review cards with text and rating
- "See all reviews" link

**Availability Status:**
- 🟢 "Available now"
- Schedule (if they have one)

**Sticky Bottom:**
- Primary: "Request Help from [Name]"
- If busy: "Join Waitlist"
- If offline: "Notify When Online"

---

### Screen 7.11: Incoming Help Request (Expert View)

**Purpose:** Notification/screen for expert receiving request

**Layout:**
- Full screen takeover or rich notification
- Time-sensitive

**Elements:**

**If In-App:**
- Modal overlay
- Urgent styling

**Header:**
- "Help Request"
- Timer: "Expires in 9:45"

**Request Details:**
- Requester avatar + name
- "Alex needs help with:"
- Guide: "MacBook Air M2 Battery Replacement"
- Current step: "Step 8 of 24"
- Their message: "Connector won't budge, AI keeps saying uncertain"

**Session Preview:**
- Thumbnail of current camera view (if permitted)
- "Alex has completed 7 steps successfully"

**Actions:**
- Primary: "Accept & Join"
- Secondary: "Decline"
- Ghost: "I'm Busy (suggest another expert)"

**If Declined:**
- Optional feedback: "Why declining?"
- "I don't know this device"
- "I'm about to go offline"
- "Other"

---

### Screen 7.12: Helper Settings & Permissions

**Purpose:** Maker controls helper capabilities

**Layout:**
- Bottom sheet or full screen
- Toggle controls

**Elements:**

**Header:**
- Helper avatar + name
- "Connected for 12:34"
- Connection quality indicator

**Permissions Section:**
- Title: "Helper Can..."

**Toggles:**
| Permission | Default | Description |
|------------|---------|-------------|
| Voice Chat | ON | Talk with you |
| Text Chat | ON | Send messages |
| Draw on Screen | ON | Add annotations |
| See AI Alerts | ON | View AI notifications |
| Advance Steps | OFF | Mark steps complete |
| Pause Session | OFF | Pause/resume |
| Access Recording | OFF | View after session |

**Audio Controls:**
- "My Microphone" - On/Off
- "Helper Volume" - Slider
- "Mute Helper" - Quick toggle

**Actions:**
- "Report Issue" - Flag inappropriate behavior
- "Remove Helper" - End Co-Pilot immediately

**Remove Confirmation:**
- "Remove [Name] from session?"
- "They won't be able to rejoin without a new invite"
- Primary: "Remove"
- Secondary: "Cancel"

---

## 8. Business Model Integration

### 8.1 Monetization Opportunities

| Feature | Model | Timeline |
|---------|-------|----------|
| Friend Invites | Free (viral growth) | Launch |
| Community Helpers | Free + Tips | Launch |
| Verified Expert Badge | Subscription/Fee | Phase 5 |
| Paid Expert Consultations | Revenue share (70/30) | Phase 6 |
| Priority Expert Queue | Pro subscriber perk | Phase 5 |
| B2B Training Mode | Enterprise pricing | Phase 6 |

### 8.2 Viral Growth Mechanics

**Invite Loop:**
1. User gets stuck → Invites friend
2. Friend receives link → Downloads app to help
3. Friend has app → Becomes potential maker
4. Friend gets stuck → Invites their friend
5. Repeat

**Expert Loop:**
1. User completes repairs successfully
2. Gets prompted: "You're good at this! Help others?"
3. Enables helper availability
4. Helps someone → Earns reputation
5. Gets tips/recognition → More motivated
6. Helps more → Community grows

### 8.3 Tipping System

**For Community Helpers:**
- After session ends, maker can tip helper
- Suggested amounts: $2, $5, $10, Custom
- 100% goes to helper (initially, to bootstrap)
- Future: 10-15% platform fee

**Tipping Flow:**
1. Session ends successfully
2. Prompt: "Say thanks to FixItFrank?"
3. "FixItFrank helped you for 23 minutes"
4. Tip options displayed
5. Payment via Apple Pay/Google Pay
6. Thank you message sent to helper

### 8.4 Expert Marketplace (Future)

**Verified Experts:**
- Application process
- Background check (optional)
- Skills verification
- Response time commitment
- Can set hourly rates

**Pricing Model:**
- Expert sets rate: $10-50/hour
- Pre-authorization at session start
- Charged per minute, minimum 5 min
- TrueStep takes 30% cut

---

## 9. Risk Assessment

### 9.1 Risk Matrix

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Privacy concerns | High | High | Clear consent, camera-only sharing, no recording default |
| Harassment/abuse | Medium | High | Report system, instant block, AI monitoring |
| Bad advice causing damage | Medium | High | Override logging, insurance adjustment, liability terms |
| Helper no-shows | High | Low | Timeout system, reputation impact, backup AI |
| Network quality issues | High | Medium | Adaptive bitrate, graceful degradation, reconnect handling |
| Expert supply shortage | Medium | Medium | Incentive programs, geographic expansion, AI fallback |
| Liability disputes | Low | High | Clear ToS, logged interactions, arbitration process |

### 9.2 Safety & Trust

**For Makers:**
- Only camera feed shared (not helper's camera)
- Mute/block/remove at any time
- Report inappropriate behavior
- AI continues monitoring (safety net)
- All interactions logged

**For Helpers:**
- No personal info shared by default
- Can end session anytime
- Report abusive makers
- Reputation system protects good actors

**Platform Safety:**
- AI monitors chat for inappropriate content
- Pattern detection for bad actors
- Community reporting system
- Ban system for repeat offenders

### 9.3 Mistake Insurance Implications

**When Co-Pilot is active:**

| Scenario | Insurance Status | Rationale |
|----------|-----------------|-----------|
| AI verified, helper agreed | Full coverage | Consensus |
| AI verified, no helper input | Full coverage | AI primary |
| AI uncertain, helper guided | Reduced coverage | Human override |
| AI warned, helper overrode | Limited coverage | Logged override |
| Helper in Takeover mode | Varies | Based on helper verification |

**Disclosure:**
- User informed when coverage changes
- Must acknowledge before continuing
- All decisions logged with timestamps

---

## 10. Competitive Analysis

### 10.1 Do Competitors Have This?

| Competitor | Remote Assist? | Details |
|------------|----------------|---------|
| iFixit FixBot | ❌ No | Solo experience only |
| BILT | ❌ No | No collaboration features |
| JigSpace | ❌ No | Single-user AR |
| YouTube | ⚠️ Partial | Live stream possible but not integrated |
| Tinker/Frontdoor | ✅ Yes | But human-only, expensive ($40+) |

### 10.2 TrueStep Co-Pilot Differentiation

**vs. Tinker/Frontdoor (human experts):**
- TrueStep: AI + human hybrid (AI safety net)
- TrueStep: Friend/family option (free)
- TrueStep: Community experts (affordable)
- TrueStep: Integrated with guided workflow

**Unique Position:**
> "The only app where AI verification and human expertise work together."

---

## 11. Success Metrics

### 11.1 Launch Metrics (Phase 4)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Co-Pilot session starts | 5% of sessions | Sessions with invite created |
| Invite acceptance rate | 40% | Accepted / Sent |
| Helper join success | 80% | Joined / Accepted |
| Session completion with helper | 90% | Higher than solo |
| New users from invites | 500/month | First session from invite |

### 11.2 Growth Metrics (Phase 5+)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Viral coefficient | >1.0 | New users from invites / Active users |
| Community helpers registered | 1,000 | Users with helper profile |
| Expert availability | 80% coverage | % of time experts available |
| Helper satisfaction | 4.5+ | Post-session rating |
| Tips sent | $5,000/month | Total tip volume |

### 11.3 Quality Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Helper session quality rating | 4.5+ stars | Maker rating of helper |
| AI override accuracy | 90% | Correct overrides / Total |
| Report rate | <1% | Reports / Sessions |
| Helper ban rate | <0.5% | Bans / Total helpers |

---

## 12. Rollout Strategy

### 12.1 Phased Rollout

**Phase 4A (Weeks 25-28): Friend Invites**
- Basic invite flow (link sharing)
- Voice and text chat
- Simple annotations
- Web viewer MVP
- No expert matching

**Phase 4B (Weeks 29-32): Community Helpers**
- Helper availability status
- Basic expert browser
- Request/accept flow
- Reputation system v1
- Tipping system

**Phase 5A (Weeks 33-36): Expert Marketplace**
- Verified expert program
- Advanced permissions
- Takeover mode
- Enhanced analytics
- Quality monitoring

**Phase 5B (Weeks 37-40): Monetization**
- Paid expert consultations
- Revenue sharing
- Pro subscriber perks
- B2B training features

### 12.2 Feature Flags

| Flag | Description | Default |
|------|-------------|---------|
| `copilot_enabled` | Master switch | ON (Phase 4+) |
| `copilot_web_viewer` | Allow web-based helpers | ON |
| `copilot_community_experts` | Expert browser | OFF → ON (Phase 4B) |
| `copilot_paid_experts` | Paid consultations | OFF → ON (Phase 5B) |
| `copilot_takeover_mode` | Helper full control | OFF → ON (Phase 5A) |
| `copilot_tips` | Tipping system | OFF → ON (Phase 4B) |

### 12.3 Beta Testing

**Internal Alpha:**
- TrueStep team testing
- Controlled scenarios
- Focus on stability

**Closed Beta:**
- 100 selected users
- Mix of makers and helpers
- Feedback surveys
- Bug bounty for issues

**Open Beta:**
- All Pro subscribers
- Phased rollout by region
- A/B test invite flows
- Monitor metrics closely

---

## 13. PRD Integration Additions

### 13.1 New Section for PRD v5

**Add as Section 6.5:**

---

### 6.5 TrueStep Co-Pilot (Remote Assistance)

Users can invite friends, family, or community experts to join their active session in real-time. The helper sees the maker's camera feed and can provide voice guidance, text chat, and on-screen annotations alongside (or instead of) the AI.

#### Key Capabilities

| For Maker | For Helper |
|-----------|------------|
| Invite via SMS, WhatsApp, email, QR | Join via app or web browser |
| Accept/reject join requests | See live camera feed |
| Grant/revoke permissions | Voice and text communication |
| Mute or remove helper anytime | Draw annotations on screen |
| Continue with AI only at any time | View AI status and alerts |

#### Session Modes

- **Assist Mode:** Helper advises, AI remains primary verifier
- **Takeover Mode:** Helper has full control, AI monitors in background
- **Spectate Mode:** View-only for community streaming

#### Privacy & Safety

- Only maker's workspace camera is shared
- Helpers cannot access device camera or microphone recording
- All interactions logged for safety and insurance
- Report/block functionality for inappropriate behavior
- AI continues monitoring regardless of helper presence

#### Insurance Implications

When human advice overrides AI recommendations, Mistake Insurance coverage may be adjusted. Users are informed before proceeding and must acknowledge any coverage changes.

---

### 13.2 Roadmap Update

**Update Phase 4:**
```
Phase 4 | Weeks 25-32 | TrueStep Community + Co-Pilot
- Video sharing platform
- Co-Pilot friend invites
- Community helper matching
- Tipping system
```

**Add Phase 5:**
```
Phase 5 | Weeks 33-40 | Expert Marketplace
- Verified expert program
- Paid consultations
- B2B training mode
- Advanced Co-Pilot features
```

### 13.3 Success Metrics Update

**Add to Section 9.3 (Community Metrics):**

- 15% of sessions include Co-Pilot
- 40% invite acceptance rate
- Viral coefficient >1.0 (each user brings >1 new user)
- 500+ registered community helpers
- $5,000/month in tips processed

### 13.4 Risk Table Update

**Add rows:**

| Risk | Impact | Mitigation |
|------|--------|------------|
| Co-Pilot privacy concerns | MEDIUM | Camera-only sharing, clear consent UI, no recording default |
| Helper gives bad advice | MEDIUM | Override logging, insurance adjustment, AI backup |
| Harassment via Co-Pilot | LOW | Report system, instant block, AI chat monitoring |

---

## 14. Future Roadmap

### 14.1 Near-Term (6-12 months)

- Multi-helper sessions (2-3 helpers watching)
- Screen sharing (maker shares phone screen)
- Scheduled help sessions (book expert in advance)
- Helper certification program
- Integration with iFixit community

### 14.2 Medium-Term (12-24 months)

- AR glasses support (helper sees through maker's glasses)
- Professional services tier (repair shops offering remote help)
- Training/certification courses led by experts
- Corporate accounts (IT helpdesk integration)

### 14.3 Long-Term Vision

> "Anyone, anywhere can get expert help for any physical task—backed by AI safety and human wisdom."

- Global expert network across languages
- Industry partnerships (Apple Genius Bar alternative)
- Educational platform for trade skills
- AI learns from human expert patterns

---

*— End of Co-Pilot Feature Specification —*
