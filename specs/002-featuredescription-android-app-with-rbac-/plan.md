# Implementation Plan: Android RBAC Sales App

**Branch**: `002-rbac-android-sales` | **Date**: 2026-01-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-featuredescription-android-app-with-rbac-worker-can-log-in-create-sales-ticket-client-name-phone-notes-sale-amount-select-products-submit-to-db-manager-can-log-in-view-all-tickets-export-as-excel-roles-worker-manager/spec.md`

## Summary

This feature delivers an Android application (Flutter) with strict RBAC (Worker/Manager), sales ticket creation with geolocation, product management, and Excel export. Uses Supabase for auth and PostgreSQL, Riverpod/Bloc for state, and Material 3 UI.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.x  
**Primary Dependencies**: Riverpod (flutter_riverpod), Supabase, PostgreSQL, geolocator, syncfusion_flutter_xlsio (or excel), Material Design 3  
**Storage**: Supabase/PostgreSQL (cloud)  
**Testing**: flutter_test, mockito, integration_test  
**Target Platform**: Android (min SDK 21+), optionally iOS  
**Project Type**: mobile  
**Performance Goals**: Ticket creation <3s, dashboard load <2s, Excel export <1min  
**Constraints**: All flows must enforce RBAC, location required for ticket, offline ticket queueing, product list real-time sync  
**Scale/Scope**: 100+ users, 10k+ tickets, 100+ products

## Constitution Check

- Clean Architecture: All business logic in service/domain layers, no logic in UI widgets.
- UI/Logic Separation: Widgets are stateless, all state via Riverpod/Bloc.
- RBAC: All endpoints, UI, and DB access check user role (worker/manager).
- Reusable Widgets: Product selector, ticket form, dashboard, and export button are reusable components.
- Security: Supabase RBAC policies enforced at API and DB level.
- All code reviews must verify these principles.

## Project Structure

### Documentation (this feature)

```
specs/002-featuredescription-android-app-with-rbac-worker-can-log-in-create-sales-ticket-client-name-phone-notes-sale-amount-select-products-submit-to-db-manager-can-log-in-view-all-tickets-export-as-excel-roles-worker-manager/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── checklists/
```

### Source Code (repository root)

```
app/
├── lib/
│   ├── models/
│   ├── services/
│   ├── widgets/
│   ├── screens/
│   └── main.dart
├── test/
│   ├── unit/
│   ├── integration/
│   └── widget/
└── pubspec.yaml
```

**Structure Decision**: Flutter app in /app, with domain-driven folders. All widgets, services, and models are reusable and testable. Backend is Supabase/PostgreSQL, managed via Supabase dashboard. Technical documentation will reside in app/docs/ as referenced in tasks and project structure.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Use of Supabase RBAC | Secure, scalable, managed auth | Custom auth is less secure, more work |
| Riverpod/Bloc | Robust state management | setState is not scalable for RBAC flows |
| Geolocator | High-accuracy, permission handling | Manual location code is error-prone |
| Excel export package | Business reporting | Manual CSV/Excel is not user-friendly |
