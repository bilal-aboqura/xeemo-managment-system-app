# Research: Account Creation & Worker Analytics (Xeemo Management System)

## Remaining Unknowns / Clarifications Needed

- Supabase schema for RBAC (roles, permissions, user linkage)
- Onboarding flow for new accounts (email notification, password delivery/reset)
- Analytics data model: what events/metrics are tracked, how are they aggregated?
- Error handling and user feedback for account creation and analytics loading
- Handling of large analytics data sets (pagination, lazy loading, aggregation)
- Localization and accessibility requirements for analytics UI
- Security: password reset, account lockout, audit logging

## Best Practices by Dependency

### Flutter
- Use Clean Architecture: separate UI (widgets), business logic (services), and data (models)
- Use Provider for state management; keep logic out of widgets
- Responsive layouts: use MediaQuery, LayoutBuilder, and flexible widgets
- Reusable widgets for analytics cards, charts, and forms
- Test UI and logic separately (flutter_test, integration_test)

### Supabase
- Use Row Level Security (RLS) for RBAC enforcement
- Store roles in a dedicated column or join table
- Use secure password hashing (Supabase handles this by default)
- Use triggers or functions for audit logging (account creation, analytics access)
- Use PostgREST for custom analytics queries if needed

### Provider
- Use ChangeNotifier for simple state, or Riverpod for more complex flows
- Keep Provider trees shallow; avoid deeply nested providers
- Use selectors to optimize rebuilds

### fl_chart
- Use line charts for trends, bar charts for comparisons, pie charts for distributions
- Make charts interactive (tooltips, zoom, pan) for professional UX
- Use async data loading and show loading indicators
- Ensure charts are responsive and accessible

## Analytics Integration Patterns
- Use date pickers and pre-set ranges for filtering (today, week, month, custom)
- For large data sets, aggregate on the backend and paginate results
- Use async/await and FutureBuilder/StreamBuilder for data loading
- Cache analytics data where possible to reduce load times
- Use skeleton loaders or shimmer effects for loading states

## Major Design/Tech Choices

### Decision: Flutter + Supabase + Provider + fl_chart
- **Rationale**: Cross-platform, strong ecosystem, rapid UI, built-in auth/storage, good charting
- **Alternatives**: Firebase (less SQL power), Bloc (more boilerplate), charts_flutter (less flexible)

### Decision: RBAC with 3 roles (Worker, Manager, Super Manager)
- **Rationale**: Clear separation of duties, scalable, secure
- **Alternatives**: 2 roles (less flexible), custom roles (more complex)

### Decision: Passwords set by super manager, 8+ chars, 1 upper, 1 lower, 1 number
- **Rationale**: Security, compliance, user onboarding control
- **Alternatives**: User sets password (less control), magic link (less secure)

### Decision: Analytics dashboard with line/bar/pie charts, date filtering, custom ranges
- **Rationale**: Professional UX, actionable insights, flexible reporting
- **Alternatives**: Table-only (less visual), static reports (less interactive)

---

This research file should be updated as new questions or technology choices arise during implementation.
