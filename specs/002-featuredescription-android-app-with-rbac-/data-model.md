# data-model.md

## Entities

### User (profiles)
- user_id: UUID (PK)
- name: String
- role: Enum ('worker', 'manager')
- email: String (unique)
- password_hash: String (Supabase managed)

### Product (products)
- product_id: UUID (PK)
- name: String (unique)
- price: Decimal
- details: String

### Sales Ticket (tickets)
- ticket_id: UUID (PK)
- client_name: String
- client_phone: String
- worker_notes: String
- client_notes: String
- sale_amount: Decimal
- worker_id: UUID (FK to profiles)
- created_at: Timestamp
- latitude: Double
- longitude: Double

### TicketProduct (junction table, if needed for quantities)
- ticket_id: UUID (FK)
- product_id: UUID (FK)
- quantity: Int

## Relationships
- User (worker) 1--* Sales Ticket
- Product *--* Sales Ticket (via TicketProduct)
- Manager can CRUD Products
- Worker can create Tickets, select Products

## Validation Rules
- Product name must be unique
- All ticket fields required except client_notes
- Latitude/Longitude required for ticket
- Sale amount must be >= 0
- Email must be unique

## State Transitions
- Ticket: draft (local) → submitted (DB)
- Product: active → edited/deleted (by manager)
- User: registered → active
