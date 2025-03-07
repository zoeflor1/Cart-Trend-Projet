WITH commandes AS (
    -- Jointure entre commandes et détails des commandes
    SELECT 
        dc.id_commande,
        dc.id_produit,
        c.date_commande,
        dc.quantite,
        p.Prix AS prix_unitaire,
        c.`id_promotion_appliquée`
    FROM `cart-trend-projet.CartTrend.stg_carttrend_details_commandes` dc
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_commandes` c 
        ON dc.id_commande = c.id_commande
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_produits` p 
        ON dc.id_produit = p.ID
),

promotions AS (
    -- Table des promotions avec calcul du prix après remise
    SELECT 
        id_produit,
        id_promotion,
        type_promotion,
        CAST(NULLIF(SAFE_CAST(valeur_pourcentage AS STRING), 'NaN') AS FLOAT64) AS valeur_pourcentage,
        CAST(NULLIF(SAFE_CAST(valeur_remise AS STRING), 'NaN') AS FLOAT64) AS valeur_remise
    FROM `cart-trend-projet.CartTrend.stg_carttrend_promotions`
),

commandes_avec_promos AS (
    -- Jointure des commandes avec promotions pour calcul du prix réduit
    SELECT 
        c.id_commande,
        c.id_produit,
        c.date_commande,
        c.quantite,
        c.prix_unitaire,
        c.`id_promotion_appliquée`,
        p.type_promotion,
        p.valeur_pourcentage,
        p.valeur_remise,
        -- Calcul du prix après promotion :
        CASE 
            WHEN c.`id_promotion_appliquée` IS NOT NULL 
                 AND p.type_promotion = 'remise fixe' 
                 AND p.valeur_remise IS NOT NULL 
                 AND c.prix_unitaire > p.valeur_remise
            THEN c.prix_unitaire - p.valeur_remise -- Remise fixe (si elle ne dépasse pas le prix)
            
            WHEN c.`id_promotion_appliquée` IS NOT NULL 
                 AND p.type_promotion = 'remise fixe' 
                 AND p.valeur_remise IS NOT NULL 
                 AND c.prix_unitaire <= p.valeur_remise
            THEN 0 -- Si la remise est plus grande que le prix du produit, on met 0
            
            WHEN c.`id_promotion_appliquée` IS NOT NULL 
                AND p.type_promotion = 'pourcentage' 
                AND p.valeur_pourcentage IS NOT NULL 
            THEN c.prix_unitaire * (1 - p.valeur_pourcentage) -- Pourcentage (déjà en format décimal)
            
            ELSE c.prix_unitaire -- Pas de promotion appliquée
        END AS prix_apres_promo
    FROM commandes c
    LEFT JOIN promotions p 
        ON c.id_produit = p.id_produit 
        AND c.`id_promotion_appliquée` = p.id_promotion
),


revenu_mensuel AS (
     SELECT 
         FORMAT_DATE('%Y-%m', DATE(c.date_commande)) AS mois,
         SUM(c.quantite * c.prix_unitaire) AS revenu_sans_promo,
         SUM(c.quantite * c.prix_apres_promo) AS revenu_avec_promo,
         SUM(c.quantite * (c.prix_unitaire - c.prix_apres_promo)) AS difference_revenu
     FROM commandes_avec_promos c
     GROUP BY 1
)

 SELECT * FROM revenu_mensuel
 ORDER BY mois