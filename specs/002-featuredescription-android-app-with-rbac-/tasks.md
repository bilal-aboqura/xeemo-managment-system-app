---

description: "Task list for Android RBAC Sales App implementation"
---

# Tasks: Android RBAC Sales App

**Input**: Design documents from `/specs/002-featuredescription-android-app-with-rbac-worker-can-log-in-create-sales-ticket-client-name-phone-notes-sale-amount-select-products-submit-to-db-manager-can-log-in-view-all-tickets-export-as-excel-roles-worker-manager/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create Flutter project structure in app/
- [X] T002 Initialize pubspec.yaml with dependencies: riverpod, supabase_flutter, geolocator, syncfusion_flutter_xlsio, material, etc.
- [X] T003 [P] Configure linting and formatting (flutter_lints, analysis_options.yaml)
- [ ] T004 [P] Setup GitHub Actions or CI for Flutter

---


## Phase 2: Foundational (Blocking Prerequisites)


**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [ ] T005 Setup Supabase project and configure PostgreSQL tables (profiles, products, tickets)
- [ ] T006 [P] Implement Supabase RBAC policies for Worker/Manager roles
- [X] T007 [P] Create base models: User, Product, SalesTicket in app/lib/models/
- [X] T008 Setup Riverpod providers for auth, products, tickets in app/lib/services/
- [X] T008a Implement Email/Password Authentication: LoginScreen and Supabase Auth logic in app/lib/screens/login_screen.dart and app/lib/services/auth_service.dart
- [X] T009 Configure error handling and logging in app/lib/services/
- [X] T010 Setup environment config management (Supabase keys, etc.)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---


## Phase 2b: Offline Support (Blocking for Ticket Submission)

**Purpose**: Ensure tickets can be created offline and synced when online.

- [X] T010a Implement local ticket queue using Hive or SQLite in app/lib/services/ticket_queue_service.dart
- [X] T010b Implement background sync service to retry ticket submission when online in app/lib/services/ticket_sync_service.dart


**Goal**: Worker can log in, create a sales ticket with all required fields, select products, capture location, and submit to DB.

**Independent Test**: Log in as Worker, create ticket, select products, capture location, submit, and verify ticket in DB.

### Implementation for User Story 1

- [X] T011 [P] [US1] Create SalesTicketForm widget in app/lib/widgets/sales_ticket_form.dart
- [X] T012 [P] [US1] Create ProductSelector widget in app/lib/widgets/product_selector.dart
- [X] T013 [P] [US1] Implement geolocation capture with permission handling in app/lib/services/geolocation_service.dart
- [X] T014 [US1] Implement ticket submission logic in app/lib/services/ticket_service.dart
- [X] T015 [US1] Integrate form, product selector, and geolocation in app/lib/screens/create_ticket_screen.dart
- [X] T016 [US1] Add offline queueing for ticket submission in app/lib/services/ticket_service.dart
- [X] T017 [US1] Add validation and error handling for all ticket fields
- [X] T018 [US1] Add logging for ticket creation events

**Checkpoint**: User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Manager: Product Management (Priority: P2)

**Goal**: Manager can add, edit, and delete products. Changes are reflected in Worker product list.

**Independent Test**: Log in as Manager, add/edit/delete products, verify changes for Workers.


### Validation & Data Integrity for User Story 2

- [ ] T022a Prevent deletion of Product if referenced by any Ticket (backend constraint or logic)
- [ ] T022b Enforce unique Product names (backend and UI validation)

- [X] T019 [P] [US2] Create ProductManagementScreen in app/lib/screens/product_management_screen.dart
- [X] T020 [P] [US2] Implement add/edit/delete product logic in app/lib/services/product_service.dart
- [X] T021 [US2] Add real-time sync for product list in app/lib/services/product_service.dart
- [X] T022 [US2] Add validation and error handling for product CRUD
- [X] T023 [US2] Add logging for product management events

**Checkpoint**: User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Manager: View & Export Tickets (Priority: P3)

**Goal**: Manager can view all tickets and export to Excel.

**Independent Test**: Log in as Manager, view dashboard, export tickets, verify Excel file.

### Implementation for User Story 3

- [X] T024 [P] [US3] Create TicketsDashboardScreen in app/lib/screens/tickets_dashboard_screen.dart
- [X] T025 [P] [US3] Implement ticket export to Excel in app/lib/services/export_service.dart
- [X] T026 [US3] Add validation and error handling for export
- [X] T027 [US3] Add logging for export events

**Checkpoint**: All user stories should now be independently functional

---


## Phase N-1: Constitution Architecture Review

**Purpose**: Explicitly verify Clean Architecture, Separation of Concerns, and RBAC compliance before final delivery.

- [ ] T034 [P] Architecture Review: Verify UI/Logic Separation in app/lib/screens/ and app/lib/services/
- [ ] T035 [P] Architecture Review: Security audit of RBAC implementation (roles, policies, endpoints)
- [ ] T036 [P] Architecture Review: Clean Architecture compliance (domain/service/widget boundaries)

**Purpose**: Improvements that affect multiple user stories

- [ ] T028 [P] Add/Update documentation in app/docs/
- [ ] T029 Code cleanup and refactoring
- [ ] T030 Performance optimization across all stories
- [ ] T031 [P] Add additional unit/integration tests in app/test/
- [ ] T032 Security hardening (review RBAC, input validation)
- [ ] T033 Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies
- Setup (Phase 1): No dependencies
- Foundational (Phase 2): Depends on Setup completion - BLOCKS all user stories
- User Stories (Phase 3+): All depend on Foundational phase completion
- Polish (Final Phase): Depends on all user stories being complete

### User Story Dependencies
- US1: Can start after Foundational (no dependencies)
- US2: Can start after Foundational (independent, but integrates with US1 product list)
- US3: Can start after Foundational (independent, but integrates with US1 ticket data)

### Parallel Execution Examples
- All [P] tasks can run in parallel (different files, no dependencies)
- User stories can be implemented in parallel after Foundational phase
- Models, widgets, and services for each story can be developed/tested in parallel

## Implementation Strategy
- MVP: Complete Setup, Foundational, and User Story 1
- Incremental: Add User Story 2, then 3, each independently testable
- Parallel: Multiple devs can work on different user stories or [P] tasks
