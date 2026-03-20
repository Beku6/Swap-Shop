# swap

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase rules deployment

After updating Firestore rules, deploy them before testing on device:

```bash
firebase deploy --only firestore:rules
```

If you also update composite indexes, deploy indexes as well:

```bash
firebase deploy --only firestore:indexes
```

## Supabase Storage checklist (product images)

1. In Supabase Storage, create bucket `product-images`.
2. For MVP, set bucket visibility to **Public**.
3. If bucket is private, add policies that allow authenticated `INSERT` and `SELECT`:

```sql
create policy "allow authenticated upload"
on storage.objects for insert
to authenticated
with check (bucket_id = 'product-images');

create policy "allow authenticated read"
on storage.objects for select
to authenticated
using (bucket_id = 'product-images');
```
4. Upload a test image from the Sell page and verify:
   - file exists in bucket
   - Firestore product document has `imageUrls`
   - image URL opens successfully

## Debug diagnostics checklist (kDebugMode)
Use this template during manual QA sessions:

- `currentUser.uid`: ____________________
- `themeMode` (system/light/dark): ____________________
- push permission state (`authorized` / `denied` / `notDetermined`): ____________________
- network status (`online` / `offline`): ____________________
- supabase bucket health (`product-images` read/upload check): ____________________

Suggested quick checks:
1. Sign in and confirm `users/{uid}` exists in Firestore for the active UID.
2. Toggle theme in Profile/Settings and confirm persisted mode after restart.
3. Toggle push notifications from Settings and verify permission + `users/{uid}.pushEnabled`.
4. Upload a small image from Sell and verify URL resolves from `product-images`.

## Release QA checklist
Run through these flows before release:

1. Auth: sign in, sign out, register, forgot password.
2. Google sign-in: success path + misconfiguration error handling.
3. Sell: publish product with 1 image and with 8 images; verify upload progress and persisted product document.
4. Home feed: load, scroll pagination, open product details.
5. Cart: add item, update quantity, remove item.
6. Favorites: toggle favorite from feed/details and verify persisted list.
7. Messages: open thread, send message, verify unread counters.
8. Swap: propose swap, accept swap, reject swap.
9. Notifications: list, open, mark as read.
10. Account deletion: re-auth flow, cleanup flow, auth user removal.
11. Offline behavior: verify Home + Messages offline banner, and blocked actions (publish/swap/send message).

## Android release hardening (AAB)

### 1) Generate upload keystore (one-time)

From repository root:

```bash
keytool -genkey -v \
  -keystore android/keystore/swapshop-upload.jks \
  -alias swapshop \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

### 2) Create `android/key.properties` (not committed)

```properties
storeFile=keystore/swapshop-upload.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=swapshop
keyPassword=YOUR_KEY_PASSWORD
```

`android/key.properties` is git-ignored by default.

### 3) Build commands

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

Optional local release APK:

```bash
flutter build apk --release
```

### 4) Versioning / Play Store bump

Version source is `pubspec.yaml`:

- `version: x.y.z+N`
  - `x.y.z` -> `versionName`
  - `N` -> `versionCode`

Increase `+N` for every Play Store upload.

### 5) Application ID

Current Android `applicationId` is `com.example.swap` in `android/app/build.gradle.kts`.

Before production publish, replace it with your final package name and register the same ID in:

- Firebase Android app config
- Google Play Console app listing
