WITH commandes AS (
    -- Jointure entre commandes et détails des commandes
    SELECT 
        dc.id_commande,
        dc.id_produit,
        c.date_commande,
        dc.quantite,
        p.Prix AS prix_unitaire_original,  -- Prix unitaire des produits
        c.`id_promotion_appliquée`
    FROM {{ ref('stg_carttrend_details_commandes') }} dc
    JOIN {{ ref('stg_carttrend_commandes') }} c 
        ON dc.id_commande = c.id_commande
    JOIN {{ ref('stg_carttrend_produits') }} p 
        ON dc.id_produit = p.ID
),
promotions AS (
    -- Table des promotions avec conversion des valeurs pour éviter les erreurs
    SELECT 
        id_produit,
        id_promotion,
        type_promotion,
        SAFE_CAST(valeur_pourcentage AS FLOAT64) AS valeur_pourcentage,
        SAFE_CAST(valeur_remise AS FLOAT64) AS valeur_remise
    FROM {{ ref('stg_carttrend_promotions') }}
),
commandes_avec_promos AS (
    -- Jointure avec promotions + Calcul du prix après promo
    SELECT 
        c.id_commande,
        c.id_produit,
        c.date_commande,
        c.quantite,
        p.type_promotion,
        p.valeur_pourcentage AS valeur_pourcentage,
        p.valeur_remise AS valeur_remise,
        c.prix_unitaire_original, -- Prix de base sans promo

        -- Calcul du prix après promo :
        CASE 
            WHEN p.id_promotion IS NULL THEN c.prix_unitaire_original  -- Pas de promo
            WHEN p.type_promotion = 'Remise fixe' THEN GREATEST(0, c.prix_unitaire_original - p.valeur_remise) -- Remise fixe
            WHEN p.type_promotion = 'Pourcentage' THEN GREATEST(0, c.prix_unitaire_original * (1 - p.valeur_pourcentage / 100)) -- Pourcentage
            ELSE c.prix_unitaire_original  -- Sécurité au cas où
        END AS prix_apres_promo
    FROM commandes c
    LEFT JOIN promotions p
        ON c.id_produit = p.id_produit 
        AND c.`id_promotion_appliquée` = p.id_promotion
),
budget_marketing AS (
    -- Pré-agrégation du budget marketing par mois
    SELECT 
        FORMAT_DATE('%Y-%m', DATE(date)) AS mois, 
        SUM(budget) AS budget_total
    FROM {{ ref('stg_carttrend_campaigns') }}
    GROUP BY 1
),
revenu_mensuel AS (
    -- Calcul des revenus, marges et nombre de commandes par mois
    SELECT 
        FORMAT_DATE('%Y-%m', DATE(c.date_commande)) AS mois,

        -- Nombre total de commandes par mois
        COUNT(DISTINCT c.id_commande) AS nombre_commandes,

        -- Calcul des revenus sans promo (total brut)
        ROUND(SUM(c.quantite * c.prix_unitaire_original), 2) AS revenu_sans_promo,

        -- Calcul des revenus avec promo (après réduction)
        ROUND(SUM(c.quantite * c.prix_apres_promo), 2) AS revenu_avec_promo,

        -- Différence due aux promos
        ROUND(SUM(c.quantite * c.prix_unitaire_original) - SUM(c.quantite * c.prix_apres_promo), 2) AS difference_revenu,

        -- Budget total pré-agrégé
        ROUND(COALESCE(bm.budget_total, 0), 2) AS budget_total,

        -- Marges avec et sans promo
        ROUND(SUM(c.quantite * c.prix_apres_promo) - COALESCE(bm.budget_total, 0), 2) AS marge_avec_promo,
        ROUND(SUM(c.quantite * c.prix_unitaire_original) - COALESCE(bm.budget_total, 0), 2) AS marge_sans_promo
    FROM commandes_avec_promos c
    LEFT JOIN budget_marketing bm
        ON FORMAT_DATE('%Y-%m', DATE(c.date_commande)) = bm.mois
    GROUP BY 1, bm.budget_total
)
SELECT * 
FROM revenu_mensuel
ORDER BY mois