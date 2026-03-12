--
-- PostgreSQL database dump
--

\restrict jDYrVOHhMNYkub5evQYQxmRyw8MXXpUNQF0nHLFxaKgKJU7E2fVwzHYvzKeKr51

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


--
-- Name: create_notification(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_notification() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO public.notifications (user_id, type, message)
  VALUES (
    NEW.user_id,
    TG_ARGV[0],
    TG_ARGV[1]
  );
  RETURN NEW;
END;
$$;


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (new.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$$;


--
-- Name: handle_new_user_notifications(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user_notifications() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  -- Safe empty trigger, does nothing on signup
  RETURN new;
END;
$$;


--
-- Name: notify_back_in_stock(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_back_in_stock() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  wishlist_users uuid[];
  user_id uuid;
begin
  -- Only notify if stock went from 0 to > 0 (restocked)
  if old.stock = 0 and new.stock > 0 then
    
    -- Find users who have this product in wishlist
    select array_agg(w.user_id) into wishlist_users
    from wishlists w
    where w.product_id = new.id;
    
    -- Skip if no users found
    if wishlist_users is null or array_length(wishlist_users, 1) is null then
      return new;
    end if;
    
    -- Create notification for each user
    foreach user_id in array wishlist_users loop
      insert into notifications (user_id, type, title, message, data)
      values (
        user_id,
        'back_in_stock',
        '✅ Back in Stock: ' || new.name,
        'Good news! ' || new.name || ' is now available again. Order now before it sells out.',
        jsonb_build_object(
          'product_id', new.id,
          'slug', new.slug,
          'stock', new.stock,
          'action', '/product-detail.html?slug=' || new.slug,
          'action_text', 'Buy Now'
        )
      );
    end loop;
    
  end if;
  
  return new;
end;
$$;


--
-- Name: notify_cart_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_cart_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  insert into notifications (user_id, product_id, title, message, type)
  values (
    new.user_id,
    new.product_id,
    'Item Added to Cart',
    'You have successfully added an item to your cart.',
    'cart');
  return new;
end;
$$;


--
-- Name: notify_cart_low_stock(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_cart_low_stock() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  cart_users uuid[];
  user_id uuid;
begin
  -- Only notify if stock dropped to 5 or below
  if new.stock <= 5 and (old.stock is null or old.stock > 5) then
    
    -- Find users who have this product in cart
    select array_agg(c.user_id) into cart_users
    from cart_items c
    where c.product_id = new.id;
    
    -- Skip if no users found
    if cart_users is null or array_length(cart_users, 1) is null then
      return new;
    end if;
    
    -- Create notification for each user
    foreach user_id in array cart_users loop
      insert into notifications (user_id, type, title, message, data)
      values (
        user_id,
        'cart_stock',
        '⚡ Low Stock: ' || new.name,
        'Only ' || new.stock || ' left in stock! Complete your purchase before it''s gone.',
        jsonb_build_object(
          'product_id', new.id,
          'slug', new.slug,
          'stock', new.stock,
          'action', '/cart.html',
          'action_text', 'Go to Cart'
        )
      );
    end loop;
    
  end if;
  
  return new;
end;
$$;


--
-- Name: notify_order_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_order_status() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  -- Notify user when order status changes
  insert into notifications (user_id, type, title, message, data)
  values (
    new.user_id,
    'order_update',
    '📦 Order ' || new.status,
    'Your order #' || substring(new.id::text, 1, 8) || ' is now ' || new.status || '.',
    jsonb_build_object(
      'order_id', new.id,
      'status', new.status,
      'action', '/orders.html',
      'action_text', 'View Order'
    )
  );
  
  return new;
end;
$$;


--
-- Name: notify_wishlist_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_wishlist_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  insert into notifications (user_id, product_id, title, message, type)
  values (
    new.user_id,
    new.product_id,
    'Item Added to Wishlist',
    'You have successfully added an item to your wishlist.',
    'wishlist'
  );
  return new;
end;
$$;


--
-- Name: notify_wishlist_sale(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.notify_wishlist_sale() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
declare
  wishlist_users uuid[];
  user_id uuid;
begin
  -- Only notify if price actually went DOWN
  if new.price_cents < old.price_cents then
    
    -- Find users who have this product in wishlist
    select array_agg(w.user_id) into wishlist_users
    from wishlists w
    where w.product_id = new.id;
    
    -- Skip if no users found
    if wishlist_users is null or array_length(wishlist_users, 1) is null then
      return new;
    end if;
    
    -- Create notification for each user
    foreach user_id in array wishlist_users loop
      insert into notifications (user_id, type, title, message, data)
      values (
        user_id,
        'wishlist_sale',
        '💰 Price Drop: ' || new.name,
        new.name || ' dropped from $' || (old.price_cents/100.0) || ' to $' || (new.price_cents/100.0) || '! Grab it now.',
        jsonb_build_object(
          'product_id', new.id,
          'slug', new.slug,
          'old_price', old.price_cents,
          'new_price', new.price_cents,
          'action', '/product-detail.html?slug=' || new.slug,
          'action_text', 'View Deal'
        )
      );
    end loop;
    
  end if;
  
  return new;
end;
$_$;


--
-- Name: reduce_stock(uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reduce_stock(p_id uuid, qty integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.products
  SET stock = GREATEST(0, stock - qty)
  WHERE id = p_id;
END;
$$;


--
-- Name: use_promo(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.use_promo(promo_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.promos
  SET used_count = used_count + 1
  WHERE id = promo_id;
END;
$$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_
        -- Filter by action early - only get subscriptions interested in this action
        -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
        and (subs.action_filter = '*' or subs.action_filter = action::text);

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: delete_leaf_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$$;


--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach (unchanged)
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT path_tokens[$1] AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $2 || '%%'
                  AND bucket_id = $3
                  AND array_length(objects.path_tokens, 1) <> $1
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT path_tokens[$1] AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $2 || '%%'
               AND bucket_id = $3
               AND array_length(objects.path_tokens, 1) = $1
             ORDER BY %I %s)
            LIMIT $4 OFFSET $5
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := split_part(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter), v_delimiter, levels);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := split_part(v_current.name, v_delimiter, levels);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    IF p_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        p_sort_column,
        v_cursor_op,
        p_sort_column,
        p_sort_order,
        p_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$_$;


--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: cart_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    product_id uuid NOT NULL,
    qty integer NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT cart_items_qty_check CHECK ((qty > 0))
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    parent_id uuid,
    icon text
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    user_id uuid NOT NULL,
    product_id bigint,
    title text,
    message text,
    type text,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.notifications ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid,
    product_id uuid,
    variant_id uuid,
    qty integer NOT NULL,
    price_cents integer NOT NULL,
    product_name text,
    product_img text
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    total_cents integer NOT NULL,
    promo_code text,
    status text DEFAULT 'pending'::text,
    shipping_address jsonb,
    created_at timestamp with time zone DEFAULT now(),
    shipping_method text DEFAULT 'standard'::text,
    payment_method text DEFAULT 'cod'::text,
    tracking_status text DEFAULT 'processing'::text,
    expected_delivery date,
    cancelled_at timestamp with time zone,
    cancel_reason text,
    notes text,
    email_confirmed boolean DEFAULT false
);


--
-- Name: orders_with_items; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.orders_with_items AS
SELECT
    NULL::uuid AS id,
    NULL::uuid AS user_id,
    NULL::integer AS total_cents,
    NULL::text AS promo_code,
    NULL::text AS status,
    NULL::jsonb AS shipping_address,
    NULL::timestamp with time zone AS created_at,
    NULL::text AS shipping_method,
    NULL::text AS payment_method,
    NULL::text AS tracking_status,
    NULL::date AS expected_delivery,
    NULL::timestamp with time zone AS cancelled_at,
    NULL::text AS cancel_reason,
    NULL::text AS notes,
    NULL::boolean AS email_confirmed,
    NULL::json AS items;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    price_cents integer NOT NULL,
    stock integer DEFAULT 0 NOT NULL,
    description text,
    img_url text,
    model_url text,
    created_at timestamp with time zone DEFAULT now(),
    category_id uuid,
    specs jsonb DEFAULT '{}'::jsonb,
    tags text[] DEFAULT '{}'::text[],
    weight_g integer,
    sku text
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    email text,
    username text,
    first_name text,
    middle_name text,
    last_name text,
    suffix text,
    contact_number text,
    address text,
    terms_accepted boolean DEFAULT false,
    rules_accepted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: promos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    discount_percent integer,
    valid_from timestamp with time zone DEFAULT now(),
    valid_until timestamp with time zone NOT NULL,
    max_uses integer,
    used_count integer DEFAULT 0,
    is_free_shipping boolean DEFAULT false,
    min_order_cents integer DEFAULT 0,
    description text,
    CONSTRAINT promos_discount_percent_check CHECK ((discount_percent >= 0))
);


--
-- Name: refund_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refund_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    user_id uuid NOT NULL,
    reason text,
    status text DEFAULT 'pending'::text,
    created_at timestamp with time zone DEFAULT now(),
    resolved_at timestamp with time zone
);


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid,
    user_id uuid,
    rating integer,
    comment text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- Name: variants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.variants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid,
    variant_name text NOT NULL,
    option_value text NOT NULL,
    price_adjustment integer DEFAULT 0,
    stock integer DEFAULT 0 NOT NULL,
    img_url text
);


--
-- Name: wishlists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wishlists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    product_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: messages_2026_03_09; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_09 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2026_03_10; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_10 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2026_03_11; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_11 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2026_03_12; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_12 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2026_03_13; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_13 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2026_03_14; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_14 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2026_03_15; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_15 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: messages_2026_03_09; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_09 FOR VALUES FROM ('2026-03-09 00:00:00') TO ('2026-03-10 00:00:00');


--
-- Name: messages_2026_03_10; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_10 FOR VALUES FROM ('2026-03-10 00:00:00') TO ('2026-03-11 00:00:00');


--
-- Name: messages_2026_03_11; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_11 FOR VALUES FROM ('2026-03-11 00:00:00') TO ('2026-03-12 00:00:00');


--
-- Name: messages_2026_03_12; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_12 FOR VALUES FROM ('2026-03-12 00:00:00') TO ('2026-03-13 00:00:00');


--
-- Name: messages_2026_03_13; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_13 FOR VALUES FROM ('2026-03-13 00:00:00') TO ('2026-03-14 00:00:00');


--
-- Name: messages_2026_03_14; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_14 FOR VALUES FROM ('2026-03-14 00:00:00') TO ('2026-03-15 00:00:00');


--
-- Name: messages_2026_03_15; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_15 FOR VALUES FROM ('2026-03-15 00:00:00') TO ('2026-03-16 00:00:00');


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.custom_oauth_providers (id, provider_type, identifier, name, client_id, client_secret, acceptable_client_ids, scopes, pkce_enabled, attribute_mapping, authorization_params, enabled, email_optional, issuer, discovery_url, skip_nonce_check, cached_discovery, discovery_cached_at, authorization_url, token_url, userinfo_url, jwks_uri, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at, invite_token, referrer, oauth_client_state_id, linking_target_id, email_optional) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{"sub": "eb7ed6ea-b864-491d-b8d7-e9286e2a1d27", "email": "akosibbear38@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-02-03 17:10:59.592347+00	2026-02-03 17:10:59.592418+00	2026-02-03 17:10:59.592418+00	72d9d905-a901-4989-a3cc-c134d3a04132
0c55e50d-aa38-4bae-8c07-d72232af595f	0c55e50d-aa38-4bae-8c07-d72232af595f	{"sub": "0c55e50d-aa38-4bae-8c07-d72232af595f", "email": "mondjonray@gmail.com", "username": "Combi", "last_name": "CRUZ", "first_name": "JOHN", "email_verified": true, "phone_verified": false}	email	2026-03-04 08:39:20.779868+00	2026-03-04 08:39:20.781142+00	2026-03-04 08:39:20.781142+00	7acf3688-2b46-4445-bbf2-37cdd1937304
569d5adc-8f2f-4a4a-ad47-f09cd8e69193	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	{"sub": "569d5adc-8f2f-4a4a-ad47-f09cd8e69193", "email": "denjebard@gmail.com", "username": "Jebard", "last_name": "Aboy", "first_name": "Den Gebhard", "email_verified": true, "phone_verified": false}	email	2026-03-06 14:14:13.127511+00	2026-03-06 14:14:13.128721+00	2026-03-06 14:14:13.128721+00	322dd42a-a9bc-46e9-bc99-c604ed6261c0
1ad66014-608b-45d0-9c15-9ab69eec9a07	1ad66014-608b-45d0-9c15-9ab69eec9a07	{"sub": "1ad66014-608b-45d0-9c15-9ab69eec9a07", "email": "jjassiemcabrillos13@gmail.com", "username": "Jass11", "last_name": "Cabrillos", "first_name": "John Jasseim", "email_verified": true, "phone_verified": false}	email	2026-03-07 03:17:38.758833+00	2026-03-07 03:17:38.758901+00	2026-03-07 03:17:38.758901+00	904a6357-38f2-4c49-b922-eb8c728ad939
cabc047b-2cb0-4808-8a1d-658858bd00f3	cabc047b-2cb0-4808-8a1d-658858bd00f3	{"sub": "cabc047b-2cb0-4808-8a1d-658858bd00f3", "email": "ayonokoji02@gmail.com", "username": "combi", "last_name": "koji", "first_name": "john", "email_verified": true, "phone_verified": false}	email	2026-03-07 04:09:47.516074+00	2026-03-07 04:09:47.516125+00	2026-03-07 04:09:47.516125+00	c7d02016-8945-4cb1-9346-ca8ea59440a5
1acb1b11-931e-49ae-93e4-8689247327c8	1acb1b11-931e-49ae-93e4-8689247327c8	{"sub": "1acb1b11-931e-49ae-93e4-8689247327c8", "email": "justineaaronasuncion09@gmail.com", "username": "Justine", "last_name": "Asuncion", "first_name": "Justine", "email_verified": true, "phone_verified": false}	email	2026-03-11 10:06:23.172659+00	2026-03-11 10:06:23.173302+00	2026-03-11 10:06:23.173302+00	b4115708-9190-4c61-a2e9-4936753cdc32
e6093655-ee0d-4000-8b71-d5b112557bdb	e6093655-ee0d-4000-8b71-d5b112557bdb	{"sub": "e6093655-ee0d-4000-8b71-d5b112557bdb", "email": "aboydengebhard@gmail.com", "username": "geb", "last_name": "geb", "first_name": "geb", "email_verified": true, "phone_verified": false}	email	2026-03-12 07:38:35.152961+00	2026-03-12 07:38:35.153016+00	2026-03-12 07:38:35.153016+00	6959d568-3808-4251-8f9f-ecb259b2af0e
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
234c23d9-0b69-4883-b682-d11cb1f96063	2026-03-10 05:16:44.991419+00	2026-03-10 05:16:44.991419+00	password	16aa5ab1-3ed8-4f57-8228-c3069619c301
df9bec2e-915a-4197-8d9b-753b7d2ce299	2026-03-11 10:07:18.001748+00	2026-03-11 10:07:18.001748+00	otp	4c9ce474-8871-4343-b034-c5db0ee75428
fd1528dd-f2e9-40dd-b2ab-6d40d68f5182	2026-03-11 10:14:21.649173+00	2026-03-11 10:14:21.649173+00	password	682e46f8-41b0-4d73-8eaa-ac36d4c9c69c
59d304b8-ea23-4ed7-8a20-a987a40c9913	2026-03-12 07:39:10.087632+00	2026-03-12 07:39:10.087632+00	otp	bffd4df1-8b86-45c2-9a6c-ece8bdd5d797
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type, token_endpoint_auth_method) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	114	t67wm7fse2sn	1acb1b11-931e-49ae-93e4-8689247327c8	f	2026-03-11 10:14:21.615136+00	2026-03-11 10:14:21.615136+00	\N	fd1528dd-f2e9-40dd-b2ab-6d40d68f5182
00000000-0000-0000-0000-000000000000	119	tl4agkhfykgs	e6093655-ee0d-4000-8b71-d5b112557bdb	t	2026-03-12 07:39:10.082829+00	2026-03-12 08:40:17.128221+00	\N	59d304b8-ea23-4ed7-8a20-a987a40c9913
00000000-0000-0000-0000-000000000000	113	isoegawj5p5t	1acb1b11-931e-49ae-93e4-8689247327c8	t	2026-03-11 10:07:17.973411+00	2026-03-12 12:19:31.361239+00	\N	df9bec2e-915a-4197-8d9b-753b7d2ce299
00000000-0000-0000-0000-000000000000	121	3qitrex43hbj	1acb1b11-931e-49ae-93e4-8689247327c8	f	2026-03-12 12:19:31.396117+00	2026-03-12 12:19:31.396117+00	isoegawj5p5t	df9bec2e-915a-4197-8d9b-753b7d2ce299
00000000-0000-0000-0000-000000000000	101	uaeycrzr5kz3	1ad66014-608b-45d0-9c15-9ab69eec9a07	t	2026-03-10 07:57:57.61951+00	2026-03-12 14:24:33.035698+00	hhzjkxige3sf	234c23d9-0b69-4883-b682-d11cb1f96063
00000000-0000-0000-0000-000000000000	122	qqwkl474655t	1ad66014-608b-45d0-9c15-9ab69eec9a07	f	2026-03-12 14:24:33.059905+00	2026-03-12 14:24:33.059905+00	uaeycrzr5kz3	234c23d9-0b69-4883-b682-d11cb1f96063
00000000-0000-0000-0000-000000000000	120	4o7mcw24id6m	e6093655-ee0d-4000-8b71-d5b112557bdb	t	2026-03-12 08:40:17.154938+00	2026-03-12 14:56:11.932316+00	tl4agkhfykgs	59d304b8-ea23-4ed7-8a20-a987a40c9913
00000000-0000-0000-0000-000000000000	123	k4exx4of4ghl	e6093655-ee0d-4000-8b71-d5b112557bdb	f	2026-03-12 14:56:11.948695+00	2026-03-12 14:56:11.948695+00	4o7mcw24id6m	59d304b8-ea23-4ed7-8a20-a987a40c9913
00000000-0000-0000-0000-000000000000	93	6lyrndxsyha7	1ad66014-608b-45d0-9c15-9ab69eec9a07	t	2026-03-10 05:16:44.955912+00	2026-03-10 06:31:53.011318+00	\N	234c23d9-0b69-4883-b682-d11cb1f96063
00000000-0000-0000-0000-000000000000	97	hhzjkxige3sf	1ad66014-608b-45d0-9c15-9ab69eec9a07	t	2026-03-10 06:31:53.013313+00	2026-03-10 07:57:57.608108+00	6lyrndxsyha7	234c23d9-0b69-4883-b682-d11cb1f96063
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
20260115000000
20260121000000
20260219120000
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
df9bec2e-915a-4197-8d9b-753b7d2ce299	1acb1b11-931e-49ae-93e4-8689247327c8	2026-03-11 10:07:17.918267+00	2026-03-12 12:19:31.436556+00	\N	aal1	\N	2026-03-12 12:19:31.436438	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	139.135.241.143	\N	\N	\N	\N	\N
234c23d9-0b69-4883-b682-d11cb1f96063	1ad66014-608b-45d0-9c15-9ab69eec9a07	2026-03-10 05:16:44.91769+00	2026-03-12 14:24:33.101876+00	\N	aal1	\N	2026-03-12 14:24:33.101753	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0	152.32.112.78	\N	\N	\N	\N	\N
59d304b8-ea23-4ed7-8a20-a987a40c9913	e6093655-ee0d-4000-8b71-d5b112557bdb	2026-03-12 07:39:10.07915+00	2026-03-12 14:56:11.975419+00	\N	aal1	\N	2026-03-12 14:56:11.97476	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	210.213.99.221	\N	\N	\N	\N	\N
fd1528dd-f2e9-40dd-b2ab-6d40d68f5182	1acb1b11-931e-49ae-93e4-8689247327c8	2026-03-11 10:14:21.585008+00	2026-03-11 10:14:21.585008+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	139.135.241.181	\N	\N	\N	\N	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	cabc047b-2cb0-4808-8a1d-658858bd00f3	authenticated	authenticated	ayonokoji02@gmail.com	$2a$10$GKkWJoR7gwaQhgO0vI035uJon9vqpcwK0ywJWLV5yqMLznWLLDTmG	2026-03-07 04:10:22.719913+00	\N		2026-03-07 04:09:47.535026+00		\N			\N	2026-03-07 04:10:22.805047+00	{"provider": "email", "providers": ["email"]}	{"sub": "cabc047b-2cb0-4808-8a1d-658858bd00f3", "email": "ayonokoji02@gmail.com", "username": "combi", "last_name": "koji", "first_name": "john", "email_verified": true, "phone_verified": false}	\N	2026-03-07 04:09:47.450189+00	2026-03-07 04:10:22.904385+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	authenticated	authenticated	denjebard@gmail.com	$2a$10$hoCQsaFzJMGfgzo.KXag..W3BjYZp6cNvsCCtcDBZFU5kxqsFW8xW	2026-03-06 14:15:56.568638+00	\N		2026-03-06 14:14:13.145907+00		\N			\N	2026-03-10 14:44:22.822578+00	{"provider": "email", "providers": ["email"]}	{"sub": "569d5adc-8f2f-4a4a-ad47-f09cd8e69193", "email": "denjebard@gmail.com", "username": "Jebard", "last_name": "Aboy", "first_name": "Den Gebhard", "email_verified": true, "phone_verified": false}	\N	2026-03-06 14:14:13.072322+00	2026-03-12 07:17:16.118282+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1acb1b11-931e-49ae-93e4-8689247327c8	authenticated	authenticated	justineaaronasuncion09@gmail.com	$2a$10$d14hlBs3SWIitJj2y3v5duLPCdjaagjjqPoHMLu8O1pimvkbQWCu2	2026-03-11 10:07:17.883999+00	\N		2026-03-11 10:06:23.194406+00		\N			\N	2026-03-11 10:14:21.584906+00	{"provider": "email", "providers": ["email"]}	{"sub": "1acb1b11-931e-49ae-93e4-8689247327c8", "email": "justineaaronasuncion09@gmail.com", "username": "Justine", "last_name": "Asuncion", "first_name": "Justine", "email_verified": true, "phone_verified": false}	\N	2026-03-11 10:06:23.067201+00	2026-03-12 12:19:31.418069+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	authenticated	authenticated	akosibbear38@gmail.com	$2a$10$yXZeA81DQMdY/YQQw8fvkeHZqjxY27d/XI.bmOWy/Kps6UGSaaWEe	2026-02-03 17:10:59.607326+00	\N		\N		\N			\N	2026-03-12 07:30:53.074271+00	{"provider": "email", "providers": ["email"]}	{"sub": "eb7ed6ea-b864-491d-b8d7-e9286e2a1d27", "email": "akosibbear38@gmail.com", "email_verified": true, "phone_verified": false}	\N	2026-02-03 17:10:59.543982+00	2026-03-12 07:30:53.106448+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1ad66014-608b-45d0-9c15-9ab69eec9a07	authenticated	authenticated	jjassiemcabrillos13@gmail.com	$2a$10$Q7BQg80U1Zr53ZcnfCkl0erikR5CvrGrIfowHtkFy7rGc/kF1K/am	2026-03-07 03:20:31.892627+00	\N		2026-03-07 03:17:38.778798+00		\N			\N	2026-03-10 05:16:44.91701+00	{"provider": "email", "providers": ["email"]}	{"sub": "1ad66014-608b-45d0-9c15-9ab69eec9a07", "email": "jjassiemcabrillos13@gmail.com", "username": "Jass11", "last_name": "Cabrillos", "first_name": "John Jasseim", "email_verified": true, "phone_verified": false}	\N	2026-03-07 03:17:38.666427+00	2026-03-12 14:24:33.080349+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e6093655-ee0d-4000-8b71-d5b112557bdb	authenticated	authenticated	aboydengebhard@gmail.com	$2a$10$TVK4f544fRw23rxhU8Zq2OyqFD04X9dLvDUkXaQC90HHFuqsGBBhK	2026-03-12 07:39:10.073182+00	\N		2026-03-12 07:38:35.162955+00		\N			\N	2026-03-12 07:39:10.078182+00	{"provider": "email", "providers": ["email"]}	{"sub": "e6093655-ee0d-4000-8b71-d5b112557bdb", "email": "aboydengebhard@gmail.com", "username": "geb", "last_name": "geb", "first_name": "geb", "email_verified": true, "phone_verified": false}	\N	2026-03-12 07:38:35.114369+00	2026-03-12 14:56:11.957115+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0c55e50d-aa38-4bae-8c07-d72232af595f	authenticated	authenticated	mondjonray@gmail.com	$2a$10$luQDTliEElYPSyjeF/kqU.PDSO4L.lRNudZzrxNtbgJTq6LP0cUIO	2026-03-04 08:39:46.057872+00	\N		2026-03-04 08:39:20.804058+00		\N			\N	2026-03-04 08:39:46.065341+00	{"provider": "email", "providers": ["email"]}	{"sub": "0c55e50d-aa38-4bae-8c07-d72232af595f", "email": "mondjonray@gmail.com", "username": "Combi", "last_name": "CRUZ", "first_name": "JOHN", "email_verified": true, "phone_verified": false}	\N	2026-03-04 08:39:20.682488+00	2026-03-04 08:39:46.104262+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_items (id, user_id, product_id, qty, created_at) FROM stdin;
cc6479fb-b32f-4923-bdf3-a7a9e1dcedb6	1ad66014-608b-45d0-9c15-9ab69eec9a07	6bce89f5-ffad-4c84-92bf-ba9c0254d1f6	1	2026-03-07 03:20:46.55366+00
cd9ad5be-244e-41d6-9116-384937640823	1ad66014-608b-45d0-9c15-9ab69eec9a07	0a7f9d9c-002c-4b8b-aa3c-6233c020b5c3	1	2026-03-07 03:21:02.252671+00
3729f2cd-46fc-416a-a8a8-8d5206531b9c	1ad66014-608b-45d0-9c15-9ab69eec9a07	55d3634d-0091-4d95-a257-eed354ad0702	1	2026-03-07 03:21:17.746923+00
5f13b2ee-7f9f-48b0-989e-94555a430ca5	1ad66014-608b-45d0-9c15-9ab69eec9a07	f06d3ba5-09f5-4c03-884f-d9e60207750c	1	2026-03-07 03:21:32.38732+00
878f4233-508c-4958-a5bf-67c8ea1acfa9	1ad66014-608b-45d0-9c15-9ab69eec9a07	6004ffc7-d262-40d5-93b8-41e861a6d3bf	1	2026-03-07 03:22:02.175942+00
7fb7f360-ce09-49d5-8094-f6d14f311201	cabc047b-2cb0-4808-8a1d-658858bd00f3	6bce89f5-ffad-4c84-92bf-ba9c0254d1f6	1	2026-03-07 04:11:12.211759+00
b39701c5-4f10-475b-832a-ac7e68b89c6f	cabc047b-2cb0-4808-8a1d-658858bd00f3	f06d3ba5-09f5-4c03-884f-d9e60207750c	1	2026-03-07 04:11:35.049874+00
022fa9ad-f9c2-455d-a740-f75b2494a414	e6093655-ee0d-4000-8b71-d5b112557bdb	9a6bbf2c-b515-4e11-b403-9d1d3b7a2fa8	1	2026-03-12 07:49:10.509082+00
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id, name, slug, parent_id, icon) FROM stdin;
f0bb3bd2-99dd-4f37-847a-af2dc873fe3e	Boards	boards	\N	\N
f170f920-3d0a-4eda-a33f-52d81dc5b3a2	Sensors	sensors	\N	\N
36225f90-95bf-485d-9808-acb8d7528135	Actuators	actuators	\N	\N
2f688ac5-1cad-4146-b5cf-eb6d0a9dae94	Electronic Circuits	Electronic Circuits	\N	\N
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, product_id, title, message, type, is_read, created_at) FROM stdin;
1	7f2b8dc9-5779-4d80-9540-b7a1c9eb0428	\N	30% FOR STUDENTS, PWD, AND SENIORS	Are you a student, PWD, or perhaps a senior? Congrats this is just for you! Get this 30% off discount for your first purchase of any product you choose! free shipping included	promo	f	2026-03-06 19:19:32.160267+00
2	0c55e50d-aa38-4bae-8c07-d72232af595f	\N	30% FOR STUDENTS, PWD, AND SENIORS	Are you a student, PWD, or perhaps a senior? Congrats this is just for you! Get this 30% off discount for your first purchase of any product you choose! free shipping included	promo	f	2026-03-06 19:19:32.160267+00
7	1ad66014-608b-45d0-9c15-9ab69eec9a07	\N	WEEKEND SALE	GET 20% OFF	promo	t	2026-03-07 04:19:04.813342+00
4	7f2b8dc9-5779-4d80-9540-b7a1c9eb0428	\N	WEEKEND SALE	GET 20% OFF	promo	f	2026-03-07 04:19:04.813342+00
5	0c55e50d-aa38-4bae-8c07-d72232af595f	\N	WEEKEND SALE	GET 20% OFF	promo	f	2026-03-07 04:19:04.813342+00
8	cabc047b-2cb0-4808-8a1d-658858bd00f3	\N	WEEKEND SALE	GET 20% OFF	promo	f	2026-03-07 04:19:04.813342+00
6	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	WEEKEND SALE	GET 20% OFF	promo	t	2026-03-07 04:19:04.813342+00
3	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	30% FOR STUDENTS, PWD, AND SENIORS	Are you a student, PWD, or perhaps a senior? Congrats this is just for you! Get this 30% off discount for your first purchase of any product you choose! free shipping included	promo	t	2026-03-06 19:19:32.160267+00
9	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #41D6381A confirmed via GCash. Total: ₱168.00.	system	f	2026-03-10 19:00:38.104558+00
10	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #41D6381A confirmed via GCash. Total: ₱168.00.	system	f	2026-03-10 19:28:36.977977+00
11	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #41D6381A confirmed via GCash. Total: ₱168.00.	system	f	2026-03-10 19:28:52.625382+00
12	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #41D6381A confirmed via GCash. Total: ₱168.00.	system	f	2026-03-10 19:29:15.451598+00
13	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #41D6381A confirmed via GCash. Total: ₱168.00.	system	f	2026-03-10 19:29:17.560181+00
14	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #41D6381A confirmed via GCash. Total: ₱168.00.	system	f	2026-03-10 19:29:33.163437+00
15	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #41D6381A confirmed via GCash. Total: ₱168.00.	system	f	2026-03-10 19:30:16.819924+00
16	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #246FE993 confirmed via GCash. Total: ₱104.00.	system	f	2026-03-10 19:31:04.99222+00
17	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #246FE993 confirmed via GCash. Total: ₱104.00.	system	t	2026-03-10 19:32:11.145585+00
18	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #5B6590B8 confirmed via GCash. Total: ₱138.00.	system	f	2026-03-10 19:37:30.022867+00
19	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #5B6590B8 confirmed via GCash. Total: ₱138.00.	system	f	2026-03-10 19:37:42.70286+00
20	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #5B6590B8 confirmed via GCash. Total: ₱138.00.	system	f	2026-03-10 19:40:43.351564+00
23	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #5B6590B8 confirmed via GCash. Total: ₱138.00.	system	t	2026-03-11 03:32:17.889524+00
22	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #5B6590B8 confirmed via GCash. Total: ₱138.00.	system	t	2026-03-10 19:45:38.756756+00
21	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #5B6590B8 confirmed via GCash. Total: ₱138.00.	system	t	2026-03-10 19:45:30.124556+00
24	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Payment Confirmed	Payment for order #5439B01A confirmed via Maya. Total: ₱398.00.	system	f	2026-03-12 07:29:19.717658+00
25	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	\N	Payment Confirmed	Payment for order #FAAAF3E5 confirmed via GCash. Total: ₱124.00.	system	f	2026-03-12 07:33:02.435108+00
26	e6093655-ee0d-4000-8b71-d5b112557bdb	\N	Payment Confirmed	Payment for order #CB714728 confirmed via GCash. Total: ₱1516.00.	system	t	2026-03-12 07:41:05.550098+00
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_items (id, order_id, product_id, variant_id, qty, price_cents, product_name, product_img) FROM stdin;
0420102a-92da-408a-94bb-11c602f7fffc	bed00b67-cc34-4417-ad6c-cfe16e1bb13c	639dc664-12af-4e16-9ae7-f4e3c1a2136e	\N	1	3900	Temperature Module	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/e21fae93-99f7-484f-8d88-ed50d972a412.png
fbafd923-2c35-47b6-a462-e1168a534142	a38b8125-6487-477b-b9d0-a88935e3f375	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
d69a373c-d518-4805-b55e-28c571326d4e	c1fd4306-9a3e-4f64-83a1-dd7bd4cc4098	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
97e6bab2-ca89-49fb-8ad7-d89ef7289ab0	92e7eb54-2538-4c0f-b70e-a0208d11d4bc	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
052e206e-9609-4d81-ae46-5dc6e0d285f5	61364ef9-78c8-402c-a15d-c7269916d5fb	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
ae162d5b-d28b-4e04-b76d-e290694778d9	9ab6ddbd-5252-4122-9578-821cbc315a20	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
d366ad26-bb73-4db1-91d9-18929d8881b1	76e0bb14-934a-4e36-84e9-3fa7f13dd31b	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
aaa929e5-1fb2-451e-b300-791d1f6def65	e18b259b-d222-4afd-84fe-d007bf61765b	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
2f90c906-942c-491c-b9f9-1fdbcfe16d5c	0b8e0290-7a6a-4c22-a712-6b28883c6ac2	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
d2255196-3c4f-47bc-828d-7ae4ceae8ea2	43616c0c-f0b0-4815-bcfd-db9ceeaf1273	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
76488954-f4fc-422e-a644-87bd9f718396	06338b50-bcce-4449-ba98-1a4f0aaaba09	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
f171ecd3-d34f-4661-8798-8eea19fc331e	5d12e4e5-4354-4b4d-a60f-1bf6ebd51cbd	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
a5cc4979-5866-4750-a221-dbfa032ebffd	063e03f7-99c2-47bc-8476-f947b7777cec	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	2	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
896ff23b-00bc-4df8-a2b3-901408d8263d	f1512590-bb2e-41fa-b3c6-8919f0ab2cbb	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	1	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
3cb70b02-f9b1-4688-bb35-2e407383b7de	f1512590-bb2e-41fa-b3c6-8919f0ab2cbb	3a10d52f-9131-403b-a1ea-1004fd685cc4	\N	1	29900	Ultrasonic Sensor	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/43c86d7d-8451-46a7-9245-22d197e1e802.png
6ed7bb6e-51cf-481c-8bc3-6c294f74b9cf	09455a12-4787-44c0-af2a-b701e84a5ad5	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	1	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
1b12a2e3-f87b-49a4-a21b-c687c13b3d8a	09455a12-4787-44c0-af2a-b701e84a5ad5	3a10d52f-9131-403b-a1ea-1004fd685cc4	\N	1	29900	Ultrasonic Sensor	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/43c86d7d-8451-46a7-9245-22d197e1e802.png
06466a73-7034-47df-b789-accdd487b15f	41d6381a-45ff-4e40-a9bd-247339129e25	e86d8889-61d6-4e97-a3a2-344a852b6efa	\N	1	6900	Motion Sensor	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/86dc093b-a396-4ed6-bfa8-dec762e7808a.png
a27a3f6f-69b3-4a04-83e3-e22656e4f860	246fe993-e66c-48df-8d81-87dc243ba53e	75a67a8c-a785-4ac9-9502-51e353a71a0f	\N	1	500	Led Lights	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/f99a6818-5a4f-4197-af19-2274bfb5a932.png
bbdec729-773a-41ea-8113-d7ae34b4ac31	5b6590b8-5b80-4853-8e3c-c9c6a87b752f	639dc664-12af-4e16-9ae7-f4e3c1a2136e	\N	1	3900	Temperature Module	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/e21fae93-99f7-484f-8d88-ed50d972a412.png
37c78ab7-e467-4afb-9ee5-76996a8a4a44	5439b01a-b209-4536-9120-b50ca70560ae	ad6d9092-30c4-46e2-a3a9-c7d0537b126b	\N	1	14900	16 x 2 LCD Display	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png
79843240-5602-4e1d-bafa-00a9d6e5fc00	faaaf3e5-4ec4-4c85-a267-9fd0bce8f847	3d3a4f22-1aac-45ac-b25c-73b9c523c37e	\N	1	2500	Male to Male Jumper Wires	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/b240c690-388d-4830-8b12-ec1f0a2ef308.png
bdb5a226-2884-40ee-b7f1-e822430b1b95	cb714728-eef3-4575-8b25-0ce1e107b137	9a6bbf2c-b515-4e11-b403-9d1d3b7a2fa8	\N	4	37900	Wifi Module ESP32	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/e7bb5e18-f5c3-4c9f-957b-2f78910087d2.png
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (id, user_id, total_cents, promo_code, status, shipping_address, created_at, shipping_method, payment_method, tracking_status, expected_delivery, cancelled_at, cancel_reason, notes, email_confirmed) FROM stdin;
bed00b67-cc34-4417-ad6c-cfe16e1bb13c	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	13800	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 14:56:34.464112+00	standard	gcash	processing	2026-03-14	\N	\N		f
a38b8125-6487-477b-b9d0-a88935e3f375	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 16:02:08.346302+00	standard	gcash	processing	2026-03-14	\N	\N		f
c1fd4306-9a3e-4f64-83a1-dd7bd4cc4098	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 16:02:13.898347+00	standard	gcash	processing	2026-03-14	\N	\N		f
92e7eb54-2538-4c0f-b70e-a0208d11d4bc	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 16:02:18.582208+00	standard	gcash	processing	2026-03-14	\N	\N		f
61364ef9-78c8-402c-a15d-c7269916d5fb	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 16:02:45.809334+00	standard	gcash	processing	2026-03-14	\N	\N		f
9ab6ddbd-5252-4122-9578-821cbc315a20	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 16:08:19.012626+00	standard	gcash	processing	2026-03-14	\N	\N		f
76e0bb14-934a-4e36-84e9-3fa7f13dd31b	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 16:36:39.364762+00	standard	gcash	processing	2026-03-14	\N	\N		f
e18b259b-d222-4afd-84fe-d007bf61765b	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 16:37:08.311909+00	standard	gcash	processing	2026-03-14	\N	\N		f
0b8e0290-7a6a-4c22-a712-6b28883c6ac2	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 16:38:34.2204+00	standard	gcash	processing	2026-03-14	\N	\N		f
43616c0c-f0b0-4815-bcfd-db9ceeaf1273	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 16:38:56.567016+00	standard	gcash	processing	2026-03-14	\N	\N		f
06338b50-bcce-4449-ba98-1a4f0aaaba09	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 16:57:18.41931+00	standard	gcash	processing	2026-03-14	\N	\N		f
5d12e4e5-4354-4b4d-a60f-1bf6ebd51cbd	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 17:14:32.143157+00	standard	gcash	processing	2026-03-14	\N	\N		f
063e03f7-99c2-47bc-8476-f947b7777cec	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 17:22:47.76245+00	standard	gcash	processing	2026-03-14	\N	\N		f
f1512590-bb2e-41fa-b3c6-8919f0ab2cbb	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	54700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 17:30:33.165359+00	standard	card	processing	2026-03-14	\N	\N		f
09455a12-4787-44c0-af2a-b701e84a5ad5	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	54700	\N	pending	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 17:31:01.378118+00	standard	maya	processing	2026-03-14	\N	\N		f
41d6381a-45ff-4e40-a9bd-247339129e25	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	16800	\N	paid	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 18:49:31.116308+00	standard	gcash	processing	2026-03-14	\N	\N		f
5439b01a-b209-4536-9120-b50ca70560ae	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	39800	\N	paid	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-12 07:29:02.031478+00	express	maya	processing	2026-03-14	\N	\N		f
246fe993-e66c-48df-8d81-87dc243ba53e	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	10400	\N	paid	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 19:30:47.369365+00	standard	gcash	processing	2026-03-14	\N	\N		f
5b6590b8-5b80-4853-8e3c-c9c6a87b752f	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	13800	\N	paid	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-10 19:33:53.026141+00	standard	gcash	processing	2026-03-14	\N	\N		f
faaaf3e5-4ec4-4c85-a267-9fd0bce8f847	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	12400	\N	paid	{"zip": "1000", "city": "Manila", "name": "JOHN CRUZ", "notes": "bilisan nyo", "phone": "09488139115", "address": "Pinagbuhatan, Pasig City", "province": "Metro Manila"}	2026-03-12 07:32:46.59229+00	standard	gcash	processing	2026-03-16	\N	\N	bilisan nyo	f
cb714728-eef3-4575-8b25-0ce1e107b137	e6093655-ee0d-4000-8b71-d5b112557bdb	151600	\N	paid	{"zip": "1602", "city": "Pasig", "name": "Den Gebhard Aboy", "notes": "", "phone": "+639497138015", "address": "100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City", "province": "Metro Manila"}	2026-03-12 07:40:50.884878+00	free	gcash	processing	2026-03-16	\N	\N		f
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, name, slug, price_cents, stock, description, img_url, model_url, created_at, category_id, specs, tags, weight_g, sku) FROM stdin;
f06d3ba5-09f5-4c03-884f-d9e60207750c	Potentiometer Linear 10k	potentiometer-linear-10k	3200	34	The 10k potentiometer is a versatile variable resistor used in various electronic applications such as volume controls, dimmer switches, and sensor calibration. This potentiometer offers precise resistance adjustment with a total resistance of 10 kilohms. With its three-terminal design, it allows for easy integration into circuits, providing smooth and reliable control over voltage levels.	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/d2e31273-c4f7-42d1-af3e-008f38106259.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/c82a4b96-9bd0-4f6e-b7fa-a9b184cb64bf.glb	2026-02-05 18:12:35.284052+00	f170f920-3d0a-4eda-a33f-52d81dc5b3a2	{}	{}	\N	\N
55d3634d-0091-4d95-a257-eed354ad0702	Arduino NANO Servo Shield	arduino-nano-servo-shield	12200	9	The Arduino Nano Servo Shield (or IO Expansion Shield) is a compact, plug-and-play breakout board designed to simplify wiring multiple servos and sensors to an Arduino Nano. It features dedicated 3-pin headers (GND, VCC, Signal) for up to 12-16 servo motors, separate external power inputs for servo motors, and breaks out all I/O pins for easy prototyping. 	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/f1aa509c-0257-4719-b856-91b414d2f4bf.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/aaae6f61-6de1-4f6a-897a-37bd2af5072a.glb	2026-02-05 14:30:55.82466+00	f0bb3bd2-99dd-4f37-847a-af2dc873fe3e	{}	{}	\N	\N
e3e7befa-5c67-4391-b863-8687d1ae0d75	Resistors	resistors	2500	100	A resistor is an essential electronic component used to control the flow of electric current in a circuit. It helps regulate voltage, protect sensitive components, and ensure stable performance in electronic devices.\n\nDesigned for reliability and precision, resistors are commonly used in appliances, computers, mobile devices, and various electronic projects. They come in different resistance values and sizes to suit a wide range of circuit applications.	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/1e270971-ee12-423f-9cbc-a7107b579e8d.png	\N	2026-03-10 05:49:34.91494+00	2f688ac5-1cad-4146-b5cf-eb6d0a9dae94	{}	{}	\N	\N
0a7f9d9c-002c-4b8b-aa3c-6233c020b5c3	HC-05 Bluetooth Module	hc-05-bluetooth-module	5900	27	Bluetooth HC 05 Module is a Bluetooth mechanism that is particularly assembled for wireless communication. You can implement the module in either Master or Slave modes and switching between these two modes is quite easy. You will get the Slave mode configured by default. Further, the Slave mode can only accept connection but can't initiate a connection to a Bluetooth-enabled device.AT command is provided to change the mode to either Master or Slave.\n\nPin Settings\nAs far as the pin configurations are concerned, the Bluetooth serial module permits all serial-enabled circuits to communicate with each other via Bluetooth. There are 6 pins in total on the unit:\n\n1. Key/EN: You can use this pin to bring the Bluetooth module in AT commands. You can execute the module in the command mode with the Key/EN pin set in high. However, the unit will remain in data mode by default.\n\n2. VCC: You can connect 5V or 3.3V to this specific pin.\n\n3. GND: It is called the Ground pin on the module.\n\n4. TXD: This pin is used to transmit serial data received by the Bluetooth module.\n\n5. RXD: This pin allows you to receive data serially transmitted by a Bluetooth module.\n\n6. State: This pin indicated whether the module is connected or not.\n\nTo perform Bluetooth communications, you can send data from the smartphone terminal to the HC 05 Bluetooth Module and see it on the PC and vice versa. There are several Bluetooth terminal applications for Android and Windows in their respective app stores.	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/cdc7cb90-0250-43a3-8005-4aee47e7e5e0.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/22c03c4a-1f9a-42a7-a14d-34857e70617a.glb	2026-02-05 18:19:22.334063+00	f170f920-3d0a-4eda-a33f-52d81dc5b3a2	{}	{}	\N	\N
6004ffc7-d262-40d5-93b8-41e861a6d3bf	Arduino UNO 	arduino-uno	15900	12	The Arduino Uno is a popular, open-source 8-bit microcontroller board based on the ATmega328P. It features 14 digital I/O pins (6 PWM), 6 analog inputs, a 16 MHz resonator, and a USB connection for programming. Designed for beginners and experts alike, it is easily powered via USB or a 7-20V adapter and used with the Arduino IDE. 	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/97407dbf-5adb-40e1-9124-eef85c166b23.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/7e5c4c6e-0d44-4584-acd1-d9c4203c33ec.glb	2026-02-05 14:23:09.881072+00	f0bb3bd2-99dd-4f37-847a-af2dc873fe3e	{}	{}	\N	\N
6bce89f5-ffad-4c84-92bf-ba9c0254d1f6	Relay Module to 5V 10A	relay-module-to-5v-10a	6500	16	The Relay is a digital normally open switch that controls a relay capable of switching much higher voltages and currents than your normal Arduino boards. When set to HIGHT, the LED will light up and the relay will close allowing current to flow. The peak voltage capability is 250V at 10 amps.\n\nFeatures:\n\nControl Voltage: 5V\nHIGHT level active\nMax Control Capacity: 10A@250V AC\nPackage List:\n\n1 x 1-Channel Relay Module-10A	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/26cf5f04-66a4-47cc-ad7f-14e8a61739ee.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/798a8853-d48b-45ef-9c19-8ec893020b73.glb	2026-02-05 18:25:39.428286+00	36225f90-95bf-485d-9808-acb8d7528135	{}	{}	\N	\N
5773bfda-ef03-4035-9e55-550c78189086	MB-102 Breadboard	mb-102-breadboard	10200	16	Easy to use: Our solderless breadboards are ideal for your prototypes, circuit design experiments and other DIY projects.\n\nEach row and column has corresponding letters and numbers, which makes it easier to use and prevents errors.\n\nPractical and reusable: The self-adhesive backing tape makes it easy to stick on a platform, as with the prototype sign\n\nWith tight plug-in contacts, the components sit well after assembly and there is no wobbling.\n\nOur plug-in boards do not need to be soldered and are therefore fully reusable. This makes it easy to create temporary prototypes and experiment with circuit design, which provides a design basis for prototype electronics.\n\nCompatible with resistors, transistors, diodes, LEDs, capacitors and other types of electronic components	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/56e799bb-79ba-4ed2-b9d3-c45cd617cceb.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/5678a96e-c44c-40b6-b56b-263ba75a9fac.glb	2026-02-05 18:02:43.672079+00	f0bb3bd2-99dd-4f37-847a-af2dc873fe3e	{}	{}	\N	\N
07f84eca-04ae-4fbd-9e50-8ca62f83ab8a	Capacitors	capacitors	3000	100	Arduino capacitors are electronic components commonly used in Arduino circuits to store and release electrical energy. They help stabilize voltage, filter noise, smooth power supply signals, and manage timing functions in electronic projects.	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/98e6dd6c-72ea-4c9d-9184-e8f406af46c0.png	\N	2026-03-10 06:33:06.157715+00	2f688ac5-1cad-4146-b5cf-eb6d0a9dae94	{}	{}	\N	\N
ff47bb9b-029c-4260-95f8-55dfb77243f3	Sound Sensor	sound-sensor	5900	100	Detect sound levels easily with this sound sensor module for Arduino projects. It can sense claps, noise, or vibrations and convert them into signals for your Arduino board. Perfect for sound-activated lights, alarms, and interactive DIY electronics projects.	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/422a6325-7737-4119-b177-1e6ecb102138.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/2041023f-b946-4f97-9383-1536809a0ac0.glb	2026-03-10 07:49:25.38313+00	f170f920-3d0a-4eda-a33f-52d81dc5b3a2	{}	{}	\N	\N
639dc664-12af-4e16-9ae7-f4e3c1a2136e	Temperature Module	temperature-module	3900	98	Monitor temperature easily with this temperature sensor module for Arduino projects. It provides accurate temperature readings that can be used for weather stations, smart systems, and monitoring applications. Simple to connect and compatible with most Arduino boards, making it perfect for beginners and electronics enthusiasts	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/e21fae93-99f7-484f-8d88-ed50d972a412.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/cea93ac8-84f0-4c5b-832d-f5df2f39bda7.glb	2026-03-10 07:31:38.483122+00	f170f920-3d0a-4eda-a33f-52d81dc5b3a2	{}	{}	\N	\N
fd165f0d-b345-4395-ae2c-3ca8a863ddf2	IR Sensor 	ir-sensor	4900	100	Detect objects and measure distance easily with this reliable IR Sensor. It is commonly used in Arduino projects for obstacle detection, line tracking, and automation systems. Simple to connect and compatible with most Arduino boards, this sensor is perfect for beginners and electronics enthusiasts.	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/44234c82-c862-4e2a-8f5f-b548bab0ba7d.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/0a344110-96f9-4df9-a5af-709af9929d76.glb	2026-03-10 07:15:05.383051+00	f170f920-3d0a-4eda-a33f-52d81dc5b3a2	{}	{}	\N	\N
4f7a2bf3-084a-413d-8181-133aafa3c612	Buzzer	buzzer	5900	100	Add sound alerts and simple audio signals to your Arduino projects with this buzzer module. It is perfect for alarms, notifications, and interactive electronics. Easy to connect and compatible with most Arduino boards, making it great for beginners and DIY electronics projects.	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/e2d480dc-f37f-4507-99f9-7c8dcb8e0fca.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/a19fbe31-6ed2-447e-9e06-549e895e79e0.glb	2026-03-10 07:27:38.430723+00	f170f920-3d0a-4eda-a33f-52d81dc5b3a2	{}	{}	\N	\N
3d3a4f22-1aac-45ac-b25c-73b9c523c37e	Male to Male Jumper Wires	male-to-male-jumper-wires	2500	99	Male-to-male jumper wires are electrical connection cables used in Arduino and breadboard projects to easily link components together without soldering. Each wire has male pin connectors on both ends, allowing them to plug directly into breadboards, Arduino headers, and other electronic modules.	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/b240c690-388d-4830-8b12-ec1f0a2ef308.png	\N	2026-03-10 06:37:05.83519+00	2f688ac5-1cad-4146-b5cf-eb6d0a9dae94	{}	{}	\N	\N
ad6d9092-30c4-46e2-a3a9-c7d0537b126b	16 x 2 LCD Display	16-x-2-lcd-display	14900	23	Display text and simple information easily with this 16×2 LCD module for Arduino. It can show up to 16 characters on 2 lines, making it perfect for displaying sensor data, messages, and project status. Easy to connect and widely used in Arduino projects, it is great for both beginners and advanced makers	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/06419f6d-9d1d-4855-9759-82c79bf466bb.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/f81abdff-48e2-4ae3-b932-9da5484552ce.glb	2026-03-10 07:20:07.287718+00	f0bb3bd2-99dd-4f37-847a-af2dc873fe3e	{}	{}	\N	\N
3a10d52f-9131-403b-a1ea-1004fd685cc4	Ultrasonic Sensor	ultrasonic-sensor	29900	98	Measure distance and detect objects with this ultrasonic sensor for Arduino projects. It uses sound waves to accurately calculate distance, making it perfect for obstacle detection, robotics, and automation systems. Easy to connect and widely used by beginners and hobbyists in DIY electronics.	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/43c86d7d-8451-46a7-9245-22d197e1e802.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/12541e28-4d8b-4358-a23f-de6cfc2a5a1d.glb	2026-03-10 07:37:17.352039+00	f170f920-3d0a-4eda-a33f-52d81dc5b3a2	{}	{}	\N	\N
e86d8889-61d6-4e97-a3a2-344a852b6efa	Motion Sensor	motion-sensor	6900	99	Detect movement easily with this PIR motion sensor for Arduino projects. It senses infrared changes from people or objects and triggers a signal when motion is detected. Perfect for security systems, automatic lights, and smart home DIY projects.	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/86dc093b-a396-4ed6-bfa8-dec762e7808a.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/c34a6abd-c4fc-4e53-b579-7f4ad1a1e947.glb	2026-03-10 07:59:40.756476+00	f170f920-3d0a-4eda-a33f-52d81dc5b3a2	{}	{}	\N	\N
75a67a8c-a785-4ac9-9502-51e353a71a0f	Led Lights	led-lights	500	99	Brighten your Arduino projects with this high-quality LED. It is perfect for beginners and hobbyists who want to add simple lighting indicators or visual effects to their circuits. Easy to connect and compatible with most Arduino boards, this LED is ideal for learning electronics and creating fun DIY projects. 	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/f99a6818-5a4f-4197-af19-2274bfb5a932.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/0ad6aad9-bdc9-4310-96fd-edb12a6efc1a.glb	2026-03-10 06:58:27.464601+00	2f688ac5-1cad-4146-b5cf-eb6d0a9dae94	{}	{}	\N	\N
9a6bbf2c-b515-4e11-b403-9d1d3b7a2fa8	Wifi Module ESP32	wifi-module-esp32	37900	96	The ESP32 WiFi Module is a powerful and versatile microcontroller with built-in WiFi and Bluetooth connectivity. It is ideal for IoT projects, smart devices, and wireless communication applications.\n\nDesigned for efficiency and performance, the ESP32 allows developers and hobbyists to easily connect their projects to the internet, control devices remotely, and build smart systems using platforms like Arduino IDE and MicroPython.	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/e7bb5e18-f5c3-4c9f-957b-2f78910087d2.png	https://tyhocgrjwxswxzzfvwct.supabase.co/storage/v1/object/public/models/ba8ec5a2-ff90-4ab1-9d44-fc134444bf22.glb	2026-03-10 08:18:47.745297+00	f0bb3bd2-99dd-4f37-847a-af2dc873fe3e	{}	{}	\N	\N
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profiles (id, email, username, first_name, middle_name, last_name, suffix, contact_number, address, terms_accepted, rules_accepted, created_at) FROM stdin;
0c55e50d-aa38-4bae-8c07-d72232af595f	mondjonray@gmail.com	Combi	JOHN	RAYMOND B.	CRUZ	\N	09488139115	Pinagbuhatan, Pasig City	t	t	2026-03-04 08:39:20.681473+00
569d5adc-8f2f-4a4a-ad47-f09cd8e69193	\N	Jebard	Den Gebhard	Sardina	Aboy	\N	+639497138015	100 San Ricardo St., Pinalad Rd., Centennial 2, Pinagbuhatan Pasig City	t	t	2026-03-06 14:14:13.071243+00
1ad66014-608b-45d0-9c15-9ab69eec9a07	\N	Jass11	John Jasseim	Lanzuela	Cabrillos	\N	09982854162	25D Kentuckty St. Bambang Taguig City	t	t	2026-03-07 03:17:38.664148+00
cabc047b-2cb0-4808-8a1d-658858bd00f3	\N	combi	john	combi	koji	\N	09508149861	Pinabuhatan Pasig	t	t	2026-03-07 04:09:47.449218+00
1acb1b11-931e-49ae-93e4-8689247327c8	\N	\N	\N	\N	\N	\N	\N	\N	f	f	2026-03-11 10:06:23.064958+00
e6093655-ee0d-4000-8b71-d5b112557bdb	\N	\N	\N	\N	\N	\N	\N	\N	f	f	2026-03-12 07:38:35.112489+00
\.


--
-- Data for Name: promos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promos (id, code, discount_percent, valid_from, valid_until, max_uses, used_count, is_free_shipping, min_order_cents, description) FROM stdin;
bc060cec-0c35-4205-8d04-a1c3637d2d21	FREESHIP	0	2026-03-10 08:24:33.729062+00	2031-03-10 08:24:33.729062+00	\N	0	t	150000	Free shipping on orders over PHP 1,500
d6d4aff8-5d14-4f89-a40d-d30834ef3edf	WELCOME15	15	2026-03-10 08:24:33.729062+00	2027-03-10 08:24:33.729062+00	500	0	f	0	Welcome offer — 15% off your first order
ba01f660-3a0a-4e28-9cbc-e27ef83353bc	ARDUINO10	10	2026-03-10 08:24:33.729062+00	2027-03-10 08:24:33.729062+00	1000	0	f	0	10% off sitewide
\.


--
-- Data for Name: refund_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refund_requests (id, order_id, user_id, reason, status, created_at, resolved_at) FROM stdin;
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reviews (id, product_id, user_id, rating, comment, created_at) FROM stdin;
\.


--
-- Data for Name: variants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.variants (id, product_id, variant_name, option_value, price_adjustment, stock, img_url) FROM stdin;
\.


--
-- Data for Name: wishlists; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wishlists (id, user_id, product_id, created_at) FROM stdin;
53327cb3-d0ba-4c27-abce-6dde6a610e72	569d5adc-8f2f-4a4a-ad47-f09cd8e69193	0a7f9d9c-002c-4b8b-aa3c-6233c020b5c3	2026-03-07 04:21:51.754861+00
0a0e9e4c-53d3-4671-8198-db7ca4dc6c01	1ad66014-608b-45d0-9c15-9ab69eec9a07	55d3634d-0091-4d95-a257-eed354ad0702	2026-03-10 05:19:13.811155+00
4943d26c-4da8-448e-952e-bfafec8e061d	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	ff47bb9b-029c-4260-95f8-55dfb77243f3	2026-03-10 08:03:04.192268+00
\.


--
-- Data for Name: messages_2026_03_09; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_03_09 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2026_03_10; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_03_10 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2026_03_11; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_03_11 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2026_03_12; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_03_12 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2026_03_13; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_03_13 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2026_03_14; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_03_14 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2026_03_15; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_03_15 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2026-01-04 11:55:27
20211116045059	2026-01-04 11:55:27
20211116050929	2026-01-04 11:55:27
20211116051442	2026-01-04 11:55:27
20211116212300	2026-01-04 11:55:27
20211116213355	2026-01-04 11:55:27
20211116213934	2026-01-04 11:55:27
20211116214523	2026-01-04 11:55:27
20211122062447	2026-01-04 11:55:27
20211124070109	2026-01-04 11:55:27
20211202204204	2026-01-04 11:55:27
20211202204605	2026-01-04 11:55:27
20211210212804	2026-01-04 11:55:27
20211228014915	2026-01-04 11:55:27
20220107221237	2026-01-04 11:55:27
20220228202821	2026-01-04 11:55:27
20220312004840	2026-01-04 11:55:27
20220603231003	2026-01-04 11:55:27
20220603232444	2026-01-04 11:55:27
20220615214548	2026-01-04 11:55:27
20220712093339	2026-01-04 11:55:27
20220908172859	2026-01-04 11:55:27
20220916233421	2026-01-04 11:55:27
20230119133233	2026-01-04 11:55:27
20230128025114	2026-01-04 11:55:27
20230128025212	2026-01-04 11:55:27
20230227211149	2026-01-04 11:55:27
20230228184745	2026-01-04 11:55:27
20230308225145	2026-01-04 11:55:27
20230328144023	2026-01-04 11:55:27
20231018144023	2026-01-04 11:55:27
20231204144023	2026-01-04 11:55:27
20231204144024	2026-01-04 11:55:27
20231204144025	2026-01-04 11:55:27
20240108234812	2026-01-04 11:55:27
20240109165339	2026-01-04 11:55:27
20240227174441	2026-01-04 11:55:27
20240311171622	2026-01-04 11:55:28
20240321100241	2026-01-04 11:55:28
20240401105812	2026-01-04 11:55:28
20240418121054	2026-01-04 11:55:28
20240523004032	2026-01-04 11:55:28
20240618124746	2026-01-04 11:55:28
20240801235015	2026-01-04 11:55:28
20240805133720	2026-01-04 11:55:28
20240827160934	2026-01-04 11:55:28
20240919163303	2026-01-04 11:55:28
20240919163305	2026-01-04 11:55:28
20241019105805	2026-01-04 11:55:28
20241030150047	2026-01-04 11:55:28
20241108114728	2026-01-04 11:55:28
20241121104152	2026-01-04 11:55:28
20241130184212	2026-01-04 11:55:28
20241220035512	2026-01-04 11:55:28
20241220123912	2026-01-04 11:55:28
20241224161212	2026-01-04 11:55:28
20250107150512	2026-01-04 11:55:28
20250110162412	2026-01-04 11:55:28
20250123174212	2026-01-04 11:55:28
20250128220012	2026-01-04 11:55:28
20250506224012	2026-01-04 11:55:28
20250523164012	2026-01-04 11:55:28
20250714121412	2026-01-04 11:55:28
20250905041441	2026-01-04 11:55:28
20251103001201	2026-01-04 11:55:28
20251120212548	2026-02-05 07:17:11
20251120215549	2026-02-05 07:17:11
20260218120000	2026-02-27 16:07:17
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at, action_filter) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
models	models	\N	2026-01-04 12:42:56.309118+00	2026-01-04 12:42:56.309118+00	t	f	\N	\N	\N	STANDARD
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2026-01-04 11:55:25.125209
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2026-01-04 11:55:25.170432
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2026-01-04 11:55:25.209875
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2026-01-04 11:55:25.299771
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2026-01-04 11:55:25.30255
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2026-01-04 11:55:25.309176
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2026-01-04 11:55:25.31179
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2026-01-04 11:55:25.321566
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2026-01-04 11:55:25.326141
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2026-01-04 11:55:25.329157
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2026-01-04 11:55:25.332628
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2026-01-04 11:55:25.356177
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2026-01-04 11:55:25.359859
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2026-01-04 11:55:25.362492
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2026-01-04 11:55:25.365191
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2026-01-04 11:55:25.37084
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2026-01-04 11:55:25.373738
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2026-01-04 11:55:25.378637
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2026-01-04 11:55:25.394136
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2026-01-04 11:55:25.403535
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2026-01-04 11:55:25.407998
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2026-01-04 11:55:25.411011
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2026-01-04 11:55:26.257471
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2026-01-04 11:55:26.289574
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2026-01-04 11:55:26.292645
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2026-01-04 11:55:26.303427
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2026-01-04 11:55:26.306189
49	buckets-objects-grants-postgres	072b1195d0d5a2f888af6b2302a1938dd94b8b3d	2026-01-04 11:55:26.321014
2	storage-schema	f6a1fa2c93cbcd16d4e487b362e45fca157a8dbd	2026-01-04 11:55:25.175215
6	change-column-name-in-get-size	ded78e2f1b5d7e616117897e6443a925965b30d2	2026-01-04 11:55:25.305895
9	fix-search-function	af597a1b590c70519b464a4ab3be54490712796b	2026-01-04 11:55:25.314666
10	search-files-search-function	b595f05e92f7e91211af1bbfe9c6a13bb3391e16	2026-01-04 11:55:25.318592
26	objects-prefixes	215cabcb7f78121892a5a2037a09fedf9a1ae322	2026-01-04 11:55:25.41377
27	search-v2	859ba38092ac96eb3964d83bf53ccc0b141663a6	2026-01-04 11:55:25.425192
28	object-bucket-name-sorting	c73a2b5b5d4041e39705814fd3a1b95502d38ce4	2026-01-04 11:55:26.217644
29	create-prefixes	ad2c1207f76703d11a9f9007f821620017a66c21	2026-01-04 11:55:26.221669
30	update-object-levels	2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6	2026-01-04 11:55:26.225721
31	objects-level-index	b40367c14c3440ec75f19bbce2d71e914ddd3da0	2026-01-04 11:55:26.231894
32	backward-compatible-index-on-objects	e0c37182b0f7aee3efd823298fb3c76f1042c0f7	2026-01-04 11:55:26.237939
33	backward-compatible-index-on-prefixes	b480e99ed951e0900f033ec4eb34b5bdcb4e3d49	2026-01-04 11:55:26.243991
34	optimize-search-function-v1	ca80a3dc7bfef894df17108785ce29a7fc8ee456	2026-01-04 11:55:26.245534
35	add-insert-trigger-prefixes	458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc	2026-01-04 11:55:26.249778
36	optimise-existing-functions	6ae5fca6af5c55abe95369cd4f93985d1814ca8f	2026-01-04 11:55:26.252325
38	iceberg-catalog-flag-on-buckets	02716b81ceec9705aed84aa1501657095b32e5c5	2026-01-04 11:55:26.260525
39	add-search-v2-sort-support	6706c5f2928846abee18461279799ad12b279b78	2026-01-04 11:55:26.269082
40	fix-prefix-race-conditions-optimized	7ad69982ae2d372b21f48fc4829ae9752c518f6b	2026-01-04 11:55:26.272401
41	add-object-level-update-trigger	07fcf1a22165849b7a029deed059ffcde08d1ae0	2026-01-04 11:55:26.278418
42	rollback-prefix-triggers	771479077764adc09e2ea2043eb627503c034cd4	2026-01-04 11:55:26.281899
43	fix-object-level	84b35d6caca9d937478ad8a797491f38b8c2979f	2026-01-04 11:55:26.28588
48	iceberg-catalog-ids	e0e8b460c609b9999ccd0df9ad14294613eed939	2026-01-04 11:55:26.308637
50	search-v2-optimised	6323ac4f850aa14e7387eb32102869578b5bd478	2026-02-13 05:21:45.958186
51	index-backward-compatible-search	2ee395d433f76e38bcd3856debaf6e0e5b674011	2026-02-13 05:21:46.099088
52	drop-not-used-indexes-and-functions	5cc44c8696749ac11dd0dc37f2a3802075f3a171	2026-02-13 05:21:46.100299
53	drop-index-lower-name	d0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854	2026-02-13 05:21:46.224115
54	drop-index-object-level	6289e048b1472da17c31a7eba1ded625a6457e67	2026-02-13 05:21:46.226369
55	prevent-direct-deletes	262a4798d5e0f2e7c8970232e03ce8be695d5819	2026-02-13 05:21:46.227521
56	fix-optimized-search-function	cb58526ebc23048049fd5bf2fd148d18b04a2073	2026-02-13 05:21:46.235486
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
3a6670f0-be3b-49ee-9070-7f5d6e4b19c4	models	42c57fbc-d5cb-421f-8f01-40cda14ade21.jpg	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 07:34:38.764944+00	2026-02-05 07:34:38.764944+00	2026-02-05 07:34:38.764944+00	{"eTag": "\\"620129d933757c8dac0824dcf793082c\\"", "size": 11471, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T07:34:39.000Z", "contentLength": 11471, "httpStatusCode": 200}	407ef23d-bb6a-4309-b797-d18c95b83bd0	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
9f8d3b6d-3ab8-433f-be98-9f01a2e4ce3f	models	a3894d1e-c57e-4bc4-8361-8194a8f93e94.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 07:34:43.141252+00	2026-02-05 07:34:43.141252+00	2026-02-05 07:34:43.141252+00	{"eTag": "\\"d8feb50684c0622a89b5681ef3f1da23-2\\"", "size": 9389360, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T07:34:43.000Z", "contentLength": 9389360, "httpStatusCode": 200}	c6f3deaf-93b4-4735-a582-13c8980023bf	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
be31e06a-4d1b-42ba-8a1a-7e392e41b6a5	models	fdb8fd6f-9e47-4ddf-9d20-6c760cd99e86.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 14:20:42.029333+00	2026-02-05 14:20:42.029333+00	2026-02-05 14:20:42.029333+00	{"eTag": "\\"b474523c79ee77a731cd0a1e4e8c2059\\"", "size": 446882, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T14:20:43.000Z", "contentLength": 446882, "httpStatusCode": 200}	ee4700db-93f7-4903-bafb-da13728580a2	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
a5ef943d-c89d-41a8-80b9-39c0545ecf22	models	97407dbf-5adb-40e1-9124-eef85c166b23.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 14:23:05.857393+00	2026-02-05 14:23:05.857393+00	2026-02-05 14:23:05.857393+00	{"eTag": "\\"b474523c79ee77a731cd0a1e4e8c2059\\"", "size": 446882, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T14:23:06.000Z", "contentLength": 446882, "httpStatusCode": 200}	b9aa7919-2dd8-4726-ae4e-a6bcf99ec321	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
0577c4f8-bd0a-47f4-b8f5-aa6c4186ab8d	models	7e5c4c6e-0d44-4584-acd1-d9c4203c33ec.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 14:23:09.378825+00	2026-02-05 14:23:09.378825+00	2026-02-05 14:23:09.378825+00	{"eTag": "\\"d43eafb93b403092f7789e902740a602\\"", "size": 4491236, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T14:23:10.000Z", "contentLength": 4491236, "httpStatusCode": 200}	c81c8254-4293-48c4-bafa-693606043723	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
464195a2-666f-4263-9e16-c440860fe974	models	f1aa509c-0257-4719-b856-91b414d2f4bf.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 14:30:54.157774+00	2026-02-05 14:30:54.157774+00	2026-02-05 14:30:54.157774+00	{"eTag": "\\"3a3e334bd1ed72827251b46ed15861e3-2\\"", "size": 7155829, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T14:30:54.000Z", "contentLength": 7155829, "httpStatusCode": 200}	4c7d9828-b06a-4493-9783-efd0e218c899	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
1558837b-2176-432a-8d68-93f9148300a1	models	aaae6f61-6de1-4f6a-897a-37bd2af5072a.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 14:30:55.557369+00	2026-02-05 14:30:55.557369+00	2026-02-05 14:30:55.557369+00	{"eTag": "\\"92fadf956ae76cb357dc267f7cc90fe5\\"", "size": 2603204, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T14:30:56.000Z", "contentLength": 2603204, "httpStatusCode": 200}	a506e323-445f-402c-bad7-2f13f10a9d65	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
b4365aa5-3aa3-4352-a529-89360b145698	models	56e799bb-79ba-4ed2-b9d3-c45cd617cceb.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 18:02:43.110046+00	2026-02-05 18:02:43.110046+00	2026-02-05 18:02:43.110046+00	{"eTag": "\\"42a7d9ccf20de098cf20ce228ce0b052\\"", "size": 1589968, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T18:02:44.000Z", "contentLength": 1589968, "httpStatusCode": 200}	1e35f744-14b8-4e0c-a505-383565e50664	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
696b3573-d76c-4954-92d6-ae508f0bffbf	models	5678a96e-c44c-40b6-b56b-263ba75a9fac.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 18:02:43.398056+00	2026-02-05 18:02:43.398056+00	2026-02-05 18:02:43.398056+00	{"eTag": "\\"79ac5288d9c927ad7f9ba9d0ed740e43\\"", "size": 319452, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T18:02:44.000Z", "contentLength": 319452, "httpStatusCode": 200}	7d83ff29-4145-49a6-afde-d2e9a5656a71	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
da5f05d4-91cf-452b-a548-3b20815b1434	models	d2e31273-c4f7-42d1-af3e-008f38106259.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 18:12:33.41561+00	2026-02-05 18:12:33.41561+00	2026-02-05 18:12:33.41561+00	{"eTag": "\\"091fe4a888de40287daa0e20107dd761\\"", "size": 40259, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T18:12:34.000Z", "contentLength": 40259, "httpStatusCode": 200}	a31cad2a-ed3b-4e02-80c5-e6844c4433de	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
27f6bbac-f3ab-448e-aded-556c19c686af	models	c82a4b96-9bd0-4f6e-b7fa-a9b184cb64bf.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 18:12:34.999449+00	2026-02-05 18:12:34.999449+00	2026-02-05 18:12:34.999449+00	{"eTag": "\\"7785df07e815113d63e9b5339250eb16\\"", "size": 1487636, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T18:12:35.000Z", "contentLength": 1487636, "httpStatusCode": 200}	751ee178-5619-4251-810c-1c4e4909e569	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
147d4812-299a-45f5-bef1-4bab22de722a	models	cdc7cb90-0250-43a3-8005-4aee47e7e5e0.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 18:19:20.727652+00	2026-02-05 18:19:20.727652+00	2026-02-05 18:19:20.727652+00	{"eTag": "\\"92ff262f8e345575be52ea1887b89057\\"", "size": 225603, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T18:19:21.000Z", "contentLength": 225603, "httpStatusCode": 200}	c1bd95ce-83b6-4ad0-9459-0c070b1231d0	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
298ae93a-4325-4f51-b667-8a030d625ea5	models	22c03c4a-1f9a-42a7-a14d-34857e70617a.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 18:19:21.996835+00	2026-02-05 18:19:21.996835+00	2026-02-05 18:19:21.996835+00	{"eTag": "\\"2379c89054b8876ea80174a1a4cd0738\\"", "size": 469996, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T18:19:22.000Z", "contentLength": 469996, "httpStatusCode": 200}	8a4fb1f7-c618-4acd-a6e8-6db4e025cf5b	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
aa4afe1c-6f38-4d14-ae7a-44d3bd8adec8	models	26cf5f04-66a4-47cc-ad7f-14e8a61739ee.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 18:25:38.383661+00	2026-02-05 18:25:38.383661+00	2026-02-05 18:25:38.383661+00	{"eTag": "\\"546937963519cc38bde6e1190bcedad2\\"", "size": 332849, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T18:25:39.000Z", "contentLength": 332849, "httpStatusCode": 200}	30b915ce-4fcd-410f-8be7-e7240009d81e	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
3d6c5102-5c9d-41f2-b84a-506f1d8eaeea	models	798a8853-d48b-45ef-9c19-8ec893020b73.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-02-05 18:25:39.275784+00	2026-02-05 18:25:39.275784+00	2026-02-05 18:25:39.275784+00	{"eTag": "\\"3fa9506795990f0876560c658e7ebc48\\"", "size": 349308, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-02-05T18:25:40.000Z", "contentLength": 349308, "httpStatusCode": 200}	ade4b378-46c7-47a4-afcc-a194befec2fe	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
40313355-c5bf-4123-aa80-c71f9431c350	models	c8e2de2a-1a71-4825-ad54-1c31d10b75b5.webp	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 05:49:34.674315+00	2026-03-10 05:49:34.674315+00	2026-03-10 05:49:34.674315+00	{"eTag": "\\"c5f292007a48fbdd186f6e9701d8e480\\"", "size": 31552, "mimetype": "image/webp", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T05:49:35.000Z", "contentLength": 31552, "httpStatusCode": 200}	1de2cb6f-9b32-4fac-ad3d-04ab45dd6e0e	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
e246dbb0-28d8-49c5-9fef-7c70ae2a1910	models	1e270971-ee12-423f-9cbc-a7107b579e8d.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 05:53:32.103502+00	2026-03-10 05:53:32.103502+00	2026-03-10 05:53:32.103502+00	{"eTag": "\\"57f5c64251ed54041a6e82c1e85e0198\\"", "size": 389067, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T05:53:33.000Z", "contentLength": 389067, "httpStatusCode": 200}	17541f99-5605-4c99-8785-2ce8d07ac270	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
aa264820-969b-4e62-bad6-956c39232d4c	models	98e6dd6c-72ea-4c9d-9184-e8f406af46c0.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 06:33:05.872464+00	2026-03-10 06:33:05.872464+00	2026-03-10 06:33:05.872464+00	{"eTag": "\\"2507868a14c41077a3b6c9928c87b72a\\"", "size": 59684, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T06:33:06.000Z", "contentLength": 59684, "httpStatusCode": 200}	0bad9c78-3e58-44f0-a344-5496517fcd35	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
0461c573-d0cd-421b-a858-ab6e6faedc20	models	0e93564c-c4a2-429a-aae3-5fd277f856b3.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 06:37:05.650123+00	2026-03-10 06:37:05.650123+00	2026-03-10 06:37:05.650123+00	{"eTag": "\\"37e5a5d032613c8810b46813eb57db62\\"", "size": 56938, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T06:37:06.000Z", "contentLength": 56938, "httpStatusCode": 200}	03b4fb77-164c-404a-9b29-92fec6b8ee36	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
7e425e41-8cc5-42d8-b54c-1b2fe2c9a215	models	b240c690-388d-4830-8b12-ec1f0a2ef308.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 06:39:27.484951+00	2026-03-10 06:39:27.484951+00	2026-03-10 06:39:27.484951+00	{"eTag": "\\"993004faa7dcf7344db6e5b980e90f16\\"", "size": 215496, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T06:39:28.000Z", "contentLength": 215496, "httpStatusCode": 200}	a3243ba5-9905-4e0e-8867-ac68d903eaf2	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
8a330e4a-6461-4a5a-8582-58370e6e2376	models	f99a6818-5a4f-4197-af19-2274bfb5a932.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 06:58:26.415209+00	2026-03-10 06:58:26.415209+00	2026-03-10 06:58:26.415209+00	{"eTag": "\\"26e52701fa6e807db1b4ed14e513830f\\"", "size": 514019, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T06:58:27.000Z", "contentLength": 514019, "httpStatusCode": 200}	74a242b8-e3b5-4050-afcf-f224b2982a7c	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
867fd3fa-b1c0-4717-a96c-0bc475379974	models	79294fe7-4e0b-4986-9934-fecf07bf6fb4.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 06:58:26.862819+00	2026-03-10 06:58:26.862819+00	2026-03-10 06:58:26.862819+00	{"eTag": "\\"8f59aa564e38e20bdaeacb25c8f14733\\"", "size": 138288, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T06:58:27.000Z", "contentLength": 138288, "httpStatusCode": 200}	9314a390-4a61-4c13-b06e-718fa230b828	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
6b49149b-2fd9-4310-a449-e53bfe830a7b	models	8cc76458-8b06-4c15-a7e0-f0945deafda7.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:03:48.25007+00	2026-03-10 07:03:48.25007+00	2026-03-10 07:03:48.25007+00	{"eTag": "\\"8f59aa564e38e20bdaeacb25c8f14733\\"", "size": 138288, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:03:49.000Z", "contentLength": 138288, "httpStatusCode": 200}	cf6e76b8-9fdd-45b1-9a33-b8c8e88b6f48	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
a38676c9-b9fa-4055-87b8-8152a4ee028e	models	c22abb04-a614-454e-a4fa-9bd988e6ac86.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:05:13.44519+00	2026-03-10 07:05:13.44519+00	2026-03-10 07:05:13.44519+00	{"eTag": "\\"2c48383ef5767e36081f40a2c3f8b459\\"", "size": 1928644, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:05:14.000Z", "contentLength": 1928644, "httpStatusCode": 200}	7ebee626-d37e-4cde-a63c-9933a7cdfde9	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
89aa2a3e-e415-4edd-9dcb-c330bfd3c1f7	models	0ad6aad9-bdc9-4310-96fd-edb12a6efc1a.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:06:13.791302+00	2026-03-10 07:06:13.791302+00	2026-03-10 07:06:13.791302+00	{"eTag": "\\"8f59aa564e38e20bdaeacb25c8f14733\\"", "size": 138288, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:06:14.000Z", "contentLength": 138288, "httpStatusCode": 200}	f11fec16-9e8e-4a7b-90f1-2a3876cf0048	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
644a9105-7986-48fd-b3c9-c9dae1a633a7	models	44234c82-c862-4e2a-8f5f-b548bab0ba7d.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:15:02.562261+00	2026-03-10 07:15:02.562261+00	2026-03-10 07:15:02.562261+00	{"eTag": "\\"cfabd233328e68e63383fc0af8e15453\\"", "size": 580402, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:15:03.000Z", "contentLength": 580402, "httpStatusCode": 200}	fa7c34d9-381a-4fa7-86d2-2a5ae6c25715	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
23c04997-4844-4fe4-88b6-97d455ae2e9a	models	5475b1ba-0082-4846-a95d-9e659ef461c5.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:15:04.933221+00	2026-03-10 07:15:04.933221+00	2026-03-10 07:15:04.933221+00	{"eTag": "\\"cfabd233328e68e63383fc0af8e15453\\"", "size": 580402, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:15:05.000Z", "contentLength": 580402, "httpStatusCode": 200}	463755fa-85f8-478f-84fb-dcd37ad4cae5	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
4fbe9a77-516d-4a26-8392-1ec0fdeb6bcd	models	0a344110-96f9-4df9-a5af-709af9929d76.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:15:04.97122+00	2026-03-10 07:15:04.97122+00	2026-03-10 07:15:04.97122+00	{"eTag": "\\"25545bc637241a9f05844c492f376837\\"", "size": 2811656, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:15:05.000Z", "contentLength": 2811656, "httpStatusCode": 200}	1c3e1bdd-b222-4e31-95b6-10be7f42156c	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
fd3c363f-a442-4342-83e9-6fc7d394e441	models	de0849d5-a7c5-4343-a625-f7e6e9d1e4d9.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:15:14.477491+00	2026-03-10 07:15:14.477491+00	2026-03-10 07:15:14.477491+00	{"eTag": "\\"25545bc637241a9f05844c492f376837\\"", "size": 2811656, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:15:14.000Z", "contentLength": 2811656, "httpStatusCode": 200}	5991a579-7efa-4c5f-bd50-2b6c24b46746	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
4fd1ba1b-67eb-4bee-a520-42d3e62268c2	models	06419f6d-9d1d-4855-9759-82c79bf466bb.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:20:05.183297+00	2026-03-10 07:20:05.183297+00	2026-03-10 07:20:05.183297+00	{"eTag": "\\"e4ab60c1e5deaae1a2fab6c4d2111527\\"", "size": 1013034, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:20:06.000Z", "contentLength": 1013034, "httpStatusCode": 200}	4b63e578-7809-401b-af50-5a4c88039289	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
04bac5b6-9f83-4f6a-91d9-15cc4a35b1b9	models	f81abdff-48e2-4ae3-b932-9da5484552ce.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:20:07.046159+00	2026-03-10 07:20:07.046159+00	2026-03-10 07:20:07.046159+00	{"eTag": "\\"d2864ebe16ffaf11d9e49bb0faf5a161\\"", "size": 537664, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:20:08.000Z", "contentLength": 537664, "httpStatusCode": 200}	cd6786c8-9075-4566-aa3d-cf2c7923a271	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
74af48c7-8ca5-4f88-8c40-b50175e108fb	models	e2d480dc-f37f-4507-99f9-7c8dcb8e0fca.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:27:37.400739+00	2026-03-10 07:27:37.400739+00	2026-03-10 07:27:37.400739+00	{"eTag": "\\"6419fda6e6e72ce7114c8633cf02b34a\\"", "size": 37788, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:27:38.000Z", "contentLength": 37788, "httpStatusCode": 200}	f194aa16-b369-48b4-b557-af840f58da56	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
d50d8604-751f-4044-81a8-253bac8d1298	models	a19fbe31-6ed2-447e-9e06-549e895e79e0.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:27:38.240685+00	2026-03-10 07:27:38.240685+00	2026-03-10 07:27:38.240685+00	{"eTag": "\\"35d1697a89d60cc326fa3257e2ae7b5f\\"", "size": 635148, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:27:39.000Z", "contentLength": 635148, "httpStatusCode": 200}	787a32bb-42db-44dc-955b-82afbfe51e9d	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
e9637d63-1d32-44e9-a9d3-76c2edbea568	models	43c86d7d-8451-46a7-9245-22d197e1e802.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:37:14.389332+00	2026-03-10 07:37:14.389332+00	2026-03-10 07:37:14.389332+00	{"eTag": "\\"e3de8475198cba8f550860f971e6f291\\"", "size": 1101016, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:37:15.000Z", "contentLength": 1101016, "httpStatusCode": 200}	7137dd5f-6d34-470c-b41b-c0918ddf0682	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
61f8319c-c9ce-4ef3-b32a-6a498f7a4332	models	3fc03ffe-5098-4ecc-9ae9-49edbbc0db21.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:37:17.096976+00	2026-03-10 07:37:17.096976+00	2026-03-10 07:37:17.096976+00	{"eTag": "\\"c8549d4385a318d172cbee5bc625e5b1\\"", "size": 5189052, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:37:18.000Z", "contentLength": 5189052, "httpStatusCode": 200}	88382426-f44b-4725-863c-c85ab70de8e4	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
7cd9b056-40a1-4a78-a563-ac633429af7f	models	12541e28-4d8b-4358-a23f-de6cfc2a5a1d.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:42:43.226404+00	2026-03-10 07:42:43.226404+00	2026-03-10 07:42:43.226404+00	{"eTag": "\\"264426786f286bae55af711e18715350-3\\"", "size": 14097248, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:42:43.000Z", "contentLength": 14097248, "httpStatusCode": 200}	8b5d8069-0ddb-466e-bc95-aff9a34aa332	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
0168c97d-75fd-4e4a-8f9a-9bdf55527090	models	379c23ac-396b-4257-8a97-5e547aa0bc51.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:49:24.651341+00	2026-03-10 07:49:24.651341+00	2026-03-10 07:49:24.651341+00	{"eTag": "\\"26e52701fa6e807db1b4ed14e513830f\\"", "size": 514019, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:49:25.000Z", "contentLength": 514019, "httpStatusCode": 200}	3f68f880-cc02-4443-a50c-c4cbd04c5ab2	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
2ecf87eb-b224-4d51-bff6-37ef401a3819	models	81a9971b-d3f9-4457-8879-d72cacf3777c.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:49:25.197201+00	2026-03-10 07:49:25.197201+00	2026-03-10 07:49:25.197201+00	{"eTag": "\\"6bb3dd263cfa6fc34d5a7059d7b6a0d5\\"", "size": 252360, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:49:26.000Z", "contentLength": 252360, "httpStatusCode": 200}	7284fdca-a06f-439c-81ab-2922fd53dbee	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
6daa9d99-8209-4e26-9d14-439c0b094b29	models	86dc093b-a396-4ed6-bfa8-dec762e7808a.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:59:39.883391+00	2026-03-10 07:59:39.883391+00	2026-03-10 07:59:39.883391+00	{"eTag": "\\"b1431eda4777aab86cebb39dc513e994\\"", "size": 458675, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:59:40.000Z", "contentLength": 458675, "httpStatusCode": 200}	b3007e9f-be69-4031-a753-501c02e91395	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
425358f5-d021-40c2-8e1a-d578705ebf18	models	c34a6abd-c4fc-4e53-b579-7f4ad1a1e947.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:59:40.542944+00	2026-03-10 07:59:40.542944+00	2026-03-10 07:59:40.542944+00	{"eTag": "\\"a46ca4dbe04be54e433b972a8e88d3f8\\"", "size": 137464, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:59:41.000Z", "contentLength": 137464, "httpStatusCode": 200}	935a642e-e20a-4870-b15a-90712fcf8a4a	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
364c0211-6e37-4681-8be8-475f417dcd91	models	e21fae93-99f7-484f-8d88-ed50d972a412.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:31:37.604169+00	2026-03-10 07:31:37.604169+00	2026-03-10 07:31:37.604169+00	{"eTag": "\\"960377bb268621197e664dbbb5734cc0\\"", "size": 317089, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:31:38.000Z", "contentLength": 317089, "httpStatusCode": 200}	817cdacc-fc0c-4da6-a125-645347e49a48	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
2fb954f8-04ed-40e8-a762-66381d235379	models	cea93ac8-84f0-4c5b-832d-f5df2f39bda7.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:31:38.319609+00	2026-03-10 07:31:38.319609+00	2026-03-10 07:31:38.319609+00	{"eTag": "\\"377cd313cf7f1267981a39faba86ec56\\"", "size": 519308, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:31:39.000Z", "contentLength": 519308, "httpStatusCode": 200}	c53950f3-8341-4fae-8473-4d031a8c7121	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
31ec3d58-93c6-44ba-9078-2bad4399aca1	models	422a6325-7737-4119-b177-1e6ecb102138.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:51:49.236316+00	2026-03-10 07:51:49.236316+00	2026-03-10 07:51:49.236316+00	{"eTag": "\\"420bc0c629e973afcde4878b39717c39\\"", "size": 4622912, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:51:50.000Z", "contentLength": 4622912, "httpStatusCode": 200}	42816f4c-a90b-4290-975a-7ad7f674f59a	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
b9cfeea7-6797-40df-be49-7b014c21f32a	models	2041023f-b946-4f97-9383-1536809a0ac0.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 07:51:49.651381+00	2026-03-10 07:51:49.651381+00	2026-03-10 07:51:49.651381+00	{"eTag": "\\"90c46a22fcb61efe29ca624bf2505ac8\\"", "size": 309196, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T07:51:50.000Z", "contentLength": 309196, "httpStatusCode": 200}	7284466e-3ad9-485a-8cd5-3a827cbaa300	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
2e04f36d-d912-479f-af06-0ce580f664c8	models	e7bb5e18-f5c3-4c9f-957b-2f78910087d2.png	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 08:18:46.590096+00	2026-03-10 08:18:46.590096+00	2026-03-10 08:18:46.590096+00	{"eTag": "\\"645a04c63e943e195b3a7186c6ed43a9\\"", "size": 2267891, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T08:18:47.000Z", "contentLength": 2267891, "httpStatusCode": 200}	8aa3438f-e49c-473e-b332-686b81a8e531	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
c93d218c-1249-4935-bde6-7b8e4fe72f27	models	ba8ec5a2-ff90-4ab1-9d44-fc134444bf22.glb	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	2026-03-10 08:18:47.525444+00	2026-03-10 08:18:47.525444+00	2026-03-10 08:18:47.525444+00	{"eTag": "\\"a569ce34566e0aced38a27cd0c0d48fb\\"", "size": 508844, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2026-03-10T08:18:48.000Z", "contentLength": 508844, "httpStatusCode": 200}	3a811372-c485-444b-b1b3-18191549a7a3	eb7ed6ea-b864-491d-b8d7-e9286e2a1d27	{}
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 123, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_id_seq', 26, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- Name: cart_items cart_items_user_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_user_id_product_id_key UNIQUE (user_id, product_id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_key UNIQUE (slug);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- Name: products products_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_slug_key UNIQUE (slug);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_username_key UNIQUE (username);


--
-- Name: promos promos_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promos
    ADD CONSTRAINT promos_code_key UNIQUE (code);


--
-- Name: promos promos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promos
    ADD CONSTRAINT promos_pkey PRIMARY KEY (id);


--
-- Name: refund_requests refund_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_requests
    ADD CONSTRAINT refund_requests_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: variants variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variants
    ADD CONSTRAINT variants_pkey PRIMARY KEY (id);


--
-- Name: wishlists wishlists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_pkey PRIMARY KEY (id);


--
-- Name: wishlists wishlists_user_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_user_id_product_id_key UNIQUE (user_id, product_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_09 messages_2026_03_09_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_09
    ADD CONSTRAINT messages_2026_03_09_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_10 messages_2026_03_10_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_10
    ADD CONSTRAINT messages_2026_03_10_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_11 messages_2026_03_11_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_11
    ADD CONSTRAINT messages_2026_03_11_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_12 messages_2026_03_12_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_12
    ADD CONSTRAINT messages_2026_03_12_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_13 messages_2026_03_13_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_13
    ADD CONSTRAINT messages_2026_03_13_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_14 messages_2026_03_14_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_14
    ADD CONSTRAINT messages_2026_03_14_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_15 messages_2026_03_15_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_15
    ADD CONSTRAINT messages_2026_03_15_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_09_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_09_inserted_at_topic_idx ON realtime.messages_2026_03_09 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_10_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_10_inserted_at_topic_idx ON realtime.messages_2026_03_10 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_11_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_11_inserted_at_topic_idx ON realtime.messages_2026_03_11 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_12_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_12_inserted_at_topic_idx ON realtime.messages_2026_03_12 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_13_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_13_inserted_at_topic_idx ON realtime.messages_2026_03_13 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_14_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_14_inserted_at_topic_idx ON realtime.messages_2026_03_14 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_15_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_15_inserted_at_topic_idx ON realtime.messages_2026_03_15 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_action_filter_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_key ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_bucket_id_name_lower; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: messages_2026_03_09_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_09_inserted_at_topic_idx;


--
-- Name: messages_2026_03_09_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_09_pkey;


--
-- Name: messages_2026_03_10_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_10_inserted_at_topic_idx;


--
-- Name: messages_2026_03_10_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_10_pkey;


--
-- Name: messages_2026_03_11_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_11_inserted_at_topic_idx;


--
-- Name: messages_2026_03_11_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_11_pkey;


--
-- Name: messages_2026_03_12_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_12_inserted_at_topic_idx;


--
-- Name: messages_2026_03_12_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_12_pkey;


--
-- Name: messages_2026_03_13_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_13_inserted_at_topic_idx;


--
-- Name: messages_2026_03_13_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_13_pkey;


--
-- Name: messages_2026_03_14_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_14_inserted_at_topic_idx;


--
-- Name: messages_2026_03_14_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_14_pkey;


--
-- Name: messages_2026_03_15_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_15_inserted_at_topic_idx;


--
-- Name: messages_2026_03_15_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_15_pkey;


--
-- Name: orders_with_items _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.orders_with_items AS
 SELECT o.id,
    o.user_id,
    o.total_cents,
    o.promo_code,
    o.status,
    o.shipping_address,
    o.created_at,
    o.shipping_method,
    o.payment_method,
    o.tracking_status,
    o.expected_delivery,
    o.cancelled_at,
    o.cancel_reason,
    o.notes,
    o.email_confirmed,
    json_agg(json_build_object('id', oi.id, 'product_id', oi.product_id, 'product_name', COALESCE(oi.product_name, p.name), 'product_img', COALESCE(oi.product_img, p.img_url), 'qty', oi.qty, 'price_cents', oi.price_cents)) AS items
   FROM ((public.orders o
     JOIN public.order_items oi ON ((oi.order_id = o.id)))
     LEFT JOIN public.products p ON ((p.id = oi.product_id)))
  GROUP BY o.id;


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: users on_auth_user_created_notifications; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER on_auth_user_created_notifications AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_notifications();


--
-- Name: products on_product_low_stock; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_product_low_stock AFTER UPDATE ON public.products FOR EACH ROW WHEN ((old.stock IS DISTINCT FROM new.stock)) EXECUTE FUNCTION public.notify_cart_low_stock();


--
-- Name: products on_product_price_drop; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_product_price_drop AFTER UPDATE ON public.products FOR EACH ROW WHEN ((old.price_cents IS DISTINCT FROM new.price_cents)) EXECUTE FUNCTION public.notify_wishlist_sale();


--
-- Name: products on_product_restock; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_product_restock AFTER UPDATE ON public.products FOR EACH ROW WHEN ((old.stock IS DISTINCT FROM new.stock)) EXECUTE FUNCTION public.notify_back_in_stock();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: categories categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.categories(id);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: order_items order_items_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.variants(id);


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refund_requests refund_requests_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_requests
    ADD CONSTRAINT refund_requests_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: refund_requests refund_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_requests
    ADD CONSTRAINT refund_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: reviews reviews_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: variants variants_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variants
    ADD CONSTRAINT variants_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: wishlists wishlists_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: wishlists wishlists_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlists
    ADD CONSTRAINT wishlists_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: products Allow deletes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow deletes" ON public.products FOR DELETE USING ((auth.role() = 'authenticated'::text));


--
-- Name: products Allow inserts; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow inserts" ON public.products FOR INSERT WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: products Allow updates; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow updates" ON public.products FOR UPDATE USING ((auth.role() = 'authenticated'::text)) WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: categories Anyone can read categories; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can read categories" ON public.categories FOR SELECT USING (true);


--
-- Name: products Anyone can read products; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can read products" ON public.products FOR SELECT USING (true);


--
-- Name: promos Anyone can read promos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can read promos" ON public.promos FOR SELECT USING (true);


--
-- Name: reviews Anyone can read reviews; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can read reviews" ON public.reviews FOR SELECT USING (true);


--
-- Name: reviews Own reviews; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Own reviews" ON public.reviews USING ((auth.uid() = user_id));


--
-- Name: wishlists Own wishlist; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Own wishlist" ON public.wishlists USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: reviews Public reviews; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public reviews" ON public.reviews FOR SELECT USING (true);


--
-- Name: orders Users can manage own orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can manage own orders" ON public.orders USING ((auth.uid() = user_id));


--
-- Name: order_items Users can view own order items; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view own order items" ON public.order_items USING ((EXISTS ( SELECT 1
   FROM public.orders
  WHERE ((orders.id = order_items.order_id) AND (orders.user_id = auth.uid())))));


--
-- Name: cart_items Users manage own cart; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users manage own cart" ON public.cart_items USING ((auth.uid() = user_id));


--
-- Name: notifications Users manage own notifications; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users manage own notifications" ON public.notifications USING ((auth.uid() = user_id));


--
-- Name: profiles Users manage own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users manage own profile" ON public.profiles USING ((auth.uid() = id));


--
-- Name: refund_requests Users manage own refunds; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users manage own refunds" ON public.refund_requests USING ((auth.uid() = user_id));


--
-- Name: reviews Users manage own reviews; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users manage own reviews" ON public.reviews USING ((auth.uid() = user_id));


--
-- Name: wishlists Users manage own wishlist; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users manage own wishlist" ON public.wishlists USING ((auth.uid() = user_id));


--
-- Name: products Your updates only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Your updates only" ON public.products FOR UPDATE USING ((auth.uid() = 'eb7ed6ea-b864-491d-b8d7-e9286e2a1d27'::uuid)) WITH CHECK ((auth.uid() = 'eb7ed6ea-b864-491d-b8d7-e9286e2a1d27'::uuid));


--
-- Name: cart_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

--
-- Name: categories; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: order_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

--
-- Name: orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

--
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: promos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.promos ENABLE ROW LEVEL SECURITY;

--
-- Name: refund_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.refund_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: reviews; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

--
-- Name: wishlists; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.wishlists ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: messages users_can_insert_their_notifications; Type: POLICY; Schema: realtime; Owner: -
--

CREATE POLICY users_can_insert_their_notifications ON realtime.messages FOR INSERT TO authenticated WITH CHECK ((topic = (('user:'::text || (auth.uid())::text) || ':notifications'::text)));


--
-- Name: messages users_can_read_their_notifications; Type: POLICY; Schema: realtime; Owner: -
--

CREATE POLICY users_can_read_their_notifications ON realtime.messages FOR SELECT TO authenticated USING ((topic = (('user:'::text || (auth.uid())::text) || ':notifications'::text)));


--
-- Name: objects Allow deletes; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Allow deletes" ON storage.objects FOR DELETE USING (((bucket_id = 'models'::text) AND (auth.role() = 'authenticated'::text)));


--
-- Name: objects Allow uploads; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Allow uploads" ON storage.objects FOR INSERT WITH CHECK (((bucket_id = 'models'::text) AND (auth.role() = 'authenticated'::text)));


--
-- Name: objects Public read models; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Public read models" ON storage.objects FOR SELECT USING ((bucket_id = 'models'::text));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: supabase_realtime_messages_publication; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime_messages_publication WITH (publish = 'insert, update, delete, truncate');


--
-- Name: supabase_realtime_messages_publication messages; Type: PUBLICATION TABLE; Schema: realtime; Owner: -
--

ALTER PUBLICATION supabase_realtime_messages_publication ADD TABLE ONLY realtime.messages;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict jDYrVOHhMNYkub5evQYQxmRyw8MXXpUNQF0nHLFxaKgKJU7E2fVwzHYvzKeKr51

