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

quantite_par_produit_tranche_age AS (
    -- Nombre de commandes par produit et tranche d'âge
    SELECT
        p.Produit AS produit,
        ta.tranche_age,
        COUNT(dc.quantite) AS nb_commandes
    FROM `cart-trend-projet.CartTrend.stg_carttrend_commandes` c
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_details_commandes` dc ON c.id_commande = dc.id_commande
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_produits` p ON dc.id_produit = p.ID
    JOIN tranche_age ta ON c.id_client = ta.id_client
    GROUP BY p.Produit, ta.tranche_age
),

produit_top_par_tranche AS (
    -- Produit le plus acheté par tranche d'âge
    SELECT 
        tranche_age,
        produit AS produit_preferer,
        nb_commandes,
        ROW_NUMBER() OVER (PARTITION BY tranche_age ORDER BY nb_commandes DESC) AS rang
    FROM quantite_par_produit_tranche_age
)

SELECT 
    tranche_age, 
    produit_preferer,
    nb_commandes
FROM produit_top_par_tranche
WHERE rang = 1
ORDER BY tranche_age
