# 🏸 Pro Badminton — UI Design System & Screen Specifications

> **Version:** 2.0 — Redesigned  
> **Framework:** Flutter 3.x / Material 3  
> **Theme:** Sport-focused dark green + energetic orange accent  
> **Target:** Android & iOS

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Color System](#2-color-system)
3. [Typography](#3-typography)
4. [Spacing & Layout](#4-spacing--layout)
5. [Component Library](#5-component-library)
6. [Screen Designs](#6-screen-designs)
7. [Animation & Motion](#7-animation--motion)
8. [Responsive Guidelines](#8-responsive-guidelines)

---

## 1. Design Philosophy

**Three core principles:**

1. **Sport Energy** — Vibrant green with orange accents conveys energy, health, and badminton court vibes
2. **Effortless Booking** — Users can go from opening the app to booking a court in under 30 seconds
3. **Clear Hierarchy** — Every screen has one primary action that's immediately obvious

**Design mood:**  
Think Nike Training Club meets Grab — sporty, clean, action-oriented with bold colors and clear CTAs.

---

## 2. Color System

### Primary Palette

| Name           | Hex       | Usage                                   |
| -------------- | --------- | --------------------------------------- |
| `primary`      | `#006400` | App bar, primary buttons, active states |
| `primaryDark`  | `#004D00` | Pressed states, gradients               |
| `primaryLight` | `#E8F5E9` | Light backgrounds, member badges        |
| `accent`       | `#FF6F00` | CTAs, badges, highlights, FABs          |
| `accentLight`  | `#FFF3E0` | Warning backgrounds, promo banners      |

### Neutral Palette

| Name             | Hex       | Usage                       |
| ---------------- | --------- | --------------------------- |
| `background`     | `#FAFAFA` | Screen background           |
| `surface`        | `#FFFFFF` | Cards, sheets, dialogs      |
| `surfaceVariant` | `#F5F5F5` | Input backgrounds, dividers |
| `textPrimary`    | `#1A1A1A` | Headlines, body text        |
| `textSecondary`  | `#6B6B6B` | Captions, helper text       |
| `textDisabled`   | `#BDBDBD` | Disabled text, placeholders |
| `divider`        | `#EEEEEE` | Dividers, borders           |

### Semantic Colors

| Name      | Hex       | Usage                |
| --------- | --------- | -------------------- |
| `success` | `#2E7D32` | Confirmed, available |
| `warning` | `#F57C00` | Pending, waiting     |
| `error`   | `#C62828` | Cancelled, errors    |
| `info`    | `#1565C0` | Informational badges |

### Status Colors (for bookings/waitlist)

| Status      | Background | Text Color | Icon            |
| ----------- | ---------- | ---------- | --------------- |
| `pending`   | `#FFF3E0`  | `#E65100`  | `access_time`   |
| `confirmed` | `#E3F2FD`  | `#1565C0`  | `check_circle`  |
| `completed` | `#E8F5E9`  | `#2E7D32`  | `task_alt`      |
| `cancelled` | `#FFEBEE`  | `#C62828`  | `cancel`        |
| `waiting`   | `#FFF8E1`  | `#F57F17`  | `hourglass_top` |

### Gradient Definitions

```
Primary Gradient:  linear-gradient(135°, #006400 → #00802B)
Accent Gradient:   linear-gradient(135°, #FF6F00 → #FF8F00)
Hero Gradient:     linear-gradient(180°, #006400 → #004D00 with 80% opacity)
```

---

## 3. Typography

### Font Family: `GoogleFonts.poppins()` (or system default)

| Style       | Size | Weight   | Letter Spacing | Usage                    |
| ----------- | ---- | -------- | -------------- | ------------------------ |
| `headline1` | 28sp | Bold     | -0.5           | Screen titles            |
| `headline2` | 24sp | Bold     | -0.3           | Section headers          |
| `headline3` | 20sp | SemiBold | 0              | Card titles              |
| `subtitle1` | 16sp | Medium   | 0.15           | Subtitles, list items    |
| `body1`     | 16sp | Regular  | 0.25           | Body text                |
| `body2`     | 14sp | Regular  | 0.25           | Secondary body, captions |
| `caption`   | 12sp | Regular  | 0.4            | Labels, timestamps       |
| `button`    | 16sp | SemiBold | 0.5            | Button text              |
| `overline`  | 10sp | SemiBold | 1.5            | Chip labels, badges      |

### Text Color Rules

- Headlines: Always `textPrimary` (#1A1A1A)
- Body on light bg: `textPrimary`
- Body on dark bg (green/orange): `#FFFFFF`
- Secondary info: `textSecondary`
- Prices: `accent` (#FF6F00) in **Bold**

---

## 4. Spacing & Layout

### Spacing Scale

| Token | Value | Usage                            |
| ----- | ----- | -------------------------------- |
| `xs`  | 4dp   | Tight spacing, icon padding      |
| `sm`  | 8dp   | Inner component spacing          |
| `md`  | 16dp  | Standard content padding         |
| `lg`  | 24dp  | Section spacing                  |
| `xl`  | 32dp  | Screen edge padding (horizontal) |
| `2xl` | 48dp  | Large section gaps               |

### Layout Rules

- **Horizontal screen padding:** 20dp (sides)
- **Card internal padding:** 16dp
- **Card corner radius:** 16dp
- **Button corner radius:** 12dp
- **Input field corner radius:** 12dp
- **Bottom nav height:** 64dp
- **App bar height:** 56dp (no title on tab screens, custom app bar)
- **Max content width:** 600dp (for tablets)

### Card Specifications

```
Card:
  elevation: 0
  shape: RoundedRectangleBorder(borderRadius: 16)
  border: 1dp solid #EEEEEE (subtle border instead of elevation)
  padding: 16dp
  background: #FFFFFF
```

---

## 5. Component Library

### 5.1 Primary Button (Filled)

```
Height: 52dp
Border Radius: 12dp
Background: primary (#006400)
Text: White, 16sp, SemiBold
Padding: Horizontal 24dp, Vertical 14dp
Full-width on mobile

States:
  Normal: bg=#006400, text=white
  Pressed: bg=#004D00
  Disabled: bg=#BDBDBD, text=#EEEEEE
  Loading: show white CircularProgressIndicator (20dp)
```

### 5.2 Secondary Button (Outlined)

```
Height: 48dp
Border: 2dp solid #006400
Text: #006400, 16sp, SemiBold
Background: transparent
Pressed: bg=#E8F5E9
```

### 5.3 Accent Button (Orange CTA)

```
Height: 52dp
Border Radius: 12dp
Background: accent (#FF6F00)
Text: White, 16sp, Bold
Used for: "Book Now", "Subscribe", "Pay Now"
```

### 5.4 Input Fields

```
Height: 56dp
Border Radius: 12dp
Border: 2dp solid #EEEEEE (normal), #006400 (focused), #C62828 (error)
Background: #FAFAFA (normal), #FFFFFF (focused)
Label: 14sp, textSecondary
Error text: 12sp, error color, below field
Prefix icon: 24dp, textSecondary
Content padding: 16dp horizontal, 16dp vertical
```

### 5.5 Court Card (List Item)

```
┌─────────────────────────────────────────────────┐
│ ┌──────────┐  Court Name            ★ 4.5 (12)  │
│ │  Image    │  Location address                  │
│ │  100x100  │  ฿200/hr  •  3.2 km               │
│ └──────────┘  [Member: ฿150/hr]                 │
└─────────────────────────────────────────────────┘

Card: elevation 0, border 1dp #EEEEEE, radius 16dp
Image: ClipRRect radius 12dp, 100x100, placeholder with shuttlecock icon
Title: 16sp SemiBold, textPrimary
Rating: amber stars + count, 14sp
Price: 16sp Bold, accent (#FF6F00)
Member price: 14sp, primary (#006400), with verified icon
Distance: 14sp, textSecondary
```

### 5.6 Booking Card

```
┌─────────────────────────────────────────────────┐
│ [Status Badge]                    ฿400.00       │
│                                                 │
│  🏸 Court Name                                  │
│  📅 01 May 2026                                 │
│  🕘 09:00 AM - 11:00 AM (2 hrs)                │
│                                                 │
│  Equipment: 1 Racket, 2 Shuttles               │
└─────────────────────────────────────────────────┘

Status badge: Rounded pill, status colors from table above
Price: 18sp Bold, accent
Info rows: 14sp with leading icons (14dp, textSecondary color)
```

### 5.7 Status Badge

```
Shape: Stadium border (fully rounded pill)
Padding: Horizontal 12dp, Vertical 4dp
Text: 12sp SemiBold
Colors: From status color table (background + text)
Icon: 14dp, same color as text, before label
```

### 5.8 Rating Stars

```
Star size: 20dp
Filled: amber (#FFC107)
Empty: #E0E0E0
Spacing: 2dp between stars
Interactive: on review screen (tap to set)
```

### 5.9 Time Slot Chip

```
Height: 44dp
Border Radius: 10dp

Available:
  bg: #E8F5E9, border: 1dp #2E7D32, text: #2E7D32
Selected:
  bg: #006400, border: none, text: white, icon: check_circle
Booked:
  bg: #FFEBEE, border: 1dp #C62828, text: #C62828, strikethrough
```

### 5.10 Equipment Counter

```
┌──────────────────────────────────────┐
│  🏸  Racket            [-] 2 [+]    │
│      ฿50 each                       │
└──────────────────────────────────────┘

Row with: emoji/icon, name, unit price, counter
Counter: - button (48dp circle) | count (16sp Bold) | + button (48dp circle)
Buttons: outlined when 0, filled primary when >0
```

### 5.11 Empty State

```
┌──────────────────────────────────────┐
│                                      │
│           [Icon 64dp]                │
│                                      │
│        No bookings yet               │
│  Your upcoming bookings will appear  │
│         here.                        │
│                                      │
│       [ Browse Courts ]              │
│                                      │
└──────────────────────────────────────┘

Icon: textDisabled color
Title: 18sp SemiBold, textPrimary
Subtitle: 14sp, textSecondary
Action button: Secondary outlined (optional)
```

### 5.12 Shimmer Loading

```
Base color: #F5F5F5
Highlight color: #EEEEEE
Duration: 1500ms
Shape: Match the content being loaded
  - Cards: RoundedRectangle 16dp
  - Text lines: Stadium shape, heights 12dp/14dp/16dp
  - Images: RoundedRectangle 12dp
```

### 5.13 Bottom Navigation Bar

```
Height: 64dp + safe area
Background: #FFFFFF
Border top: 1dp #EEEEEE
Selected color: #006400
Unselected color: #BDBDBD
Indicator: pill shape behind selected icon (bg: #E8F5E9)
Font: 12sp Medium

Items:
  Home: Icons.sports_tennis
  Map: Icons.map_outlined
  Bookings: Icons.calendar_today_outlined
  Profile: Icons.person_outline

Admin item (5th, conditional):
  Admin: Icons.admin_panel_settings_outlined
```

---

## 6. Screen Designs

### 6.1 Splash Screen

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│                                     │
│              🏸                     │
│         (shuttlecock icon           │
│          animated bounce)           │
│                                     │
│        Pro Badminton                │
│    Find & Book Courts Near You      │
│                                     │
│         ● ○ ○ (loading dots)        │
│                                     │
│                                     │
│                                     │
│                                     │
│   Background: primary gradient      │
│   Text: white                       │
└─────────────────────────────────────┘
```

**Specs:**

- Background: Primary gradient (135°, #006400 → #00802B) full screen
- Shuttlecock icon: 96dp, white, with subtle bounce animation (0.5s, easeInOut)
- Title: 32sp Bold, white
- Subtitle: 16sp Regular, white 80% opacity
- Loading: Three animated dots (not CircularProgressIndicator) — more on-brand
- Duration: 1.5s minimum display, then auto-navigate

---

### 6.2 Login Screen

```
┌─────────────────────────────────────┐
│  ← (back to splash if needed)       │
│                                     │
│         [green shuttlecock          │
│          icon in circle,            │
│          80dp, bg: primaryLight]    │
│                                     │
│           Welcome Back              │
│      Sign in to your account        │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ ✉  Email                    │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 🔒 Password          [👁]   │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │        Sign In              │    │
│  └─────────────────────────────┘    │
│  (primary button, full width)       │
│                                     │
│  Don't have an account? Register    │
│                                     │
│  ────────── or ──────────           │
│  (optional: social login later)     │
│                                     │
└─────────────────────────────────────┘
```

**Specs:**

- Background: #FAFAFA
- Top spacing: 60dp from safe area
- Logo circle: 80dp, bg #E8F5E9, icon 40dp primary color
- "Welcome Back": 28sp Bold, textPrimary
- "Sign in to your account": 14sp, textSecondary
- Fields: standard input spec (see 5.4), spacing 16dp between
- "Sign In" button: primary button spec (see 5.1), full width
- "Don't have an account? **Register**": Register text in primary color, clickable
- Error display: Red snackbar at bottom with error icon
- Loading: Button shows white spinner, fields become non-interactive

---

### 6.3 Register Screen

```
┌─────────────────────────────────────┐
│  ← Back                             │
│                                     │
│         [green shuttlecock          │
│          icon in circle]            │
│                                     │
│         Create Account              │
│    Join Pro Badminton today         │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 👤 Full Name                │    │
│  └─────────────────────────────┘    │
│  16dp                               │
│  ┌─────────────────────────────┐    │
│  │ ✉  Email                    │    │
│  └─────────────────────────────┘    │
│  16dp                               │
│  ┌─────────────────────────────┐    │
│  │ 🔒 Password          [👁]   │    │
│  └─────────────────────────────┘    │
│  16dp                               │
│  ┌─────────────────────────────┐    │
│  │ 📍 Address                  │    │
│  │   (multiline, max 3 lines)  │    │
│  └─────────────────────────────┘    │
│  24dp                               │
│  ┌─────────────────────────────┐    │
│  │       Create Account        │    │
│  └─────────────────────────────┘    │
│                                     │
│  Already have an account? Login     │
│                                     │
└─────────────────────────────────────┘
```

**Specs:**

- Same layout pattern as login
- "Create Account": 28sp Bold
- Address field: min 2 lines, max 3 lines, with location pin prefix icon
- All other specs match login screen

---

### 6.4 Home / Search Screen

```
┌─────────────────────────────────────┐
│  🏸 Pro Badminton      [👤 Profile] │
│  ┌─────────────────────────────┐    │
│  │ 🔍  Search courts...        │    │
│  └─────────────────────────────┘    │
│                                     │
│  [All] [Nearby] [< ฿300] [Top ⭐]  │
│  (filter chips row, scrollable)     │
│                                     │
│  ── Nearby Courts ──────────────    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ [img]  Court Name   ★ 4.5  │    │
│  │        Location             │    │
│  │        ฿200/hr • 3.2 km    │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ [img]  Court Name   ★ 4.2  │    │
│  │        Location             │    │
│  │        ฿250/hr • 5.1 km    │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ [img]  Court Name   ★ 3.8  │    │
│  │        Location             │    │
│  │        ฿180/hr • 1.5 km    │    │
│  └─────────────────────────────┘    │
│                                     │
│      [ 🗺️ Map View ] (FAB)         │
│                                     │
│ ═════════════════════════════════   │
│  🏸     🗺️     📅     👤           │
│  Home  Map  Bookings Profile        │
└─────────────────────────────────────┘
```

**Specs:**

- Custom app bar: No AppBar widget, use Column with custom layout
  - Row: "Pro Badminton" (20sp Bold) + profile avatar circle (36dp, tap → profile)
  - Padding: 20dp horizontal, 12dp top
- Search bar: 52dp height, radius 26dp (stadium shape), bg #FFFFFF, shadow elevation 2dp
  - Prefix: search icon 20dp, textSecondary
  - "Search courts..." placeholder in textDisabled
- Filter chips: Scrollable horizontal row, 8dp below search
  - Selected: bg primary, text white
  - Unselected: bg surface, border 1dp #EEEEEE, text textSecondary
  - Chips: "All", "Nearby", "< ฿300/hr", "Top Rated ⭐"
- Section header: "Nearby Courts" — 18sp SemiBold + horizontal line
- Court cards: See 5.5 spec
  - Stacked vertically with 12dp gap
  - Tappable → Court Detail
- FAB: "🗺️ Map View" extended FAB, accent color, bottom-right, 16dp above bottom nav
- Pull-to-refresh: RefreshIndicator with primary color
- Empty state: See 5.11 spec with "No courts found" + "Try adjusting your filters"
- Loading: Shimmer cards (see 5.12)

---

### 6.5 Map View Screen

```
┌─────────────────────────────────────┐
│  ← Back    Map View                 │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │         Google Map              │ │
│ │    (markers for each court)     │ │
│ │         🏸                      │ │
│ │              🏸                 │ │
│ │     🏸                          │ │
│ │                                 │ │
│ │      [📍 My Location FAB]      │ │
│ └─────────────────────────────────┘ │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ [img] Court Name  ★ 4.5    │    │ ← Bottom sheet (draggable)
│  │       Location              │    │
│  │       ฿200/hr • 3.2km      │    │
│  │       [View Details →]      │    │
│  └─────────────────────────────┘    │
│                                     │
│ ═════════════════════════════════   │
│  🏸     🗺️     📅     👤           │
│  Home  Map  Bookings Profile        │
└─────────────────────────────────────┘
```

**Specs:**

- Full-screen Google Map with court markers
- Markers: Custom green marker icon with shuttlecock emoji
- Tap marker → bottom sheet slides up with court preview card
- Bottom sheet: draggable, peek height 160dp, expanded shows more details
- My Location FAB: white circle, elevation 4dp, bottom-right above nav
- Court preview card: same style as court card, with "View Details →" text button

---

### 6.6 Court Detail Screen

```
┌─────────────────────────────────────┐
│  ← Back               [♡ Share]    │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │      Hero Image (200dp)         │ │
│ │      (placeholder if none)      │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│  Court Name                ★ 4.5   │
│  📍 Location address       (12)    │
│                                     │
│  ┌─────────┐  ┌─────────┐          │
│  │ ฿200/hr  │  │ 3.2 km  │          │
│  │ Standard │  │ Distance│          │
│  └─────────┘  └─────────┘          │
│  ┌─────────┐                        │
│  │ ฿150/hr  │ ← member price card   │
│  │ Member*  │   (if user is member) │
│  └─────────┘                        │
│                                     │
│  About                              │
│  Description text goes here...      │
│                                     │
│  ┌─────────────────────────────────┐│
│  │  [Mini Map - 150dp height]      ││
│  │   with court pin                ││
│  └─────────────────────────────────┘│
│                                     │
│  Reviews (12) ──────── [Write ✍]   │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  User Name    ★★★★☆  2d ago │    │
│  │  "Great court! Good ..."    │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │  User Name    ★★★★★  5d ago │    │
│  │  "Excellent facilities..."  │    │
│  └─────────────────────────────┘    │
│                                     │
│  ═══════════════════════════════    │
│  ┌─────────────────────────────┐    │
│  │     🏸  Book Now  - ฿200/hr │    │ ← Sticky bottom bar
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

**Specs:**

- Hero image: Full width, 200dp height, ClipRRect top 0, bottom 16dp
  - Placeholder: gradient bg with shuttlecock icon if no image
- Title: 24sp Bold, textPrimary
- Rating row: amber stars (20dp) + "4.5" Bold + "(12 reviews)" textSecondary
- Location: 14sp with pin icon, textSecondary
- Info cards row: 3 small stat cards (price, distance, hours)
  - Each: bg surface, border 1dp, radius 12dp, centered content
  - Price: accent color Bold, label textSecondary
- Member price: green card with verified icon, if user is member
- About section: "About" 18sp SemiBold + description 14sp
- Mini map: ClipRRect 12dp, 150dp height, static court pin
- Reviews section: "Reviews (12)" header + "Write a Review" text button
  - Review cards: avatar circle (32dp) + name + stars + date + comment
- Sticky bottom bar: white bg, elevation 8dp, padding 16dp
  - "Book Now" accent button, full width, 52dp height
  - Shows price: "Book Now — ฿200/hr"

---

### 6.7 Booking Flow (Multi-step)

**Shared layout:**

```
┌─────────────────────────────────────┐
│  ← Back     Book Court     1/6     │ ← step indicator
│  ━━━━━━━━━━━○─────── (progress)     │
│                                     │
│  [Step Content Area]                │
│                                     │
│                                     │
│                                     │
│                                     │
│  ┌─────────────────────────────┐    │
│  │         Continue →          │    │ ← bottom button
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

**Step 1: Select Date**

```
┌─────────────────────────────────────┐
│  ← Back     Select Date      1/6   │
│  ━━○────────────────────────        │
│                                     │
│  ┌─────────────────────────────┐    │
│  │    📅  Table Calendar       │    │
│  │    (only future dates)      │    │
│  │    Selected: green circle   │    │
│  │    Today: orange dot        │    │
│  └─────────────────────────────┘    │
│                                     │
│  Selected: Thursday, 1 May 2026     │
│                                     │
│  ┌─────────────────────────────┐    │
│  │         Continue →          │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

**Step 2: Select Time Slot**

```
┌─────────────────────────────────────┐
│  ← Back     Select Time      2/6   │
│  ━━━━○────────────────────          │
│                                     │
│  Duration: [1hr] [2hr] [3hr]       │
│  (toggle buttons)                   │
│                                     │
│  Available Slots:                   │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐      │
│  │08:0│ │09:0│ │10:0│ │11:0│      │
│  │ 0  │ │ 0  │ │ 0✓ │ │ 0  │      │
│  └────┘ └────┘ └────┘ └────┘      │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐      │
│  │12:0│ │13:0│ │14:0│ │15:0│      │
│  │ XX │ │ 0  │ │ 0  │ │ 0  │      │
│  └────┘ └────┘ └────┘ └────┘      │
│                                     │
│  🟢 Available  🔴 Booked  ✅ Yours │
│                                     │
│  ┌─────────────────────────────┐    │
│  │         Continue →          │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

- Duration selector: 3 toggle buttons in a row, primary when selected
- Time slots: GridView with 4 columns, chips from spec 5.9
- When duration > 1hr, selecting a start time auto-highlights consecutive slots
- If any consecutive slot is booked, show as unavailable

**Step 3: Equipment Rentals**

```
┌─────────────────────────────────────┐
│  ← Back     Equipment        3/6   │
│  ━━━━━━○──────────────────          │
│                                     │
│  Add equipment to your booking?     │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🏸  Racket          ฿50   │    │
│  │      per racket             │    │
│  │            [-]  0  [+]      │    │
│  └─────────────────────────────┘    │
│  12dp                               │
│  ┌─────────────────────────────┐    │
│  │  🪶  Shuttlecock     ฿30   │    │
│  │      per piece              │    │
│  │            [-]  2  [+]      │    │
│  └─────────────────────────────┘    │
│  12dp                               │
│  ┌─────────────────────────────┐    │
│  │  👟  Shoes           ฿40   │    │
│  │      per pair               │    │
│  │            [-]  0  [+]      │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │         Continue →          │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

- Equipment cards: bg surface, border 1dp, radius 16dp
- Counter: See spec 5.10
- Emoji icons for visual interest

**Step 4: Price Summary**

```
┌─────────────────────────────────────┐
│  ← Back     Order Summary     4/6  │
│  ━━━━━━━○────────────────           │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Court Cost                 │    │
│  │  2 hrs × ฿200/hr    ฿400   │    │
│  │  ─────────────────────────  │    │
│  │  Equipment                  │    │
│  │  2× Shuttlecock      ฿60   │    │
│  │  ─────────────────────────  │    │
│  │  Member Discount     -฿100  │    │ ← green text if member
│  │  ─────────────────────────  │    │
│  │  Total              ฿360    │    │ ← bold, accent color
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │     Proceed to Payment →    │    │ ← accent button
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

**Step 5: Payment Method**

```
┌─────────────────────────────────────┐
│  ← Back     Payment          5/6   │
│  ━━━━━━━━━○────────────             │
│                                     │
│  Choose payment method              │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ 💳  Credit Card             │    │ ← selected: green border
│  │      Pay securely via Stripe│    │
│  │                    ○ / ●    │    │
│  └─────────────────────────────┘    │
│  12dp                               │
│  ┌─────────────────────────────┐    │
│  │ 🏦  Bank Transfer           │    │
│  │      Transfer to our account│    │
│  │                    ○ / ●    │    │
│  └─────────────────────────────┘    │
│  12dp                               │
│  ┌─────────────────────────────┐    │
│  │ 📱  PromptPay               │    │
│  │      Scan QR to pay         │    │
│  │                    ○ / ●    │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │       Confirm Payment       │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

- Payment cards: bg surface, border 2dp, radius 16dp
- Selected: border primary (#006400), bg primaryLight (#E8F5E9)
- Radio indicator: right-aligned, primary color

**Step 6: Confirmation**

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│            ✅                       │
│     (animated checkmark,            │
│      80dp, green circle)            │
│                                     │
│      Booking Confirmed!             │
│   Your court has been reserved      │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Booking #B001              │    │
│  │  Court Name                 │    │
│  │  📅 01 May 2026             │    │
│  │  🕘 09:00 - 11:00           │    │
│  │  💰 ฿360.00                 │    │
│  │  Status: Confirmed ✓        │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │      View Booking →         │    │
│  └─────────────────────────────┘    │
│  12dp                               │
│  ┌─────────────────────────────┐    │
│  │      Back to Home           │    │ ← outlined button
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

### 6.8 My Bookings Screen

```
┌─────────────────────────────────────┐
│  My Bookings                        │
│                                     │
│  [Upcoming] [Completed] [Cancelled] │ ← tab bar (pills)
│  ━━━━━━━━━                          │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ [Confirmed]         ฿400   │    │
│  │  🏸 Court Name              │    │
│  │  📅 01 May 2026             │    │
│  │  🕘 09:00 - 11:00 (2hrs)   │    │
│  │  Equipment: 1 Racket       │    │
│  └─────────────────────────────┘    │
│  12dp                               │
│  ┌─────────────────────────────┐    │
│  │ [Pending]           ฿200   │    │
│  │  🏸 Another Court           │    │
│  │  📅 03 May 2026             │    │
│  │  🕘 14:00 - 15:00 (1hr)    │    │
│  └─────────────────────────────┘    │
│                                     │
│  ═══════════════════════════════    │
│  🏸     🗺️     📅     👤           │
│  Home  Map  Bookings Profile        │
└─────────────────────────────────────┘
```

**Specs:**

- Custom tab bar: Pill-shaped tabs, not standard TabBar
  - Selected: bg primary, text white
  - Unselected: bg transparent, text textSecondary
- Booking cards: See spec 5.6
- Swipe to cancel (Dismissible) on Upcoming tab
  - Background: red with trash icon when swiping
  - Confirmation dialog before cancel
- Empty state per tab: "No upcoming bookings", "No completed bookings", etc.
- Pull-to-refresh

---

### 6.9 Booking Detail Screen

```
┌─────────────────────────────────────┐
│  ← Back     Booking Details        │
│                                     │
│  ┌─────────────────────────────┐    │
│  │     [CONFIRMED ✓]           │    │ ← large status badge, centered
│  │                             │    │
│  │  ┌────┐  Court Name         │    │
│  │  │img │                     │    │
│  │  └────┘  📍 Location        │    │
│  └─────────────────────────────┘    │
│                                     │
│  Booking Information                │
│  ┌─────────────────────────────┐    │
│  │  📅 Date     01 May 2026   │    │
│  │  🕘 Time     09:00-11:00   │    │
│  │  ⏱ Duration  2 hours       │    │
│  │  🏸 Equipment 1R, 2S, 0Sh  │    │
│  └─────────────────────────────┘    │
│                                     │
│  Payment Information                │
│  ┌─────────────────────────────┐    │
│  │  Method    Credit Card      │    │
│  │  Amount    ฿360.00          │    │
│  │  Status    Paid ✓           │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │     ❌  Cancel Booking       │    │ ← red outlined button
│  └─────────────────────────────┘    │
│  OR                                 │
│  ┌─────────────────────────────┐    │
│  │     ✍  Write a Review       │    │ ← primary button (if completed)
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

---

### 6.10 Review Screen

```
┌─────────────────────────────────────┐
│  ← Back     Write a Review         │
│                                     │
│  🏸 Court Name                      │
│                                     │
│  How was your experience?           │
│                                     │
│     ☆  ☆  ☆  ☆  ☆                  │
│    (tap to rate, 40dp stars)        │
│    1=Terrible ... 5=Excellent       │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Share your thoughts...     │    │
│  │  (multiline, 4 lines min)   │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │      Submit Review          │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

- Stars: 40dp, interactive (tap to set), with scale animation on tap
- Rating label below stars changes: "Terrible" → "Poor" → "Average" → "Good" → "Excellent"
- Comment field: min 4 lines, border radius 12dp

---

### 6.11 Waitlist Screen

```
┌─────────────────────────────────────┐
│  ← Back     My Waitlists           │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ [Waiting]  Position: #2     │    │
│  │  🏸 Court Name              │    │
│  │  📅 01 May 2026             │    │
│  │  🕘 09:00 - 10:00           │    │
│  │                             │    │
│  │  [Leave Waitlist →]         │    │ ← red text button
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ [Waiting]  Position: #5     │    │
│  │  🏸 Another Court           │    │
│  │  📅 03 May 2026             │    │
│  │  🕘 14:00 - 15:00           │    │
│  │                             │    │
│  │  [Leave Waitlist →]         │    │
│  └─────────────────────────────┘    │
│                                     │
│  Empty: "You're not on any          │
│  waitlists. Join one from a         │
│  court detail page!"                │
│                                     │
└─────────────────────────────────────┘
```

---

### 6.12 Membership Screen

```
┌─────────────────────────────────────┐
│  ← Back     Membership              │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  ╔═══════════════════════╗  │    │
│  │  ║  🏆 PRO MEMBER        ║  │    │ ← gradient card if active
│  │  ║                       ║  │    │
│  │  ║  Active until          ║  │    │
│  │  ║  28 May 2026           ║  │    │
│  │  ║  30 days remaining     ║  │    │
│  │  ╚═══════════════════════╝  │    │
│  └─────────────────────────────┘    │
│                                     │
│  Member Benefits                    │
│  ✅ Discounted rate: ฿150/hr       │
│  ✅ Priority booking                │
│  ✅ Exclusive member events         │
│  ✅ Free equipment rental (1/mo)   │
│                                     │
│  ── Savings Calculator ─────────    │
│                                     │
│  Hours per week:                    │
│  [───●──────] 4 hours              │
│                                     │
│  ┌──────────┐  ┌──────────┐        │
│  │ Standard  │  │  Member  │        │
│  │  ฿3,200   │  │  ฿2,400  │        │
│  │  /month   │  │  /month  │        │
│  └──────────┘  └──────────┘        │
│        You save ฿800/month! 🎉     │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🏆 Subscribe — ฿199/month │    │ ← accent button (if not member)
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

- Member card: gradient background (primary → primaryDark), white text, rounded 20dp
  - If inactive: grey gradient, "Not a Member" text
- Benefits list: Check icons in success color
- Savings calculator: Slider for hours/week (1-10), live calculation
- Comparison cards: side by side, standard vs member pricing
- Subscribe button: accent (orange), only shown if not a member

---

### 6.13 Community Screen

```
┌─────────────────────────────────────┐
│  Community                          │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  User Name         2d ago   │    │
│  │  Post Title                 │    │
│  │  Post content preview...    │    │
│  │  [Edit] [Delete] ← own only│    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Another User      5d ago   │    │
│  │  Post Title                 │    │
│  │  Post content preview...    │    │
│  └─────────────────────────────┘    │
│                                     │
│                      ┌───┐          │
│                      │ ✏ │ ← FAB   │
│                      └───┘          │
│                                     │
│ ═════════════════════════════════   │
│  🏸     🗺️     📅     👤           │
│  Home  Map  Bookings Profile        │
└─────────────────────────────────────┘
```

- Post cards: author avatar (32dp) + name + timestamp
  - Title: 16sp SemiBold
  - Content: 14sp, max 3 lines, overflow ellipsis
  - Own posts: edit/delete icon buttons (textSecondary)
- FAB: accent color, pencil icon, creates new post

---

### 6.14 Profile Screen

```
┌─────────────────────────────────────┐
│                                     │
│      ┌───────────────────┐          │
│      │   🏸 Pro Badminton│          │ ← header card
│      └───────────────────┘          │
│                                     │
│         [avatar circle 64dp]        │
│          Pannawit Team              │
│        team@gmail.com               │
│      [🏆 Member] badge             │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  👤  Edit Profile        →  │    │
│  ├─────────────────────────────┤    │
│  │  🏆  Membership          →  │    │
│  ├─────────────────────────────┤    │
│  │  ⏱  My Waitlists        →  │    │
│  ├─────────────────────────────┤    │
│  │  💬  Community           →  │    │
│  ├─────────────────────────────┤    │
│  │  🌐  Language            →  │    │
│  │       English              │    │ ← current language shown
│  ├─────────────────────────────┤    │
│  │  🔧  Admin Panel        →  │    │ ← ADMIN only
│  ├─────────────────────────────┤    │
│  │  ℹ️  About               →  │    │
│  ├─────────────────────────────┤    │
│  │  🚪  Logout              →  │    │ ← red text
│  └─────────────────────────────┘    │
│                                     │
│ ═════════════════════════════════   │
│  🏸     🗺️     📅     👤           │
│  Home  Map  Bookings Profile        │
└─────────────────────────────────────┘
```

**Specs:**

- Header: No AppBar. Custom header with primary gradient bg (rounded bottom corners 24dp)
  - Height: ~180dp
  - "Pro Badminton" text + shuttlecock icon, white
- Avatar: 64dp circle, bg white, primary color text initial, overlapping header bottom edge (-32dp margin)
- Name: 20sp Bold
- Email: 14sp, textSecondary
- Member badge: green chip below email
- Menu items: ListTile with leading icon (24dp), title, trailing chevron
  - Dividers: 1dp #EEEEEE between items
  - Tap animations: ripple effect
  - Logout: icon + text in error (red) color
- Language: subtitle shows current language "English"

---

### 6.15 Admin Dashboard

```
┌─────────────────────────────────────┐
│  ← Back     Admin Dashboard        │
│                                     │
│  ┌──────────┐  ┌──────────┐        │
│  │  👥 150   │  │  🏸 8    │        │
│  │  Users    │  │  Courts  │        │
│  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐        │
│  │  📅 24   │  │  💰 ฿45K │        │
│  │  Bookings│  │  Revenue │        │
│  └──────────┘  └──────────┘        │
│                                     │
│  Quick Actions                      │
│  ┌─────────────────────────────┐    │
│  │  + Add Court              →  │    │
│  ├─────────────────────────────┤    │
│  │  📅 All Bookings          →  │    │
│  ├─────────────────────────────┤    │
│  │  👥 All Users             →  │    │
│  ├─────────────────────────────┤    │
│  │  💬 Community Posts       →  │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

- Stats cards: 2×2 grid, bg surface, border 1dp, radius 16dp
  - Icon (32dp) + big number (24sp Bold) + label (14sp textSecondary)
  - Accent color for numbers
- Quick actions: ListTile rows with icons

---

### 6.16–6.20 Admin Screens (Manage Courts/Bookings/Users/Community)

All follow a similar pattern:

```
┌─────────────────────────────────────┐
│  ← Back     Manage Courts    [+]   │
│                                     │
│  🔍 Search...                       │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Court Name                 │    │
│  │  ฿200/hr  ★ 4.5            │    │
│  │  [Edit] [Delete]            │    │
│  └─────────────────────────────┘    │
│                                     │
│  ... more items ...                 │
│                                     │
└─────────────────────────────────────┘
```

- Search bar at top
- List items with action buttons
- Swipe to delete (with confirmation)
- FAB (+) to add new (for courts)
- Admin screens have white background, no bottom nav

---

## 7. Animation & Motion

### Transition Animations

| Transition          | Type           | Duration | Curve         |
| ------------------- | -------------- | -------- | ------------- |
| Screen enter        | Slide + Fade   | 300ms    | easeOut       |
| Screen exit         | Slide + Fade   | 250ms    | easeIn        |
| Tab switch          | CrossFade      | 200ms    | easeInOut     |
| Card tap            | Scale (0.98)   | 100ms    | easeInOut     |
| Button press        | Scale (0.95)   | 80ms     | easeInOut     |
| FAB appear          | Scale + Fade   | 300ms    | spring        |
| Shimmer loading     | Shimmer effect | 1500ms   | linear (loop) |
| Success checkmark   | Scale + Draw   | 500ms    | easeOutBack   |
| Star rating tap     | Scale (1.2→1)  | 200ms    | easeOutBack   |
| Status badge appear | FadeIn         | 200ms    | easeIn        |

### Splash Animation Sequence

```
0ms:    Screen appears (green gradient bg)
200ms:  Shuttlecock icon fades in
500ms:  Shuttlecock bounces (scale 1.0 → 1.1 → 1.0)
700ms:  "Pro Badminton" text slides up + fades in
900ms:  Subtitle fades in
1200ms: Loading dots begin animating
1500ms+: Navigation to login/home
```

---

## 8. Responsive Guidelines

### Phone (default, < 600dp width)

- All specs as described above
- Bottom navigation visible
- Cards full width

### Tablet (≥ 600dp width)

- Max content width: 600dp, centered
- Court cards: 2-column grid instead of list
- Admin dashboard: 4-column stats grid
- Bottom nav replaced with rail (if ≥ 840dp)

### Safe Areas

- Respect iOS safe areas (notch, home indicator)
- Android: System bars handled by Scaffold

---

## Quick Reference: Design Tokens for Flutter

```dart
// Colors
static const Color primary = Color(0xFF006400);
static const Color primaryDark = Color(0xFF004D00);
static const Color primaryLight = Color(0xFFE8F5E9);
static const Color accent = Color(0xFFFF6F00);
static const Color accentLight = Color(0xFFFFF3E0);
static const Color background = Color(0xFFFAFAFA);
static const Color surface = Color(0xFFFFFFFF);
static const Color surfaceVariant = Color(0xFFF5F5F5);
static const Color textPrimary = Color(0xFF1A1A1A);
static const Color textSecondary = Color(0xFF6B6B6B);
static const Color textDisabled = Color(0xFFBDBDBD);
static const Color divider = Color(0xFFEEEEEE);
static const Color success = Color(0xFF2E7D32);
static const Color warning = Color(0xFFF57C00);
static const Color error = Color(0xFFC62828);
static const Color info = Color(0xFF1565C0);

// Spacing
static const double xs = 4;
static const double sm = 8;
static const double md = 16;
static const double lg = 24;
static const double xl = 32;
static const double xxl = 48;

// Radius
static const double radiusCard = 16;
static const double radiusButton = 12;
static const double radiusInput = 12;
static const double radiusChip = 10;
static const double radiusAvatar = 50;
```
