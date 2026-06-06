# Research: Super Manager Account Creation & Analytics Feature

## 1. Remaining Unknowns / Clarifications Needed

- **Onboarding Flows**: Is there a separate onboarding process for workers vs. managers? What information is required at account creation (e.g., name, email, role, department)?
- **Supabase Schema**: Are there existing tables for users, roles, and analytics? How are user-role relationships modeled (single role per user or multi-role)?
- **Analytics Data Model**: What metrics are tracked (e.g., tasks completed, hours worked, sales)? How is data aggregated (daily, weekly, custom)?
- **RBAC Enforcement**: Is RBAC enforced at the API/database level, or only in the app UI? Are there edge cases (e.g., demoting a manager)?
- **Error Handling**: What are the requirements for error feedback (e.g., toast, dialog, inline)? How are Supabase/network errors surfaced?
- **Password Policy Enforcement**: Should password strength be checked client-side, server-side, or both? Is password reset required?
- **Analytics UI**: What chart types are needed (bar, line, pie)? Are there accessibility or theming requirements?
- **Date Filtering**: Should the default range be today, this week, or custom? How are time zones handled?
- **Large Data Sets**: Is pagination or infinite scroll required for analytics tables? Should charts aggregate or sample data?

## 2. Dependency Best Practices

### Flutter (Dart 3.x)
- Use null safety and strong typing throughout.
- Structure code with feature-based folders (e.g., screens, models, providers).
- Use `const` constructors and widgets for performance.
- Apply responsive design (e.g., `LayoutBuilder`, `MediaQuery`) for analytics dashboards.
- Use `intl` for date formatting and localization.

### Supabase (PostgreSQL/Auth)
- Use Supabase Auth for secure user management and RBAC.
- Store roles in a dedicated column or join table; enforce with RLS (Row Level Security) policies.
- Use parameterized queries to prevent SQL injection.
- Store analytics data in normalized tables; use indexes on date/user fields for fast queries.
- Use Supabase Functions (Edge Functions) for complex business logic if needed.

### Provider
- Use `ChangeNotifier` for state management of user sessions, analytics data, and filters.
- Scope providers appropriately (e.g., `ProviderScope` at app root, feature providers at screen level).
- Use selectors to minimize widget rebuilds.
- Dispose providers when not needed to avoid memory leaks.

### fl_chart
- Use `LineChart` and `BarChart` for time-series and categorical analytics.
- Make charts interactive (tooltips, zoom, pan) for professional UX.
- Use custom themes to match app branding.
- Handle empty or loading states gracefully.
- For large data sets, aggregate or sample data before rendering.

## 3. Analytics Integration Patterns

- **Date Filtering**: Use `DateRangePicker` for custom ranges; provide presets (today, week, month).
- **Custom Ranges**: Store start/end dates in provider; update queries and charts reactively.
- **Large Data Sets**: Fetch only required data for the selected range; use server-side aggregation (SQL `GROUP BY`, `COUNT`, etc.).
- **Performance**: Debounce filter changes; cache results where possible.
- **UI**: Show loading indicators during fetch; allow export (CSV, PDF) if needed.

## 4. Major Design/Tech Choices

### 4.1. User Account Creation & RBAC
- **Decision**: Use Supabase Auth with custom roles (Worker, Manager, Super Manager) and enforce RBAC via RLS.
- **Rationale**: Centralizes authentication and authorization; leverages Supabase's secure, scalable backend.
- **Alternatives**: Custom backend with Firebase Auth; manual role checks in Flutter (less secure).

### 4.2. Analytics Dashboard
- **Decision**: Use fl_chart for interactive, responsive charts; aggregate data server-side.
- **Rationale**: fl_chart is well-supported, customizable, and performant for Flutter; server-side aggregation reduces client load.
- **Alternatives**: charts_flutter (less flexible), custom chart widgets (higher maintenance).

### 4.3. State Management
- **Decision**: Use Provider for managing user session, analytics data, and filters.
- **Rationale**: Provider is simple, well-integrated with Flutter, and suitable for medium-complexity apps.
- **Alternatives**: Riverpod (more advanced, but more boilerplate), Bloc (overkill for current scope).

### 4.4. Password Policy Enforcement
- **Decision**: Enforce password policy both client-side (Flutter) and server-side (Supabase function/trigger).
- **Rationale**: Improves UX and security; prevents weak passwords from being set.
- **Alternatives**: Client-side only (less secure), server-side only (worse UX).

### 4.5. Date Filtering & Large Data Handling
- **Decision**: Use date pickers and presets in UI; query Supabase with date filters and aggregation.
- **Rationale**: Efficient for both user and system; minimizes data transfer and processing on client.
- **Alternatives**: Fetch all data and filter client-side (inefficient for large data sets).

---

This research file should be updated as requirements or technology choices evolve.