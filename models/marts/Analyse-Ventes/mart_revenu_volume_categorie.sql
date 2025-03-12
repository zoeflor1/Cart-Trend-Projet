WITH quantite_par_categorie AS (
    SELECT
        FORMAT_DATE('%Y-%m', DATE(c.date_commande)) AS mois,
        p.`Catégorie`,
        SUM(dc.quantite) AS quantite_vendue
    FROM `cart-trend-projet.CartTrend.stg_carttrend_commandes` c
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_details_commandes` dc 
        ON c.id_commande = dc.id_commande
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_produits` p 
        ON dc.id_produit = p.ID
    GROUP BY mois, p.`Catégorie`
),

commandes_avec_promos AS (
    SELECT 
        c.id_commande,
        dc.id_produit,
        c.date_commande,
        dc.quantite,
        p.Prix AS prix_unitaire,
        c.`id_promotion_appliquée`,
        p.`Catégorie`,
        -- Calcul du prix après promotion :
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
        c.`Catégorie`,
        ROUND(SUM(dc.quantite * c.prix_apres_promo), 2) AS revenu_genere
    FROM commandes_avec_promos c
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_details_commandes` dc 
        ON c.id_commande = dc.id_commande
    GROUP BY 1, 2
)

-- Jointure entre quantite_par_categorie et revenu_par_categorie
SELECT 
    qpc.mois,
    PARSE_DATE('%Y-%m', qpc.mois) AS mois_date, -- Ajout d'une colonne date pour le tri
    qpc.`Catégorie`,
    qpc.quantite_vendue,
    rpc.revenu_genere
FROM quantite_par_categorie qpc
LEFT JOIN revenu_par_categorie rpc 
    ON qpc.mois = rpc.mois AND qpc.`Catégorie` = rpc.`Catégorie`
ORDER BY mois_date, qpc.`Catégorie`