-- 1. Add avatar_url to student_profiles
ALTER TABLE student_profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 2. Add avatar_url to admin_profiles (optional but good practice)
ALTER TABLE admin_profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 3. Create the 'avatars' storage bucket (if using Supabase Storage)
insert into storage.buckets (id, name, public) 
values ('avatars', 'avatars', true) 
on conflict (id) do nothing;

-- 4. Set up storage policies to allow authenticated users to upload and anyone to read
create policy "Avatar images are publicly accessible."
  on storage.objects for select
  using ( bucket_id = 'avatars' );

create policy "Anyone can upload an avatar."
  on storage.objects for insert
  with check ( bucket_id = 'avatars' );

create policy "Anyone can update an avatar."
  on storage.objects for update
  with check ( bucket_id = 'avatars' );
