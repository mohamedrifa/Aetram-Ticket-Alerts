# Aetram Ticket Support

Internal Flutter application for monitoring, taking, and resolving support tickets. The app uses a premium black-and-gold interface, Riverpod state management, Dio networking, GoRouter navigation, secure session storage, local notifications, and best-effort WorkManager checks.

## Prototype security warning

Static client-side authentication is suitable only for a controlled internal prototype. This version contains plain-text demo passwords in the application bundle, where they can be extracted. Replace this flow with authenticated backend identity before production use. `flutter_secure_storage` protects only the logged-in session; the entered password is never persisted.

Flutter `.env` assets are also bundled and extractable. Use them only for non-secret configuration such as URLs, timeouts, feature flags, and polling intervals. Never place API secrets, database passwords, private keys, Firebase service-account credentials, or real production employee passwords in `.env`.

## Setup

1. Copy `.env.example` to `.env` and adjust non-secret values if required.
2. Run `flutter pub get`.
3. Run `flutter run` on an Android or iOS device.

The existing project and native platform folders are retained. Android 13 notification permission is declared in `android/app/src/main/AndroidManifest.xml`.
At startup, Android checks notification access and battery-optimization exemption. Missing notification access triggers the system permission prompt; missing battery exemption opens Android's approval screen. These checks are skipped when access is already granted.

## Demo users

All three records and plain-text demo passwords are centralized in `lib/features/auth/data/static_users.dart`.

| Username | Password | Backend ID |
| --- | --- | ---: |
| `hemalatha` | `Hemalatha@123` | 121 |
| `gopinath` | `Gopinath@123` | 76 |
| `vimal` | `Vimal@123` | 31 |

Replace these demo users, IDs, and passwords before controlled distribution. The API requires the numeric backend ID as `PickedBy`, while the GET payload currently exposes the assignee as a display name.

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

`.env` is ignored by Git while `.env.example` is tracked.

## API integration

- `GET /api/Ticket/GetTicketDetail`
- `POST /api/Ticket/InsertTicketResponse`

The second request is intentionally POST even if an older Postman collection identifies it as GET. Ticket parsing is defensive, and failed POST operations never optimistically change local assignment or status.

## Notifications and refresh behavior

After first login, the app explains why ticket alerts are useful before requesting OS permission. Existing tickets establish a baseline and do not trigger historical notifications. Later successful checks compare IDs with `seenTicketIds_<backendUserId>` and notify only for newly detected `Open` tickets. Seen IDs are kept separately for users 121, 76, and 31.

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
