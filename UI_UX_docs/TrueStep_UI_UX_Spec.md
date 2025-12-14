# TrueStep UI/UX Design Specification
**Version:** 2.0  
**Based on:** TrueStep PRD v4  
**Platform:** Flutter (iOS, Android)  
**Total Screens:** 34  

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy-the-glass-sentinel)
2. [Design System](#2-design-system)
3. [Onboarding Flow](#3-onboarding-flow-4-screens)
4. [Home & Navigation](#4-home--navigation-3-screens)
5. [Guide Discovery](#5-guide-discovery-3-screens)
6. [Session Flow](#6-session-flow-7-screens)
7. [Community](#7-community-4-screens)
8. [Session History](#8-session-history-2-screens)
9. [Mistake Insurance](#9-mistake-insurance-claim-flow-5-screens)
10. [Settings & Account](#10-settings--account-2-screens)
11. [Paywall & Subscription](#11-paywall--subscription-2-screens)
12. [Error & Edge States](#12-error--edge-states-4-screens)
13. [Accessibility](#13-accessibility-specifications)
14. [Motion & Animation](#14-motion--animation-guide)
15. [Voice UI Patterns](#15-voice-ui-patterns)
16. [Flutter Implementation Notes](#16-flutter-implementation-notes)

---

## 1. Design Philosophy: "The Glass Sentinel"

### Core Principles

| Principle | Description |
|-----------|-------------|
| **Hands-Free First** | Voice commands, large touch targets, minimal required taps during active sessions |
| **Ambient Awareness** | UI fades when not needed; information appears contextually |
| **Traffic Light Language** | Green/Yellow/Red states universally communicate system status |
| **Glass & Glow** | Glassmorphism surfaces with subtle luminous accents |
| **Trust Through Transparency** | Always show what the AI is doing and why |

### Visual Style

- **Theme:** Dark Mode Default (reduces glare on physical objects)
- **Surfaces:** Frosted glass cards with 20% opacity, 16px blur
- **Typography:** SF Pro Display (iOS) / Roboto (Android), high contrast
- **Iconography:** Outlined icons with 2px stroke, glow effects for active states
- **Depth:** Subtle shadows and layering to create hierarchy

### Interaction Model

- **Primary:** Voice commands during active sessions
- **Secondary:** Large tap targets (minimum 48x48dp)
- **Tertiary:** Swipe gestures for navigation
- **Feedback:** Haptic confirmation for all actions

---

## 2. Design System

### 2.1 Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `--bg-primary` | `#0A0A0A` | Main background |
| `--bg-secondary` | `#121212` | Card backgrounds |
| `--bg-surface` | `#1E1E1E` | Elevated surfaces |
| `--glass-overlay` | `rgba(255,255,255,0.08)` | Glassmorphism fill |
| `--glass-border` | `rgba(255,255,255,0.12)` | Glassmorphism stroke |
| `--text-primary` | `#FFFFFF` | Headlines, primary text |
| `--text-secondary` | `#B3B3B3` | Body text, descriptions |
| `--text-tertiary` | `#666666` | Hints, disabled states |
| `--sentinel-green` | `#00E676` | Success, verified, safe |
| `--sentinel-green-glow` | `rgba(0,230,118,0.3)` | Green state glow |
| `--analysis-yellow` | `#FFC400` | Processing, warning |
| `--analysis-yellow-glow` | `rgba(255,196,0,0.3)` | Yellow state glow |
| `--intervention-red` | `#FF3D00` | Stop, danger, error |
| `--intervention-red-glow` | `rgba(255,61,0,0.4)` | Red state glow |
| `--accent-blue` | `#2979FF` | Primary actions, links |
| `--accent-purple` | `#7C4DFF` | Pro features, premium |

### 2.2 Typography Scale

| Style | Font | Size | Weight | Line Height |
|-------|------|------|--------|-------------|
| Display | SF Pro Display | 32sp | Bold | 40sp |
| Headline | SF Pro Display | 24sp | Semibold | 32sp |
| Title | SF Pro Text | 20sp | Semibold | 28sp |
| Body Large | SF Pro Text | 16sp | Regular | 24sp |
| Body | SF Pro Text | 14sp | Regular | 20sp |
| Caption | SF Pro Text | 12sp | Regular | 16sp |
| Overline | SF Pro Text | 10sp | Medium | 14sp |

### 2.3 Spacing System

Base unit: 8dp

| Token | Value |
|-------|-------|
| `--space-xs` | 4dp |
| `--space-sm` | 8dp |
| `--space-md` | 16dp |
| `--space-lg` | 24dp |
| `--space-xl` | 32dp |
| `--space-xxl` | 48dp |

### 2.4 Component Tokens

#### Buttons

| Type | Background | Text | Border Radius | Height |
|------|------------|------|---------------|--------|
| Primary | `--accent-blue` | White | 12dp | 56dp |
| Secondary | Transparent | `--accent-blue` | 12dp | 56dp |
| Danger | `--intervention-red` | White | 12dp | 56dp |
| Ghost | Transparent | `--text-secondary` | 12dp | 48dp |
| Pill | `--glass-overlay` | `--text-primary` | 28dp | 40dp |

#### Cards

| Type | Background | Border | Radius | Blur |
|------|------------|--------|--------|------|
| Glass Card | `--glass-overlay` | `--glass-border` | 16dp | 20dp |
| Solid Card | `--bg-surface` | None | 16dp | None |
| Alert Card | State color @ 15% | State color | 16dp | 10dp |

### 2.5 Iconography

- **Style:** Outlined, 2dp stroke
- **Sizes:** 20dp (inline), 24dp (standard), 32dp (feature), 48dp (hero)
- **Active State:** Filled variant with glow effect
- **Library:** Custom icons + Lucide Icons base

---

## 3. Onboarding Flow (4 Screens)

### Screen 3.1: Welcome Carousel

**Purpose:** Introduce value proposition to first-time users.

**Layout:**
- Full-screen with gradient background (`#0A0A0A` → `#1a1a2e`)
- Horizontal page indicator dots at bottom
- Skip button (top right)

**Carousel Cards (3 swipes):**

**Card 1: "Your AI Repair Partner"**
- Hero Illustration: Phone with glowing "eye" watching hands repair a device
- Headline: "Never miss a step again"
- Body: "TrueStep watches your work and guides you through repairs and recipes with real-time verification."

**Card 2: "Visual Verification"**
- Hero Illustration: Traffic light transitioning Green → Yellow → Green
- Headline: "AI that actually watches"
- Body: "Unlike videos, TrueStep confirms each step is done correctly before moving forward."

**Card 3: "Mistake Insurance"**
- Hero Illustration: Shield icon with checkmark
- Headline: "Protected when it matters"
- Body: "If our AI misses something and your device is damaged, we'll help cover the cost."

**Bottom CTA:**
- Primary Button: "Get Started"
- Text Link: "Already have an account? Sign In"

---

### Screen 3.2: Permission Requests

**Purpose:** Request necessary system permissions with context.

**Layout:**
- Centered content with illustration
- Single permission per screen (progressive disclosure)

**Permission 1: Camera**
- Illustration: Camera icon with sparkles
- Headline: "Enable Camera Access"
- Body: "TrueStep needs your camera to watch your progress and verify each step in real-time."
- Primary Button: "Allow Camera"
- Ghost Button: "Not Now" (shows limitations warning)

**Permission 2: Microphone**
- Illustration: Microphone with waveform
- Headline: "Enable Voice Control"
- Body: "Go hands-free! Say 'Hey TrueStep' to control the app while your hands are busy."
- Primary Button: "Allow Microphone"
- Ghost Button: "Skip" (voice disabled indicator)

**Permission 3: Notifications**
- Illustration: Bell icon with badges
- Headline: "Stay Informed"
- Body: "Get alerts when recordings are about to expire and when the community engages with your shares."
- Primary Button: "Allow Notifications"
- Ghost Button: "Maybe Later"

---

### Screen 3.3: Account Creation

**Purpose:** Create account or continue anonymously.

**Layout:**
- Centered content
- Social sign-in buttons prominent
- Anonymous option clear but secondary

**Elements:**
- Headline: "Create Your Account"
- Body: "Save your progress, access Mistake Insurance, and join the community."

**Sign-In Options (Stacked Buttons):**
1. "Continue with Apple" (Apple icon, white bg)
2. "Continue with Google" (Google icon, white bg)
3. "Continue with Email" (Mail icon, outlined)

**Divider:** "or"

**Anonymous Option:**
- Ghost Button: "Continue as Guest"
- Caption: "Some features will be limited"

**Footer:**
- Caption: "By continuing, you agree to our Terms of Service and Privacy Policy"

---

### Screen 3.4: First Task Suggestion

**Purpose:** Guide user to immediate value; reduce empty state anxiety.

**Layout:**
- Friendly, conversational UI
- Quick-start suggestions

**Elements:**
- Header: "Welcome aboard! 👋"
- Subhead: "What would you like to tackle first?"

**Suggestion Cards (2x2 Grid):**

| Card | Icon | Title | Subtitle |
|------|------|-------|----------|
| 1 | 🍳 | "Cook Something" | "Try a guided recipe" |
| 2 | 🔧 | "Fix Something" | "Repair a device" |
| 3 | 📱 | "Scan My Device" | "Get repair options" |
| 4 | 👀 | "Just Explore" | "Browse the app" |

**Bottom:**
- Text: "You can always change this later"

---

## 4. Home & Navigation (3 Screens)

### Screen 4.1: Home - The Briefing

**Purpose:** Primary entry point for all tasks.

**Layout:**
- Scrollable vertical layout
- Sticky header with user avatar and notification bell
- Bottom navigation bar

**Header Section:**
- Greeting: "Good evening, [Name]" or "Hello, Maker"
- Subscription Badge: "Free • 2 sessions left" or "Pro Member"
- Notification Bell (with badge count)

**The Omni-Bar (Prominent):**
- Glass pill container, centered
- Placeholder: "Paste URL, describe task, or say 'Hey TrueStep'..."
- Microphone icon (right side, tap to activate voice)
- Tap expands to full search screen

**Continue Session Card (Conditional):**
- Only shows if user has incomplete session
- Glass card with yellow accent border
- Content: "Continue: MacBook Battery Replacement"
- Progress: "Step 12 of 24 • 45% complete"
- Thumbnail of last frame
- CTA: "Resume" button

**Quick Actions Row (Horizontal Scroll):**

| Action | Icon | Label |
|--------|------|-------|
| 1 | 📷 | "Scan Device" |
| 2 | 📄 | "Read Manual" |
| 3 | 🥗 | "Kitchen Scan" |
| 4 | 🔥 | "Popular Repairs" |

**Recent Sessions Section:**
- Header: "Recent Activity"
- Horizontal scroll of 3 most recent session cards
- Each card shows: Thumbnail, Title, Date, Status badge
- "See All" link → Session History

**Community Feed Section:**
- Header: "Live from the Workbench"
- 2-3 cards showing recent community shares
- Content: Creator avatar, title, view count, time ago
- "Explore Community" link

**Bottom Navigation Bar:**
- Home (active), Search, Community, History, Profile
- Floating action button center: "+" (Quick start new session)

---

### Screen 4.2: Search / Omni-Bar Expanded

**Purpose:** Full search experience for guides and content.

**Layout:**
- Full screen overlay
- Auto-focus keyboard on open
- Recent searches and suggestions

**Elements:**

**Search Input:**
- Large text field with microphone button
- "X" button to clear/close

**Input Type Tabs:**
- "All" | "Repairs" | "Recipes" | "Community"

**Recent Searches:**
- Header: "Recent"
- List of recent search terms with clock icon
- Swipe to delete individual items
- "Clear All" option

**Trending Searches:**
- Header: "Trending Now"
- Chip pills: "iPhone 15 screen", "PS5 SSD upgrade", "Sourdough bread"

**Suggestions (As User Types):**
- Real-time dropdown
- Icon indicates type: 🔧 repair, 🍳 recipe, 👤 creator
- Highlight matching text

---

### Screen 4.3: Profile & Quick Settings

**Purpose:** User identity and quick access to settings.

**Layout:**
- Modal bottom sheet (swipe up from profile tab)
- Or full screen from avatar tap

**Elements:**

**User Header:**
- Avatar (large, 80dp)
- Name / Email
- Member since date
- Edit button

**Stats Row:**
- Sessions Completed: 24
- Community Shares: 3
- Reputation Score: 4.8★

**Subscription Card:**
- Current Plan: "Free" or "Pro"
- If Free: "2 of 3 sessions used this month"
- CTA: "Upgrade to Pro"

**Quick Links (List):**
- My Sessions
- Saved Guides
- Community Profile
- Settings
- Help & Support
- Sign Out

---

## 5. Guide Discovery (3 Screens)

### Screen 5.1: Search Results

**Purpose:** Display matching guides from search.

**Layout:**
- List view with filter chips
- Sort options

**Elements:**

**Filter Chips (Horizontal Scroll):**
- "All Results" | "Repairs" | "Recipes" | "Video Available" | "Free Only"

**Sort Dropdown:**
- "Most Relevant" | "Most Popular" | "Newest" | "Shortest"

**Results List:**
Each card contains:
- Thumbnail (left, 80x80dp)
- Title (bold)
- Source: "iFixit" or "Community" badge
- Meta: "24 steps • ~45 min • 3 tools needed"
- Difficulty: Easy/Medium/Hard chip
- Price: "Free" / "$4.99" / "Pro" badge
- Rating: 4.8★ (142 reviews)

**Empty State:**
- Illustration: Magnifying glass with question mark
- Headline: "No guides found"
- Body: "Try different keywords or scan your device for suggestions"
- CTA: "Scan Device"

---

### Screen 5.2: Guide Preview

**Purpose:** Detailed view before starting a session.

**Layout:**
- Scrollable detail page
- Sticky bottom CTA

**Hero Section:**
- Large thumbnail/video preview
- Play button if video available
- Back button overlay

**Title Section:**
- Guide title (Display style)
- Source badge + link
- Rating with review count
- Bookmark button

**Quick Stats Row:**
- ⏱ "45 min" | 🔧 "3 tools" | 📊 "Medium" | 👁 "1.2k views"

**Description:**
- 2-3 line summary
- "Read more" expansion

**Tools Required Section:**
- Header: "You'll Need"
- Grid of tool cards with images
- Missing tool indicator (if user has saved inventory)
- "Buy tools" affiliate links (optional)

**Steps Preview:**
- Header: "24 Steps Overview"
- Collapsed accordion showing step titles
- Step 1: "Remove back panel screws"
- Step 2: "Disconnect battery"
- etc.

**Community Sessions:**
- Header: "Watch Others Complete This"
- Horizontal scroll of community video cards
- "See all X videos"

**Reviews Section:**
- Header: "Reviews"
- Overall rating large
- Recent review cards
- "Write a Review" link

**Sticky Bottom Bar:**
- Price: "$4.99" or "Free"
- Primary Button: "Start Guided Session"
- If Pro required: "Upgrade to Start"

---

### Screen 5.3: Tool Inventory (Optional Feature)

**Purpose:** Save tools user owns for smart recommendations.

**Layout:**
- Grid view of tool categories
- Toggle owned/needed

**Elements:**

**Header:**
- Title: "My Tool Inventory"
- Subtitle: "Help TrueStep suggest guides you can complete"

**Category Sections:**
- Screwdrivers (expandable)
- Pry Tools
- Tweezers
- Specialty Tools
- Kitchen Tools
- etc.

**Tool Cards:**
- Tool image
- Tool name
- Checkbox (owned/not owned)
- Info icon for details

**Smart Suggestion:**
- Banner: "You can complete 47 guides with your current tools"

---

## 6. Session Flow (7 Screens)

### Screen 6.1: Session Start / Image Ingestion

**Purpose:** Process user's input (URL, text, or image) before session.

**Layout:**
- Loading state with progress indication
- Preview of detected content

**For Image Input:**

**Camera/Gallery View:**
- Full screen camera
- Gallery button (bottom left)
- Capture button (center)
- Flash toggle (top)

**Processing State:**
- Captured image displayed
- Scanning animation overlay
- Text: "Analyzing image..."
- Progress indicator

**Confirmation Dialog:**
- Detected device image
- Headline: "I see a MacBook Air M2"
- Body: "Is this the device you want to repair?"
- Primary: "Yes, Find Guides"
- Secondary: "No, Try Again"
- Tertiary: "Enter Manually"

**Guide Matching:**
- Text: "Found 3 repair guides for MacBook Air M2"
- List of matching guides
- Select to proceed

---

### Screen 6.2: Calibration

**Purpose:** Establish scale reference for accurate visual analysis.

**Layout:**
- Full camera view
- Overlay guide

**Elements:**

**Header:**
- Title: "Quick Calibration"
- Subtitle: "This helps TrueStep measure accurately"

**Camera View:**
- Live feed
- Dashed circle outline (coin placement guide)
- Corner markers for alignment

**Instructions:**
- Text: "Place a US quarter (or 24mm coin) inside the circle"
- Animated arrow pointing to circle

**Detection States:**

*Searching:*
- Circle outline: White dashed
- Text: "Looking for coin..."

*Detected:*
- Circle outline: Green solid
- Checkmark animation
- Text: "Perfect! Calibration complete"

**Bottom Actions:**
- Primary: "Continue" (enabled after detection)
- Ghost: "Skip Calibration"

**Skip Warning Modal:**
- Icon: Warning triangle
- Headline: "Skip Calibration?"
- Body: "Some precision features may be less accurate without calibration."
- Primary: "Skip Anyway"
- Secondary: "Go Back"

---

### Screen 6.3: Tool Audit (The "Stage")

**Purpose:** Verify all required tools before starting.

**Layout:**
- Camera feed as background
- AR overlay for detection
- Tool checklist panel

**Elements:**

**Header Overlay:**
- Semi-transparent bar
- Title: "Let's Stage Your Workbench"
- Subtitle: "Lay out your tools so I can see them"

**Camera Feed:**
- Full screen live view
- Green bounding boxes appear around detected tools
- Tool label appears above each box: "✓ P5 Pentalobe"

**Tool Checklist Panel (Right Side):**
- Glass panel, 40% width
- Header: "Required Tools"
- List items:
  - ✓ P5 Pentalobe Driver (green, checked)
  - ✓ Spudger (green, checked)
  - ○ Suction Cup (white, unchecked)
  - ○ Tweezers (white, unchecked)

**Animation:**
- When tool detected, list item animates:
  - Checkbox fills green
  - Subtle confetti particles
  - Line connecting screen detection to list item

**Progress Indicator:**
- "3 of 5 tools found"
- Progress bar

**Bottom Actions:**
- Primary: "All Tools Ready →" (disabled until complete, then pulses green)
- Ghost: "I'm Missing Tools" → shows purchase links
- Text link: "Skip Tool Check" (reduces insurance coverage)

**Skip Warning:**
- Modal explaining reduced Mistake Insurance coverage
- Must acknowledge to proceed

---

### Screen 6.4: Active Session - Green State (Watching)

**Purpose:** Core guided experience - AI actively monitoring.

**Layout:**
- Minimal UI overlay on camera feed
- Information appears contextually

**Elements:**

**Traffic Light Header:**
- Height: 64dp
- Background: `--sentinel-green`
- Left: Animated eye icon (blinking periodically)
- Center: "WATCHING • Step 4 of 24"
- Right: Pause button

**Camera Feed:**
- Full screen, crystal clear
- Subtle green vignette at edges (barely visible)

**Instruction Card (Bottom):**
- Glass card, slides up from bottom
- Step number badge: "4"
- Instruction text: "Disconnect the battery connector by gently lifting the tab"
- Reference thumbnail (tap to enlarge)
- Safety warning (if applicable): ⚠️ "Don't touch metal contacts"

**Voice Hint:**
- Small pill at bottom
- Microphone icon + "Say 'Done' or 'Help'"

**Quick Actions (Hidden, Swipe Up):**
- "Show Reference Image"
- "Repeat Instructions"
- "I Need Help"
- "End Session"

**Gesture Controls:**
- Swipe left: Previous step (with confirmation)
- Swipe right: Disabled (must verify to advance)
- Two-finger tap: Pause session
- Long press: Activate voice command

---

### Screen 6.5: Active Session - Yellow State (Verifying)

**Purpose:** AI is actively analyzing completion.

**Layout:**
- Same as Green state with color transition

**Transition Animation:**
- Header color morphs from green to yellow (300ms)
- Eye icon transforms to waveform animation
- Yellow glow vignette pulses at edges

**Traffic Light Header:**
- Background: `--analysis-yellow`
- Left: Waveform animation (Lottie)
- Center: "VERIFYING • Hold steady..."
- Right: Cancel button

**Camera Feed:**
- Scanning line animation (horizontal line sweeping)
- Focus indicator on area being analyzed

**Instruction Card (Bottom):**
- Updates to: "Checking: Battery connector disconnected..."
- Progress bar showing analysis
- Estimated time: "~2 seconds"

**States within Yellow:**

*Analyzing:*
- Waveform animating
- "Analyzing step completion..."

*Uncertain:*
- Header stays yellow
- Text: "Need a better view..."
- Instruction: "Move closer" or "Adjust angle"

*Escalating to Tier 3:*
- Text: "Running deeper analysis..."
- Subtitle: "This might take a moment"

---

### Screen 6.6: Active Session - Red State (Intervention)

**Purpose:** Stop user from making a mistake.

**Layout:**
- Maximum attention-grabbing UI
- Blocks further action until acknowledged

**Trigger Animation:**
- Screen flashes red (100ms)
- Strong haptic burst
- Audio alert (if enabled)

**Visual Treatment:**
- Heavy red vignette overlay
- Pulsing red border (3dp)
- Camera feed dimmed to 50%

**Alert Modal (Center):**
- Glass card with red border
- Icon: Stop hand (64dp)
- Headline: "STOP" (Display, bold)
- Subhead: "Incorrect Tool Detected"
- Body: "You're using a Phillips #00 screwdriver. This step requires a P5 Pentalobe driver."
- Visual comparison: Side-by-side images of wrong vs right tool

**Actions:**
- Primary (Red): "I Understand"
- Secondary: "Show Me The Right Tool"
- Tertiary: "I Disagree" (flags for review)

**"Show Me The Right Tool" Expansion:**
- Image of correct tool
- Name and specifications
- "Where to buy" link
- "I have it now" button

**After Acknowledgment:**
- Red state dismisses
- Returns to Green state
- Voice: "Okay, I'm watching again. Take your time."

---

### Screen 6.7: Session Completion

**Purpose:** Celebrate success, handle recordings, prompt community share.

**Layout:**
- Celebratory UI
- Summary stats
- Clear CTAs

**Celebration Animation:**
- Confetti burst from top
- Success checkmark animation (Lottie)
- Subtle haptic success pattern

**Header:**
- Large checkmark icon
- Headline: "Repair Complete! 🎉"
- Subhead: "MacBook Air M2 Battery Replacement"

**Stats Card:**
- Glass card with green accent
- Grid layout:
  - ⏱ "47 min 23 sec"
  - ✓ "24/24 steps verified"
  - 🛡 "Insurance Active"
  - 📊 "92% AI confidence"

**Recording Section:**
- Header: "Session Recording"
- Preview thumbnail (tap to play)
- Duration: "47:23"

**Retention Notice:**
- Icon: Clock
- Text: "Recording auto-deletes in 30 days"
- Subtext: "Share to Community to preserve permanently"

**Community Share Card:**
- Glass card with purple accent (premium feel)
- Headline: "Share with the Community?"
- Body: "Help others learn from your successful repair"
- Toggle: "Share anonymously" (default off)
- Preview: How it will appear

**Action Buttons:**
- Primary: "Save & Finish"
- Secondary: "Share to Community"
- Ghost: "Watch Time-Lapse"

**Rating Prompt (After Save):**
- Modal: "How was TrueStep's guidance?"
- 5-star rating
- Optional comment field
- "Submit" / "Skip"

---

## 7. Community (4 Screens)

### Screen 7.1: Community Feed

**Purpose:** Browse and discover shared sessions.

**Layout:**
- Vertical feed (TikTok/Reels style option available)
- Filter tabs
- Search access

**Header:**
- Title: "Community"
- Search icon (right)
- Filter icon (right)

**Filter Tabs:**
- "For You" | "Trending" | "Following" | "Repairs" | "Recipes"

**Feed Cards:**
Each card contains:
- Creator avatar + name + follow button
- Video thumbnail (16:9)
- Play button overlay
- Title: "MacBook M2 Battery Replacement"
- Stats: "1.2k views • 89 helpful"
- Time: "2 hours ago"
- Engagement: Like, Helpful, Comment, Share icons

**Tap Behavior:**
- Tap card → Full screen video player

**Pull to Refresh:**
- Custom animation with TrueStep logo

---

### Screen 7.2: Video Player

**Purpose:** Watch community session recordings.

**Layout:**
- Full screen video
- Overlay controls
- Step markers

**Video Player:**
- Full screen playback
- Tap to show/hide controls

**Controls Overlay:**

*Top Bar:*
- Back button
- Title
- More options (Report, Save, Share)

*Center:*
- Play/Pause (large)
- 10s skip back/forward

*Bottom:*
- Progress bar with step markers
- Current time / Duration
- Fullscreen toggle
- Playback speed

**Step Markers:**
- Dots on progress bar indicating step transitions
- Tap marker to jump to that step
- Tooltip shows step name

**Side Actions (Vertical, Right):**
- Like (heart)
- "Helpful" (thumbs up)
- Comment (speech bubble)
- Share (arrow)
- Creator profile (avatar)

**Comments Panel:**
- Slides up from bottom
- Shows comments with timestamps
- "Add a comment" input

---

### Screen 7.3: Creator Profile

**Purpose:** View community member's public profile.

**Layout:**
- Profile header
- Stats
- Video grid

**Header:**
- Cover image (blurred video frame)
- Avatar (80dp)
- Display name
- Bio (optional)
- Follow button

**Stats Row:**
- Videos: 12
- Followers: 234
- Helpful votes: 567
- Member since: Jan 2026

**Tabs:**
- "Videos" | "About"

**Video Grid:**
- 3-column grid of thumbnails
- Play count overlay on each
- Tap to play

**About Tab:**
- Specialties: "MacBook repairs, iPhone screens"
- Badges earned
- Verification status

---

### Screen 7.4: My Community Profile

**Purpose:** Manage own community presence.

**Layout:**
- Same as Creator Profile
- Edit capabilities

**Additional Elements:**

**Edit Profile Button:**
- Opens edit modal

**Video Management:**
- Each video has edit/delete options
- Analytics per video (views, helpful, comments)

**Privacy Settings:**
- "Show my profile in search"
- "Allow comments on my videos"
- "Show my real name"

**Analytics Card:**
- Total views this month
- New followers this week
- Top performing video

---

## 8. Session History (2 Screens)

### Screen 8.1: Session History List

**Purpose:** Access all past sessions.

**Layout:**
- Filterable list view
- Clear status indicators

**Header:**
- Title: "My Sessions"
- Filter button
- Search button

**Filter Options (Modal):**
- Type: All, Repairs, Recipes
- Status: All, Recording Available, Expired, Shared
- Date range

**Session Cards:**
Each card shows:
- Thumbnail (left)
- Title
- Date completed
- Duration
- Status badge:
  - 🟢 "Recording Available" (green)
  - 🔵 "Shared to Community" (blue)
  - ⚪ "Expired" (grey)
  - 🟡 "Claim Filed" (yellow)
- Expiry countdown: "Deletes in 7 days"

**Card Actions (Swipe or Tap):**
- "Watch Recording"
- "Share to Community"
- "File Claim"
- "Delete"

**Empty State:**
- Illustration: Empty folder
- Headline: "No sessions yet"
- Body: "Complete your first guided session to see it here"
- CTA: "Start a Session"

---

### Screen 8.2: Session Detail

**Purpose:** Detailed view of a single past session.

**Layout:**
- Video player
- Step breakdown
- Actions

**Video Section:**
- Large player (16:9)
- Play button
- Duration

**Info Section:**
- Title
- Date & time
- Total duration
- Guide source link

**Recording Status Card:**
- If available:
  - "Recording available until [date]"
  - Countdown: "7 days remaining"
  - CTA: "Share to preserve"
- If expired:
  - "Recording deleted on [date]"
  - "Metadata preserved"
- If shared:
  - "Shared to Community on [date]"
  - Link to community post

**Step Breakdown:**
- Expandable list of all steps
- Each step shows:
  - Step number
  - Title
  - Verification status (✓ or !)
  - AI confidence %
  - Timestamp in video
  - Tap to jump to that point

**Actions:**
- "Watch Full Session"
- "Share to Community"
- "File Insurance Claim" (if eligible)
- "Delete Session"

---

## 9. Mistake Insurance Claim Flow (5 Screens)

### Screen 9.1: Claim Initiation

**Purpose:** Start the claims process.

**Layout:**
- Educational content
- Clear requirements

**Header:**
- Title: "File a Claim"
- Subtitle: "Mistake Insurance"

**Eligibility Card:**
- Status: "✓ Eligible" or "✗ Not Eligible"
- If not eligible, explain why

**Requirements Checklist:**
- ✓ Session completed with TrueStep guidance
- ✓ Recording still available (not expired)
- ✓ Claim filed within 30 days
- ✓ Damage occurred during guided session

**Session Selection:**
- If multiple eligible sessions, show picker
- Selected session card with details

**What to Expect:**
- "Claims are reviewed within 3-5 business days"
- "Maximum payout: $100"
- "Evidence is preserved for 90 days during review"

**CTA:**
- Primary: "Start Claim"
- Ghost: "Learn More About Mistake Insurance"

---

### Screen 9.2: Damage Documentation

**Purpose:** Capture evidence of damage.

**Layout:**
- Camera capture
- Guidance for good photos

**Instructions:**
- Headline: "Document the Damage"
- Body: "Take clear photos showing what went wrong"

**Photo Capture:**
- Camera view
- Capture button
- Gallery of captured photos (up to 5)
- Tips overlay: "Good lighting", "Multiple angles", "Close-ups"

**Photo Requirements:**
- Minimum 2 photos
- Progress: "2 of 5 photos (minimum 2)"

**Guidance Panel:**
- "Include photos of:"
- • The damaged area
- • The device as a whole
- • Any parts that broke

**Navigation:**
- Back: "Previous"
- Next: "Continue" (enabled after 2 photos)

---

### Screen 9.3: Issue Description

**Purpose:** Describe what happened.

**Layout:**
- Form fields
- Step selection

**Step Selection:**
- Header: "Which step was the problem?"
- Dropdown/picker of all session steps
- Selecting step shows that verification clip

**Description Field:**
- Label: "What happened?"
- Large text area
- Placeholder: "Describe what went wrong and when you noticed..."
- Character count: 0/500

**Damage Type (Optional):**
- Checkboxes:
  - Component broke
  - Wrong part installed
  - Device won't turn on
  - Cosmetic damage
  - Other

**Verification Clip Preview:**
- Shows the 3-second clip from selected step
- Player controls
- Caption: "This clip will be reviewed"

**Navigation:**
- Back: "Previous"
- Next: "Review Claim"

---

### Screen 9.4: Claim Review & Submit

**Purpose:** Review all claim details before submission.

**Layout:**
- Summary of all entered information
- Legal acknowledgment
- Submit CTA

**Summary Sections:**

**Session Info:**
- Title, Date, Duration
- Guide source

**Problem Step:**
- Step number and title
- Verification clip thumbnail

**Damage Documentation:**
- Photo thumbnails (tap to enlarge)
- Description text

**Your Description:**
- Full text of issue description

**Evidence Preservation Notice:**
- "By submitting, your session recording will be preserved for 90 days for review"

**Acknowledgment:**
- Checkbox: "I confirm this information is accurate and the damage occurred during this TrueStep session"

**CTA:**
- Primary: "Submit Claim"
- Ghost: "Save Draft"

---

### Screen 9.5: Claim Status & Tracking

**Purpose:** Track claim progress.

**Layout:**
- Status timeline
- Claim details

**Header:**
- Claim ID: "#TS-2026-00142"
- Filed: "Jan 15, 2026"

**Status Timeline:**
Vertical stepper showing:
1. ✓ "Claim Submitted" - Jan 15
2. ✓ "Under Review" - Jan 16
3. ○ "Decision Made" - Pending
4. ○ "Resolved"

**Current Status Card:**
- Large status text: "Under Review"
- Body: "A specialist is reviewing your session recording and evidence"
- Estimated completion: "2-3 business days"

**Claim Details (Expandable):**
- Session info
- Photos submitted
- Description
- Step in question

**Actions:**
- "Add Information" (if reviewer requests)
- "Contact Support"
- "Cancel Claim"

**Resolution States:**

*Approved:*
- Green card
- "Claim Approved"
- Amount: "$XX.XX"
- "Refund will be processed within 5-7 business days"

*Denied:*
- Red card
- "Claim Denied"
- Reason: "The verification clip shows the connector was properly seated..."
- "Appeal Decision" button

---

## 10. Settings & Account (2 Screens)

### Screen 10.1: Settings Main

**Purpose:** Central settings hub.

**Layout:**
- Grouped list sections
- Toggle switches and chevrons

**Sections:**

**Account:**
- Profile (chevron → edit profile)
- Email: "user@email.com"
- Subscription: "Pro Member" (chevron → manage)
- Sign Out

**Session Preferences:**
- Default input method: URL / Voice / Image
- Voice language: English (US)
- Haptic feedback: Toggle ON/OFF
- Audio confirmations: Toggle ON/OFF
- Dominant hand: Left / Right (affects UI placement)

**Recording & Privacy:**
- Auto-record sessions: Toggle ON/OFF (default ON)
- Recording quality: Standard / High
- Share usage analytics: Toggle ON/OFF
- "Manage My Data" (chevron)

**Notifications:**
- Recording expiry warnings: Toggle
- Community activity: Toggle
- Tips & tutorials: Toggle
- Marketing: Toggle

**Accessibility:**
- Text size: Slider
- High contrast mode: Toggle
- Reduce motion: Toggle
- Screen reader optimizations: Toggle

**Support:**
- Help Center (chevron)
- Contact Support (chevron)
- Report a Bug (chevron)
- Send Feedback (chevron)

**About:**
- Version: 1.0.0 (Build 42)
- Terms of Service
- Privacy Policy
- Licenses

---

### Screen 10.2: Manage My Data

**Purpose:** GDPR/privacy compliance; data management.

**Layout:**
- Informational content
- Action buttons

**Header:**
- Title: "Your Data"
- Subtitle: "Control how TrueStep uses your information"

**Data Summary Card:**
- Sessions recorded: 24
- Total recording time: 18 hours
- Storage used: 2.3 GB
- Data collected since: Jan 2026

**Data Categories:**
- Session recordings
- Step verification data
- Usage analytics
- Account information

**Actions:**

**Export My Data:**
- Button: "Request Data Export"
- Body: "Download all your TrueStep data"
- Timeline: "Ready within 48 hours"

**Delete Recordings:**
- Button: "Delete All Recordings"
- Warning: "This cannot be undone. Insurance claims will be affected."
- Requires confirmation

**Delete Account:**
- Button: "Delete My Account"
- Warning: "All data will be permanently deleted"
- 14-day grace period
- Requires password confirmation

---

## 11. Paywall & Subscription (2 Screens)

### Screen 11.1: Upgrade Prompt

**Purpose:** Convert free users to paid.

**Trigger Points:**
- 4th free session attempt
- Accessing Pro-only guide
- Tapping upgrade anywhere in app

**Layout:**
- Benefits focused
- Clear pricing
- Social proof

**Header:**
- Close button (X)
- Title: "Unlock TrueStep Pro"

**Value Illustration:**
- Animated hero showing Pro features

**Benefits List:**
- ✓ Unlimited guided sessions
- ✓ Access to premium guides
- ✓ Extended recording storage (90 days)
- ✓ Priority AI processing
- ✓ Masterclass modes
- ✓ Ad-free experience

**Pricing Cards:**

**Monthly:**
- "$14.99/month"
- "Billed monthly"
- "Most flexible"

**Annual (Highlighted):**
- "$99.99/year"
- "Save 44%"
- "Best value"
- Badge: "POPULAR"

**Or Pay-Per-Guide:**
- "$4.99 per repair guide"
- "No subscription needed"

**Social Proof:**
- "Join 10,000+ makers who upgraded"
- Star rating: 4.8/5
- Testimonial snippet

**CTA:**
- Primary: "Start 7-Day Free Trial"
- Caption: "Cancel anytime. No charge until trial ends."

**Footer:**
- "Restore Purchases"
- Terms link

---

### Screen 11.2: Subscription Management

**Purpose:** View and manage subscription.

**Layout:**
- Current plan details
- History
- Management options

**Current Plan Card:**
- Plan name: "TrueStep Pro (Annual)"
- Status: "Active"
- Price: "$99.99/year"
- Renewal date: "Renews Jan 15, 2027"
- Payment method: "Visa •••• 4242"

**Benefits Reminder:**
- Collapsed list of what's included

**Management Actions:**
- "Change Plan"
- "Update Payment Method"
- "Cancel Subscription"

**Purchase History:**
- List of past transactions
- Date, amount, status
- Download receipt option

**Cancel Flow:**
- "Why are you canceling?" survey
- Retention offer: "Stay and get 50% off next month"
- Confirm cancellation
- "You'll have access until [date]"

---

## 12. Error & Edge States (4 Screens)

### Screen 12.1: Offline Mode

**Purpose:** Handle no internet connection.

**Detection:**
- Monitor connectivity
- Show immediately when offline detected

**Layout:**
- Banner or full screen depending on context

**Banner Version (During Browse):**
- Yellow bar at top
- Icon: Wifi off
- Text: "You're offline. Some features unavailable."
- Dismiss button

**Full Screen (During Session Start):**
- Illustration: Disconnected cloud
- Headline: "No Internet Connection"
- Body: "TrueStep needs an internet connection to verify your progress in real-time."
- Primary: "Try Again"
- Secondary: "View Offline Guides" (if cached)

**Offline Capabilities:**
- View previously cached guides (read-only)
- Access session history (metadata only)
- Cannot start new guided sessions
- Cannot access community

---

### Screen 12.2: API/Service Error

**Purpose:** Handle backend failures gracefully.

**Scenarios:**
- AI service timeout
- Server error
- Rate limiting

**During Verification (Critical):**
- Yellow state persists longer
- Text: "Verification is taking longer than usual..."
- After 10s: "Having trouble connecting to AI"
- Options:
  - "Try Again"
  - "Mark Step Complete Manually" (reduces insurance)
  - "End Session"

**During Browse (Non-Critical):**
- Toast notification
- "Couldn't load content. Tap to retry."
- Auto-retry after 30s

**Service Unavailable:**
- Full screen
- Illustration: Server with wrench
- Headline: "We're Having Some Trouble"
- Body: "Our servers are experiencing issues. Please try again shortly."
- "Check Status" link to status page
- Auto-refresh indicator

---

### Screen 12.3: Permission Denied Recovery

**Purpose:** Guide users to fix permission issues.

**Camera Permission Denied:**
- Illustration: Camera with lock
- Headline: "Camera Access Required"
- Body: "TrueStep needs camera access to guide you through repairs."
- Steps:
  1. "Open Settings"
  2. "Find TrueStep"
  3. "Enable Camera"
- Primary: "Open Settings"
- Secondary: "Not Now"

**Microphone Denied (Non-Blocking):**
- Banner: "Voice control disabled. Enable microphone in Settings."
- Link: "Enable"

---

### Screen 12.4: Session Recovery

**Purpose:** Recover from interrupted sessions.

**Scenarios:**
- App crash
- Phone died
- Accidental close

**On App Reopen:**
- Modal overlay
- Headline: "Welcome back!"
- Body: "You have an incomplete session"
- Session card preview

**Options:**
- Primary: "Resume Session"
- Secondary: "Start Over"
- Ghost: "Discard Session"

**Resume Behavior:**
- Returns to last verified step
- Shows recap: "You completed 12 of 24 steps"
- "Continue from Step 13"

**If Recording Corrupted:**
- Warning: "Some recording data may be incomplete"
- "Continue without full insurance coverage?"
- Options to proceed or restart

---

## 13. Accessibility Specifications

### Visual Accessibility

**Color Contrast:**
- All text meets WCAG 2.1 AA standards
- Minimum 4.5:1 for body text
- Minimum 3:1 for large text and UI components

**Colorblind Support:**
- Traffic light states include icons, not just colors:
  - Green: Eye icon
  - Yellow: Waveform icon
  - Red: Stop hand icon
- Pattern indicators in addition to color

**Text Scaling:**
- Supports 200% text scaling
- UI reflows gracefully
- No text truncation on critical info

**High Contrast Mode:**
- Toggle in settings
- Increases all borders
- Removes glassmorphism blur
- Solid backgrounds

### Motor Accessibility

**Touch Targets:**
- Minimum 48x48dp for all interactive elements
- Minimum 8dp spacing between targets

**Gesture Alternatives:**
- All swipe actions have tap alternatives
- Voice commands for all critical actions
- External keyboard navigation support

**Timing:**
- No time-limited interactions (except session recording)
- Adjustable timeout for prompts

### Auditory Accessibility

**Captions:**
- All voice prompts have text alternatives
- Community videos support captions

**Visual Alerts:**
- All audio alerts paired with visual indicators
- Screen flash for Red intervention

### Screen Reader Support

**Labels:**
- All images have alt text
- All buttons have descriptive labels
- Dynamic content updates announced

**Navigation:**
- Logical focus order
- Skip links for repetitive content
- Landmarks for major sections

**Live Regions:**
- Traffic light state changes announced
- Verification status announced
- Step completion announced

---

## 14. Motion & Animation Guide

### Principles

1. **Purposeful:** Animation clarifies state changes, not decoration
2. **Fast:** Most animations 200-300ms
3. **Interruptible:** User actions can cancel animations
4. **Respectful:** Honor "Reduce Motion" setting

### Animation Tokens

| Type | Duration | Easing |
|------|----------|--------|
| Micro (feedback) | 100ms | ease-out |
| State change | 200ms | ease-in-out |
| Enter/Exit | 300ms | ease-out |
| Complex | 400-600ms | custom spring |
| Celebration | 1000ms | bounce |

### Key Animations

**Traffic Light Transition:**
- Background color morphs (300ms)
- Icon cross-fades (200ms)
- Glow pulses (continuous)

**Tool Detection:**
- Bounding box scales in (200ms)
- Checkmark bounces (300ms)
- Line draws to checklist (400ms)
- Confetti burst (600ms)

**Step Verification:**
- Circular progress (variable, tied to AI)
- Success: Scale pulse + checkmark
- Failure: Shake + red flash

**Red Intervention:**
- Screen flash (100ms)
- Border pulse (continuous until dismissed)
- Modal scales in with bounce (300ms)

**Completion Celebration:**
- Confetti burst (1000ms)
- Checkmark draws (400ms)
- Stats count up (600ms)

### Lottie Animations Used

| Animation | File | Usage |
|-----------|------|-------|
| Watching Eye | `eye_blink.json` | Green state header |
| Waveform | `waveform.json` | Yellow state header |
| Stop Hand | `stop_hand.json` | Red state modal |
| Confetti | `confetti.json` | Completion screen |
| Loading Dots | `loading.json` | General loading |
| Scanning Line | `scan_line.json` | Verification state |

---

## 15. Voice UI Patterns

### Wake Word & Commands

**Wake Word:** "Hey TrueStep"

**Core Commands:**
| Command | Aliases | Action |
|---------|---------|--------|
| "Next" | "Done", "Next step", "Continue" | Mark step complete (triggers verification) |
| "Repeat" | "Say again", "What?" | Repeat current instruction |
| "Help" | "I need help", "Show me" | Show reference image/video |
| "Pause" | "Wait", "Hold on" | Pause session |
| "Resume" | "Continue", "Go" | Resume paused session |
| "Stop" | "End", "Cancel" | End session (with confirmation) |
| "Back" | "Previous", "Go back" | Go to previous step |

### Voice Feedback

**Recognition Indicator:**
- Small waveform animation in corner
- Transcription preview bubble
- Confirmation pulse

**Responses:**
- Acknowledgment: "Got it" / "Okay" / "Moving on"
- Clarification: "Did you say [command]?"
- Unrecognized: "I didn't catch that. Try saying 'next' or 'help'"

### Voice Settings

**Options:**
- Voice enabled/disabled
- Wake word on/off
- Response voice: Male/Female/Neutral
- Response volume
- Speech rate

### Voice Errors

**No Speech Detected:**
- After 10s of listening: "I didn't hear anything. Tap the mic to try again."

**Noisy Environment:**
- "Having trouble hearing you. Try speaking louder or tap controls."

**Network Error:**
- "Voice commands need internet. Use touch controls for now."

---

## 16. Flutter Implementation Notes

### State Management

```dart
// Riverpod providers for session state
final sessionStateProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});

enum SentinelState { idle, watching, verifying, intervention, completed }

class SessionState {
  final SentinelState sentinelState;
  final int currentStep;
  final int totalSteps;
  final String currentInstruction;
  final double aiConfidence;
  final List<StepLog> stepLogs;
  // ...
}
```

### Traffic Light Header Widget

```dart
class TrafficLightHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionStateProvider);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 64,
      decoration: BoxDecoration(
        color: _getBackgroundColor(state.sentinelState),
        boxShadow: [
          BoxShadow(
            color: _getGlowColor(state.sentinelState),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStateIcon(state.sentinelState),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getStatusText(state),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildActionButton(state.sentinelState),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getBackgroundColor(SentinelState state) {
    switch (state) {
      case SentinelState.watching:
        return const Color(0xFF00E676); // Sentinel Green
      case SentinelState.verifying:
        return const Color(0xFFFFC400); // Analysis Yellow
      case SentinelState.intervention:
        return const Color(0xFFFF3D00); // Intervention Red
      default:
        return const Color(0xFF1E1E1E);
    }
  }
  
  Widget _buildStateIcon(SentinelState state) {
    switch (state) {
      case SentinelState.watching:
        return Lottie.asset(
          'assets/animations/eye_blink.json',
          width: 32,
          height: 32,
        );
      case SentinelState.verifying:
        return Lottie.asset(
          'assets/animations/waveform.json',
          width: 32,
          height: 32,
        );
      case SentinelState.intervention:
        return const Icon(
          Icons.front_hand,
          color: Colors.white,
          size: 32,
        );
      default:
        return const SizedBox(width: 32);
    }
  }
}
```

### Glass Card Component

```dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsets padding;
  
  const GlassCard({
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.all(16),
  });
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor ?? Colors.white.withOpacity(0.12),
              width: accentColor != null ? 2 : 1,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
```

### Key Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
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
  purchases_flutter: ^6.6.0  # RevenueCat
  
  # Utilities
  permission_handler: ^11.0.1
  connectivity_plus: ^5.0.1
  shared_preferences: ^2.2.2
  hive_flutter: ^1.1.0
```

---

## Appendix A: Screen Flow Diagram

```
                              ┌─────────────┐
                              │   Splash    │
                              └──────┬──────┘
                                     │
                    ┌────────────────┴────────────────┐
                    ▼                                 ▼
            ┌──────────────┐                  ┌──────────────┐
            │  Onboarding  │                  │     Home     │
            │   (New User) │                  │  (Returning) │
            └──────┬───────┘                  └──────┬───────┘
                   │                                 │
                   └─────────────┬───────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │      Home/Briefing     │
                    │    (Bottom Nav Hub)    │
                    └────────────┬───────────┘
                                 │
        ┌────────────┬───────────┼───────────┬────────────┐
        ▼            ▼           ▼           ▼            ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
   │ Search  │ │Community│ │ Quick + │ │ History │ │ Profile │
   └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
        │           │           │           │           │
        ▼           ▼           ▼           ▼           ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
   │ Results │ │  Feed   │ │Ingestion│ │ Session │ │Settings │
   └────┬────┘ └────┬────┘ └────┬────┘ │ Detail  │ └─────────┘
        │           │           │      └────┬────┘
        ▼           ▼           │           │
   ┌─────────┐ ┌─────────┐      │           ▼
   │  Guide  │ │  Video  │      │      ┌─────────┐
   │ Preview │ │ Player  │      │      │  Claim  │
   └────┬────┘ └─────────┘      │      │  Flow   │
        │                       │      └─────────┘
        └───────────┬───────────┘
                    │
                    ▼
          ┌─────────────────┐
          │   Calibration   │
          └────────┬────────┘
                   │
                   ▼
          ┌─────────────────┐
          │   Tool Audit    │
          └────────┬────────┘
                   │
                   ▼
          ┌─────────────────┐
          │ Active Session  │
          │ (Traffic Light) │
          │  Green/Yellow/  │
          │      Red        │
          └────────┬────────┘
                   │
                   ▼
          ┌─────────────────┐
          │   Completion    │
          │ (Share/Finish)  │
          └─────────────────┘
```

---

## Appendix B: File Structure

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
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── providers/
│   ├── home/
│   ├── search/
│   ├── session/
│   │   ├── screens/
│   │   │   ├── calibration_screen.dart
│   │   │   ├── tool_audit_screen.dart
│   │   │   ├── active_session_screen.dart
│   │   │   └── completion_screen.dart
│   │   ├── widgets/
│   │   │   ├── traffic_light_header.dart
│   │   │   ├── instruction_card.dart
│   │   │   └── intervention_modal.dart
│   │   └── providers/
│   │       └── session_provider.dart
│   ├── community/
│   ├── history/
│   ├── claims/
│   ├── settings/
│   └── paywall/
├── shared/
│   ├── widgets/
│   │   ├── glass_card.dart
│   │   ├── primary_button.dart
│   │   └── loading_indicator.dart
│   └── providers/
└── services/
    ├── ai_service.dart
    ├── camera_service.dart
    ├── voice_service.dart
    └── storage_service.dart

assets/
├── animations/
│   ├── eye_blink.json
│   ├── waveform.json
│   ├── confetti.json
│   └── loading.json
├── images/
│   ├── onboarding/
│   └── icons/
└── fonts/
```

---

*— End of Document —*
