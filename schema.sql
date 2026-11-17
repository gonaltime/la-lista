-- La Lista: base de datos para Supabase.
-- Pega todo este archivo en Supabase → SQL Editor → New query → Run.

create table public.items (
  id uuid primary key default gen_random_uuid(),
  list_code text not null check (char_length(list_code) between 16 and 64),
  name text not null check (char_length(name) between 1 and 60),
  qty int not null default 1 check (qty between 1 and 999),
  done boolean not null default false,
  added_by text check (char_length(added_by) <= 30),
  done_by text check (char_length(done_by) <= 30),
  created_at timestamptz not null default now(),
  done_at timestamptz
);
create index items_list_code_idx on public.items(list_code);
alter table public.items enable row level security;
-- Sin políticas a propósito: la tabla solo se usa a través de las funciones de abajo,
-- que exigen el código secreto de la lista (el que va al final del enlace).
revoke all on public.items from anon, authenticated;

create or replace function public.lista_get(p_code text)
returns setof public.items language sql security definer set search_path = public stable as $$
  select * from public.items where list_code = p_code and char_length(p_code) >= 16 order by created_at desc;
$$;

create or replace function public.lista_add(p_code text, p_name text, p_qty int, p_who text, p_id uuid default null, p_done boolean default false, p_done_by text default null, p_created timestamptz default null)
returns public.items language plpgsql security definer set search_path = public as $$
declare r public.items; existing public.items;
begin
  if char_length(p_code) < 16 then raise exception 'bad code'; end if;
  if (select count(*) from public.items where list_code = p_code) >= 300 then raise exception 'list full'; end if;
  -- si ya está apuntado y sin comprar, suma la cantidad
  if p_id is null then
    select * into existing from public.items
      where list_code = p_code and not done and lower(name) = lower(trim(p_name)) limit 1;
    if found then
      update public.items set qty = least(999, qty + greatest(1, p_qty)) where id = existing.id returning * into r;
      return r;
    end if;
  end if;
  insert into public.items(id, list_code, name, qty, added_by, done, done_by, done_at, created_at)
  values (coalesce(p_id, gen_random_uuid()), p_code, trim(p_name), greatest(1, least(999, coalesce(p_qty,1))),
          nullif(trim(p_who),''), coalesce(p_done,false), p_done_by, case when p_done then now() end, coalesce(p_created, now()))
  on conflict (id) do nothing
  returning * into r;
  return r;
end $$;

create or replace function public.lista_set_done(p_code text, p_id uuid, p_done boolean, p_who text)
returns void language sql security definer set search_path = public as $$
  update public.items
     set done = p_done,
         done_by = case when p_done then nullif(trim(p_who),'') end,
         done_at = case when p_done then now() end
   where id = p_id and list_code = p_code;
$$;

create or replace function public.lista_delete(p_code text, p_ids uuid[])
returns void language sql security definer set search_path = public as $$
  delete from public.items where list_code = p_code and id = any(p_ids);
$$;

revoke all on function public.lista_get(text), public.lista_add(text,text,int,text,uuid,boolean,text,timestamptz),
  public.lista_set_done(text,uuid,boolean,text), public.lista_delete(text,uuid[]) from public;
grant execute on function public.lista_get(text), public.lista_add(text,text,int,text,uuid,boolean,text,timestamptz),
  public.lista_set_done(text,uuid,boolean,text), public.lista_delete(text,uuid[]) to anon, authenticated;
