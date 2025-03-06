SELECT 
    id_commande,
    COALESCE(NULLIF(TRIM(CAST(id_produit AS STRING)), ''), NULL) AS id_produit,  -- Conversion de id_produit en STRING avant TRIM
    SAFE_CAST(NULLIF(TRIM(CAST(`quantité` AS STRING)), '') AS INT64) AS quantite,  -- Conversion de quantité en STRING avant TRIM puis en INT64
    COALESCE(NULLIF(TRIM(CAST(`emballage_spécial` AS STRING)), ''), NULL) AS emballage_special  -- Conversion de emballage_special en STRING avant TRIM

FROM `cart-trend-projet.CartTrend.Carttrend_Details_Commandes`

WHERE id_commande IS NOT NULL  -- Supprime les lignes où 'id_commande' est NULL

ORDER BY id_commande ASC
