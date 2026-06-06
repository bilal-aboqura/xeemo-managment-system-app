-- Drop the existing tables (CASCADE allows dropping tickets even if ticket_products depends on it)
DROP TABLE IF EXISTS public.tickets CASCADE;
DROP TABLE IF EXISTS public.ticket_products CASCADE; -- We are moving products to a JSON column in tickets, so we can drop this.

-- Create the new tickets table with all columns
create table public.tickets (
  ticket_id text not null primary key, -- Changed to text to match your UUID string usage
  client_name text not null,
  client_phone text not null,
  laundry_name text default '',
  worker_notes text default '',
  client_notes text default '',
  sale_amount numeric not null,
  worker_id text not null, -- Changed to text to match your UUID string usage
  worker_name text default '',
  latitude double precision not null default 0.0,
  longitude double precision not null default 0.0,
  created_at timestamp with time zone not null default timezone('utc'::text, now()),
  status text not null default 'draft',
  products jsonb not null default '[]'::jsonb
);

-- Enable RLS (Row Level Security) is recommended, but you can turn it off for development if needed
alter table public.tickets enable row level security;

-- Allow public access for now (or configure specific policies)
create policy "Enable all access for all users" on public.tickets for all using (true) with check (true);
