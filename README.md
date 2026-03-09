## City Services Directory App

This Flutter application is a **city services directory** for Kigali. Authenticated users can add and manage community points of interest (e.g. hospitals, police stations, parks), and everyone can browse, search, filter, and view them on a map.

### Features

- **Email/password authentication**
  - Sign up with email and password, with **email verification** before accessing the main app.
  - Login, logout, and basic error feedback from Firebase Authentication.
  - User profile stored in Firestore (`users` collection) with display name and email.

- **Listings (services/places) CRUD**
  - Each listing represents a **service/place** in Kigali (e.g. hospital, café, park, tourist attraction).
  - Authenticated users can **create, edit, and delete** their own listings via `My Listings` and the `ListingFormScreen`.
  - A listing contains name, category, address, contact info, description, and geo-coordinates (latitude/longitude).

- **Directory with search and filters**
  - `DirectoryScreen` shows all listings with:
    - **Search bar** (text search by listing name).
    - **Category filter bar** (`CategoryFilterBar`) with predefined categories like Hospital, Police Station, Public Library, etc.
  - Tapping a listing opens a detailed view with map, address, and contact information.

- **Map view**
  - `MapViewScreen` displays all listings as markers on a **Google Map**.
  - Markers show listing name and category; tapping the info window opens the detailed listing screen.
  - Auto-centers on the first listing, with a sensible default (Kigali center) if no listings exist.

- **Listing detail & directions**
  - `ListingDetailScreen` combines a map preview with rich listing details.
  - **“Directions”** button opens Google Maps with navigation to the listing’s coordinates.

- **Settings and preferences**
  - `SettingsScreen` shows the current user profile (name + email).
  - Toggle for **location-related notifications**, persisted locally via `SharedPreferences` through `SettingsProvider`.
  - Logout button to end the current session.

- **User experience**
  - Consistent theming and colors (Material 3) configured in `App`.
  - `LoadingOverlay` for async operations and `ErrorBanner` for surfacing provider-level errors.

### Firestore database structure

The app uses **Cloud Firestore** with two main collections:

- **`users` collection** (user profiles)
  - **Document ID**: Firebase Auth `uid`.
  - **Fields** (see `UserProfile` in `lib/models/user_profile_model.dart`):
    - `uid: string` – user id (duplicates doc id for convenience).
    - `email: string` – user email.
    - `displayName: string` – name chosen at signup.
    - `createdAt: Timestamp` – when the profile was created.
  - Managed by `FirestoreService.createOrUpdateUserProfile` and `FirestoreService.getUserProfile`.

- **`listings` collection** (services/places)
  - Each document represents a **service/place listing** used throughout the directory and map views.
  - **Fields** (see `Listing` in `lib/models/listing_model.dart`):
    - `name: string` – display name of the service/place.
    - `category: string` – one of the predefined categories (e.g. Hospital, Café, Park).
    - `address: string` – human-readable address.
    - `contactNumber: string` – phone or contact number.
    - `description: string` – short description of the service/place.
    - `latitude: number` – latitude coordinate.
    - `longitude: number` – longitude coordinate.
    - `createdBy: string` – `uid` of the Firebase user who created the listing.
    - `timestamp: Timestamp` – listing creation time (used for ordering).
  - Accessed through `FirestoreService`:
    - `watchAllListings()` – real-time stream of all listings (ordered by `timestamp`).
    - `watchListingsByUser(uid)` – real-time stream filtered by `createdBy`.
    - `createListing(listing)` – adds a new listing document.
    - `updateListing(listing)` – updates an existing listing document.
    - `deleteListing(id)` – deletes a listing by id.

In the UI, these Firestore documents are **mapped into Dart models** (`Listing`, `UserProfile`) and then exposed via providers to the widget tree.

### State management approach

The app uses **`provider` + `ChangeNotifier`** for state management. All application state is kept in pure Dart classes (providers and services), and the UI listens to them via `Provider`/`Consumer`/`context.watch`.

- **Auth state – `AuthProvider` (`lib/providers/auth_provider.dart`)**
  - Wraps `AuthService` (Firebase Authentication) and `FirestoreService`.
  - Subscribes to `authStateChanges()` to react to login/logout events.
  - Exposes:
    - `firebaseUser` – current `User?` from Firebase Auth.
    - `profile` – `UserProfile?` loaded from the `users` collection.
    - `isEmailVerified` – used by the root router to gate access to the main app.
    - Async actions: `signup`, `login`, `sendEmailVerification`, `reloadUser`, `logout`.
  - Sets `isLoading` and `errorMessage` so the UI can show `LoadingOverlay` and error banners.

- **Listings state – `ListingsProvider` (`lib/providers/listings_provider.dart`)**
  - Depends on `FirestoreService` and `LocationService`.
  - Maintains an in-memory list `_allListings` from `watchAllListings()` (real-time Firestore stream).
  - Exposes a **derived `listings` getter** that applies:
    - Category filter (`_selectedCategory`) using values from `kCategories`.
    - Search filter (`_searchQuery`) matching listing names.
  - Provides CRUD operations:
    - `createListing` – builds a `Listing` and calls `FirestoreService.createListing`.
    - `updateListing` – passes updated `Listing` to `FirestoreService.updateListing`.
    - `deleteListing` – removes a listing by id.
  - Location helpers:
    - `useCurrentLocation()` – uses `LocationService` to fetch the device’s current coordinates and returns `(latitude, longitude)` for the form.
  - Also exposes `isLoading`, `errorMessage`, and `clearError()` for UI feedback.

- **Settings state – `SettingsProvider` (`lib/providers/settings_provider.dart`)**
  - Handles **local preferences** via `SharedPreferences`.
  - Currently tracks:
    - `locationNotificationsEnabled: bool`.
  - On app startup, `loadPreferences()` is called to load existing settings.
  - Persists changes with `setLocationNotificationsEnabled`.

All providers are registered at the top level in `App` (`lib/app.dart`) using `MultiProvider`. This makes auth, listings, and settings state available to all screens via the Flutter widget tree.

### Navigation overview

Navigation is centralized in `App` (`lib/app.dart`):

- **App initialization**
  - `main.dart` initializes Firebase with `firebase_options.dart`, then runs `App`.
  - `App` sets up theming and wraps the app in `MultiProvider`.

- **Root routing – `_RootRouter`**
  - Listens to `AuthProvider`:
    - If there is **no authenticated user**, shows the **login flow** (`LoginScreen`).
    - If the user is logged in but **email is not verified**, shows `EmailVerifyScreen`.
    - If the user is logged in and verified, shows the main **`HomeShell`**.

- **Home shell and bottom navigation**
  - `HomeShell` is a `StatefulWidget` that manages a bottom navigation bar with four tabs:
    - `DirectoryScreen` – main directory with search and category filters.
    - `MyListingsScreen` – user’s own listings, with edit/delete and a FAB to add new listings.
    - `MapViewScreen` – full-screen map view of all listings.
    - `SettingsScreen` – profile, preferences, and logout.
  - Each screen reads from the appropriate provider(s) to display up-to-date data.

- **Additional flows**
  - From `DirectoryScreen`, tapping a card opens `ListingDetailScreen` via `Navigator.push`.
  - From `MyListingsScreen`, tapping add or edit opens `ListingFormScreen` for create/update.
  - From map markers or detail screen buttons, navigation may jump to Google Maps (external app) for directions.

### High-level Firebase setup (for reviewers)

To run the app with your own Firebase project:

- **1. Create Firebase project & Android app**
  - In the Firebase console, create a new project and add an **Android app** using the app’s package name from `android/app/src/main/AndroidManifest.xml`.
  - Download the generated `google-services.json` and place it in `android/app/`.

- **2. Enable products**
  - Enable **Email/Password Authentication**.
  - Enable **Cloud Firestore**.

- **3. Configure Flutter**
  - Use `flutterfire configure` (or equivalent) to generate `lib/firebase_options.dart`, or manually supply the options used in `Firebase.initializeApp`.
  - Run `flutter pub get`, then `flutter run` on a connected device/emulator.

This README summarizes the app’s **features**, the **Firestore database structure** (`users` and `listings` collections), and the **state management approach** built on `provider` + `ChangeNotifier`.

## Kigali City Services & Places Directory

Flutter mobile app to help Kigali residents find and navigate to public services and leisure locations.

### Tech Stack

- Flutter (latest stable)
- Firebase Authentication + Cloud Firestore
- Provider for state management
- Google Maps (`google_maps_flutter`)
- Location (`geolocator`, `geocoding`)
- `url_launcher`, `shared_preferences`

### Getting Started

1. **Install Flutter**
   - Install the latest stable Flutter SDK and set up an emulator or physical device.

2. **Install dependencies**
   - From this project directory, run:
     - `flutter pub get`

3. **Configure Firebase**
   - Create a Firebase project in the Firebase console.
   - Add Android (and iOS if needed) apps to the Firebase project.
   - Use the FlutterFire CLI to generate `lib/firebase_options.dart`:
     - `dart pub global activate flutterfire_cli`
     - `flutterfire configure`
   - This will generate a `DefaultFirebaseOptions` class used by `main.dart`.

4. **Google Maps API keys**
   - Create a Google Cloud project and enable the Maps SDK for Android/iOS.
   - Create API keys and restrict them appropriately.
   - Add the keys to the platform-specific config (do **not** hardcode keys in Dart):
     - Android: `android/app/src/main/AndroidManifest.xml`
     - iOS: `ios/Runner/AppDelegate.swift` / `Info.plist` as per `google_maps_flutter` docs.

5. **Location permissions**
   - Configure runtime location permissions using `geolocator` setup guides:
     - Android: update `AndroidManifest.xml` with location permissions.
     - iOS: add `NSLocationWhenInUseUsageDescription` (and related keys if needed) to `Info.plist`.

6. **Run the app**
   - Start a simulator or connect a device.
   - Run:
     - `flutter run`

7. **Apply Firestore security rules**
   - From the Firebase console or using the CLI, apply `firestore.rules` from the project root so that:
     - Authenticated users can read all listings.
     - Only the creator of a listing can create/update/delete it.
     - Users can read/write only their own profile document under `/users/{uid}`.

### Architecture

The app follows a Provider-based architecture:

- **Services** (`lib/services/`): pure Dart classes for Firebase Auth, Firestore CRUD, and location helpers.
- **Providers** (`lib/providers/`): `ChangeNotifier` classes holding UI state and calling services.
- **Screens** (`lib/screens/`): Flutter UI widgets that consume providers via `context.watch` / `context.read`.
- **Widgets** (`lib/widgets/`): Reusable UI building blocks (listing cards, filter bars, overlays, banners).

See `kigali_app_cursor_rules.md` for the detailed architecture, data model, and feature rules.

### Key Flows

- **Authentication & Verification**
  - Users sign up and receive an email verification link.
  - Until verified, they are held on the Email Verify screen and cannot access the main app.
  - Login also enforces email verification before entering the main app.

- **Directory & Listings**
  - Directory tab shows all listings with search and category filter.
  - My Listings tab shows only listings created by the current user, with create/edit/delete support.
  - Listing details show full info, a map marker, and a Get Directions button that opens Google Maps.

- **Map & Settings**
  - Map View displays markers for all (or filtered) listings; tapping an info window opens the detail screen.
  - Settings shows the user profile, a toggle for location-based notifications, and a logout button.


