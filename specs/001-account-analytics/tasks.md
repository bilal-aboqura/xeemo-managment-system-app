# Tasks: Account Creation and Worker Analytics

**Input**: Design documents from `/specs/001-account-analytics/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Create Flutter project structure and directories per plan.md (lib/models, lib/services, lib/widgets, lib/screens, test/)
- [ ] T002 Initialize Flutter project with dependencies: provider, fl_chart, supabase_flutter, flutter_test, mockito
- [ ] T003 [P] Configure linting and formatting tools (analysis_options.yaml, flutter format)
- [ ] T004 [P] Setup environment configuration for Supabase keys in lib/config/

---

## Phase 2: Foundational (Blocking Prerequisites)

- [ ] T005 Setup Supabase database schema and migrations for User, ManagerAssignment, WorkerAnalytics tables (see data-model.md)
- [ ] T006 [P] Implement authentication and RBAC logic in lib/services/auth_service.dart
- [ ] T007 [P] Setup Provider state management structure in lib/providers/
- [ ] T008 [P] Create base models: User, ManagerAssignment, WorkerAnalytics in lib/models/
- [ ] T009 Configure error handling and logging infrastructure in lib/core/
- [ ] T010 Setup API contract integration for user creation and analytics endpoints (see contracts/openapi.yaml)

---

## Phase 3: User Story 1 - Create Worker Accounts (Priority: P1) 🎯 MVP

**Goal**: Super manager can create worker accounts with required info and password policy
**Independent Test**: Create a worker account and verify login, validation, and error handling

- [ ] T011 [P] [US1] Implement User model and validation in lib/models/user.dart
- [ ] T012 [P] [US1] Implement worker account creation UI in lib/screens/create_worker_screen.dart
- [ ] T013 [P] [US1] Implement worker account creation logic in lib/services/user_service.dart
- [ ] T014 [US1] Add password strength validation (8+ chars, 1 upper, 1 lower, 1 number) in user_service.dart
- [ ] T015 [US1] Add error handling for duplicate email and missing fields in create_worker_screen.dart
- [ ] T016 [US1] Add success/error feedback UI in create_worker_screen.dart
- [x] T017 [US1] Add worker list UI and integration in lib/screens/worker_list_screen.dart
- [x] T018 [US1] Ensure new worker appears in list after creation

---

## Phase 4: User Story 2 - Create Manager Accounts (Priority: P2)

**Goal**: Super manager can create manager accounts with assigned area and password policy
**Independent Test**: Create a manager account and verify permissions and assignment

- [x] T019 [P] [US2] Implement ManagerAssignment model in lib/models/manager_assignment.dart
- [x] T020 [P] [US2] Implement manager account creation UI in lib/screens/create_manager_screen.dart
- [x] T021 [P] [US2] Implement manager account creation logic in lib/services/user_service.dart
- [x] T022 [US2] Add password strength validation for managers in user_service.dart
- [x] T023 [US2] Add error handling for duplicate email and missing fields in create_manager_screen.dart
- [x] T024 [US2] Add success/error feedback UI in create_manager_screen.dart
- [x] T025 [US2] Add manager list UI and integration in lib/screens/manager_list_screen.dart
- [x] T026 [US2] Ensure new manager appears in list after creation

---

## Phase 5: User Story 3 - View Worker Analytics Details (Priority: P1)

**Goal**: Super manager can view full analytics for any worker
**Independent Test**: Click worker card, see analytics with all metrics and visualizations

- [x] T027 [P] [US3] Implement WorkerAnalytics model in lib/models/worker_analytics.dart
- [x] T028 [P] [US3] Implement analytics data fetching logic in lib/services/analytics_service.dart
- [x] T029 [P] [US3] Implement worker analytics card UI in lib/widgets/worker_card.dart
- [x] T030 [US3] Implement analytics detail screen with charts in lib/screens/worker_analytics_screen.dart
- [x] T031 [US3] Integrate line, bar, and pie charts using fl_chart in worker_analytics_screen.dart
- [x] T032 [US3] Add loading indicator and empty state handling in worker_analytics_screen.dart
- [x] T033 [US3] Preserve scroll position when navigating back to worker list

---

## Phase 6: User Story 4 - Filter Analytics by Specific Date Ranges (Priority: P2)

**Goal**: Super manager can filter analytics by preset date ranges (today, week, month, etc.)
**Independent Test**: Select each range, verify analytics update accordingly

- [x] T034 [P] [US4] Implement date range filter UI (preset options) in worker_analytics_screen.dart
- [x] T035 [P] [US4] Implement logic to fetch and display analytics for selected preset range in analytics_service.dart
- [x] T036 [US4] Ensure analytics update immediately on range change

---

## Phase 7: User Story 5 - Filter Analytics by Custom Date Ranges (Priority: P2)

**Goal**: Super manager can filter analytics by custom start/end dates
**Independent Test**: Select custom range, verify analytics update and validation

- [x] T037 [P] [US5] Implement custom date range picker UI in worker_analytics_screen.dart
- [x] T038 [P] [US5] Implement logic to fetch and display analytics for custom range in analytics_service.dart
- [x] T039 [US5] Add validation for end >= start and no future dates in custom range
- [x] T040 [US5] Ensure analytics update immediately on custom range change

---

## Final Phase: Polish & Cross-Cutting Concerns

- [x] T041 [P] Refactor reusable widgets (cards, forms, charts) into lib/widgets/
- [x] T042 [P] Add localization and accessibility support for analytics UI
- [x] T043 [P] Add integration and unit tests for all services and screens in test/
- [x] T044 [P] Add documentation for setup, usage, and architecture in README.md and docs/
- [x] T045 [P] Review RBAC enforcement and security for all sensitive actions
- [x] T046 [P] Final code review and constitution compliance check

---

## Dependencies

- Phase 2 (Foundational) must be complete before any user story phases
- User Story 1 (Create Worker Accounts) is MVP and can be delivered/tested independently
- User Story 2 (Create Manager Accounts) depends on foundational and can run in parallel with analytics stories
- User Story 3 (View Worker Analytics) can run in parallel with User Story 2 after foundation
- User Story 4 and 5 (Date filtering) depend on analytics detail screen
- Polish phase can run in parallel after all user stories are implemented

## Parallel Execution Examples

- T003, T004 can run in parallel after T002
- T006, T007, T008 can run in parallel after T005
- T011, T012, T013 can run in parallel after foundation
- T019, T020, T021 can run in parallel with analytics tasks (T027, T028, T029)
- T034, T037 can run in parallel after analytics detail screen
- T041-T045 can run in parallel after user stories

## Implementation Strategy

- Deliver MVP with User Story 1 (worker account creation)
- Incrementally add manager accounts, analytics, and filtering
- Refactor and polish after all core flows are complete
