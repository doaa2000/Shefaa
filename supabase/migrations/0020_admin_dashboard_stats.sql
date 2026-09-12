-- =============================================================================
-- The admin panel's home page was showing invented numbers.
--
-- It calls admin_dashboard_stats, which was never written, and the repository
-- falls back to the seed figures when the call fails -- silently. So the front
-- page of the panel read 1,437 bookings, 3,219 patients and EGP 684,500 of
-- revenue, none of which had ever happened, with nothing on screen to say so.
--
-- That is worse than a page that breaks. A broken page is obviously broken; a
-- page of confident numbers that are fiction is believed, and decisions get
-- made on it.
--
-- Everything below is counted from bookings, payments, profiles and the
-- location tree. The trend is by booking month, so a month with no bookings
-- appears as a zero rather than as a gap in the line.
--
-- Safe to re-run.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Two small helpers the figures below lean on.
-- -----------------------------------------------------------------------------

-- Growth from one month to the next, as a percentage rounded to one place.
--
-- A month with nothing before it reports 0 rather than an infinite jump: the
-- first month a clinic runs is not infinite growth, and a chart cannot draw it.
create or replace function public.month_over_month(
  p_current  numeric,
  p_previous numeric
)
returns numeric
language sql
immutable
as $$
  select case
    when coalesce(p_previous, 0) = 0 then 0
    else round(((coalesce(p_current, 0) - p_previous) / p_previous) * 100, 1)
  end;
$$;

-- Month names in Arabic, by number. A lookup rather than a locale, because the
-- database's locales are not something this app should depend on being set.
create or replace function public.arabic_month(p_month integer)
returns text
language sql
immutable
as $$
  select (array[
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ])[greatest(least(p_month, 12), 1)];
$$;

create or replace function public.admin_dashboard_stats()
returns json
language plpgsql
stable
-- definer: the figures span every doctor and every patient, which no single
-- caller's policies would show them. Guarded by is_admin() in the body, so
-- being able to call it is not the same as being allowed to read it.
security definer
set search_path = public
as $$
declare
  v_month_start date := date_trunc('month', current_date)::date;
  v_prev_start  date := (date_trunc('month', current_date) - interval '1 month')::date;
begin
  if not public.is_admin() then
    raise exception 'Administrators only'
      using errcode = 'insufficient_privilege', hint = 'not_an_admin';
  end if;

  return json_build_object(
    'bookings', json_build_object(
      'value', (select count(*) from public.bookings where status <> 'cancelled'),
      -- Growth against last month, as a percentage. Null months are zero, and
      -- a first month with nothing before it shows no growth rather than an
      -- infinite jump.
      'trend', public.month_over_month(
        (select count(*) from public.bookings
          where status <> 'cancelled' and booked_date >= v_month_start),
        (select count(*) from public.bookings
          where status <> 'cancelled'
            and booked_date >= v_prev_start and booked_date < v_month_start)
      )
    ),
    'doctors', json_build_object(
      'value', (select count(*) from public."Doctors" where status = 'active'),
      -- Doctors are added by hand and rarely; a month-on-month percentage on a
      -- number that moves once a quarter is noise, so it stays at zero.
      'trend', 0
    ),
    'revenue', json_build_object(
      'value', coalesce((select sum(amount) from public.payments where status = 'paid'), 0),
      'trend', public.month_over_month(
        coalesce((select sum(p.amount) from public.payments p
          where p.status = 'paid' and p.created_at >= v_month_start), 0),
        coalesce((select sum(p.amount) from public.payments p
          where p.status = 'paid'
            and p.created_at >= v_prev_start and p.created_at < v_month_start), 0)
      )
    ),
    'patients', json_build_object(
      -- Everyone with an account, whether or not they have booked yet: this is
      -- the panel's count of its own users.
      'value', (select count(*) from public.profiles),
      'trend', public.month_over_month(
        (select count(*) from public.profiles where created_at >= v_month_start),
        (select count(*) from public.profiles
          where created_at >= v_prev_start and created_at < v_month_start)
      )
    ),
    'trend', (
      select json_build_object(
        'monthsEn', coalesce(json_agg(to_char(m.month, 'Mon') order by m.month), '[]'::json),
        'monthsAr', coalesce(json_agg(public.arabic_month(
          extract(month from m.month)::integer) order by m.month), '[]'::json),
        'values', coalesce(json_agg(m.total order by m.month), '[]'::json)
      )
      from (
        select g.month::date as month,
               (select count(*) from public.bookings b
                 where b.status <> 'cancelled'
                   and b.booked_date >= g.month::date
                   and b.booked_date < (g.month + interval '1 month')::date) as total
          from generate_series(
            date_trunc('month', current_date) - interval '5 months',
            date_trunc('month', current_date),
            interval '1 month'
          ) as g(month)
      ) m
    ),
    'byCity', coalesce((
      select json_agg(row_to_json(c) order by c.value desc)
        from (
          select g.name as en, g.name as ar, count(b.id)::integer as value
            from public."Governorates" g
            join public."Cities" ci on ci.governorate_id = g.id
            join public."Clinics" cl on cl.city_id = ci.id
            join public."Doctors" d on d.clinic_id = cl.id
            join public.bookings b on b.doctor_id = d.id and b.status <> 'cancelled'
           group by g.id, g.name
          having count(b.id) > 0
           order by count(b.id) desc
           limit 6
        ) c
    ), '[]'::json)
  );
end;
$$;

revoke execute on function public.admin_dashboard_stats() from public;
grant execute on function public.admin_dashboard_stats() to authenticated;
