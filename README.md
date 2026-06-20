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

## Demo users

All three records and plain-text demo passwords are centralized in `lib/features/auth/data/static_users.dart`.

| Username | Employee code | Demo password | Backend ID | Role |
| --- | --- | --- | ---: | --- |
| `support1` | `EMP001` | `Support@123` | 95 | Support Executive |
| `support2` | `EMP002` | `Support@456` | 96 | Support Executive |
| `manager1` | `EMP003` | `Manager@789` | 97 | Support Manager |

Replace these demo users, IDs, and passwords before controlled distribution. The API requires the numeric backend ID as `PickedBy`, while the GET payload currently exposes the assignee as a display name.

## Environment variables

- `APP_NAME`
- `API_BASE_URL`
- `API_CONNECT_TIMEOUT_SECONDS`
- `API_RECEIVE_TIMEOUT_SECONDS`
- `TICKET_POLLING_SECONDS`
- `BACKGROUND_CHECK_MINUTES`
- `ENABLE_BACKGROUND_CHECK`

`.env` is ignored by Git while `.env.example` is tracked.

## API integration

- `GET /api/Ticket/GetTicketDetail`
- `POST /api/Ticket/InsertTicketResponse`

The second request is intentionally POST even if an older Postman collection identifies it as GET. Ticket parsing is defensive, and failed POST operations never optimistically change local assignment or status.

## Notifications and refresh behavior

After first login, the app explains why ticket alerts are useful before requesting OS permission. Existing tickets establish a baseline and do not trigger historical notifications. Later successful checks compare IDs with `seenTicketIds_<backendUserId>` and notify only for newly detected `Open` tickets. Seen IDs are kept separately for users 95, 96, and 97.

While active, the dashboard refreshes immediately, on resume, through pull-to-refresh, and every `TICKET_POLLING_SECONDS` (60 seconds by default). Android WorkManager runs a best-effort periodic check when enabled, normally no more frequently than approximately 15 minutes. Exact one-minute background execution is not guaranteed on Android or iOS; the operating system controls scheduling. Near-real-time background alerts require a backend push service such as Firebase Cloud Messaging.

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
