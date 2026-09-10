-- =============================================================================
-- Shefaa — reference data seed.
--
-- Rebuilds the master data that was lost: specialties, the governorate → city →
-- clinic tree, doctors, and bookable slots for the next 14 days.
--
-- Ported from Shefaa_Admin_Panel/src/infrastructure/seed/seed-data.ts, which is
-- the design's own data and the only surviving copy of this content.
--
-- Run AFTER migrations/0000_base_schema.sql. Safe to re-run: every insert is
-- `on conflict do nothing`, and the identity sequences are re-synced at the end.
--
-- NOT seeded on purpose:
--   * patients  — a profile row must match a real auth.users id. Restore those
--                 from auth.users instead (see the query at the bottom).
--   * bookings / payments — transactional history. Seeding fake rows here would
--                 put invented revenue on the admin dashboard.
-- =============================================================================

begin;

-- ---------- Governorates -----------------------------------------------------
insert into public."Governorates" (id, name) values
  (1, 'القاهرة'),
  (2, 'الجيزة'),
  (3, 'الإسكندرية'),
  (4, 'الدقهلية')
on conflict (id) do nothing;

-- ---------- Cities -----------------------------------------------------------
insert into public."Cities" (id, governorate_id, name) values
  (1, 1, 'مدينة نصر'),
  (2, 1, 'المعادي'),
  (3, 1, 'مصر الجديدة'),
  (4, 2, 'الدقي'),
  (5, 2, '٦ أكتوبر'),
  (6, 3, 'سموحة'),
  (7, 3, 'سيدي جابر'),
  (8, 4, 'المنصورة')
on conflict (id) do nothing;

-- ---------- Clinics ----------------------------------------------------------
insert into public."Clinics" (id, city_id, name) values
  (1,  1, 'مركز شفاء للقلب'),
  (2,  1, 'برج نصر الطبي'),
  (3,  2, 'عيادة المعادي للأسرة'),
  (4,  3, 'عيادة الكوربة التخصصية'),
  (5,  4, 'استوديو الدقي للأسنان'),
  (6,  5, 'مستشفى أكتوبر كير'),
  (7,  5, 'عيادات الشيخ زايد'),
  (8,  6, 'مركز سموحة للعيون'),
  (9,  7, 'عيادة الكورنيش للجلدية'),
  (10, 8, 'عيادة المنصورة للأطفال')
on conflict (id) do nothing;

-- ---------- Specialties ------------------------------------------------------
-- NOTE: the app renders `specialties.name` directly and its locale is fixed to
-- Arabic, so `name` holds the Arabic label. Migration 001 later added `name_ar`
-- for the admin panel; both are filled with the same value here. If you ever
-- switch `name` to English, update SpecialtyModel/the grid at the same time.
insert into public.specialties (id, name, name_ar, icon, color, base_fee, description) values
  (1,  'أمراض القلب',          'أمراض القلب',          'heart',      '#D6533F', 700, 'تشخيص وعلاج أمراض القلب والأوعية الدموية.'),
  (2,  'الجلدية',              'الجلدية',              'sparkle',    '#C98A1E', 500, 'العناية بأمراض الجلد والشعر والأظافر.'),
  (3,  'طب الأطفال',           'طب الأطفال',           'baby',       '#67B2D8', 450, 'الرعاية الطبية للرضع والأطفال والمراهقين.'),
  (4,  'العظام',               'العظام',               'bone',       '#5A8FB0', 550, 'رعاية العظام والمفاصل والأربطة والجهاز الحركي.'),
  (5,  'الأسنان',              'الأسنان',              'tooth',      '#7B6FCB', 500, 'صحة الفم وعلاج الأسنان وتجميلها.'),
  (6,  'المخ والأعصاب',        'المخ والأعصاب',        'brain',      '#9B7BC9', 650, 'اضطرابات المخ والعمود الفقري والجهاز العصبي.'),
  (7,  'النساء والتوليد',      'النساء والتوليد',      'heart',      '#D67BA0', 600, 'صحة المرأة الإنجابية ورعاية الحمل.'),
  (8,  'العيون',               'العيون',               'eye',        '#4A93BC', 500, 'فحص العيون والنظر والجراحة.'),
  (9,  'الأنف والأذن والحنجرة','الأنف والأذن والحنجرة','ear',        '#2E9E73', 450, 'تشخيص وعلاج الأنف والأذن والحنجرة.'),
  (10, 'الطب النفسي',          'الطب النفسي',          'brain',      '#6B7785', 600, 'تقييم الصحة النفسية والعلاج النفسي.')
on conflict (id) do nothing;

-- ---------- Doctors ----------------------------------------------------------
insert into public."Doctors"
  (id, name, specialization, specialty_id, clinic_id, consultation_fee, location, waiting_time, rating, status) values
  (1,  'د. أحمد السيد',   'أمراض القلب',           1,  1,  700, 'مركز شفاء للقلب - مدينة نصر',        20, 4.8, 'active'),
  (2,  'د. منى خليل',     'الجلدية',               2,  9,  600, 'عيادة الكورنيش للجلدية - سيدي جابر', 15, 4.6, 'active'),
  (3,  'د. طارق منصور',   'طب الأطفال',            3,  10, 450, 'عيادة المنصورة للأطفال - المنصورة',  25, 4.7, 'active'),
  (4,  'د. هناء فوزي',    'العظام',                4,  6,  550, 'مستشفى أكتوبر كير - ٦ أكتوبر',       30, 4.5, 'active'),
  (5,  'د. عمر سليم',     'الأسنان',               5,  5,  500, 'استوديو الدقي للأسنان - الدقي',      20, 4.9, 'active'),
  (6,  'د. نور عادل',     'المخ والأعصاب',         6,  4,  650, 'عيادة الكوربة التخصصية - مصر الجديدة',35, 4.4, 'inactive'),
  (7,  'د. ياسمين سعد',   'النساء والتوليد',       7,  3,  600, 'عيادة المعادي للأسرة - المعادي',     25, 4.8, 'active'),
  (8,  'د. خالد رشاد',    'العيون',                8,  8,  500, 'مركز سموحة للعيون - سموحة',          15, 4.6, 'active'),
  (9,  'د. سلمى جمال',    'الأنف والأذن والحنجرة', 9,  4,  450, 'عيادة الكوربة التخصصية - مصر الجديدة',20, 4.5, 'active'),
  (10, 'د. حسام نبيل',    'الطب النفسي',           10, 1,  800, 'مركز شفاء للقلب - مدينة نصر',        45, 4.9, 'active'),
  (11, 'د. دينا عزيز',    'الجلدية',               2,  9,  600, 'عيادة الكورنيش للجلدية - سيدي جابر', 20, 4.3, 'inactive'),
  (12, 'د. شريف لطفي',    'أمراض القلب',           1,  2,  750, 'برج نصر الطبي - مدينة نصر',          30, 4.7, 'active'),
  (13, 'د. رنا وائل',     'النساء والتوليد',       7,  3,  600, 'عيادة المعادي للأسرة - المعادي',     25, 4.8, 'active'),
  (14, 'د. كريم فؤاد',    'العظام',                4,  6,  520, 'مستشفى أكتوبر كير - ٦ أكتوبر',       30, 4.5, 'active')
on conflict (id) do nothing;

-- ---------- Bookable slots ---------------------------------------------------
-- 30-minute slots for the next 14 days, for every active doctor:
--   morning  09:00 → 13:00
--   evening  17:00 → 21:00
-- Fridays are skipped. This is what makes the booking flow testable end to end.
insert into public.doctor_availability (doctor_id, date, start_time, end_time, session, is_active)
select
  d.id,
  day::date,
  slot,
  slot + interval '30 minutes',
  case when slot < time '13:00' then 'morning' else 'evening' end,
  true
from public."Doctors" d
cross join generate_series(current_date, current_date + 13, interval '1 day') as day
cross join (
  select (time '09:00' + (n * interval '30 minutes')) as slot
  from generate_series(0, 7) as n            -- 09:00 .. 12:30
  union all
  select (time '17:00' + (n * interval '30 minutes'))
  from generate_series(0, 7) as n            -- 17:00 .. 20:30
) as slots
where d.status = 'active'
  and extract(dow from day) <> 5             -- 5 = Friday
on conflict (doctor_id, date, start_time) do nothing;

-- ---------- Re-sync the identity sequences -----------------------------------
-- Explicit ids above bypass the sequences; without this the next INSERT that
-- relies on the default would collide with an id we just used.
select setval(pg_get_serial_sequence('public."Governorates"', 'id'),
              coalesce((select max(id) from public."Governorates"), 1), true);
select setval(pg_get_serial_sequence('public."Cities"', 'id'),
              coalesce((select max(id) from public."Cities"), 1), true);
select setval(pg_get_serial_sequence('public."Clinics"', 'id'),
              coalesce((select max(id) from public."Clinics"), 1), true);
select setval(pg_get_serial_sequence('public.specialties', 'id'),
              coalesce((select max(id) from public.specialties), 1), true);
select setval(pg_get_serial_sequence('public."Doctors"', 'id'),
              coalesce((select max(id) from public."Doctors"), 1), true);

commit;

-- =============================================================================
-- AFTERWARDS — restore the patient profiles from the surviving auth accounts.
--
-- auth.users lives in the `auth` schema, so a DELETE against the `public`
-- tables does not touch it. Check first:
--
--     select count(*) from auth.users;
--
-- If that returns your users, rebuild their profile rows:
--
--     insert into public.profiles (id, name)
--     select id, coalesce(raw_user_meta_data ->> 'name', split_part(email, '@', 1))
--     from auth.users
--     on conflict (id) do nothing;
--
-- Names/phones the users typed in are gone, but the accounts keep working and
-- the app stops erroring on a missing profile row.
-- =============================================================================
