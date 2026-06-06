# Account Creation and Worker Analytics Feature

## Overview

This feature provides comprehensive account management and worker analytics functionality for the Xeemo Management System. It allows super managers to create and manage worker and manager accounts, and view detailed performance analytics for each worker.

## Features

### Account Management

- **Create Worker Accounts**: Super managers can create new worker accounts with name, email, and password validation.
- **Create Manager Accounts**: Super managers can create manager accounts with optional assigned area.
- **View Worker List**: Display all workers with quick access to analytics.
- **View Manager List**: Display all managers with role badges and special styling for super managers.

### Worker Analytics

- **Analytics Dashboard**: Comprehensive analytics view for each worker
- **Visualization Charts**:
  - Line chart for daily sales trends
  - Bar chart for daily ticket counts
  - Pie chart for product breakdown
  - Productivity score gauge
- **Date Range Filtering**:
  - Preset ranges: Today, Yesterday, This Week, Last Week, This Month, Last Month, Last 7/30/90 Days
  - Custom date range picker with validation
- **Trend Analysis**: Shows improvement or decline in performance

## Architecture

### Directory Structure

```
lib/
├── core/
│   ├── router.dart         # App routing configuration
│   ├── theme.dart          # Theme constants
│   ├── localization.dart   # Arabic strings
│   └── error_handler.dart  # Error handling
├── models/
│   ├── user_model.dart             # User entity
│   ├── manager_assignment_model.dart # Manager-worker assignments
│   └── worker_analytics_model.dart  # Analytics data models
├── services/
│   ├── user_service.dart      # Account management
│   ├── analytics_service.dart # Analytics data fetching
│   └── supabase_service.dart  # Database access
├── screens/
│   ├── create_worker_screen.dart           # Worker creation form
│   ├── create_manager_screen.dart          # Manager creation form
│   ├── worker_list_screen.dart             # Worker list view
│   ├── manager_list_screen.dart            # Manager list view
│   └── worker_analytics_detail_screen.dart # Analytics detail view
├── widgets/
│   ├── worker_card.dart      # Reusable worker card
│   └── shared_widgets.dart   # Common UI components
└── providers/
    └── auth_provider.dart    # Authentication state
```

### Data Models

#### User

- `userId`: Unique identifier
- `name`: Full name
- `email`: Email address
- `role`: worker | manager | super_manager
- `createdAt`: Creation timestamp

#### ManagerAssignment

- `id`: Assignment ID
- `managerId`: Manager's user ID
- `workerId`: Worker's user ID
- `assignedArea`: Optional area/region
- `assignedAt`: Assignment timestamp
- `createdBy`: Super manager who created the assignment

#### WorkerAnalyticsSummary

- `workerId`: Worker's ID
- `workerName`: Worker's name
- `dateRange`: Analytics period
- `totalTickets`: Total ticket count
- `totalSales`: Total sales amount
- `averageProductivityScore`: Average productivity (0-100)
- `averageActivityHours`: Average daily activity hours
- `dailyAnalytics`: Daily breakdown
- `productBreakdown`: Product-wise breakdown
- `trend`: Performance trend data

### Services

#### UserService

- `createWorker()`: Create a new worker account
- `createManager()`: Create a new manager account
- `getAllWorkers()`: Fetch all workers
- `getAllManagers()`: Fetch all managers
- `validatePassword()`: Password strength validation
- `validateEmail()`: Email format validation
- `validateName()`: Name validation

#### AnalyticsService

- `getWorkerAnalytics()`: Fetch analytics for a specific worker
- `getAllWorkersAnalytics()`: Fetch analytics for all workers

## Usage

### Creating a Worker Account

```dart
final userService = UserService();
final result = await userService.createWorker(
  name: 'أحمد محمد',
  email: 'ahmed@example.com',
  password: 'SecurePass123',
  createdByUserId: currentUser.userId,
);

result.when(
  success: (user) => print('Created: ${user.name}'),
  failure: (error) => print('Error: ${error.message}'),
);
```

### Fetching Worker Analytics

```dart
final analyticsService = AnalyticsService();
final dateRange = DateRangePreset.last30Days.getDateRange();

final analytics = await analyticsService.getWorkerAnalytics(
  workerId: 'worker-123',
  workerName: 'أحمد',
  dateRange: dateRange,
);

if (analytics != null) {
  print('Total Sales: ${analytics.totalSales}');
  print('Total Tickets: ${analytics.totalTickets}');
}
```

### Custom Date Range

```dart
final customRange = AnalyticsDateRange(
  start: DateTime(2024, 1, 1),
  end: DateTime(2024, 1, 31),
);

final analytics = await analyticsService.getWorkerAnalytics(
  workerId: 'worker-123',
  workerName: 'أحمد',
  dateRange: customRange,
);
```

## Routes

| Route                                | Screen                      | Description           |
| ------------------------------------ | --------------------------- | --------------------- |
| `/worker-list`                       | WorkerListScreen            | List of all workers   |
| `/manager-list`                      | ManagerListScreen           | List of all managers  |
| `/create-worker`                     | CreateWorkerScreen          | Worker creation form  |
| `/create-manager`                    | CreateManagerScreen         | Manager creation form |
| `/worker-analytics-detail/:id/:name` | WorkerAnalyticsDetailScreen | Detailed analytics    |

## Password Requirements

- Minimum 8 characters
- At least 1 uppercase letter (A-Z)
- At least 1 lowercase letter (a-z)
- At least 1 number (0-9)

## Localization

All UI strings are in Arabic. Centralized strings are available in `lib/core/localization.dart`.

## Testing

Run unit tests:

```bash
cd app
flutter test
```

Test files:

- `test/user_service_test.dart`: UserService validation tests
- `test/worker_analytics_model_test.dart`: Analytics model tests
- `test/manager_assignment_model_test.dart`: Assignment model tests

## Dependencies

- `flutter_riverpod`: State management
- `go_router`: Navigation
- `fl_chart`: Charts and visualizations
- `google_fonts`: Typography
- `supabase_flutter`: Backend services
- `intl`: Date formatting
