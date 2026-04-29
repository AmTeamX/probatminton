# 🏸 FolkliyGrunt (Pro Badminton) — Flutter Mobile App Implementation Guide

> **Purpose:** This document provides everything an AI coding assistant needs to fully implement a cross-platform Flutter mobile application that replicates ALL user-facing functionalities of the existing FolkliyGrunt web application. Share this file with your AI tool (e.g., Cline, Cursor, GitHub Copilot) as context when building the mobile app.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack Requirements](#2-tech-stack-requirements)
3. [Backend API Reference](#3-backend-api-reference)
4. [Database Schema](#4-database-schema)
5. [App Screens & Features](#5-app-screens--features)
6. [Authentication Flow](#6-authentication-flow)
7. [Detailed Screen Specifications](#7-detailed-screen-specifications)
8. [Implementation Phases](#8-implementation-phases)
9. [Design & UI Guidelines](#9-design--ui-guidelines)
10. [Network & API Integration Patterns](#10-network--api-integration-patterns)
11. [Environment Configuration](#11-environment-configuration)
12. [Backend Changes Needed](#12-backend-changes-needed)
13. [Project Structure](#13-project-structure)
14. [AI Implementation Instructions](#14-ai-implementation-instructions)
15. [Quick Reference](#15-quick-reference)

---

## 1. Project Overview

**FolkliyGrunt** (branded as **"Pro Badminton"**) is a **Badminton Court Management System** for Thailand. It allows users to:

- Register/login with email & password
- Search and discover badminton courts by name, distance, and price
- View court details with location maps, reviews, and ratings
- Book court time slots with optional equipment rentals (rackets, shuttlecocks, shoes)
- Pay via credit card (Stripe), bank transfer, or PromptPay
- Join waitlists when courts are fully booked
- Leave verified reviews and star ratings (1–5)
- Subscribe to a membership plan (฿199/month for discounted rates)
- View and manage their bookings
- Switch between 3 languages: English, Thai (TH), Chinese (中文)
- (Admin only) Manage courts, bookings, users, and community posts

**Currency:** Thai Baht (฿)
**Country:** Thailand
**Languages:** English, Thai, Chinese
**Platforms:** Android & iOS (cross-platform via Flutter)

---

## 2. Tech Stack Requirements

| Component              | Technology                                          |
| ---------------------- | --------------------------------------------------- |
| **Framework**          | Flutter 3.x (stable channel)                        |
| **Language**           | Dart 3.x                                            |
| **Min Android SDK**    | 21 (Android 5.0)                                    |
| **Min iOS**            | 12.0                                                |
| **Architecture**       | Clean Architecture / MVVM                           |
| **State Management**   | Riverpod (preferred) OR Bloc                        |
| **Networking**         | Dio 5.x                                             |
| **Serialization**      | json_serializable + freezed (or manual fromJson/toJson) |
| **Image Loading**      | CachedNetworkImage                                  |
| **Auth**               | Supabase Auth via direct REST API calls             |
| **Maps**               | google_maps_flutter                                 |
| **Payments**           | flutter_stripe                                      |
| **Local Storage**      | flutter_secure_storage (tokens) + shared_preferences (settings) |
| **Navigation**         | GoRouter                                            |
| **DI**                 | Riverpod (providers) OR get_it                      |
| **Localization**       | flutter_localizations + intl                        |
| **Testing**            | flutter_test, mockito, integration_test             |

### Required `pubspec.yaml` Dependencies

```yaml
name: probadminton
description: Pro Badminton - Badminton Court Management System
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Navigation
  go_router: ^14.2.0

  # Networking
  dio: ^5.4.0

  # Serialization
  json_annotation: ^4.9.0
  freezed_annotation: ^2.4.0

  # Storage
  flutter_secure_storage: ^9.2.0
  shared_preferences: ^2.2.0

  # UI
  cached_network_image: ^3.3.0
  flutter_rating_bar: ^4.0.1
  shimmer: ^3.0.0
  pull_to_refresh_flutter3: ^2.0.2

  # Maps
  google_maps_flutter: ^2.6.0
  geolocator: ^12.0.0
  geocoding: ^3.0.0

  # Payments
  flutter_stripe: ^10.2.0

  # Date/Time
  intl: ^0.19.0
  table_calendar: ^3.1.0

  # Icons & Fonts
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.0

  # Image Picker
  image_picker: ^1.0.7

  # Permissions
  permission_handler: ^11.3.0

  # Connectivity
  connectivity_plus: ^6.0.0

  # URL Launcher
  url_launcher: ^6.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.0
  json_serializable: ^6.8.0
  freezed: ^2.5.0
  riverpod_generator: ^2.4.0
  mockito: ^5.4.0

flutter:
  uses-material-design: true
  generate: true
```

---

## 3. Backend API Reference

**Base URL:** `http://<SERVER_IP>:8080/api` (use 10.0.2.2 for Android emulator, `localhost` for iOS simulator, or your machine's LAN IP for physical device)

All authenticated endpoints require header: `Authorization: Bearer <access_token>`

### 3.1 Authentication (`/api/auth`)

#### POST `/api/auth/register`

- **Auth:** None
- **Body:**

```json
{
  "email": "string",
  "password": "string",
  "full_name": "string",
  "address": "string",
  "role": "CUSTOMER"
}
```

- **Response 201:**

```json
{
  "message": "User registered successfully",
  "user": {
    "id": "uuid",
    "auth_id": "uuid",
    "full_name": "string",
    "address": "string",
    "role": "CUSTOMER"
  }
}
```

#### POST `/api/auth/login`

- **Auth:** None
- **Body:**

```json
{
  "email": "string",
  "password": "string"
}
```

- **Response 200:**

```json
{
  "message": "Login successful",
  "session": {
    "access_token": "string",
    "refresh_token": "string",
    "expires_at": 1234567890,
    "user": {
      "id": "uuid",
      "email": "string",
      "role": "CUSTOMER"
    }
  }
}
```

#### GET `/api/auth/profile`

- **Auth:** Required (user token)
- **Response 200:**

```json
{
  "user": {
    "id": "uuid",
    "auth_id": "uuid",
    "email": "string",
    "full_name": "string",
    "address": "string",
    "role": "CUSTOMER",
    "membership_status": "none",
    "membership_expires_at": null
  }
}
```

#### GET `/api/auth/membership/status`

- **Auth:** Required
- **Response 200:**

```json
{
  "membership_status": "active",
  "membership_expires_at": "2026-05-28T00:00:00.000Z",
  "days_remaining": 30
}
```

#### POST `/api/auth/membership/subscribe`

- **Auth:** Required
- **Body:**

```json
{
  "plan": "monthly"
}
```

- **Response 200:**

```json
{
  "message": "Membership activated",
  "charged_amount_thb": 199,
  "membership": {
    "membership_status": "active",
    "membership_expires_at": "2026-05-28T00:00:00.000Z"
  }
}
```

#### PUT `/api/auth/profile`

- **Auth:** Required
- **Body:**

```json
{
  "full_name": "string",
  "address": "string"
}
```

- **Response 200:**

```json
{
  "message": "Profile updated",
  "user": { "...": "..." }
}
```

---

### 3.2 Courts (`/api/courts`)

#### GET `/api/courts`

- **Auth:** Required
- **Query Params:**
  - `search` (string, optional) — search by court name
  - `maxPrice` (number, optional) — filter by max hourly price
  - `lat` (number, optional) — user latitude for distance sorting
  - `lng` (number, optional) — user longitude for distance sorting
  - `radius` (number, optional) — max distance in km
- **Response 200:**

```json
{
  "courts": [
    {
      "id": "uuid",
      "name": "string",
      "description": "string",
      "location": "string",
      "price_per_hour": 200,
      "latitude": 13.7563,
      "longitude": 100.5018,
      "image_url": "string",
      "avg_rating": 4.5,
      "review_count": 12,
      "distance_km": 3.2,
      "created_at": "2026-01-01T00:00:00.000Z"
    }
  ]
}
```

#### GET `/api/courts/:id`

- **Auth:** Required
- **Response 200:**

```json
{
  "court": {
    "id": "uuid",
    "name": "string",
    "description": "string",
    "location": "string",
    "price_per_hour": 200,
    "latitude": 13.7563,
    "longitude": 100.5018,
    "image_url": "string",
    "avg_rating": 4.5,
    "review_count": 12,
    "created_at": "2026-01-01T00:00:00.000Z"
  }
}
```

#### GET `/api/courts/:id/availability`

- **Auth:** Required
- **Query Params:**
  - `date` (string, required) — format: YYYY-MM-DD
- **Response 200:**

```json
{
  "date": "2026-05-01",
  "court_id": "uuid",
  "slots": [
    {
      "start_time": "08:00",
      "end_time": "09:00",
      "available": true,
      "price": 200
    },
    {
      "start_time": "09:00",
      "end_time": "10:00",
      "available": false,
      "price": 200
    }
  ]
}
```

#### POST `/api/courts` (Admin only)

- **Auth:** Admin token
- **Body:**

```json
{
  "name": "string",
  "description": "string",
  "location": "string",
  "price_per_hour": 200,
  "latitude": 13.7563,
  "longitude": 100.5018,
  "image_url": "string"
}
```

#### PUT `/api/courts/:id` (Admin only)

- **Auth:** Admin token
- **Body:** Same as create (all fields optional)

#### DELETE `/api/courts/:id` (Admin only)

- **Auth:** Admin token

---

### 3.3 Bookings (`/api/bookings`)

#### GET `/api/bookings`

- **Auth:** Required (returns only the user's bookings; admin gets all)
- **Response 200:**

```json
{
  "bookings": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "court_id": "uuid",
      "court_name": "string",
      "booking_date": "2026-05-01",
      "start_time": "09:00",
      "end_time": "11:00",
      "duration_hours": 2,
      "total_price": 400,
      "status": "confirmed",
      "equipment_rentals": {
        "rackets": 1,
        "shuttlecocks": 2,
        "shoes": 0
      },
      "created_at": "2026-04-28T10:00:00.000Z"
    }
  ]
}
```

#### POST `/api/bookings`

- **Auth:** Required
- **Body:**

```json
{
  "court_id": "uuid",
  "booking_date": "2026-05-01",
  "start_time": "09:00",
  "end_time": "11:00",
  "duration_hours": 2,
  "equipment_rentals": {
    "rackets": 1,
    "shuttlecocks": 2,
    "shoes": 0
  }
}
```

- **Response 201:**

```json
{
  "message": "Booking created successfully",
  "booking": { "...": "..." },
  "total_price": 510
}
```

#### GET `/api/bookings/:id`

- **Auth:** Required (owner or admin)
- **Response 200:**

```json
{
  "booking": { "...": "..." }
}
```

#### PUT `/api/bookings/:id/cancel`

- **Auth:** Required (owner or admin)
- **Response 200:**

```json
{
  "message": "Booking cancelled successfully",
  "booking": { "status": "cancelled", "...": "..." }
}
```

#### PUT `/api/bookings/:id` (Admin only)

- **Auth:** Admin
- **Body:** `{ "status": "confirmed" }` or other updates

---

### 3.4 Payments (`/api/payments`)

#### POST `/api/payments/create-payment-intent`

- **Auth:** Required
- **Body:**

```json
{
  "booking_id": "uuid",
  "payment_method": "credit_card"
}
```

- **Response 200:**

```json
{
  "client_secret": "pi_xxx_secret_yyy",
  "payment_intent_id": "pi_xxx",
  "amount": 40000
}
```

#### POST `/api/payments/confirm`

- **Auth:** Required
- **Body:**

```json
{
  "booking_id": "uuid",
  "payment_intent_id": "pi_xxx",
  "payment_method": "credit_card"
}
```

#### POST `/api/payments/bank-transfer`

- **Auth:** Required
- **Body:**

```json
{
  "booking_id": "uuid",
  "bank_name": "Bangkok Bank",
  "reference_number": "string"
}
```

#### POST `/api/payments/promptpay`

- **Auth:** Required
- **Body:**

```json
{
  "booking_id": "uuid"
}
```

#### GET `/api/payments/booking/:bookingId`

- **Auth:** Required
- **Response 200:**

```json
{
  "payment": {
    "id": "uuid",
    "booking_id": "uuid",
    "amount": 400,
    "payment_method": "credit_card",
    "status": "completed",
    "created_at": "..."
  }
}
```

---

### 3.5 Waitlist (`/api/waitlist`)

#### POST `/api/waitlist`

- **Auth:** Required
- **Body:**

```json
{
  "court_id": "uuid",
  "booking_date": "2026-05-01",
  "start_time": "09:00",
  "end_time": "10:00"
}
```

- **Response 201:**

```json
{
  "message": "Added to waitlist",
  "position": 3,
  "waitlist_entry": { "...": "..." }
}
```

#### GET `/api/waitlist`

- **Auth:** Required (user sees their own; admin sees all)
- **Query Params:**
  - `court_id` (optional)
  - `date` (optional)
- **Response 200:**

```json
{
  "waitlist": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "court_id": "uuid",
      "court_name": "string",
      "booking_date": "2026-05-01",
      "start_time": "09:00",
      "end_time": "10:00",
      "position": 1,
      "status": "waiting",
      "created_at": "..."
    }
  ]
}
```

#### DELETE `/api/waitlist/:id`

- **Auth:** Required (owner or admin)
- **Response 200:**

```json
{
  "message": "Removed from waitlist"
}
```

---

### 3.6 Reviews (`/api/reviews`)

#### GET `/api/reviews`

- **Query Params:**
  - `court_id` (required) — filter reviews by court
- **Response 200:**

```json
{
  "reviews": [
    {
      "id": "uuid",
      "court_id": "uuid",
      "user_id": "uuid",
      "user_name": "string",
      "rating": 4,
      "comment": "Great court!",
      "created_at": "2026-04-28T10:00:00.000Z"
    }
  ],
  "average_rating": 4.3,
  "total_reviews": 15
}
```

#### POST `/api/reviews`

- **Auth:** Required
- **Body:**

```json
{
  "court_id": "uuid",
  "rating": 5,
  "comment": "Excellent facilities!"
}
```

- **Response 201:**

```json
{
  "message": "Review submitted successfully",
  "review": { "...": "..." }
}
```

#### PUT `/api/reviews/:id`

- **Auth:** Required (owner only)
- **Body:**

```json
{
  "rating": 4,
  "comment": "Updated comment"
}
```

#### DELETE `/api/reviews/:id`

- **Auth:** Required (owner or admin)

---

### 3.7 Community (`/api/community`)

#### GET `/api/community`

- **Auth:** Required
- **Response 200:**

```json
{
  "posts": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "user_name": "string",
      "title": "string",
      "content": "string",
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

#### POST `/api/community`

- **Auth:** Required
- **Body:**

```json
{
  "title": "string",
  "content": "string"
}
```

#### PUT `/api/community/:id`

- **Auth:** Required (owner only)
- **Body:**

```json
{
  "title": "string",
  "content": "string"
}
```

#### DELETE `/api/community/:id`

- **Auth:** Required (owner or admin)

---

### 3.8 Health & Meta

#### GET `/api/health`

- **Auth:** None
- **Response 200:** `{ "status": "ok", "timestamp": "..." }`

#### GET `/api/meta`

- **Auth:** None
- **Response 200:** `{ "version": "1.0.0", "endpoints": ["..."] }`

---

## 4. Database Schema

### Tables

#### `users`

| Column                | Type         | Constraints                                       |
| --------------------- | ------------ | ------------------------------------------------- |
| id                    | UUID         | PK, auto-generated                                |
| auth_id               | UUID         | FK to Supabase Auth users                         |
| email                 | VARCHAR(255) | UNIQUE, NOT NULL                                  |
| full_name             | VARCHAR(255) | NOT NULL                                          |
| address               | TEXT         |                                                   |
| role                  | VARCHAR(20)  | DEFAULT 'CUSTOMER', CHECK IN ('CUSTOMER','ADMIN') |
| membership_status     | VARCHAR(20)  | DEFAULT 'none'                                    |
| membership_expires_at | TIMESTAMP    | NULLABLE                                          |
| created_at            | TIMESTAMP    | DEFAULT NOW()                                     |

#### `courts`

| Column         | Type          | Constraints   |
| -------------- | ------------- | ------------- |
| id             | UUID          | PK            |
| name           | VARCHAR(255)  | NOT NULL      |
| description    | TEXT          |               |
| location       | VARCHAR(500)  | NOT NULL      |
| price_per_hour | DECIMAL(10,2) | NOT NULL      |
| latitude       | DECIMAL(10,8) |               |
| longitude      | DECIMAL(11,8) |               |
| image_url      | VARCHAR(500)  |               |
| avg_rating     | DECIMAL(3,2)  | DEFAULT 0     |
| review_count   | INTEGER       | DEFAULT 0     |
| created_at     | TIMESTAMP     | DEFAULT NOW() |

#### `bookings`

| Column            | Type          | Constraints                                                                 |
| ----------------- | ------------- | --------------------------------------------------------------------------- |
| id                | UUID          | PK                                                                          |
| user_id           | UUID          | FK to users.id                                                              |
| court_id          | UUID          | FK to courts.id                                                             |
| booking_date      | DATE          | NOT NULL                                                                    |
| start_time        | TIME          | NOT NULL                                                                    |
| end_time          | TIME          | NOT NULL                                                                    |
| duration_hours    | INTEGER       | NOT NULL, CHECK 1-3                                                         |
| total_price       | DECIMAL(10,2) | NOT NULL                                                                    |
| status            | VARCHAR(20)   | DEFAULT 'pending', CHECK IN ('pending','confirmed','cancelled','completed') |
| equipment_rentals | JSONB         | DEFAULT '{}'                                                                |
| created_at        | TIMESTAMP     | DEFAULT NOW()                                                               |

#### `payments`

| Column                   | Type          | Constraints                                          |
| ------------------------ | ------------- | ---------------------------------------------------- |
| id                       | UUID          | PK                                                   |
| booking_id               | UUID          | FK to bookings.id                                    |
| amount                   | DECIMAL(10,2) | NOT NULL                                             |
| payment_method           | VARCHAR(50)   | CHECK IN ('credit_card','bank_transfer','promptpay') |
| status                   | VARCHAR(20)   | DEFAULT 'pending'                                    |
| stripe_payment_intent_id | VARCHAR(255)  | NULLABLE                                             |
| bank_reference           | VARCHAR(255)  | NULLABLE                                             |
| created_at               | TIMESTAMP     | DEFAULT NOW()                                        |

#### `reviews`

| Column     | Type      | Constraints         |
| ---------- | --------- | ------------------- |
| id         | UUID      | PK                  |
| court_id   | UUID      | FK to courts.id     |
| user_id    | UUID      | FK to users.id      |
| rating     | INTEGER   | NOT NULL, CHECK 1-5 |
| comment    | TEXT      |                     |
| created_at | TIMESTAMP | DEFAULT NOW()       |
| updated_at | TIMESTAMP |                     |

#### `waitlist`

| Column       | Type        | Constraints       |
| ------------ | ----------- | ----------------- |
| id           | UUID        | PK                |
| user_id      | UUID        | FK to users.id    |
| court_id     | UUID        | FK to courts.id   |
| booking_date | DATE        | NOT NULL          |
| start_time   | TIME        | NOT NULL          |
| end_time     | TIME        | NOT NULL          |
| position     | INTEGER     | NOT NULL          |
| status       | VARCHAR(20) | DEFAULT 'waiting' |
| created_at   | TIMESTAMP   | DEFAULT NOW()     |

#### `community_posts`

| Column     | Type         | Constraints    |
| ---------- | ------------ | -------------- |
| id         | UUID         | PK             |
| user_id    | UUID         | FK to users.id |
| title      | VARCHAR(255) | NOT NULL       |
| content    | TEXT         | NOT NULL       |
| created_at | TIMESTAMP    | DEFAULT NOW()  |
| updated_at | TIMESTAMP    |               |

### Equipment Rental Pricing (Constants)

| Equipment   | Price per unit |
| ----------- | -------------- |
| Racket      | ฿50            |
| Shuttlecock | ฿30            |
| Shoes       | ฿40            |

### Court Pricing

| Type                    | Price                       |
| ----------------------- | --------------------------- |
| Standard rate           | ฿200/hour (varies by court) |
| Member rate             | ฿150/hour                   |
| Membership subscription | ฿199/month                  |

---

## 5. App Screens & Features

The mobile app must include ALL of the following screens and features:

### 5.1 Authentication Screens

| #   | Screen              | Description                                                 |
| --- | ------------------- | ----------------------------------------------------------- |
| 1   | **Splash Screen**   | App logo, auto-redirect to login or home based on token     |
| 2   | **Login Screen**    | Email + password fields, login button, link to register     |
| 3   | **Register Screen** | Email, password, full name, address fields; register button |

### 5.2 Main App Screens (Bottom Navigation)

| #   | Screen            | Tab      | Description                                                                                                       |
| --- | ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------- |
| 4   | **Home / Search** | Home     | Search bar (name), filters (max price, distance), list of courts with cards showing name, price, rating, distance |
| 5   | **Map View**      | Map      | Map showing courts as markers; tap marker for court card preview                                                  |
| 6   | **My Bookings**   | Bookings | List of user's bookings grouped by status (upcoming, completed, cancelled); tap to see details                    |
| 7   | **Profile**       | Profile  | User info, membership status, settings, language switch, logout                                                   |

### 5.3 Detail Screens

| #   | Screen                | Description                                                                                                                                |
| --- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 8   | **Court Detail**      | Court image, name, description, location, price, rating, map pin, "Book Now" button, reviews list                                          |
| 9   | **Booking Flow**      | Select date, see available time slots, select duration (1-3hr), add equipment rentals, see price breakdown, choose payment method, confirm |
| 10  | **Payment Screen**    | Choose payment method (Credit Card / Bank Transfer / PromptPay), process payment, show confirmation                                        |
| 11  | **Booking Detail**    | Full booking info with status badge, court info, time, equipment, payment status, cancel button                                            |
| 12  | **Review Screen**     | Leave a review (star rating 1-5 + comment) for a completed booking's court                                                                 |
| 13  | **Waitlist Screen**   | View waitlist positions, join waitlist for full slots, leave waitlist                                                                      |
| 14  | **Membership Screen** | Current membership status, subscribe 199/mo, savings calculator, benefits list                                                             |
| 15  | **Community Screen**  | List of community posts, create new post, edit/delete own posts                                                                            |

### 5.4 Admin Screens (role = ADMIN only)

| #   | Screen               | Description                                       |
| --- | -------------------- | ------------------------------------------------- |
| 16  | **Admin Dashboard**  | Quick stats (total bookings, revenue, courts)     |
| 17  | **Manage Courts**    | List courts, add/edit/delete court                |
| 18  | **Manage Bookings**  | View all bookings, update status, cancel bookings |
| 19  | **Manage Users**     | View all users, view user details                 |
| 20  | **Manage Community** | View/edit/delete community posts                  |

---

## 6. Authentication Flow

```
Splash Screen -> Check stored token -> Valid? -> Home Screen
                                     -> Invalid/Expired? -> Login Screen

Login Screen -> POST /api/auth/login -> Store tokens in FlutterSecureStorage -> Home Screen
Register Screen -> POST /api/auth/register -> Auto-login -> Home Screen

All API calls attach: Authorization: Bearer <access_token>
On 401 response -> Clear tokens -> Redirect to Login
```

### Token Storage

- Store `access_token`, `refresh_token`, and `expires_at` in `FlutterSecureStorage`
- Attach `Authorization: Bearer <access_token>` to all API calls except login/register
- On 401 response, attempt token refresh or redirect to login

---

## 7. Detailed Screen Specifications

### 7.1 Login Screen

- App logo at top
- Email text field with email keyboard type
- Password text field with toggle visibility
- "Login" button (full width, primary color)
- "Don't have an account? Register" link
- Error message display (invalid credentials, network error)
- Loading indicator during API call

### 7.2 Register Screen

- Full name field
- Email field
- Password field (min 6 chars, with toggle visibility)
- Address field (multiline)
- "Register" button
- "Already have an account? Login" link
- Success: auto-login then navigate to home

### 7.3 Home / Search Screen

- Search bar at top (searches court names)
- Filter row: Max Price slider/input, Distance toggle
- Court list (`ListView.builder`) with cards showing:
  - Court image (placeholder if none)
  - Court name
  - Location
  - Price per hour
  - Star rating + review count
  - Distance (if location enabled)
- Pull-to-refresh (`RefreshIndicator`)
- Empty state when no courts match
- Uses device GPS for distance calculation (`geolocator` package)
- Floating "Map View" button

### 7.4 Court Detail Screen

- Hero image at top (full width)
- Court name (large text)
- Star rating (visual stars) + review count
- Price per hour (with member discount if active)
- Description text
- Location with small map preview
- "Book Now" CTA button (sticky at bottom)
- Reviews section:
  - Average rating display
  - List of reviews with user name, rating stars, comment, date
  - "Write a Review" button (if user has completed booking)

### 7.5 Booking Flow (Multi-step)

**Step 1: Select Date**

- Calendar date picker (`table_calendar` or Flutter's built-in `showDatePicker`)
- Only future dates selectable

**Step 2: Select Time Slot**

- Grid of available time slots (08:00-22:00, hourly)
- Color-coded: green=available, red=booked
- Select start time and duration (1, 2, or 3 hours)

**Step 3: Equipment Rentals**

- Toggle/counter for each:
  - Rackets (฿50 each)
  - Shuttlecocks (฿30 each)
  - Shoes (฿40 each)

**Step 4: Price Summary**

- Court cost: hours x price/hr
- Equipment costs breakdown
- Membership discount (if active)
- Total amount
- "Proceed to Payment" button

**Step 5: Payment Method**

- Three options (radio buttons/cards):
  - Credit Card (Stripe)
  - Bank Transfer
  - PromptPay
- For Credit Card: Opens Stripe payment sheet (`flutter_stripe`)
- For Bank Transfer: Shows bank details + reference number input
- For PromptPay: Shows QR code or prompt

**Step 6: Confirmation**

- Success screen with booking details
- "View Booking" and "Back to Home" buttons

### 7.6 My Bookings Screen

- Tab layout: Upcoming | Completed | Cancelled
- Each booking card shows:
  - Court name
  - Date
  - Time (start - end)
  - Status badge (color-coded)
  - Total price
- Tap card: Booking Detail screen
- Swipe to cancel (on upcoming bookings) (`Dismissible` widget)

### 7.7 Booking Detail Screen

- Status badge (large, color-coded)
- Court info (name, image thumbnail)
- Date & time
- Duration
- Equipment rented
- Price breakdown
- Payment status & method
- Cancel button (if upcoming and not yet cancelled)
- "Write Review" button (if completed and not yet reviewed)

### 7.8 Waitlist Screen

- List of user's waitlist entries
- Each entry shows:
  - Court name
  - Date & time slot
  - Position in queue (#1, #2, etc.)
  - Status (waiting / notified / expired)
- "Join Waitlist" button (on court detail when slot is full)
- "Leave Waitlist" button on each entry

### 7.9 Membership Screen

- Current status card (Active/Inactive)
- If inactive:
  - Benefits list (discounted rate ฿150/hr, priority booking, etc.)
  - "Subscribe ฿199/month" button
  - Savings calculator: Input hours per week, shows standard vs member cost vs savings
- If active:
  - Expiry date
  - Days remaining
  - Benefits active indicator

### 7.10 Community Screen

- List of posts (newest first)
- Each post card: title, content preview, author, date
- Floating action button to create new post
- Tap post for detail/edit view
- Own posts have edit/delete options

### 7.11 Profile Screen

- User avatar (initials circle)
- Full name
- Email
- Address
- Membership status badge
- Menu items (`ListTile`):
  - Edit Profile
  - Membership
  - My Waitlists
  - Community
  - Language (EN / TH / CN)
  - Admin Panel (if role = ADMIN)
  - About
  - Logout

### 7.12 Admin Dashboard (Admin only)

- Summary cards: Total Users, Total Courts, Today's Bookings, Revenue
- Quick actions: Add Court, View All Bookings

---

## 8. Implementation Phases

### Phase 1: Project Setup & Auth (Days 1-2)

- [ ] Initialize Flutter project (`flutter create probadminton`)
- [ ] Configure `pubspec.yaml` dependencies (Dio, Riverpod, GoRouter, etc.)
- [ ] Set up project structure (Clean Architecture: data/domain/presentation layers)
- [ ] Configure Dio client with auth interceptor
- [ ] Implement `FlutterSecureStorage` for token storage
- [ ] Build Login Screen UI
- [ ] Build Register Screen UI
- [ ] Connect to `/api/auth/login` and `/api/auth/register`
- [ ] Implement token storage and auth state management (Riverpod `StateNotifier`)
- [ ] Build Splash Screen with auth check

### Phase 2: Court Discovery (Days 3-4)

- [ ] Build Home/Search Screen with search bar and filters
- [ ] Implement court list with `ListView.builder`
- [ ] Connect to `GET /api/courts` with search/filter params
- [ ] Build Court Detail Screen
- [ ] Connect to `GET /api/courts/:id`
- [ ] Implement map integration (`google_maps_flutter` for court location)
- [ ] Add GPS permission (`permission_handler`) and distance calculation (`geolocator`)
- [ ] Build reviews list in Court Detail
- [ ] Connect to `GET /api/reviews?court_id=xxx`

### Phase 3: Booking Flow (Days 5-7)

- [ ] Build date picker for booking (`table_calendar`)
- [ ] Connect to `GET /api/courts/:id/availability?date=xxx`
- [ ] Build time slot selection UI (grid with `GridView`)
- [ ] Build duration selector (1-3 hours)
- [ ] Build equipment rental selection (rackets, shuttlecocks, shoes)
- [ ] Build price summary with breakdown
- [ ] Build payment method selection screen
- [ ] Implement Stripe payment integration (`flutter_stripe` for credit card)
- [ ] Implement bank transfer payment flow
- [ ] Implement PromptPay payment flow
- [ ] Connect to payment API endpoints
- [ ] Build booking confirmation screen

### Phase 4: Bookings Management (Days 8-9)

- [ ] Build My Bookings screen with tabs (Upcoming/Completed/Cancelled)
- [ ] Connect to `GET /api/bookings`
- [ ] Build Booking Detail screen
- [ ] Implement cancel booking (`PUT /api/bookings/:id/cancel`)
- [ ] Build review submission screen
- [ ] Connect to `POST /api/reviews`

### Phase 5: Waitlist & Membership (Days 10-11)

- [ ] Build Waitlist screen
- [ ] Connect to `GET /api/waitlist` and `POST /api/waitlist`
- [ ] Implement "Join Waitlist" from court detail
- [ ] Implement leave waitlist (`DELETE /api/waitlist/:id`)
- [ ] Build Membership screen with status display
- [ ] Connect to `GET /api/auth/membership/status`
- [ ] Build subscribe flow (`POST /api/auth/membership/subscribe`)
- [ ] Build savings calculator

### Phase 6: Community & Profile (Days 12-13)

- [ ] Build Community screen (post list)
- [ ] Connect to `GET /api/community`
- [ ] Build create post screen (`POST /api/community`)
- [ ] Build edit/delete post functionality
- [ ] Build Profile screen with user info
- [ ] Connect to `GET /api/auth/profile`
- [ ] Build Edit Profile screen (`PUT /api/auth/profile`)
- [ ] Implement language switching (EN/TH/CN) with `flutter_localizations`
- [ ] Implement logout (clear tokens)

### Phase 7: Admin Features (Days 14-15)

- [ ] Build Admin Dashboard with stats
- [ ] Build Manage Courts screen (CRUD)
- [ ] Build Manage Bookings screen (all bookings, status updates)
- [ ] Build Manage Users screen
- [ ] Build Manage Community screen
- [ ] Role-based navigation (show Admin tab only for ADMIN role)

### Phase 8: Polish & Testing (Days 16-17)

- [ ] Error handling for all API calls
- [ ] Loading states and shimmer effects
- [ ] Pull-to-refresh on all lists
- [ ] Empty states for all lists
- [ ] Network connectivity handling (`connectivity_plus`)
- [ ] Token refresh logic
- [ ] Input validation on all forms
- [ ] UI polish and responsive design
- [ ] Unit tests for providers/ViewModels
- [ ] Integration tests for API calls
- [ ] Test on both Android and iOS

---

## 9. Design & UI Guidelines

### Color Scheme

| Element        | Color                                  |
| -------------- | -------------------------------------- |
| Primary        | #006400 (Dark Green - badminton theme) |
| Primary Light  | #4CAF50                                |
| Secondary      | #FF6F00 (Orange accent)                |
| Background     | #F5F5F5                                |
| Surface        | #FFFFFF                                |
| Error          | #B00020                                |
| Success        | #4CAF50                                |
| Text Primary   | #212121                                |
| Text Secondary | #757575                                |

### Typography

- Headings: Bold, 24sp / 20sp / 18sp
- Body: Regular, 16sp / 14sp
- Captions: 12sp

### Component Patterns

- **Cards**: Rounded corners (12dp), elevation 2dp, white background (`Card` widget with `shape: RoundedRectangleBorder`)
- **Buttons**: Primary = filled green (`ElevatedButton`), Secondary = outlined (`OutlinedButton`)
- **Input Fields**: Outlined text fields with labels (`TextFormField` with `InputDecoration.outlinedInputBorder`)
- **Bottom Navigation**: 4 items (Home, Map, Bookings, Profile) — `NavigationBar` or `BottomNavigationBar`
- **Snackbars**: For success/error messages (`ScaffoldMessenger.of(context).showSnackBar(...)`)
- **Progress**: `CircularProgressIndicator` or `LinearProgressIndicator` during loading

### App Icon

- Badminton shuttlecock icon
- Green background
- White foreground
- Use `flutter_launcher_icons` package to generate

### Flutter Theme

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF006400),
    brightness: Brightness.light,
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
```

---

## 10. Network & API Integration Patterns

### Dio Client Setup

```dart
class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl, required TokenStorage tokenStorage}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired - attempt refresh or redirect to login
          final refreshed = await tokenStorage.refreshToken();
          if (refreshed != null) {
            // Retry with new token
            error.requestOptions.headers['Authorization'] = 'Bearer $refreshed';
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          }
          // Redirect to login
        }
        handler.next(error);
      },
    ));

    // Logging interceptor (debug only)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;
}
```

### API Service Classes (Dart)

```dart
// lib/data/remote/api/auth_api.dart
class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<Response> register(Map<String, dynamic> body) =>
      _dio.post('/auth/register', data: body);

  Future<Response> login(Map<String, dynamic> body) =>
      _dio.post('/auth/login', data: body);

  Future<Response> getProfile() =>
      _dio.get('/auth/profile');

  Future<Response> getMembershipStatus() =>
      _dio.get('/auth/membership/status');

  Future<Response> subscribeMembership(Map<String, dynamic> body) =>
      _dio.post('/auth/membership/subscribe', data: body);

  Future<Response> updateProfile(Map<String, dynamic> body) =>
      _dio.put('/auth/profile', data: body);
}

// lib/data/remote/api/court_api.dart
class CourtApi {
  final Dio _dio;

  CourtApi(this._dio);

  Future<Response> getCourts({
    String? search,
    double? maxPrice,
    double? lat,
    double? lng,
    double? radius,
  }) => _dio.get('/courts', queryParameters: {
    if (search != null) 'search': search,
    if (maxPrice != null) 'maxPrice': maxPrice,
    if (lat != null) 'lat': lat,
    if (lng != null) 'lng': lng,
    if (radius != null) 'radius': radius,
  });

  Future<Response> getCourtDetail(String courtId) =>
      _dio.get('/courts/$courtId');

  Future<Response> getCourtAvailability(String courtId, String date) =>
      _dio.get('/courts/$courtId/availability', queryParameters: {'date': date});

  Future<Response> createCourt(Map<String, dynamic> body) =>
      _dio.post('/courts', data: body);

  Future<Response> updateCourt(String courtId, Map<String, dynamic> body) =>
      _dio.put('/courts/$courtId', data: body);

  Future<Response> deleteCourt(String courtId) =>
      _dio.delete('/courts/$courtId');
}

// lib/data/remote/api/booking_api.dart
class BookingApi {
  final Dio _dio;

  BookingApi(this._dio);

  Future<Response> getBookings() => _dio.get('/bookings');

  Future<Response> createBooking(Map<String, dynamic> body) =>
      _dio.post('/bookings', data: body);

  Future<Response> getBookingDetail(String bookingId) =>
      _dio.get('/bookings/$bookingId');

  Future<Response> cancelBooking(String bookingId) =>
      _dio.put('/bookings/$bookingId/cancel');

  Future<Response> updateBooking(String bookingId, Map<String, dynamic> body) =>
      _dio.put('/bookings/$bookingId', data: body);
}

// lib/data/remote/api/payment_api.dart
class PaymentApi {
  final Dio _dio;

  PaymentApi(this._dio);

  Future<Response> createPaymentIntent(Map<String, dynamic> body) =>
      _dio.post('/payments/create-payment-intent', data: body);

  Future<Response> confirmPayment(Map<String, dynamic> body) =>
      _dio.post('/payments/confirm', data: body);

  Future<Response> bankTransfer(Map<String, dynamic> body) =>
      _dio.post('/payments/bank-transfer', data: body);

  Future<Response> promptPay(Map<String, dynamic> body) =>
      _dio.post('/payments/promptpay', data: body);

  Future<Response> getPaymentForBooking(String bookingId) =>
      _dio.get('/payments/booking/$bookingId');
}

// lib/data/remote/api/review_api.dart
class ReviewApi {
  final Dio _dio;

  ReviewApi(this._dio);

  Future<Response> getReviews(String courtId) =>
      _dio.get('/reviews', queryParameters: {'court_id': courtId});

  Future<Response> createReview(Map<String, dynamic> body) =>
      _dio.post('/reviews', data: body);

  Future<Response> updateReview(String reviewId, Map<String, dynamic> body) =>
      _dio.put('/reviews/$reviewId', data: body);

  Future<Response> deleteReview(String reviewId) =>
      _dio.delete('/reviews/$reviewId');
}

// lib/data/remote/api/waitlist_api.dart
class WaitlistApi {
  final Dio _dio;

  WaitlistApi(this._dio);

  Future<Response> getWaitlist({String? courtId, String? date}) =>
      _dio.get('/waitlist', queryParameters: {
        if (courtId != null) 'court_id': courtId,
        if (date != null) 'date': date,
      });

  Future<Response> joinWaitlist(Map<String, dynamic> body) =>
      _dio.post('/waitlist', data: body);

  Future<Response> leaveWaitlist(String entryId) =>
      _dio.delete('/waitlist/$entryId');
}

// lib/data/remote/api/community_api.dart
class CommunityApi {
  final Dio _dio;

  CommunityApi(this._dio);

  Future<Response> getPosts() => _dio.get('/community');

  Future<Response> createPost(Map<String, dynamic> body) =>
      _dio.post('/community', data: body);

  Future<Response> updatePost(String postId, Map<String, dynamic> body) =>
      _dio.put('/community/$postId', data: body);

  Future<Response> deletePost(String postId) =>
      _dio.delete('/community/$postId');
}
```

### Token Storage

```dart
// lib/data/local/token_storage.dart
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _expiresAtKey = 'expires_at';

  final FlutterSecureStorage _secureStorage;

  TokenStorage(this._secureStorage);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresAt,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _expiresAtKey, value: expiresAt.toString());
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<bool> isTokenValid() async {
    final expiresAtStr = await _secureStorage.read(key: _expiresAtKey);
    if (expiresAtStr == null) return false;
    final expiresAt = int.tryParse(expiresAtStr);
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiresAt * 1000;
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _expiresAtKey);
  }

  Future<String?> refreshToken() async {
    // Implement token refresh if backend supports it
    // Otherwise return null to trigger re-login
    return null;
  }
}
```

### Data Models (Dart)

```dart
// lib/domain/models/user.dart
class UserProfile {
  final String id;
  final String authId;
  final String email;
  final String fullName;
  final String? address;
  final String role;
  final String membershipStatus;
  final DateTime? membershipExpiresAt;

  UserProfile({
    required this.id,
    required this.authId,
    required this.email,
    required this.fullName,
    this.address,
    required this.role,
    required this.membershipStatus,
    this.membershipExpiresAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    authId: json['auth_id'],
    email: json['email'],
    fullName: json['full_name'],
    address: json['address'],
    role: json['role'],
    membershipStatus: json['membership_status'] ?? 'none',
    membershipExpiresAt: json['membership_expires_at'] != null
        ? DateTime.parse(json['membership_expires_at'])
        : null,
  );

  bool get isAdmin => role == 'ADMIN';
  bool get isMember => membershipStatus == 'active';
}

// lib/domain/models/court.dart
class Court {
  final String id;
  final String name;
  final String? description;
  final String location;
  final double pricePerHour;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final double? avgRating;
  final int? reviewCount;
  final double? distanceKm;
  final DateTime createdAt;

  Court({
    required this.id,
    required this.name,
    this.description,
    required this.location,
    required this.pricePerHour,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.avgRating,
    this.reviewCount,
    this.distanceKm,
    required this.createdAt,
  });

  factory Court.fromJson(Map<String, dynamic> json) => Court(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    location: json['location'],
    pricePerHour: (json['price_per_hour'] as num).toDouble(),
    latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
    longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    imageUrl: json['image_url'],
    avgRating: json['avg_rating'] != null ? (json['avg_rating'] as num).toDouble() : null,
    reviewCount: json['review_count'],
    distanceKm: json['distance_km'] != null ? (json['distance_km'] as num).toDouble() : null,
    createdAt: DateTime.parse(json['created_at']),
  );
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool available;
  final double price;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.available,
    required this.price,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    startTime: json['start_time'],
    endTime: json['end_time'],
    available: json['available'],
    price: (json['price'] as num).toDouble(),
  );
}

// lib/domain/models/booking.dart
class Booking {
  final String id;
  final String userId;
  final String courtId;
  final String? courtName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final int durationHours;
  final double totalPrice;
  final String status;
  final EquipmentRentals? equipmentRentals;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.courtId,
    this.courtName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
    this.equipmentRentals,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'],
    userId: json['user_id'],
    courtId: json['court_id'],
    courtName: json['court_name'],
    bookingDate: json['booking_date'],
    startTime: json['start_time'],
    endTime: json['end_time'],
    durationHours: json['duration_hours'],
    totalPrice: (json['total_price'] as num).toDouble(),
    status: json['status'],
    equipmentRentals: json['equipment_rentals'] != null
        ? EquipmentRentals.fromJson(json['equipment_rentals'])
        : null,
    createdAt: DateTime.parse(json['created_at']),
  );

  bool get isUpcoming => status == 'pending' || status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}

class EquipmentRentals {
  final int rackets;
  final int shuttlecocks;
  final int shoes;

  EquipmentRentals({
    this.rackets = 0,
    this.shuttlecocks = 0,
    this.shoes = 0,
  });

  factory EquipmentRentals.fromJson(Map<String, dynamic> json) => EquipmentRentals(
    rackets: json['rackets'] ?? 0,
    shuttlecocks: json['shuttlecocks'] ?? 0,
    shoes: json['shoes'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'rackets': rackets,
    'shuttlecocks': shuttlecocks,
    'shoes': shoes,
  };

  double get totalCost => (rackets * 50) + (shuttlecocks * 30) + (shoes * 40).toDouble();
}

// lib/domain/models/review.dart
class Review {
  final String id;
  final String courtId;
  final String userId;
  final String? userName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.courtId,
    required this.userId,
    this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    courtId: json['court_id'],
    userId: json['user_id'],
    userName: json['user_name'],
    rating: json['rating'],
    comment: json['comment'],
    createdAt: DateTime.parse(json['created_at']),
  );
}

// lib/domain/models/waitlist_entry.dart
class WaitlistEntry {
  final String id;
  final String userId;
  final String courtId;
  final String? courtName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final int position;
  final String status;
  final DateTime createdAt;

  WaitlistEntry({
    required this.id,
    required this.userId,
    required this.courtId,
    this.courtName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.position,
    required this.status,
    required this.createdAt,
  });

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) => WaitlistEntry(
    id: json['id'],
    userId: json['user_id'],
    courtId: json['court_id'],
    courtName: json['court_name'],
    bookingDate: json['booking_date'],
    startTime: json['start_time'],
    endTime: json['end_time'],
    position: json['position'],
    status: json['status'],
    createdAt: DateTime.parse(json['created_at']),
  );
}

// lib/domain/models/community_post.dart
class CommunityPost {
  final String id;
  final String userId;
  final String? userName;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommunityPost({
    required this.id,
    required this.userId,
    this.userName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
    id: json['id'],
    userId: json['user_id'],
    userName: json['user_name'],
    title: json['title'],
    content: json['content'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
  );
}
```

### Riverpod Providers Example

```dart
// lib/presentation/providers/auth_provider.dart
@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<AuthStatus> build() async {
    // Check stored token on app start
    final tokenStorage = ref.read(tokenStorageProvider);
    final isValid = await tokenStorage.isTokenValid();
    if (isValid) {
      final profile = await ref.read(authApiProvider).getProfile();
      return AuthStatus.authenticated(
        UserProfile.fromJson(profile.data['user']),
      );
    }
    return const AuthStatus.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(authApiProvider).login({
        'email': email,
        'password': password,
      });
      final session = response.data['session'];
      final tokenStorage = ref.read(tokenStorageProvider);
      await tokenStorage.saveTokens(
        accessToken: session['access_token'],
        refreshToken: session['refresh_token'],
        expiresAt: session['expires_at'],
      );
      final profile = await ref.read(authApiProvider).getProfile();
      return AuthStatus.authenticated(
        UserProfile.fromJson(profile.data['user']),
      );
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearTokens();
    state = const AsyncData(AuthStatus.unauthenticated());
  }
}

// lib/presentation/providers/court_provider.dart
@riverpod
Future<List<Court>> courts(CourtsRef ref, {String? search, double? maxPrice}) async {
  final response = await ref.read(courtApiProvider).getCourts(
    search: search,
    maxPrice: maxPrice,
  );
  final courtsJson = response.data['courts'] as List;
  return courtsJson.map((json) => Court.fromJson(json)).toList();
}

@riverpod
Future<Court> courtDetail(CourtDetailRef ref, String courtId) async {
  final response = await ref.read(courtApiProvider).getCourtDetail(courtId);
  return Court.fromJson(response.data['court']);
}

@riverpod
Future<List<TimeSlot>> courtAvailability(CourtAvailabilityRef ref, String courtId, String date) async {
  final response = await ref.read(courtApiProvider).getCourtAvailability(courtId, date);
  final slotsJson = response.data['slots'] as List;
  return slotsJson.map((json) => TimeSlot.fromJson(json)).toList();
}
```

---

## 11. Environment Configuration

### App Configuration Constants

```dart
// lib/core/constants/api_config.dart
class ApiConfig {
  // Android emulator: use 10.0.2.2
  // iOS simulator: use localhost
  // Physical device: use your machine's LAN IP (e.g., 192.168.1.x)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  // Supabase config (same as web app)
  static const String supabaseUrl = 'https://obywrvuqmiajsirekqmy.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

  // Stripe publishable key
  static const String stripePublishableKey = 'pk_test_...';

  // Equipment pricing
  static const double racketPrice = 50.0;
  static const double shuttlecockPrice = 30.0;
  static const double shoesPrice = 40.0;
  static const double memberHourlyRate = 150.0;
  static const double membershipMonthlyPrice = 199.0;
}
```

### Android Permissions (`android/app/src/main/AndroidManifest.xml`)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these before <application> tag -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:usesCleartextTraffic="true"
        ...>
        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY" />
    </application>
</manifest>
```

### iOS Permissions (`ios/Runner/Info.plist`)

```xml
<dict>
    <!-- Add these inside the main <dict> -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location to show nearby badminton courts.</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>We need your location to show nearby badminton courts.</string>
</dict>
```

### Network Security Config (for local HTTP on Android)

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">192.168.0.0/16</domain>
    </domain-config>
</network-security-config>
```

### Localization Setup

```yaml
# l10n.yaml (project root)
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

Create localization files:
- `lib/l10n/app_en.arb` — English
- `lib/l10n/app_th.arb` — Thai
- `lib/l10n/app_zh.arb` — Chinese

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",
  "appTitle": "Pro Badminton",
  "login": "Login",
  "register": "Register",
  "email": "Email",
  "password": "Password",
  "searchCourts": "Search courts...",
  "bookNow": "Book Now",
  "myBookings": "My Bookings",
  "profile": "Profile",
  "logout": "Logout"
}
```

---

## 12. Backend Changes Needed

The existing backend should work with minimal changes for the mobile client:

### 12.1 CORS Configuration

Add the mobile app's origin to allowed origins. In `server.js`, the CORS config should allow requests from the mobile app. Since mobile apps don't have a traditional "origin," ensure the backend accepts requests without origin headers or with custom mobile origins.

### 12.2 API-Only Mode

The backend already supports `ENABLE_FRONTEND=false` mode for API-only operation. Use this when running the backend for the mobile app.

### 12.3 Recommended `.env` for Mobile Development

```env
PORT=8080
ENABLE_FRONTEND=false
CORS_ORIGINS=*
```

### 12.4 No New API Endpoints Needed

All existing endpoints should work for the mobile client. The mobile app will use the same REST API that the web frontend uses.

### 12.5 Stripe Configuration

Ensure Stripe is configured to accept payments from mobile SDK. The `client_secret` returned by `POST /api/payments/create-payment-intent` will be used by `flutter_stripe` to process the payment.

---

## 13. Project Structure

```
probadminton/
├── lib/
│   ├── main.dart                           # App entry point
│   ├── app.dart                            # MaterialApp + GoRouter setup
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_config.dart             # API base URL, pricing constants
│   │   │   └── app_theme.dart              # ThemeData definition
│   │   ├── network/
│   │   │   ├── api_client.dart             # Dio client with interceptors
│   │   │   └── api_exceptions.dart         # Custom exception classes
│   │   └── utils/
│   │       ├── price_calculator.dart       # Booking price calculation
│   │       ├── validators.dart             # Form input validators
│   │       └── formatters.dart             # Date/currency formatters
│   ├── data/
│   │   ├── remote/
│   │   │   └── api/
│   │   │       ├── auth_api.dart
│   │   │       ├── court_api.dart
│   │   │       ├── booking_api.dart
│   │   │       ├── payment_api.dart
│   │   │       ├── review_api.dart
│   │   │       ├── waitlist_api.dart
│   │   │       └── community_api.dart
│   │   ├── local/
│   │   │   ├── token_storage.dart          # FlutterSecureStorage wrapper
│   │   │   └── preferences_storage.dart    # SharedPreferences wrapper
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       ├── court_repository.dart
│   │       ├── booking_repository.dart
│   │       ├── payment_repository.dart
│   │       ├── review_repository.dart
│   │       ├── waitlist_repository.dart
│   │       └── community_repository.dart
│   ├── domain/
│   │   └── models/
│   │       ├── user.dart
│   │       ├── court.dart
│   │       ├── booking.dart
│   │       ├── review.dart
│   │       ├── waitlist_entry.dart
│   │       ├── community_post.dart
│   │       └── payment.dart
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   ├── court_provider.dart
│   │   │   ├── booking_provider.dart
│   │   │   ├── payment_provider.dart
│   │   │   ├── review_provider.dart
│   │   │   ├── waitlist_provider.dart
│   │   │   ├── community_provider.dart
│   │   │   ├── membership_provider.dart
│   │   │   └── locale_provider.dart
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   │   └── splash_screen.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   ├── map/
│   │   │   │   └── map_screen.dart
│   │   │   ├── court/
│   │   │   │   ├── court_detail_screen.dart
│   │   │   │   └── booking_screen.dart         # Multi-step booking flow
│   │   │   ├── bookings/
│   │   │   │   ├── my_bookings_screen.dart
│   │   │   │   └── booking_detail_screen.dart
│   │   │   ├── payment/
│   │   │   │   └── payment_screen.dart
│   │   │   ├── reviews/
│   │   │   │   └── review_screen.dart
│   │   │   ├── waitlist/
│   │   │   │   └── waitlist_screen.dart
│   │   │   ├── membership/
│   │   │   │   └── membership_screen.dart
│   │   │   ├── community/
│   │   │   │   ├── community_screen.dart
│   │   │   │   └── create_post_screen.dart
│   │   │   ├── profile/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   └── edit_profile_screen.dart
│   │   │   └── admin/
│   │   │       ├── admin_dashboard_screen.dart
│   │   │       ├── manage_courts_screen.dart
│   │   │       ├── manage_bookings_screen.dart
│   │   │       ├── manage_users_screen.dart
│   │   │       └── manage_community_screen.dart
│   │   ├── widgets/
│   │   │   ├── court_card.dart
│   │   │   ├── booking_card.dart
│   │   │   ├── review_card.dart
│   │   │   ├── rating_stars.dart
│   │   │   ├── time_slot_grid.dart
│   │   │   ├── equipment_selector.dart
│   │   │   ├── price_summary.dart
│   │   │   ├── status_badge.dart
│   │   │   ├── empty_state.dart
│   │   │   ├── loading_shimmer.dart
│   │   │   └── bottom_nav_bar.dart
│   │   └── router/
│   │       └── app_router.dart                  # GoRouter configuration
│   ├── l10n/
│   │   ├── app_en.arb                           # English translations
│   │   ├── app_th.arb                           # Thai translations
│   │   └── app_zh.arb                           # Chinese translations
│   └── generated/
│       └── l10n/                                # Generated localization files
├── android/
│   ├── app/
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── res/
│   │           └── xml/
│   │               └── network_security_config.xml
│   ├── build.gradle
│   └── ...
├── ios/
│   └── Runner/
│       └── Info.plist
├── test/
│   ├── unit/
│   │   ├── repositories/
│   │   └── providers/
│   └── widget/
│       └── screens/
├── integration_test/
│   └── app_test.dart
├── pubspec.yaml
├── l10n.yaml
└── analysis_options.yaml
```

---

## 14. AI Implementation Instructions

When implementing this mobile app, follow this approach:

1. **Start with Phase 1** (project setup + auth). Do not move to the next phase until login and registration work correctly.

2. **Use the existing backend** running at `http://10.0.2.2:8080/api` (Android emulator), `http://localhost:8080/api` (iOS simulator), or your LAN IP (physical device). Start the backend with `ENABLE_FRONTEND=false`.

3. **For each screen**, implement in this order:
   - Domain layer: Model classes with `fromJson` / `toJson`
   - Data layer: API service class (Dio methods), Repository class
   - Presentation layer: Riverpod provider (state management with `StateNotifier` or generated providers)
   - UI: Flutter screen widget with all interactive elements
   - Navigation: Wire up the screen in GoRouter

4. **Authentication**: After login, store the `access_token` in `FlutterSecureStorage`. Use a Dio interceptor to automatically attach the token to all subsequent requests.

5. **Error handling**: Every API call should have try/catch with user-friendly error messages shown as `SnackBar` or dialog.

6. **Price calculations**:
   - Standard rate: `court.pricePerHour * durationHours`
   - Equipment: `rackets * 50 + shuttlecocks * 30 + shoes * 40`
   - Member rate: `150 * durationHours` (if membership active)
   - Total = court cost + equipment cost

7. **Stripe integration**: Use the `flutter_stripe` package with the `client_secret` from the backend's `create-payment-intent` endpoint.

8. **Maps**: Use `google_maps_flutter` for showing court locations. Request location permission via `permission_handler` and get current location with `geolocator`.

9. **Multi-language**: Store language preference in `SharedPreferences`. Use Flutter's built-in localization system with `.arb` files (`lib/l10n/app_en.arb`, `lib/l10n/app_th.arb`, `lib/l10n/app_zh.arb`).

10. **Admin features**: Check the user's `role` field. If `"ADMIN"`, show the Admin tab in bottom navigation and admin-specific menu items. Otherwise, hide all admin functionality.

11. **Cross-platform testing**: Test on both Android and iOS. For Android emulator use `10.0.2.2`, for iOS simulator use `localhost`.

---

## 15. Quick Reference

| Item             | Value                                                       |
| ---------------- | ----------------------------------------------------------- |
| App Name         | Pro Badminton                                               |
| Package Name     | com.folkliygrunt.probadminton                               |
| Backend Base URL | `http://10.0.2.2:8080/api/` (Android emulator)             |
|                  | `http://localhost:8080/api/` (iOS simulator)                |
| Currency         | Thai Baht (฿)                                               |
| Min Android      | 5.0 (API 21)                                                |
| Min iOS          | 12.0                                                        |
| Framework        | Flutter 3.x (cross-platform)                                |
| Language         | Dart 3.x                                                    |
| Architecture     | Clean Architecture + Riverpod                               |
| UI               | Material 3                                                  |
| Auth             | Supabase (email/password, JWT)                              |
| Payments         | Stripe (flutter_stripe), Bank Transfer, PromptPay           |
| Maps             | google_maps_flutter                                         |
| State Management | Riverpod                                                    |
| Navigation       | GoRouter                                                    |

---

> **Note to AI:** Implement all screens and features listed above. The mobile app must have feature parity with the web application. Every user-facing feature from the web app must be present in the mobile app. Start with authentication, then court discovery, then booking flow, then the remaining features in order. Test each phase before moving to the next. The app should run on both Android and iOS.