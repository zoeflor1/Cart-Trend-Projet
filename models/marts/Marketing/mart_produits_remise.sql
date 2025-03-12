WITH Promotions AS (
    -- Sélection des promotions "Pourcentage" ou "Remise fixe"
    SELECT 
        id_produit,  
        id_promotion,
        type_promotion,
        date_debut_date,
        date_fin_date
    FROM {{ ref('stg_carttrend_promotions') }}
    WHERE type_promotion IN ('Pourcentage', 'Remise fixe')
),
CommandesAvecPromos AS (
    -- Jointure entre commandes, détails des commandes et promotions
    SELECT 
        dc.id_produit,
        c.date_commande,
        dc.quantite,
        COALESCE(p.type_promotion, 'Sans promotion') AS type_promotion
    FROM {{ ref('stg_carttrend_details_commandes') }} dc
    JOIN {{ ref('stg_carttrend_commandes') }} c 
        ON dc.id_commande = c.id_commande
    LEFT JOIN Promotions p
        ON dc.id_produit = p.id_produit 
        AND c.date_commande BETWEEN p.date_debut_date AND p.date_fin_date  -- Vérifie que la date de la commande est dans la période de promo
)
SELECT 
    type_promotion, 
    SUM(quantite) AS nombre_produits_vendus
FROM CommandesAvecPromos
GROUP BY type_promotion
ORDER BY nombre_produits_vendus DESC