WITH tranche_age AS (
    SELECT
        id_client,
        CASE 
            WHEN `âge` < 20 THEN 'Moins de 20 ans'
            WHEN `âge` BETWEEN 20 AND 29 THEN '20-29 ans'
            WHEN `âge` BETWEEN 30 AND 39 THEN '30-39 ans'
            WHEN `âge` BETWEEN 40 AND 49 THEN '40-49 ans'
            ELSE '50 ans et plus'
        END AS tranche_age
    FROM `cart-trend-projet.CartTrend.stg_carttrend_clients`
),

quantite_par_categorie_tranche_age AS (
    SELECT
        p.`Catégorie`,
        ta.tranche_age,
        COUNT(DISTINCT c.id_commande) AS nb_commandes
    FROM `cart-trend-projet.CartTrend.stg_carttrend_commandes` c
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_details_commandes` dc ON c.id_commande = dc.id_commande
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_produits` p ON dc.id_produit = p.ID
    JOIN tranche_age ta ON c.id_client = ta.id_client
    GROUP BY p.`Catégorie`, ta.tranche_age
)

SELECT * 
FROM quantite_par_categorie_tranche_age
ORDER BY `Catégorie`, tranche_age