# 🏸 Pro Badminton — Task List & Implementation Plan

> This document tracks all tasks required to build the Pro Badminton Flutter mobile app, broken into implementation phases.

---

## Project Overview

**FolkliyGrunt** (branded as **"Pro Badminton"**) is a **Badminton Court Management System** for Thailand. The mobile app must replicate ALL user-facing functionalities of the existing web application.

- **Currency:** Thai Baht (฿)
- **Country:** Thailand
- **Languages:** English, Thai, Chinese
- **Platforms:** Android & iOS (cross-platform via Flutter)
- **Architecture:** Clean Architecture + Riverpod + GoRouter

---

## App Screens (20 total)

### Authentication Screens (3)

| #   | Screen              | Description                                                 |
| --- | ------------------- | ----------------------------------------------------------- |
| 1   | **Splash Screen**   | App logo, auto-redirect to login or home based on token     |
| 2   | **Login Screen**    | Email + password fields, login button, link to register     |
| 3   | **Register Screen** | Email, password, full name, address fields; register button |

### Main App Screens — Bottom Navigation (4)

| #   | Screen            | Tab      | Description                                                                                                       |
| --- | ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------- |
| 4   | **Home / Search** | Home     | Search bar (name), filters (max price, distance), list of courts with cards showing name, price, rating, distance |
| 5   | **Map View**      | Map      | Map showing courts as markers; tap marker for court card preview                                                  |
| 6   | **My Bookings**   | Bookings | List of user's bookings grouped by status (upcoming, completed, cancelled); tap to see details                    |
| 7   | **Profile**       | Profile  | User info, membership status, settings, language switch, logout                                                   |

### Detail Screens (8)

| #   | Screen                | Description                                                                                                                                |
| --- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 8   | **Court Detail**      | Court image, name, description, location, price, rating, map pin, "Book Now" button, reviews list                                          |
| 9   | **Booking Flow**      | Select date, see available time slots, select duration (1-3hr), add equipment rentals, see price breakdown, choose payment method, confirm |
| 10  | **Payment Screen**    | Choose payment method (Credit Card / Bank Transfer / PromptPay), process payment, show confirmation                                        |
| 11  | **Booking Detail**    | Full booking info with status badge, court info, time, equipment, payment status, cancel button                                            |
| 12  | **Review Screen**     | Leave a review (star rating 1-5 + comment) for a completed booking's court                                                                 |
| 13  | **Waitlist Screen**   | View waitlist positions, join waitlist for full slots, leave waitlist                                                                      |
| 14  | **Membership Screen** | Current membership status, subscribe ฿199/mo, savings calculator, benefits list                                                            |
| 15  | **Community Screen**  | List of community posts, create new post, edit/delete own posts                                                                            |

### Admin Screens (5)

| #   | Screen               | Description                                       |
| --- | -------------------- | ------------------------------------------------- |
| 16  | **Admin Dashboard**  | Quick stats (total bookings, revenue, courts)     |
| 17  | **Manage Courts**    | List courts, add/edit/delete court                |
| 18  | **Manage Bookings**  | View all bookings, update status, cancel bookings |
| 19  | **Manage Users**     | View all users, view user details                 |
| 20  | **Manage Community** | View/edit/delete community posts                  |

---

## Implementation Phases

### Phase 1: Project Setup & Auth (Days 1-2) ✅ COMPLETE

- [x] Initialize Flutter project (`flutter create probadminton`)
- [x] Configure `pubspec.yaml` dependencies (Dio, Riverpod, GoRouter, etc.)
- [x] Set up project structure (Clean Architecture: data/domain/presentation layers)
- [x] Configure Dio client with auth interceptor
- [x] Implement `FlutterSecureStorage` for token storage
- [x] Build Splash Screen UI
- [x] Build Login Screen UI
- [x] Build Register Screen UI
- [x] Connect to `POST /api/auth/login` and `POST /api/auth/register`
- [x] Implement token storage and auth state management (Riverpod `StateNotifier`)
- [x] Wire up GoRouter with auth guards (redirect to login if unauthenticated)

**Additionally completed (early):**

- [x] All 7 API service classes (auth, court, booking, payment, review, waitlist, community)
- [x] All 7 domain models (user, court, booking, review, waitlist_entry, community_post, payment)
- [x] Core utilities (price_calculator, validators, formatters, api_exceptions)
- [x] Profile screen with logout functionality
- [x] Home screen placeholder
- [x] Android manifest + network security config for HTTP/cleartext traffic
- [x] `flutter analyze` passes with zero issues

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

## Key User Flows to Verify

### Authentication Flow

```
Splash Screen → Check stored token → Valid? → Home Screen
                                     → Invalid/Expired? → Login Screen

Login Screen → POST /api/auth/login → Store tokens → Home Screen
Register Screen → POST /api/auth/register → Auto-login → Home Screen
On 401 response → Clear tokens → Redirect to Login
```

### Booking Flow

```
Home → Select Court → Court Detail → Book Now → Select Date → Select Time →
Select Equipment → Price Summary → Payment Method → Payment → Confirmation
```

### Membership Flow

```
Profile → Membership → View Status → Subscribe (฿199/mo) → Confirmation
```

### Review Flow

```
My Bookings → Completed Booking → Write Review → Star Rating + Comment → Submit
```

### Waitlist Flow

```
Court Detail → Slot Full → Join Waitlist → View Waitlist Position → Leave Waitlist
```

---

## Pricing Reference

### Equipment Rental Pricing

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

### Price Calculation

- Standard rate: `court.pricePerHour × durationHours`
- Equipment: `rackets × 50 + shuttlecocks × 30 + shoes × 40`
- Member rate: `150 × durationHours` (if membership active)
- Total = court cost + equipment cost

---

## Definition of Done

Each phase is complete when:

- [ ] All screens for that phase are built and functional
- [ ] API connections work with real backend
- [ ] Error handling is in place
- [ ] Loading states are shown during API calls
- [ ] Navigation between screens works correctly
- [ ] Both Android and iOS builds succeed
