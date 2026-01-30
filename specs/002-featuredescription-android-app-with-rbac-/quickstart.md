# quickstart.md

## Prerequisites
- Flutter 3.x SDK
- Dart 3.x
- Supabase project (with PostgreSQL)
- Android Studio or VS Code
- Required Flutter packages: riverpod, supabase_flutter, geolocator, syncfusion_flutter_xlsio, material, etc.

## Setup
1. Clone the repo and checkout the `002-rbac-android-sales` branch.
2. Run `flutter pub get` in `/app`.
3. Configure Supabase keys in `lib/services/supabase_service.dart`.
4. Set up database tables in Supabase (profiles, products, tickets).
5. Run the app on an Android device or emulator: `flutter run`.

## Usage
- Log in as Worker or Manager (use email/password).
- Worker: Create sales ticket, select products, capture location, submit.
- Manager: Manage products, view dashboard, export tickets to Excel.

## Testing
- Run unit tests: `flutter test`
- Run integration tests: `flutter test integration_test`

## Notes
- All business logic is in providers/services, not UI widgets.
- RBAC enforced at both app and Supabase policy level.
- All widgets are reusable and stateless.
