-- Turni Team Helpdesk: schema e permessi Supabase
-- IMPORTANTE: crea prima il tuo utente in Supabase > Authentication > Users.
-- Sostituisci OGNI occorrenza di ADMIN_USER_UUID con il suo User UID (UUID).
-- Esegui questo script nel SQL Editor del progetto.

create table if not exists public.employees (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.shifts (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references public.employees(id) on delete cascade,
  shift_date date not null,
  shift_type text not null check (shift_type in ('Mattina','Pomeriggio','Notte','Riposo','Ferie','Malattia')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint one_shift_per_employee_day unique (employee_id, shift_date)
);

alter table public.employees enable row level security;
alter table public.shifts enable row level security;

-- Rimuove eventuali grants preesistenti e concede solo ciò che serve.
revoke all on table public.employees from anon, authenticated;
revoke all on table public.shifts from anon, authenticated;

grant select on table public.employees to anon, authenticated;
grant select on table public.shifts to anon, authenticated;
grant insert, update, delete on table public.employees to authenticated;
grant insert, update, delete on table public.shifts to authenticated;

drop policy if exists "Public can view active employees" on public.employees;
create policy "Public can view active employees"
on public.employees for select to anon, authenticated
using (active = true);

drop policy if exists "Admin can insert employees" on public.employees;
create policy "Admin can insert employees"
on public.employees for insert to authenticated
with check ((select auth.uid()) = 'ADMIN_USER_UUID'::uuid);

drop policy if exists "Admin can update employees" on public.employees;
create policy "Admin can update employees"
on public.employees for update to authenticated
using ((select auth.uid()) = 'ADMIN_USER_UUID'::uuid)
with check ((select auth.uid()) = 'ADMIN_USER_UUID'::uuid);

drop policy if exists "Admin can delete employees" on public.employees;
create policy "Admin can delete employees"
on public.employees for delete to authenticated
using ((select auth.uid()) = 'ADMIN_USER_UUID'::uuid);

drop policy if exists "Public can view shifts" on public.shifts;
create policy "Public can view shifts"
on public.shifts for select to anon, authenticated
using (true);

drop policy if exists "Admin can insert shifts" on public.shifts;
create policy "Admin can insert shifts"
on public.shifts for insert to authenticated
with check ((select auth.uid()) = 'ADMIN_USER_UUID'::uuid);

drop policy if exists "Admin can update shifts" on public.shifts;
create policy "Admin can update shifts"
on public.shifts for update to authenticated
using ((select auth.uid()) = 'ADMIN_USER_UUID'::uuid)
with check ((select auth.uid()) = 'ADMIN_USER_UUID'::uuid);

drop policy if exists "Admin can delete shifts" on public.shifts;
create policy "Admin can delete shifts"
on public.shifts for delete to authenticated
using ((select auth.uid()) = 'ADMIN_USER_UUID'::uuid);

-- Non assegnare mai la chiave service_role al sito pubblico.
