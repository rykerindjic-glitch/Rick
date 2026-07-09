# Production Log — install on your phones

This is a real web app that two (or more) phones share. One database, everyone sees the same board.
Two free accounts: Supabase (the shared database) and Netlify (hosts the app). ~15 minutes.

## STEP 1 — Make the shared database (Supabase)
1. Go to https://supabase.com -> Start your project -> sign in with Google/GitHub.
2. New project. Name it (e.g. "production-log"), set a database password (save it somewhere), pick the closest region, Create. Wait ~2 min.
3. Left sidebar -> SQL Editor -> New query. Paste everything in db-setup.sql, click Run. You should see "Success".
4. Get your key: click the green "Connect" button at the top of the page, or go to Settings -> API Keys. Copy the **Publishable key** (sb_publishable_...) — or the legacy **anon** key (the long eyJ... one) if that's all your project shows. (Your Project URL is already filled into config.js, so you don't need to copy that.)

## STEP 2 — Paste your key into the app
1. Open config.js (in this folder) in any text editor (Notepad is fine).
2. SB_URL is already filled in. Paste your key into SB_KEY, between the quotes, replacing PASTE_YOUR_KEY_HERE. Save.

## STEP 3 — Put it online (Netlify)
1. Go to https://app.netlify.com/drop  (sign in, free).
2. Drag THIS WHOLE FOLDER onto the page. It gives you a link like https://something.netlify.app in a few seconds.
   (That link is your app. You can rename it under Site settings -> Change site name.)

## STEP 4 — Install on each phone
1. Open the netlify.app link in the phone browser (Safari on iPhone, Chrome on Android).
2. iPhone: Share button -> Add to Home Screen. Android: menu (3 dots) -> Add to Home screen / Install app.
3. Tap the new icon. It runs full screen like an app. Do this on both phones — they now share the same data.

## Notes
- The board comes pre-loaded with your 222 wells and recent readings.
- Both phones stay in sync within ~15 seconds (and instantly when you reopen the app).
- No login: anyone with the link can edit. Keep the link to your crew. (We can add a password later.)
- Offline: the app still opens and shows the last data it saw, but logging a haul needs signal.
- To change anything in the app later, just ask me for a new build and re-drag the folder onto Netlify Drop.

## db-setup.sql (also saved as a file in this folder)

```sql
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
```
