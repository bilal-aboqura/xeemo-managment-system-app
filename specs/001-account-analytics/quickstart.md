# Quickstart: Account Creation & Worker Analytics

## Prerequisites
- Flutter 3.x SDK
- Supabase project (PostgreSQL, Auth enabled)
- Dart 3.x
- Packages: provider, fl_chart, supabase_flutter, flutter_test, mockito

## Setup
1. Clone the repo and checkout `001-account-analytics` branch
2. Run `flutter pub get` in the app directory
3. Configure Supabase keys in `lib/config/`
4. Run database migrations for user, manager_assignment, worker_analytics tables
5. Start the app: `flutter run`

## Usage
- Log in as Super Manager
- Create worker/manager accounts (with email, password, role)
- Assign workers to managers
- Click any worker card to view analytics
- Filter analytics by preset or custom date ranges

## Testing
- Run all tests: `flutter test`
- Integration: `integration_test/`

## Notes
- All analytics and account flows are RBAC protected
- Passwords must meet security requirements
- Charts are responsive and interactive
