# Data Model: Account Creation & Worker Analytics

## Entities

### User
- id: UUID
- name: String
- email: String (unique)
- password_hash: String
- role: Enum (Worker, Manager, Super Manager)
- created_at: Timestamp
- status: Enum (Active, Inactive, Locked)

### ManagerAssignment
- id: UUID
- manager_id: UUID (User, role=Manager)
- worker_id: UUID (User, role=Worker)
- assigned_area: String
- assigned_at: Timestamp

### WorkerAnalytics
- id: UUID
- worker_id: UUID (User, role=Worker)
- date: Date
- task_completion_rate: Float
- activity_hours: Float
- productivity_score: Float
- login_frequency: Int
- task_types_breakdown: JSON
- engagement_metrics: JSON
- performance_trends: JSON
- created_at: Timestamp

### DateRangeFilter
- start_date: Date
- end_date: Date
- filter_type: Enum (Preset, Custom)

## Relationships
- User (Manager) 1---* ManagerAssignment *---1 User (Worker)
- User (Worker) 1---* WorkerAnalytics

## Validation Rules
- Email must be unique and valid format
- Password must be 8+ chars, 1 upper, 1 lower, 1 number (enforced on creation)
- Role must be one of: Worker, Manager, Super Manager
- Date ranges must not include future dates; end >= start

## State Transitions
- User: [Created] → [Active] → [Inactive/Locked]
- ManagerAssignment: [Created] → [Active] → [Revoked]
- WorkerAnalytics: [Created] (immutable)
