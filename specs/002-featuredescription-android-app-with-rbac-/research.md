# research.md

## Phase 0: Research & Clarifications

### Technology Choices

- **Flutter**: Chosen for cross-platform mobile development, strong community, and Material 3 support.
- **State Management**: Riverpod preferred for testability, modularity, and clean separation. Bloc is a valid alternative if team prefers.
- **Backend**: Supabase for managed auth (RBAC) and PostgreSQL for scalable, secure data storage. Supabase provides real-time sync and easy integration with Flutter.
- **Geolocation**: 'geolocator' package is industry standard for permission handling and high-accuracy GPS on Android.
- **Excel Export**: 'syncfusion_flutter_xlsio' is robust and feature-rich; 'excel' is a lighter alternative. Both support .xlsx export on device.
- **UI**: Material Design 3 for modern, accessible, and consistent UI.

### Best Practices

- **RBAC**: Enforce at both Supabase policy and app logic. Never trust client role alone.
- **State Management**: Use providers for all business logic and state. UI widgets must be stateless and reusable.
- **Geolocation**: Always request permission at runtime. Handle denied/failed gracefully. Use high-accuracy mode for ticket capture.
- **Excel Export**: Export from in-memory data, not direct DB. Validate file before sharing.
- **Offline Support**: Queue tickets locally if offline, retry on reconnect. Warn user if unsent tickets remain.
- **Database Schema**:
  - 'profiles': user_id (PK), name, role (worker/manager), email, ...
  - 'products': product_id (PK), name (unique), price, details
  - 'tickets': ticket_id (PK), client_name, client_phone, worker_notes, client_notes, sale_amount, worker_id (FK), created_at, latitude, longitude

### Alternatives Considered

- **State**: Bloc (more boilerplate, but familiar to some teams)
- **Backend**: Firebase (less SQL control, weaker RBAC)
- **Excel Export**: Manual CSV (less user-friendly, no .xlsx formatting)
- **Geolocation**: Manual Android code (less portable, more error-prone)

### Decisions

- Use Riverpod for state unless team prefers Bloc.
- Use Supabase RBAC and PostgreSQL for all data/auth.
- Use geolocator for GPS.
- Use syncfusion_flutter_xlsio for Excel export.
- All widgets/components must be reusable and stateless.
- All RBAC enforced at both backend and app logic.
