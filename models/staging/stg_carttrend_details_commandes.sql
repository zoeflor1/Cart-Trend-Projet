-- models/staging/stg_carttrend_details_commandes.sql

SELECT 
    id_commande,
    COALESCE(NULLIF(TRIM(id_produit), ''), 'NaN') AS id_produit,
    COALESCE(NULLIF(TRIM(CAST(`quantité` AS STRING)), ''), 'NaN') AS `quantité`,
    COALESCE(NULLIF(TRIM(`emballage_spécial`), ''), 'NaN') AS `emballage_spécial`

FROM `cart-trend-projet.CartTrend.Carttrend_Details_Commandes`

WHERE id_commande IS NOT NULL  -- Supprime les lignes où 'id_commande' est NULL

ORDER BY id_commande ASC
