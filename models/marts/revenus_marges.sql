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
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_commandes` c ON dc.id_commande = c.id_commande
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_produits` p ON dc.id_produit = p.ID
),

promotions AS (
    -- Table des promotions avec calcul du prix après remise
    SELECT 
        cp.id_produit,
        cp.id_promotion,
        cp.type_promotion,
        -- Utilisation des nouvelles colonnes
        CAST(NULLIF(cp.valeur_pourcentage, 'NaN') AS FLOAT64) AS valeur_pourcentage,
        CAST(NULLIF(cp.valeur_remise, 'NaN') AS FLOAT64) AS valeur_remise
    FROM `cart-trend-projet.CartTrend.stg_carttrend_promotions` cp
),

commandes_avec_promos AS (
    -- Jointure des commandes avec promotions pour calcul du prix réduit
    SELECT 
        c.*,
        p.type_promotion,
        p.valeur_pourcentage,
        p.valeur_remise,
        -- Calcul du prix après promotion :
        CASE 
            WHEN c.`id_promotion_appliquée` IS NOT NULL AND p.type_promotion = 'remise fixe' AND p.valeur_remise IS NOT NULL THEN 
                GREATEST(c.prix_unitaire - p.valeur_remise, 0) -- Remise fixe
            WHEN c.`id_promotion_appliquée` IS NOT NULL AND p.type_promotion = 'pourcentage' AND p.valeur_pourcentage IS NOT NULL THEN 
                c.prix_unitaire * (1 - p.valeur_pourcentage / 100) -- Pourcentage
            ELSE 
                c.prix_unitaire -- Si pas de promo, le prix reste le même
        END AS prix_apres_promo
    FROM commandes c
    LEFT JOIN promotions p ON c.id_produit = p.id_produit AND c.`id_promotion_appliquée` = p.id_promotion
),

revenu_mensuel AS (
    -- Calcul des revenus et marges par mois
    SELECT 
        FORMAT_DATE('%Y-%m', DATE(c.date_commande)) AS mois,
        SUM(c.quantite * c.prix_unitaire) AS revenu_sans_promo,
        SUM(c.quantite * c.prix_apres_promo) AS revenu_avec_promo,
        SUM(c.quantite * c.prix_unitaire) - SUM(c.quantite * c.prix_apres_promo) AS difference_revenu,
        COALESCE(SUM(cam.budget), 0) AS budget_total,
        SUM(c.quantite * c.prix_apres_promo) - COALESCE(SUM(cam.budget), 0) AS marge_avec_promo,
        SUM(c.quantite * c.prix_unitaire) - COALESCE(SUM(cam.budget), 0) AS marge_sans_promo
    FROM commandes_avec_promos c
    LEFT JOIN `cart-trend-projet.CartTrend.stg_carttrend_campaigns` cam
        ON FORMAT_DATE('%Y-%m', DATE(c.date_commande)) = FORMAT_DATE('%Y-%m', DATE(cam.date))
    GROUP BY 1
)

SELECT * FROM revenu_mensuel
ORDER BY mois