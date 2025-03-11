WITH base_data AS (
    SELECT 
        id_campagne,
        PARSE_DATE('%Y-%m-%d', date) AS date,
        INITCAP(TRIM(COALESCE(canal, ''))) AS canal,  
        GREATEST(COALESCE(impressions, 0), 0) AS impressions,  
        GREATEST(COALESCE(conversions, 0), 0) AS conversions,
        GREATEST(COALESCE(clics, 0), 0) AS clics,
        GREATEST(COALESCE(CTR, 0), 0) AS CTR,
        GREATEST(COALESCE(budget, 0), 0) AS budget,
        INITCAP(TRIM(COALESCE(`événement_type`, 'Aucun'))) AS `événement_type`
    FROM `cart-trend-projet.CartTrend.Carttrend_Campaigns`
    WHERE date IS NOT NULL  
)

SELECT 
    canal,
    
    -- Nombre total de clics et conversions
    CAST(ROUND(SUM(clics), 2) AS INT) AS nbr_clics,
    CAST(SUM(conversions) AS INT) AS nbr_conversion,

    -- Moyenne du CTR arrondie à 3 décimales
    ROUND(AVG(CTR), 3) AS CTR_moyen,

    -- Budget total dépensé
    ROUND(SUM(budget), 2) AS budget_total,

    -- Coût par acquisition (CPA) = Budget total / Nombre de conversions
    CASE 
        WHEN SUM(conversions) > 0 THEN ROUND(SUM(budget) / SUM(conversions), 2)
        ELSE NULL 
    END AS CPA,

    -- Taux de conversion (Conversions / Clic) * 100
    ROUND(
        CASE 
            WHEN SUM(impressions) = 0 THEN 0  
            ELSE (SUM(conversions) / SUM(clics)) * 100
        END, 
    2) AS taux_conversion_canal,

    -- 🔥 Ajout du taux de clic (CTR) = (Clics / Impressions) * 100
    ROUND(
        CASE 
            WHEN SUM(impressions) = 0 THEN 0  
            ELSE (SUM(clics) / SUM(impressions)) * 100
        END, 
    2) AS taux_clic_canal,

    -- Calcul des parts des événements en %
    ROUND(
        (SUM(CASE WHEN `événement_type` = 'Soldes' THEN 1 ELSE 0 END) * 1.0) / COUNT(*) * 100, 2
    ) AS part_soldes,
    
    ROUND(
        (SUM(CASE WHEN `événement_type` = 'Black Friday' THEN 1 ELSE 0 END) * 1.0) / COUNT(*) * 100, 2
    ) AS part_black_friday,
    
    ROUND(
        (SUM(CASE WHEN `événement_type` = 'Aucun' THEN 1 ELSE 0 END) * 1.0) / COUNT(*) * 100, 2
    ) AS part_aucun,
    
    ROUND(
        (SUM(CASE WHEN `événement_type` = 'Noël' THEN 1 ELSE 0 END) * 1.0) / COUNT(*) * 100, 2
    ) AS part_noel

FROM base_data
GROUP BY canal
ORDER BY CPA DESC
