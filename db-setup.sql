create table if not exists wells (
  lsd text primary key,
  grp text,
  cap numeric,
  rate numeric,
  lat numeric,
  lng numeric,
  tracked boolean default false
);
create table if not exists readings (
  id text primary key,
  lsd text,
  date date,
  hauled numeric,
  remaining numeric
);
alter table wells enable row level security;
alter table readings enable row level security;
drop policy if exists "anon_all_wells" on wells;
drop policy if exists "anon_all_readings" on readings;
drop policy if exists "auth_all_wells" on wells;
drop policy if exists "auth_all_readings" on readings;
create policy "auth_all_wells" on wells for all to authenticated using (true) with check (true);
create policy "auth_all_readings" on readings for all to authenticated using (true) with check (true);

create table if not exists audit_log (
  id bigint generated always as identity primary key,
  at timestamptz default now(),
  user_email text default (auth.jwt() ->> 'email'),
  action text,
  lsd text,
  details jsonb
);
alter table audit_log enable row level security;
drop policy if exists "audit_insert" on audit_log;
drop policy if exists "audit_select" on audit_log;
create policy "audit_insert" on audit_log for insert to authenticated with check (true);
create policy "audit_select" on audit_log for select to authenticated using ((auth.jwt() ->> 'email') = 'PUT_YOUR_LOGIN_EMAIL_HERE');
