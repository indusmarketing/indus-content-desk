# Indus Content Desk

Shared content calendar for the Indus Real Estate marketing team: dashboard, month calendar, drag-and-drop production board and full post briefs. Hosted on GitHub Pages, with sign-in and data in Supabase.

## What's in this repo

- `index.html`: the whole dashboard.
- `config.js`: your Supabase address and public key (you fill this in).
- `supabase/schema.sql`: creates the posts table, sign-in rules and live updates.
- The 44 planned posts are NOT in this repo. They come as a separate file (`indus-seed-posts.sql`) so unreleased launch details never sit in a public repo.

## Setup (about 20 minutes, once)

1. Create the database
   - Go to https://supabase.com, sign up free, click New project. Name it `indus-content-desk`, pick the region closest to Dubai, set a strong database password and save it somewhere safe.
   - When it's ready, open SQL Editor > New query. Paste all of `supabase/schema.sql`, click Run.
   - New query again. Paste all of `indus-seed-posts.sql` (sent separately), click Run. Don't commit that file here. Table Editor > posts should now show 44 rows.

2. Lock sign-ups so only invited people get in
   - Authentication > Sign In / Providers (or Authentication > Settings): turn OFF "Allow new users to sign up". Keep Email enabled.
   - Authentication > Users > Add user > Create new user. Add your email and a password, tick "Auto Confirm User". Do the same for your editor (and your manager if needed).

3. Connect the dashboard
   - Project Settings > API. Copy the Project URL and the `anon` `public` key.
   - In this repo, edit `config.js` and paste them in. Commit.
   - Never paste the `service_role` key anywhere in this repo.

4. Turn on GitHub Pages
   - Repo Settings > Pages > Build and deployment: Source = Deploy from a branch, Branch = `main`, folder = `/ (root)`. Save.
   - After a minute the site is live at `https://indusmarketing.github.io/indus-content-desk/`.
   - Authentication > URL Configuration in Supabase: set Site URL to that address.

5. Test with two people: one changes a post's status, the other should see it update within a few seconds.

## Day-to-day

- Everyone signs in with the email and password the admin created.
- The dashboard can change status, owner and team notes. Titles, captions and dates are changed by the admin in Supabase Table Editor > posts, so the plan can't be edited by accident.
- Add a person: Authentication > Users > Add user. Remove a person: delete them there.
- Free Supabase projects pause after about a week with no activity. If the dashboard stops loading, open the Supabase project and click Restore.

## Security notes

- The page itself is public on GitHub Pages, but it shows nothing until someone signs in, and the database refuses every read and write without a valid login.
- If this repo is public, anyone can read the code and the public key. That is expected and safe with the rules above. Post content lives only in the database, so keep `indus-seed-posts.sql` out of the repo.
