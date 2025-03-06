-- models/staging/stg_carttrend_campaigns.sql
SELECT 
    id_campagne,

    PARSE_DATE('%Y-%m-%d', date) AS date,  -- Convertir la colonne 'date' en format DATE

    CASE 
        WHEN TRIM(`événement_oui_non`) = '' OR `événement_oui_non` IS NULL THEN 'No'  -- Si la valeur est vide ou NULL, remplacer par 'No'
        ELSE INITCAP(TRIM(COALESCE(`événement_oui_non`, '')))  -- Enlever les espaces et garder la valeur avec la première lettre en majuscule
    END AS `événement_oui_non`,

    INITCAP(TRIM(COALESCE(`événement_type`, ''))) AS `événement_type`,   -- Garder la colonne 'événement_type' telle quelle

    INITCAP(TRIM(COALESCE(canal, ''))) AS canal,           -- Garder la colonne 'canal' telle quelle

    -- Empêcher les valeurs négatives pour 'budget' en remplaçant par 0
    GREATEST(COALESCE(budget, 0), 0) AS budget,  -- Remplacer NULL ou une valeur négative par 0

    -- Empêcher les valeurs négatives pour 'impressions' en remplaçant par 0
    GREATEST(COALESCE(impressions, 0), 0) AS impressions,  -- Remplacer NULL ou une valeur négative par 0

    -- Empêcher les valeurs négatives pour 'clics' en remplaçant par 0
    GREATEST(COALESCE(clics, 0), 0) AS clics,  -- Remplacer NULL ou une valeur négative par 0

    -- Empêcher les valeurs négatives pour 'conversions' en remplaçant par 0
    GREATEST(COALESCE(conversions, 0), 0) AS conversions,  -- Remplacer NULL ou une valeur négative par 0

    -- Empêcher les valeurs négatives pour 'CTR' en remplaçant par 0
    GREATEST(COALESCE(CTR, 0), 0) AS CTR  -- Remplacer NULL ou une valeur négative par 0

FROM `cart-trend-projet.CartTrend.Carttrend_Campaigns`
WHERE date IS NOT NULL  -- Exclure les lignes où la colonne 'date' est NULL
