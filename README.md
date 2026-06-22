# Aetram Ticket Support

Internal Flutter application for monitoring, taking, and resolving support tickets. The app uses a premium black-and-gold interface, Riverpod state management, Dio networking, GoRouter navigation, secure session storage, local notifications, and best-effort WorkManager checks.

## Prototype security warning

Realtime Database credential validation without Firebase Authentication is suitable only for a controlled internal prototype. The client must have read access to the `supportUsers` records, so those passwords can be extracted by anyone who obtains the Firebase application configuration. Replace this flow with backend authentication before production use. `flutter_secure_storage` stores only `backendUserId` and `username`; the entered password is never persisted.

Flutter `.env` assets are also bundled and extractable. Use them only for non-secret configuration such as URLs, timeouts, feature flags, and polling intervals. Never place API secrets, database passwords, private keys, Firebase service-account credentials, or real production employee passwords in `.env`.

## Setup

1. Open Firebase Console and register Android app `com.example.aetram_ticket_alerts`.
2. Register iOS app `com.example.aetramTicketAlerts`.
3. Copy each platform's public Firebase values into the matching `.env` fields. Realtime Database values are available under Firebase Project Settings and the database page.
4. Import `firebase/demo_data.json` into Realtime Database or create the same records manually.
5. Publish `firebase/database.rules.json` in the Realtime Database Rules tab.
6. Run `flutter pub get` and then `flutter run`.

The existing project and native platform folders are retained. Android 13 notification permission is declared in `android/app/src/main/AndroidManifest.xml`.
At startup, Android checks notification access and battery-optimization exemption. Missing notification access triggers the system permission prompt; missing battery exemption opens Android's approval screen. These checks are skipped when access is already granted.

## Firebase login data

Credentials live only under the Firebase `supportUsers` node. A ready-to-import example is provided at `firebase/demo_data.json`.

| Username | Password | Backend ID |
| --- | --- | ---: |
| `gopinath` | `Gopinath@123` | 76 |

After the first successful Firebase validation, only the username and backend ID are saved in secure storage. Future launches restore that session without querying or storing the password. Logout clears the session.

## Environment variables

- `APP_NAME`
- `API_BASE_URL`
- `ATTACHMENT_BASE_URL`
- `API_CONNECT_TIMEOUT_SECONDS`
- `API_RECEIVE_TIMEOUT_SECONDS`
- `TICKET_POLLING_SECONDS`
- `ANDROID_ALARM_INTERVAL_SECONDS`
- `BACKGROUND_CHECK_MINUTES`
- `ENABLE_BACKGROUND_CHECK`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_DATABASE_URL`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_ANDROID_API_KEY`
- `FIREBASE_ANDROID_APP_ID`
- `FIREBASE_IOS_API_KEY`
- `FIREBASE_IOS_APP_ID`
- `FIREBASE_IOS_BUNDLE_ID`

`.env` is ignored by Git while `.env.example` is tracked.

## API integration

- `GET /api/Ticket/GetTicketDetail`
- `POST /api/Ticket/InsertTicketResponse`

The second request is intentionally POST even if an older Postman collection identifies it as GET. Ticket parsing is defensive, and failed POST operations never optimistically change local assignment or status.

## Notifications and refresh behavior

At startup, the app checks notification permission before restoring the login session. Existing tickets establish a baseline and do not trigger historical notifications. Later successful checks compare IDs with `seenTicketIds_<backendUserId>` and notify only for newly detected `Open` tickets.

Android AlarmManager schedules a background Dart callback using `ANDROID_ALARM_INTERVAL_SECONDS` (requested as 10 seconds by default). The callback can run after the application UI/process ends, stores a unique ticket count per user, and sends a notification only when that count increases and an unseen ticket has an `Open` status. Android commonly clamps or batches short periodic alarms, so the practical cadence may be roughly one minute or longer, especially in Doze mode. Alarms survive reboot but never survive Android Force Stop until the app is opened again. WorkManager remains a slower fallback. Reliable immediate cross-platform alerts still require backend push notifications such as Firebase Cloud Messaging.

## Quality checks

```text
flutter format .
flutter analyze
flutter test
flutter build apk
```

Tests do not call the live API. They cover parsing, normalization, filtering, attachment conversion, login form validation, new-ticket detection, API success/error handling, ticket-card rendering, and close-comment validation.

## Current backend limitations

- No backend authentication or API authorization is documented.
- No atomic assignment/conflict contract is documented; the server should reject concurrent takes, ideally with HTTP 409.
- No response/history endpoint is available.
- No `ClosedAt` or reliable `UpdatedAt` field is returned.
- Polling downloads the full ticket collection because no incremental endpoint exists.
- Attachment paths require client conversion and may not be publicly reachable.
- Real-time notifications require backend push support and device-token registration.
- There is no documented ticket reassignment or reopen endpoint.
