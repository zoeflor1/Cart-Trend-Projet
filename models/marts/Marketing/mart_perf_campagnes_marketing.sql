SELECT 
    `canal`,
    CAST(ROUND(SUM(clics), 2) AS INT) AS `nbr_clics`,
    CAST(SUM(conversions) AS INT) AS `nbr_conversion`,
    ROUND(AVG(CTR), 3) AS `CTR_moyen`,
    ROUND(SUM(budget), 2) AS `budget_total`,
    CASE 
        WHEN SUM(conversions) > 0 THEN ROUND(SUM(budget) / SUM(conversions), 2)
        ELSE NULL 
    END AS `CPA`,
    
    -- Calcul des parts de chaque `événement_type`
    ROUND(
        (SUM(CASE WHEN `événement_type` = 'Soldes' THEN 1 ELSE 0 END) * 1.0) / COUNT(*) * 100, 2
    ) AS `part_soldes`,
    
    ROUND(
        (SUM(CASE WHEN `événement_type` = 'Black Friday' THEN 1 ELSE 0 END) * 1.0) / COUNT(*) * 100, 2
    ) AS `part_black_friday`,
    
    ROUND(
        (SUM(CASE WHEN `événement_type` = 'Aucun' THEN 1 ELSE 0 END) * 1.0) / COUNT(*) * 100, 2
    ) AS `part_aucun`,
    
    ROUND(
        (SUM(CASE WHEN `événement_type` = 'Noël' THEN 1 ELSE 0 END) * 1.0) / COUNT(*) * 100, 2
    ) AS `part_noel`

FROM {{ ref('stg_carttrend_campaigns') }}
GROUP BY `canal`
ORDER BY `CPA` DESC
