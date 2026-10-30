-- Indus Content Desk: database setup
-- Run once in Supabase: SQL Editor > New query > paste > Run.

create table if not exists public.posts (
  id               text primary key,          -- the post date, e.g. 2026-11-04
  date             date not null,
  day              text,
  week             text,
  tier             text check (tier in ('MUST','SHOULD','NICE')),
  pillar           text,
  series           text,
  title            text not null,
  format           text,
  flow             text,
  caption          text,
  cta              text,
  stories          text,
  pages            text,
  assets           text,
  lock             text,
  prod_deadline    date,
  sched_deadline   date,
  plan_notes       text,
  status           text not null default 'Not Started'
                   check (status in ('Not Started','Briefing','In Production','For Review','Approved','Scheduled','Published','Dropped')),
  owner            text default '',
  notes            text default '',
  updated_by_email text default '',
  updated_at       timestamptz
);

-- Stamp who changed a post and when. The browser cannot fake this.
create or replace function public.stamp_post_update()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  new.updated_at := now();
  new.updated_by_email := coalesce(auth.jwt() ->> 'email', new.updated_by_email);
  return new;
end $$;

drop trigger if exists posts_stamp on public.posts;
create trigger posts_stamp before update on public.posts
for each row execute function public.stamp_post_update();

-- Signed-in team members may only change status, owner and notes.
-- The plan itself (titles, captions, dates) is edited by an admin in the Supabase table editor.
create or replace function public.lock_plan_fields()
returns trigger language plpgsql as $$
begin
  if auth.role() = 'authenticated' then
    if (new.id, new.date, new.title, new.caption, new.flow, new.tier, new.prod_deadline, new.sched_deadline)
       is distinct from (old.id, old.date, old.title, old.caption, old.flow, old.tier, old.prod_deadline, old.sched_deadline) then
      raise exception 'Only status, owner and notes can be changed from the dashboard';
    end if;
  end if;
  return new;
end $$;

drop trigger if exists posts_lock on public.posts;
create trigger posts_lock before update on public.posts
for each row execute function public.lock_plan_fields();

-- Row Level Security: nobody reads or writes without signing in.
alter table public.posts enable row level security;

drop policy if exists "team can read posts" on public.posts;
create policy "team can read posts" on public.posts
  for select to authenticated using (true);

drop policy if exists "team can update posts" on public.posts;
create policy "team can update posts" on public.posts
  for update to authenticated using (true) with check (true);

grant select, update on public.posts to authenticated;

-- No insert or delete policy: the dashboard cannot add or remove posts.

-- Live updates between viewers.
do $$ begin
  alter publication supabase_realtime add table public.posts;
exception when duplicate_object then null; end $$;
