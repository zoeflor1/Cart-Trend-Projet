SELECT 
    id_commande,
    id_client,

    CASE 
        WHEN REGEXP_CONTAINS(`id_entrepôt_départ`, r'^[Ee]?\d+$') THEN CONCAT('E', REGEXP_REPLACE(`id_entrepôt_départ`, r'^[Ee]?', ''))
        ELSE 'E000000'
    END AS `id_entrepôt_départ`,

    PARSE_DATE('%Y-%m-%d', date_commande) AS date_commande,

    COALESCE(NULLIF(TRIM(statut_commande), ''), 'NaN') AS statut_commande,
    COALESCE(NULLIF(TRIM(`id_promotion_appliquée`), ''), 'NaN') AS `id_promotion_appliquée`,
    COALESCE(NULLIF(TRIM(mode_de_paiement), ''), 'NaN') AS mode_de_paiement,
    COALESCE(NULLIF(TRIM(`numéro_tracking`), ''), 'NaN') AS `numéro_tracking`,

    COALESCE(CAST(PARSE_DATE('%Y-%m-%d', `date_livraison_estimée`) AS STRING), 'NaN') AS `date_livraison_estimée`,

    -- Calcul du délai en jours entre la date de commande et la date de livraison estimée
    DATE_DIFF(
        SAFE.PARSE_DATE('%Y-%m-%d', `date_livraison_estimée`), 
        SAFE.PARSE_DATE('%Y-%m-%d', date_commande), 
        DAY
    ) AS `délai_livraison_jours`

FROM `cart-trend-projet.CartTrend.Carttrend_Commandes`
WHERE id_commande IS NOT NULL  
AND id_client IS NOT NULL  
ORDER BY id_commande ASC