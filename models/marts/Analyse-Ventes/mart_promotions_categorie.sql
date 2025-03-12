WITH commandes AS (
    -- Jointure entre commandes et détails des commandes
    SELECT 
        dc.id_commande,
        dc.id_produit,
        c.date_commande,
        dc.quantite
    FROM {{ ref('stg_carttrend_details_commandes') }} dc
    JOIN {{ ref('stg_carttrend_commandes') }} c 
        ON dc.id_commande = c.id_commande
),
promotions AS (
    -- Sélection des promotions valides sur la période de commande
    SELECT 
        id_produit,
        type_promotion,
        date_debut_date,
        date_fin_date
    FROM {{ ref('stg_carttrend_promotions') }}
    WHERE type_promotion IN ('Pourcentage', 'Remise fixe')
),
commandes_avec_promos AS (
    -- Jointure avec promotions
    SELECT 
        c.id_commande,
        c.id_produit,
        c.date_commande,
        c.quantite,
        p.type_promotion
    FROM commandes c
    LEFT JOIN promotions p
        ON c.id_produit = p.id_produit 
        AND c.date_commande BETWEEN p.date_debut_date AND p.date_fin_date
),
revenu_mensuel AS (
    SELECT 
        FORMAT_DATE('%Y-%m', DATE(c.date_commande)) AS mois,
        COUNT(DISTINCT c.id_commande) AS nombre_commandes,
        COUNT(CASE WHEN c.type_promotion IS NOT NULL THEN c.id_commande END) AS nombre_promotions_appliquees,
        SUM(CASE WHEN c.type_promotion = 'Pourcentage' THEN c.quantite ELSE 0 END) AS quantite_promo_pourcentage,
        SUM(CASE WHEN c.type_promotion = 'Remise fixe' THEN c.quantite ELSE 0 END) AS quantite_promo_remise_fixe,
        SUM(CASE WHEN c.type_promotion IS NULL THEN c.quantite ELSE 0 END) AS quantite_sans_promo,
        SUM(c.quantite) AS quantite_totale_vendue
    FROM commandes_avec_promos c
    GROUP BY 1
),
quantite_par_categorie AS (
    SELECT
        FORMAT_DATE('%Y-%m', DATE(c.date_commande)) AS mois,
        p.`Catégorie` AS categorie,
        SUM(dc.quantite) AS quantite_vendue
    FROM `cart-trend-projet.CartTrend.stg_carttrend_commandes` c
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_details_commandes` dc 
        ON c.id_commande = dc.id_commande
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_produits` p 
        ON dc.id_produit = p.ID
    GROUP BY mois, categorie
),
commandes_avec_promos_categorie AS (
    SELECT 
        c.id_commande,
        dc.id_produit,
        c.date_commande,
        dc.quantite,
        p.Prix AS prix_unitaire,
        c.`id_promotion_appliquée`,
        p.`Catégorie` AS categorie,
        CASE 
            WHEN c.`id_promotion_appliquée` IS NOT NULL AND promo.type_promotion = 'remise fixe' AND promo.valeur_remise IS NOT NULL THEN 
                p.Prix - promo.valeur_remise 
            WHEN c.`id_promotion_appliquée` IS NOT NULL AND promo.type_promotion = 'pourcentage' AND promo.valeur_pourcentage IS NOT NULL THEN 
                p.Prix * (1 - promo.valeur_pourcentage / 100) 
            ELSE 
                p.Prix
        END AS prix_apres_promo
    FROM `cart-trend-projet.CartTrend.stg_carttrend_commandes` c
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_details_commandes` dc 
        ON c.id_commande = dc.id_commande
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_produits` p 
        ON dc.id_produit = p.ID
    LEFT JOIN `cart-trend-projet.CartTrend.stg_carttrend_promotions` promo 
        ON dc.id_produit = promo.id_produit AND c.`id_promotion_appliquée` = promo.id_promotion
),
revenu_par_categorie AS (
    SELECT 
        FORMAT_DATE('%Y-%m', DATE(c.date_commande)) AS mois,
        c.categorie,
        ROUND(SUM(dc.quantite * c.prix_apres_promo), 2) AS revenu_genere
    FROM commandes_avec_promos_categorie c
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_details_commandes` dc 
        ON c.id_commande = dc.id_commande
    GROUP BY 1, 2
)
SELECT 
    qpc.mois,
    PARSE_DATE('%Y-%m', qpc.mois) AS mois_date,
    qpc.categorie,
    qpc.quantite_vendue,
    rpc.revenu_genere,
    rm.nombre_commandes,
    rm.nombre_promotions_appliquees,
    rm.quantite_promo_pourcentage,
    rm.quantite_promo_remise_fixe,
    rm.quantite_sans_promo,
    rm.quantite_totale_vendue
FROM quantite_par_categorie qpc
LEFT JOIN revenu_par_categorie rpc 
    ON qpc.mois = rpc.mois AND qpc.categorie = rpc.categorie
LEFT JOIN revenu_mensuel rm
    ON qpc.mois = rm.mois
ORDER BY mois_date, qpc.categorie
