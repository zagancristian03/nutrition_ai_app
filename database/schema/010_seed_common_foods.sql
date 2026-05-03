-- =============================================================================
-- 010_seed_common_foods.sql
-- Seeds ~150 of the most common foods (fruits, vegetables, grains, proteins,
-- dairy, plant proteins, nuts & seeds, snacks, beverages, condiments, fast food).
--
-- Idempotent: each row uses source = 'seed' and a stable source_food_id slug,
-- so re-running this script will silently skip rows that already exist.
-- Macros are per 100 g (per 100 ml for liquids); `serving_size_g` is a sensible
-- default portion. Values come from public USDA / Open Food Facts averages and
-- are rounded for readability.
-- =============================================================================

with seed_foods (name, brand, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, serving_size_g, source, source_food_id) as (
    values
    -- ---------------------------------------------------------------- Fruits --
    ('apple',                   null::text,  52.0::float8,  0.3::float8, 14.0::float8,  0.2::float8, 182.0::float8, 'seed', 'seed:fruit:apple'),
    ('banana',                  null,        89.0,          1.1,         23.0,          0.3,         118.0,         'seed', 'seed:fruit:banana'),
    ('orange',                  null,        47.0,          0.9,         12.0,          0.1,         131.0,         'seed', 'seed:fruit:orange'),
    ('strawberry',              null,        32.0,          0.7,          7.7,          0.3,         144.0,         'seed', 'seed:fruit:strawberry'),
    ('blueberry',               null,        57.0,          0.7,         14.0,          0.3,         148.0,         'seed', 'seed:fruit:blueberry'),
    ('raspberry',               null,        52.0,          1.2,         12.0,          0.7,         123.0,         'seed', 'seed:fruit:raspberry'),
    ('blackberry',              null,        43.0,          1.4,         10.0,          0.5,         144.0,         'seed', 'seed:fruit:blackberry'),
    ('grape',                   null,        69.0,          0.7,         18.0,          0.2,         151.0,         'seed', 'seed:fruit:grape'),
    ('pineapple',               null,        50.0,          0.5,         13.0,          0.1,         165.0,         'seed', 'seed:fruit:pineapple'),
    ('watermelon',              null,        30.0,          0.6,          7.6,          0.2,         152.0,         'seed', 'seed:fruit:watermelon'),
    ('cantaloupe',              null,        34.0,          0.8,          8.2,          0.2,         156.0,         'seed', 'seed:fruit:cantaloupe'),
    ('mango',                   null,        60.0,          0.8,         15.0,          0.4,         165.0,         'seed', 'seed:fruit:mango'),
    ('pear',                    null,        57.0,          0.4,         15.0,          0.1,         178.0,         'seed', 'seed:fruit:pear'),
    ('peach',                   null,        39.0,          0.9,         10.0,          0.3,         150.0,         'seed', 'seed:fruit:peach'),
    ('plum',                    null,        46.0,          0.7,         11.0,          0.3,          66.0,         'seed', 'seed:fruit:plum'),
    ('kiwi',                    null,        61.0,          1.1,         15.0,          0.5,          76.0,         'seed', 'seed:fruit:kiwi'),
    ('avocado',                 null,       160.0,          2.0,          9.0,         15.0,         100.0,         'seed', 'seed:fruit:avocado'),
    ('cherry',                  null,        50.0,          1.0,         12.0,          0.3,         138.0,         'seed', 'seed:fruit:cherry'),
    ('lemon',                   null,        29.0,          1.1,          9.0,          0.3,          58.0,         'seed', 'seed:fruit:lemon'),
    ('lime',                    null,        30.0,          0.7,         11.0,          0.2,          67.0,         'seed', 'seed:fruit:lime'),
    ('pomegranate',             null,        83.0,          1.7,         19.0,          1.2,         174.0,         'seed', 'seed:fruit:pomegranate'),
    ('grapefruit',              null,        42.0,          0.8,         11.0,          0.1,         230.0,         'seed', 'seed:fruit:grapefruit'),
    ('apricot',                 null,        48.0,          1.4,         11.0,          0.4,          35.0,         'seed', 'seed:fruit:apricot'),
    ('coconut meat, raw',       null,       354.0,          3.3,         15.0,         33.0,          80.0,         'seed', 'seed:fruit:coconut'),
    ('raisins',                 null,       299.0,          3.1,         79.0,          0.5,          43.0,         'seed', 'seed:fruit:raisins'),
    ('dates, medjool',          null,       277.0,          1.8,         75.0,          0.2,          24.0,         'seed', 'seed:fruit:dates'),

    -- ----------------------------------------------------------- Vegetables --
    ('broccoli',                null,        34.0,          2.8,          7.0,          0.4,          91.0,         'seed', 'seed:veg:broccoli'),
    ('spinach, raw',            null,        23.0,          2.9,          3.6,          0.4,          30.0,         'seed', 'seed:veg:spinach'),
    ('carrot',                  null,        41.0,          0.9,         10.0,          0.2,          61.0,         'seed', 'seed:veg:carrot'),
    ('tomato',                  null,        18.0,          0.9,          3.9,          0.2,         123.0,         'seed', 'seed:veg:tomato'),
    ('cucumber',                null,        16.0,          0.7,          3.6,          0.1,         100.0,         'seed', 'seed:veg:cucumber'),
    ('lettuce, romaine',        null,        17.0,          1.2,          3.3,          0.3,          47.0,         'seed', 'seed:veg:lettuce-romaine'),
    ('bell pepper, red',        null,        31.0,          1.0,          6.0,          0.3,         119.0,         'seed', 'seed:veg:bell-pepper-red'),
    ('onion',                   null,        40.0,          1.1,          9.3,          0.1,         110.0,         'seed', 'seed:veg:onion'),
    ('garlic',                  null,       149.0,          6.4,         33.0,          0.5,           3.0,         'seed', 'seed:veg:garlic'),
    ('potato, boiled',          null,        87.0,          1.9,         20.0,          0.1,         173.0,         'seed', 'seed:veg:potato-boiled'),
    ('sweet potato, baked',     null,        90.0,          2.0,         21.0,          0.2,         151.0,         'seed', 'seed:veg:sweet-potato-baked'),
    ('zucchini',                null,        17.0,          1.2,          3.1,          0.3,         196.0,         'seed', 'seed:veg:zucchini'),
    ('cauliflower',             null,        25.0,          1.9,          5.0,          0.3,         100.0,         'seed', 'seed:veg:cauliflower'),
    ('mushroom, white',         null,        22.0,          3.1,          3.3,          0.3,          70.0,         'seed', 'seed:veg:mushroom-white'),
    ('cabbage, green',          null,        25.0,          1.3,          5.8,          0.1,          89.0,         'seed', 'seed:veg:cabbage-green'),
    ('asparagus',               null,        20.0,          2.2,          3.9,          0.1,         134.0,         'seed', 'seed:veg:asparagus'),
    ('celery',                  null,        16.0,          0.7,          3.0,          0.2,          40.0,         'seed', 'seed:veg:celery'),
    ('eggplant',                null,        25.0,          1.0,          6.0,          0.2,          82.0,         'seed', 'seed:veg:eggplant'),
    ('corn, sweet, cooked',     null,        96.0,          3.4,         21.0,          1.5,         154.0,         'seed', 'seed:veg:corn-cooked'),
    ('green beans, cooked',     null,        35.0,          1.9,          7.9,          0.3,         100.0,         'seed', 'seed:veg:green-beans-cooked'),
    ('peas, green, cooked',     null,        84.0,          5.4,         16.0,          0.2,         160.0,         'seed', 'seed:veg:peas-cooked'),
    ('kale',                    null,        35.0,          2.9,          4.4,          1.5,          67.0,         'seed', 'seed:veg:kale'),
    ('brussels sprouts, cooked',null,        36.0,          2.6,          7.0,          0.5,          78.0,         'seed', 'seed:veg:brussels-sprouts-cooked'),
    ('beetroot, cooked',        null,        44.0,          1.7,         10.0,          0.2,         100.0,         'seed', 'seed:veg:beetroot-cooked'),
    ('pumpkin, cooked',         null,        20.0,          0.7,          5.0,          0.1,         245.0,         'seed', 'seed:veg:pumpkin-cooked'),

    -- ----------------------------------------------------- Grains & starches --
    ('white rice, cooked',      null,       130.0,          2.7,         28.0,          0.3,         158.0,         'seed', 'seed:grain:white-rice-cooked'),
    ('brown rice, cooked',      null,       123.0,          2.7,         26.0,          1.0,         195.0,         'seed', 'seed:grain:brown-rice-cooked'),
    ('pasta, cooked',           null,       158.0,          5.8,         31.0,          0.9,         140.0,         'seed', 'seed:grain:pasta-cooked'),
    ('whole wheat pasta, cooked',null,      149.0,          5.3,         30.0,          1.3,         140.0,         'seed', 'seed:grain:whole-wheat-pasta-cooked'),
    ('white bread',             null,       265.0,          9.0,         49.0,          3.2,          28.0,         'seed', 'seed:grain:white-bread'),
    ('whole wheat bread',       null,       247.0,         13.0,         41.0,          3.4,          28.0,         'seed', 'seed:grain:whole-wheat-bread'),
    ('rolled oats, dry',        null,       379.0,         13.0,         68.0,          6.5,          40.0,         'seed', 'seed:grain:oats-rolled-dry'),
    ('quinoa, cooked',          null,       120.0,          4.4,         21.0,          1.9,         185.0,         'seed', 'seed:grain:quinoa-cooked'),
    ('couscous, cooked',        null,       112.0,          3.8,         23.0,          0.2,         157.0,         'seed', 'seed:grain:couscous-cooked'),
    ('flour tortilla',          null,       304.0,          8.7,         49.0,          7.1,          49.0,         'seed', 'seed:grain:flour-tortilla'),
    ('corn tortilla',           null,       218.0,          5.7,         45.0,          2.9,          26.0,         'seed', 'seed:grain:corn-tortilla'),
    ('bagel, plain',            null,       250.0,         10.0,         49.0,          1.5,          95.0,         'seed', 'seed:grain:bagel-plain'),
    ('cornflakes',              null,       357.0,          7.5,         84.0,          0.4,          30.0,         'seed', 'seed:grain:cornflakes'),
    ('granola',                 null,       471.0,         10.0,         64.0,         20.0,          60.0,         'seed', 'seed:grain:granola'),
    ('egg noodles, cooked',     null,       138.0,          4.5,         25.0,          2.1,         160.0,         'seed', 'seed:grain:egg-noodles-cooked'),

    -- ------------------------------------------------------- Animal proteins --
    ('chicken breast, cooked',  null,       165.0,         31.0,          0.0,          3.6,         120.0,         'seed', 'seed:protein:chicken-breast-cooked'),
    ('chicken thigh, cooked',   null,       209.0,         26.0,          0.0,         11.0,         100.0,         'seed', 'seed:protein:chicken-thigh-cooked'),
    ('ground beef 90/10, cooked',null,      217.0,         26.0,          0.0,         12.0,         113.0,         'seed', 'seed:protein:ground-beef-9010-cooked'),
    ('sirloin steak, cooked',   null,       271.0,         27.0,          0.0,         17.0,         170.0,         'seed', 'seed:protein:sirloin-steak-cooked'),
    ('pork chop, cooked',       null,       231.0,         26.0,          0.0,         13.0,         145.0,         'seed', 'seed:protein:pork-chop-cooked'),
    ('bacon, cooked',           null,       541.0,         37.0,          1.4,         42.0,           8.0,         'seed', 'seed:protein:bacon-cooked'),
    ('ham, sliced',             null,       145.0,         21.0,          1.5,          5.5,          28.0,         'seed', 'seed:protein:ham-sliced'),
    ('turkey breast, cooked',   null,       135.0,         30.0,          0.0,          1.0,          85.0,         'seed', 'seed:protein:turkey-breast-cooked'),
    ('salmon, cooked',          null,       208.0,         20.0,          0.0,         13.0,         154.0,         'seed', 'seed:protein:salmon-cooked'),
    ('tuna, canned in water',   null,       116.0,         26.0,          0.0,          0.8,         142.0,         'seed', 'seed:protein:tuna-canned-water'),
    ('shrimp, cooked',          null,        99.0,         24.0,          0.2,          0.3,          85.0,         'seed', 'seed:protein:shrimp-cooked'),
    ('cod, cooked',             null,       105.0,         23.0,          0.0,          0.9,         100.0,         'seed', 'seed:protein:cod-cooked'),
    ('tilapia, cooked',         null,       129.0,         26.0,          0.0,          2.7,         100.0,         'seed', 'seed:protein:tilapia-cooked'),
    ('egg, whole',              null,       155.0,         13.0,          1.1,         11.0,          50.0,         'seed', 'seed:protein:egg-whole'),
    ('egg white',               null,        52.0,         11.0,          0.7,          0.2,          33.0,         'seed', 'seed:protein:egg-white'),

    -- ------------------------------------------------------------------ Dairy --
    ('milk, whole',             null,        61.0,          3.2,          4.8,          3.3,         244.0,         'seed', 'seed:dairy:milk-whole'),
    ('milk, semi-skimmed',      null,        50.0,          3.4,          4.9,          1.7,         244.0,         'seed', 'seed:dairy:milk-semi'),
    ('milk, skim',              null,        34.0,          3.4,          5.0,          0.1,         245.0,         'seed', 'seed:dairy:milk-skim'),
    ('greek yogurt, plain, nonfat',null,     59.0,         10.0,          3.6,          0.4,         170.0,         'seed', 'seed:dairy:greek-yogurt-plain-nonfat'),
    ('plain yogurt, whole',     null,        61.0,          3.5,          4.7,          3.3,         245.0,         'seed', 'seed:dairy:yogurt-plain-whole'),
    ('cheddar cheese',          null,       402.0,         25.0,          1.3,         33.0,          28.0,         'seed', 'seed:dairy:cheddar'),
    ('mozzarella',              null,       280.0,         28.0,          3.1,         17.0,          28.0,         'seed', 'seed:dairy:mozzarella'),
    ('feta',                    null,       264.0,         14.0,          4.1,         21.0,          28.0,         'seed', 'seed:dairy:feta'),
    ('cottage cheese, low fat', null,        81.0,         11.0,          4.3,          2.3,         113.0,         'seed', 'seed:dairy:cottage-cheese-lowfat'),
    ('butter',                  null,       717.0,          0.9,          0.1,         81.0,          14.0,         'seed', 'seed:dairy:butter'),
    ('cream cheese',            null,       342.0,          6.0,          4.1,         34.0,          28.0,         'seed', 'seed:dairy:cream-cheese'),
    ('parmesan',                null,       431.0,         38.0,          4.1,         29.0,           5.0,         'seed', 'seed:dairy:parmesan'),
    ('sour cream',              null,       198.0,          2.4,          4.6,         19.0,          30.0,         'seed', 'seed:dairy:sour-cream'),

    -- ------------------------------------------------------- Plant proteins --
    ('tofu, firm',              null,       144.0,         17.0,          2.8,          8.7,         100.0,         'seed', 'seed:plant:tofu-firm'),
    ('tempeh',                  null,       192.0,         20.0,          7.6,         11.0,          84.0,         'seed', 'seed:plant:tempeh'),
    ('lentils, cooked',         null,       116.0,          9.0,         20.0,          0.4,         198.0,         'seed', 'seed:plant:lentils-cooked'),
    ('chickpeas, cooked',       null,       164.0,          8.9,         27.0,          2.6,         164.0,         'seed', 'seed:plant:chickpeas-cooked'),
    ('black beans, cooked',     null,       132.0,          8.9,         24.0,          0.5,         172.0,         'seed', 'seed:plant:black-beans-cooked'),
    ('kidney beans, cooked',    null,       127.0,          8.7,         23.0,          0.5,         177.0,         'seed', 'seed:plant:kidney-beans-cooked'),
    ('white beans, cooked',     null,       139.0,          9.7,         25.0,          0.4,         179.0,         'seed', 'seed:plant:white-beans-cooked'),
    ('edamame, cooked',         null,       122.0,         11.0,         10.0,          5.2,         155.0,         'seed', 'seed:plant:edamame-cooked'),
    ('peanut butter',           null,       588.0,         25.0,         20.0,         50.0,          32.0,         'seed', 'seed:plant:peanut-butter'),
    ('almond butter',           null,       614.0,         21.0,         19.0,         56.0,          32.0,         'seed', 'seed:plant:almond-butter'),
    ('hummus',                  null,       166.0,          7.9,         14.0,          9.6,          30.0,         'seed', 'seed:plant:hummus'),
    ('soy milk',                null,        54.0,          3.3,          6.3,          1.8,         243.0,         'seed', 'seed:plant:soy-milk'),
    ('almond milk, unsweetened',null,        17.0,          0.6,          1.5,          1.1,         240.0,         'seed', 'seed:plant:almond-milk-unsw'),

    -- -------------------------------------------------------- Nuts & seeds --
    ('almonds',                 null,       579.0,         21.0,         22.0,         50.0,          28.0,         'seed', 'seed:nut:almonds'),
    ('walnuts',                 null,       654.0,         15.0,         14.0,         65.0,          28.0,         'seed', 'seed:nut:walnuts'),
    ('cashews',                 null,       553.0,         18.0,         30.0,         44.0,          28.0,         'seed', 'seed:nut:cashews'),
    ('peanuts, dry roasted',    null,       567.0,         26.0,         16.0,         49.0,          28.0,         'seed', 'seed:nut:peanuts-roasted'),
    ('pistachios',              null,       562.0,         20.0,         28.0,         45.0,          28.0,         'seed', 'seed:nut:pistachios'),
    ('pecans',                  null,       691.0,          9.2,         14.0,         72.0,          28.0,         'seed', 'seed:nut:pecans'),
    ('hazelnuts',               null,       628.0,         15.0,         17.0,         61.0,          28.0,         'seed', 'seed:nut:hazelnuts'),
    ('sunflower seeds',         null,       584.0,         21.0,         20.0,         51.0,          28.0,         'seed', 'seed:seed:sunflower'),
    ('pumpkin seeds',           null,       559.0,         30.0,         11.0,         49.0,          28.0,         'seed', 'seed:seed:pumpkin'),
    ('chia seeds',              null,       486.0,         17.0,         42.0,         31.0,          15.0,         'seed', 'seed:seed:chia'),
    ('flax seeds',              null,       534.0,         18.0,         29.0,         42.0,          10.0,         'seed', 'seed:seed:flax'),
    ('sesame seeds',            null,       573.0,         18.0,         23.0,         50.0,           9.0,         'seed', 'seed:seed:sesame'),

    -- ------------------------------------------------------ Snacks & sweets --
    ('dark chocolate, 70-85%',  null,       598.0,          7.8,         46.0,         43.0,          28.0,         'seed', 'seed:snack:dark-chocolate'),
    ('milk chocolate',          null,       535.0,          7.6,         59.0,         30.0,          40.0,         'seed', 'seed:snack:milk-chocolate'),
    ('potato chips',            null,       536.0,          7.0,         53.0,         35.0,          28.0,         'seed', 'seed:snack:potato-chips'),
    ('air-popped popcorn',      null,       387.0,         13.0,         78.0,          4.5,           8.0,         'seed', 'seed:snack:popcorn-air'),
    ('pretzels',                null,       380.0,         10.0,         80.0,          2.9,          30.0,         'seed', 'seed:snack:pretzels'),
    ('saltine crackers',        null,       421.0,          9.0,         74.0,          9.0,          14.0,         'seed', 'seed:snack:saltines'),
    ('granola bar',             null,       471.0,         10.0,         64.0,         20.0,          28.0,         'seed', 'seed:snack:granola-bar'),
    ('vanilla ice cream',       null,       207.0,          3.5,         24.0,         11.0,          66.0,         'seed', 'seed:snack:ice-cream-vanilla'),
    ('chocolate chip cookie',   null,       488.0,          5.3,         64.0,         24.0,          16.0,         'seed', 'seed:snack:cookie-chocchip'),
    ('glazed donut',            null,       421.0,          4.4,         51.0,         23.0,          60.0,         'seed', 'seed:snack:donut-glazed'),
    ('chocolate brownie',       null,       466.0,          6.0,         59.0,         25.0,          56.0,         'seed', 'seed:snack:brownie'),
    ('croissant',               null,       406.0,          8.2,         46.0,         21.0,          57.0,         'seed', 'seed:snack:croissant'),
    ('muffin, blueberry',       null,       377.0,          5.9,         55.0,         15.0,          57.0,         'seed', 'seed:snack:muffin-blueberry'),

    -- ----------------------------------------------------------- Beverages --
    ('orange juice',            null,        45.0,          0.7,         10.0,          0.2,         248.0,         'seed', 'seed:bev:orange-juice'),
    ('apple juice',             null,        46.0,          0.1,         11.0,          0.1,         248.0,         'seed', 'seed:bev:apple-juice'),
    ('coca-cola',               null,        42.0,          0.0,         11.0,          0.0,         355.0,         'seed', 'seed:bev:coca-cola'),
    ('beer, regular',           null,        43.0,          0.5,          3.6,          0.0,         355.0,         'seed', 'seed:bev:beer-regular'),
    ('red wine',                null,        85.0,          0.1,          2.6,          0.0,         147.0,         'seed', 'seed:bev:red-wine'),
    ('white wine',              null,        82.0,          0.1,          2.6,          0.0,         147.0,         'seed', 'seed:bev:white-wine'),
    ('coffee, black',           null,         1.0,          0.1,          0.0,          0.0,         240.0,         'seed', 'seed:bev:coffee-black'),
    ('tea, black',              null,         1.0,          0.0,          0.3,          0.0,         240.0,         'seed', 'seed:bev:tea-black'),
    ('sports drink',            null,        26.0,          0.0,          6.5,          0.0,         240.0,         'seed', 'seed:bev:sports-drink'),
    ('energy drink',            null,        45.0,          0.0,         11.0,          0.0,         250.0,         'seed', 'seed:bev:energy-drink'),

    -- ---------------------------------------------- Oils, sauces, sweeteners --
    ('olive oil',               null,       884.0,          0.0,          0.0,        100.0,          14.0,         'seed', 'seed:fat:olive-oil'),
    ('vegetable oil',           null,       884.0,          0.0,          0.0,        100.0,          14.0,         'seed', 'seed:fat:vegetable-oil'),
    ('mayonnaise',              null,       680.0,          1.0,          0.6,         75.0,          14.0,         'seed', 'seed:sauce:mayonnaise'),
    ('ketchup',                 null,       101.0,          1.7,         27.0,          0.1,          17.0,         'seed', 'seed:sauce:ketchup'),
    ('mustard, yellow',         null,        66.0,          4.4,          5.8,          4.0,           5.0,         'seed', 'seed:sauce:mustard-yellow'),
    ('soy sauce',               null,        53.0,          8.1,          4.9,          0.6,          16.0,         'seed', 'seed:sauce:soy-sauce'),
    ('honey',                   null,       304.0,          0.3,         82.0,          0.0,          21.0,         'seed', 'seed:sweet:honey'),
    ('maple syrup',             null,       260.0,          0.0,         67.0,          0.2,          20.0,         'seed', 'seed:sweet:maple-syrup'),
    ('white sugar',             null,       387.0,          0.0,        100.0,          0.0,           4.0,         'seed', 'seed:sweet:sugar-white'),
    ('brown sugar',             null,       380.0,          0.1,         98.0,          0.0,           4.0,         'seed', 'seed:sweet:sugar-brown'),
    ('table salt',              null,         0.0,          0.0,          0.0,          0.0,           1.0,         'seed', 'seed:cond:salt'),

    -- ---------------------------------------------------- Fast food / mixed --
    ('cheese pizza, slice',     null,       266.0,         11.0,         33.0,         10.0,         107.0,         'seed', 'seed:fast:cheese-pizza'),
    ('hamburger, plain',        null,       295.0,         17.0,         30.0,         12.0,         110.0,         'seed', 'seed:fast:hamburger-plain'),
    ('cheeseburger',            null,       303.0,         15.0,         30.0,         14.0,         133.0,         'seed', 'seed:fast:cheeseburger'),
    ('french fries',            null,       312.0,          3.4,         41.0,         15.0,         100.0,         'seed', 'seed:fast:french-fries'),
    ('hot dog, with bun',       null,       290.0,         11.0,         22.0,         18.0,          98.0,         'seed', 'seed:fast:hot-dog-bun'),
    ('chicken nuggets',         null,       296.0,         15.0,         18.0,         19.0,          84.0,         'seed', 'seed:fast:chicken-nuggets'),
    ('caesar salad with chicken',null,      154.0,         11.0,          5.0,         10.0,         200.0,         'seed', 'seed:meal:caesar-salad-chicken'),
    ('sushi, salmon nigiri',    null,       142.0,          9.0,         20.0,          3.0,          30.0,         'seed', 'seed:meal:sushi-salmon-nigiri')
)
insert into foods (name, brand, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, serving_size_g, source, source_food_id)
select s.name, s.brand,
       s.calories_per_100g, s.protein_per_100g, s.carbs_per_100g, s.fat_per_100g,
       s.serving_size_g, s.source, s.source_food_id
from   seed_foods s
left join foods f
       on f.source = s.source and f.source_food_id = s.source_food_id
where  f.id is null;

-- Quick visibility for the operator running it.
select count(*) as seed_rows_in_db
from   foods
where  source = 'seed';
