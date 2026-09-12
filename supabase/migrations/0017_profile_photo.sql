-- =============================================================================
-- A patient can put a photograph on their own profile.
--
-- The column is new; the bucket is the second one this project keeps, after
-- banners, and its rules are the opposite shape: banners are written by one
-- administrator and read by everyone, while these are written by many people
-- who must each be confined to their own.
--
-- That confinement is the whole of the storage policy: the first folder of the
-- object's path has to be the writer's own user id. Without it any signed-in
-- patient could overwrite anybody's photograph, since one bucket is one
-- namespace.
--
-- Safe to re-run.
-- =============================================================================

alter table public.profiles add column if not exists image text;

comment on column public.profiles.image is
  'Public URL of the patient''s own photograph, or null. Written by the app '
  'after an upload to the avatars bucket.';

do $$
begin
  if to_regclass('storage.buckets') is null then
    raise notice 'storage schema not present -- skipping bucket setup';
    return;
  end if;

  -- public: a photograph is shown wherever the patient's own name is, so it is
  -- served straight from the CDN rather than through a signed URL per view.
  insert into storage.buckets (id, name, public)
  values ('avatars', 'avatars', true)
  on conflict (id) do nothing;

  -- foldername(name) splits the path; [1] is the first folder. Requiring it to
  -- be the caller's own id is what keeps one patient out of another's files.
  execute 'drop policy if exists avatars_insert_own on storage.objects';
  execute $p$
    create policy avatars_insert_own on storage.objects
      for insert to authenticated
      with check (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = auth.uid()::text
      )
  $p$;

  -- Replacing a photograph is an update when the path is reused.
  execute 'drop policy if exists avatars_update_own on storage.objects';
  execute $p$
    create policy avatars_update_own on storage.objects
      for update to authenticated
      using (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = auth.uid()::text
      )
      with check (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = auth.uid()::text
      )
  $p$;

  execute 'drop policy if exists avatars_delete_own on storage.objects';
  execute $p$
    create policy avatars_delete_own on storage.objects
      for delete to authenticated
      using (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = auth.uid()::text
      )
  $p$;
end $$;
