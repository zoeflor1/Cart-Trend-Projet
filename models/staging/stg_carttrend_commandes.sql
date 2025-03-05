-- models/staging/stg_carttrend_commandes.sql

SELECT 
    -- Supprimer les lignes où 'id_commande' est NULL
    id_commande,

    id_client,

    -- S'assurer que 'id_entrepôt_départ' commence bien par 'E' suivi de chiffres
    CASE 
        WHEN REGEXP_CONTAINS(`id_entrepôt_départ`, r'^[Ee]?\d+$') THEN CONCAT('E', REGEXP_REPLACE(`id_entrepôt_départ`, r'^[Ee]?', ''))
        ELSE 'E000000'  -- Valeur par défaut si l'entrepôt n'est pas valide
    END AS `id_entrepôt_départ`,

    -- Uniformiser le format de la date de commande
    PARSE_DATE('%Y-%m-%d', date_commande) AS date_commande,

    -- Remplacement des valeurs vides par 'NaN' pour certaines colonnes
    COALESCE(NULLIF(TRIM(statut_commande), ''), 'NaN') AS statut_commande,
    COALESCE(NULLIF(TRIM(`id_promotion_appliquée`), ''), 'NaN') AS `id_promotion_appliquée`,
    COALESCE(NULLIF(TRIM(mode_de_paiement), ''), 'NaN') AS mode_de_paiement,
    COALESCE(NULLIF(TRIM(`numéro_tracking`), ''), 'NaN') AS `numéro_tracking`,

    -- Uniformisation du format de la date de livraison estimée
    COALESCE(CAST(PARSE_DATE('%Y-%m-%d', `date_livraison_estimée`) AS STRING), 'NaN') AS `date_livraison_estimée`

FROM `cart-trend-projet.CartTrend.Carttrend_Commandes`
WHERE id_commande IS NOT NULL  -- Exclure les lignes où 'id_commande' est NULL
AND id_client IS NOT NULL -- Exclure les lignes où 'id_client' est NULL
ORDER BY id_commande ASC