-- =============================================================================
-- 012_food_aliases.sql
-- Multilingual searchable aliases for curated catalog rows (source = 'seed').
--
-- * One canonical nutrition row in `foods`; many aliases per locale.
-- * Does NOT duplicate foods, does NOT touch nutrition per language.
-- * Safe to re-run: idempotent table/index creation + seed uses ON CONFLICT DO NOTHING.
--
-- food_id type must match `foods.id` (Supabase: uuid; see backend POST /foods).
-- If your database still uses bigserial for foods.id, change `uuid` below to bigint.
-- =============================================================================

create extension if not exists pg_trgm;

create table if not exists food_aliases (
    id                  uuid primary key default gen_random_uuid(),
    food_id             uuid not null references foods(id) on delete cascade,
    locale              text not null,
    alias               text not null,
    normalized_alias    text not null,
    is_primary          boolean not null default false,
    created_at          timestamptz not null default now(),
    updated_at          timestamptz not null default now(),

    constraint food_aliases_locale_nonempty
        check (length(trim(locale)) > 0),
    constraint food_aliases_alias_nonempty
        check (length(trim(alias)) > 0),
    constraint food_aliases_normalized_nonempty
        check (length(trim(normalized_alias)) > 0)
);

create unique index if not exists food_aliases_food_locale_norm_unique
    on food_aliases (food_id, locale, normalized_alias);

create unique index if not exists food_aliases_one_primary_per_food_locale
    on food_aliases (food_id, locale)
    where is_primary;

create index if not exists idx_food_aliases_food_id
    on food_aliases (food_id);

create index if not exists idx_food_aliases_locale_norm
    on food_aliases (locale, normalized_alias);

create index if not exists idx_food_aliases_norm_trgm
    on food_aliases using gin (normalized_alias gin_trgm_ops);

-- -----------------------------------------------------------------------------
-- Seed Romanian + English aliases (only where seed slug exists in `foods`).
-- normalized_alias must match backend food_search_text.normalize_food_search_text()
-- (lowercase, NFKD strip combining, whitespace collapsed).
-- -----------------------------------------------------------------------------

INSERT INTO food_aliases (food_id, locale, alias, normalized_alias, is_primary)
SELECT f.id, v.locale, v.alias, v.normalized_alias, v.is_primary
FROM (VALUES
    -- Chicken breast
    ('seed:protein:chicken-breast-cooked', 'ro', 'Piept de pui', 'piept de pui', true),
    ('seed:protein:chicken-breast-cooked', 'ro', 'carne de pui', 'carne de pui', false),
    ('seed:protein:chicken-breast-cooked', 'ro', 'pui', 'pui', false),
    -- Chicken thigh
    ('seed:protein:chicken-thigh-cooked', 'ro', 'Pulpe de pui', 'pulpe de pui', true),
    ('seed:protein:chicken-thigh-cooked', 'ro', 'pui', 'pui', false),
    ('seed:protein:chicken-thigh-cooked', 'ro', 'carne de pui', 'carne de pui', false),
    -- Turkey
    ('seed:protein:turkey-breast-cooked', 'ro', 'Curcan', 'curcan', true),
    ('seed:protein:turkey-breast-cooked', 'ro', 'piept de curcan', 'piept de curcan', false),
    -- Nuggets
    ('seed:fast:chicken-nuggets', 'ro', 'Nuggets de pui', 'nuggets de pui', true),
    ('seed:fast:chicken-nuggets', 'ro', 'pui', 'pui', false),
    -- Rice
    ('seed:grain:white-rice-cooked', 'ro', 'Orez gătit', 'orez gatit', true),
    ('seed:grain:white-rice-cooked', 'ro', 'orez', 'orez', false),
    ('seed:grain:white-rice-cooked', 'ro', 'orez alb', 'orez alb', false),
    ('seed:grain:brown-rice-cooked', 'ro', 'Orez brun gătit', 'orez brun gatit', true),
    ('seed:grain:brown-rice-cooked', 'ro', 'orez', 'orez', false),
    -- Milk
    ('seed:dairy:milk-whole', 'ro', 'Lapte', 'lapte', true),
    ('seed:dairy:milk-whole', 'ro', 'lapte integral', 'lapte integral', false),
    ('seed:dairy:milk-semi', 'ro', 'Lapte', 'lapte', true),
    ('seed:dairy:milk-semi', 'ro', 'lapte semidegresat', 'lapte semidegresat', false),
    ('seed:dairy:milk-skim', 'ro', 'Lapte degresat', 'lapte degresat', true),
    ('seed:dairy:milk-skim', 'ro', 'lapte', 'lapte', false),
    -- Eggs
    ('seed:protein:egg-whole', 'ro', 'Ou', 'ou', true),
    ('seed:protein:egg-whole', 'ro', 'ouă', 'oua', false),
    ('seed:protein:egg-whole', 'ro', 'oua', 'oua', false),
    ('seed:protein:egg-white', 'ro', 'Albuș de ou', 'albus de ou', true),
    ('seed:protein:egg-white', 'ro', 'Albuș', 'albus', false),
    ('seed:protein:egg-white', 'ro', 'albuș', 'albus', false),
    -- Potatoes
    ('seed:veg:potato-boiled', 'ro', 'Cartofi fierți', 'cartofi fierti', true),
    ('seed:veg:potato-boiled', 'ro', 'cartof', 'cartof', false),
    ('seed:veg:potato-boiled', 'ro', 'cartofi', 'cartofi', false),
    ('seed:veg:sweet-potato-baked', 'ro', 'Cartof dulce', 'cartof dulce', true),
    ('seed:veg:sweet-potato-baked', 'ro', 'cartofi dulci', 'cartofi dulci', false),
    -- Cheese
    ('seed:dairy:cheddar', 'ro', 'Brânză', 'branza', true),
    ('seed:dairy:cheddar', 'ro', 'cascaval', 'cascaval', false),
    ('seed:dairy:cheddar', 'ro', 'cașcaval', 'cascaval', false),
    ('seed:dairy:mozzarella', 'ro', 'Mozzarella', 'mozzarella', true),
    ('seed:dairy:feta', 'ro', 'Brânză feta', 'branza feta', true),
    -- Yogurt
    ('seed:dairy:greek-yogurt-plain-nonfat', 'ro', 'Iaurt grecesc', 'iaurt grecesc', true),
    ('seed:dairy:yogurt-plain-whole', 'ro', 'Iaurt', 'iaurt', true),
    ('seed:dairy:yogurt-plain-whole', 'ro', 'iaurt natural', 'iaurt natural', false),
    -- Beef / pork
    ('seed:protein:ground-beef-9010-cooked', 'ro', 'Vită tocată', 'vita tocata', true),
    ('seed:protein:ground-beef-9010-cooked', 'ro', 'carne de vită', 'carne de vita', false),
    ('seed:protein:ground-beef-9010-cooked', 'ro', 'vita', 'vita', false),
    ('seed:protein:sirloin-steak-cooked', 'ro', 'Friptură de vită', 'friptura de vita', true),
    ('seed:protein:sirloin-steak-cooked', 'ro', 'carne de vită', 'carne de vita', false),
    ('seed:protein:sirloin-steak-cooked', 'ro', 'vită', 'vita', false),
    ('seed:protein:pork-chop-cooked', 'ro', 'Cotlet de porc', 'cotlet de porc', true),
    ('seed:protein:pork-chop-cooked', 'ro', 'porc', 'porc', false),
    ('seed:protein:pork-chop-cooked', 'ro', 'carne de porc', 'carne de porc', false),
    -- Fish
    ('seed:protein:salmon-cooked', 'ro', 'Somon', 'somon', true),
    ('seed:protein:salmon-cooked', 'ro', 'pește', 'peste', false),
    ('seed:protein:tuna-canned-water', 'ro', 'Ton', 'ton', true),
    ('seed:protein:tuna-canned-water', 'ro', 'pește', 'peste', false),
    ('seed:protein:cod-cooked', 'ro', 'Cod', 'cod', true),
    ('seed:protein:cod-cooked', 'ro', 'pește', 'peste', false),
    ('seed:protein:tilapia-cooked', 'ro', 'Tilapia', 'tilapia', true),
    ('seed:protein:tilapia-cooked', 'ro', 'pește', 'peste', false),
    -- Bread / pasta
    ('seed:grain:white-bread', 'ro', 'Pâine', 'paine', true),
    ('seed:grain:white-bread', 'ro', 'pâine albă', 'paine alba', false),
    ('seed:grain:whole-wheat-bread', 'ro', 'Pâine integrală', 'paine integrala', true),
    ('seed:grain:pasta-cooked', 'ro', 'Paste', 'paste', true),
    ('seed:grain:whole-wheat-pasta-cooked', 'ro', 'Paste integrale', 'paste integrale', true),
    -- Vegetables
    ('seed:veg:tomato', 'ro', 'Roșie', 'rosie', true),
    ('seed:veg:tomato', 'ro', 'roșii', 'rosii', false),
    ('seed:veg:tomato', 'ro', 'rosii', 'rosii', false),
    ('seed:veg:cucumber', 'ro', 'Castravete', 'castravete', true),
    ('seed:veg:lettuce-romaine', 'ro', 'Salată', 'salata', true),
    ('seed:veg:lettuce-romaine', 'ro', 'salată verde', 'salata verde', false),
    ('seed:veg:onion', 'ro', 'Ceapă', 'ceapa', true),
    ('seed:veg:garlic', 'ro', 'Usturoi', 'usturoi', true),
    -- Fruits
    ('seed:fruit:apple', 'ro', 'Măr', 'mar', true),
    ('seed:fruit:apple', 'ro', 'mere', 'mere', false),
    ('seed:fruit:banana', 'ro', 'Banană', 'banana', true),
    ('seed:fruit:banana', 'ro', 'banane', 'banane', false),
    ('seed:fruit:orange', 'ro', 'Portocală', 'portocala', true),
    ('seed:fruit:strawberry', 'ro', 'Căpșuni', 'capsuni', true),
    ('seed:fruit:blueberry', 'ro', 'Afine', 'afine', true),
    -- Nuts / fats / sweet
    ('seed:nut:almonds', 'ro', 'Migdale', 'migdale', true),
    ('seed:nut:almonds', 'ro', 'nuci', 'nuci', false),
    ('seed:nut:walnuts', 'ro', 'Nuci', 'nuci', true),
    ('seed:fat:olive-oil', 'ro', 'Ulei de măsline', 'ulei de masline', true),
    ('seed:dairy:butter', 'ro', 'Unt', 'unt', true),
    ('seed:sweet:sugar-white', 'ro', 'Zahăr', 'zahar', true),
    ('seed:sweet:sugar-white', 'ro', 'zahăr', 'zahar', false),
    ('seed:sweet:honey', 'ro', 'Miere', 'miere', true),
    ('seed:grain:oats-rolled-dry', 'ro', 'Ovăz', 'ovaz', true),
    ('seed:grain:oats-rolled-dry', 'ro', 'fulgi de ovăz', 'fulgi de ovaz', false),

    -- English display primaries (optional; match colloquial search)
    ('seed:protein:chicken-breast-cooked', 'en', 'Chicken breast', 'chicken breast', true),
    ('seed:grain:white-rice-cooked', 'en', 'White rice', 'white rice', true),
    ('seed:dairy:milk-whole', 'en', 'Milk', 'milk', true),
    ('seed:protein:egg-whole', 'en', 'Egg', 'egg', true)
) AS v(source_food_id, locale, alias, normalized_alias, is_primary)
JOIN foods f ON f.source = 'seed' AND f.source_food_id = v.source_food_id
ON CONFLICT (food_id, locale, normalized_alias) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Diagnostics
-- -----------------------------------------------------------------------------
select count(*) as food_aliases_total from food_aliases;
select locale, count(*) as n from food_aliases group by locale order by locale;
