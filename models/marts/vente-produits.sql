WITH 
-- Quantité vendue par produit (commandes)
quantite_vendue AS (
    SELECT 
        dc.id_produit,
        SUM(dc.quantite) AS quantite_vendue
    FROM `cart-trend-projet.CartTrend.stg_carttrend_details_commandes` dc
    GROUP BY dc.id_produit
),

-- Nombre de promotions par produit
nombre_promotions AS (
    SELECT 
        p.id_produit,
        COUNT(DISTINCT p.id_promotion) AS nombre_promotions
    FROM `cart-trend-projet.CartTrend.stg_carttrend_promotions` p
    GROUP BY p.id_produit
),

-- Nombre de fois qu'un produit a été mis en favoris
nombre_favoris AS (
    SELECT 
        pr.ID AS id_produit,
        COUNT(DISTINCT c.id_client) AS nombre_favoris
    FROM `cart-trend-projet.CartTrend.stg_carttrend_clients` c
    CROSS JOIN UNNEST(SPLIT(c.favoris, ',')) AS id_favori -- Découpe les valeurs séparées par virgule
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_produits` pr 
        ON pr.ID = TRIM(id_favori)  -- On retire les espaces inutiles autour des ID
    GROUP BY pr.ID
),

-- Fusionner toutes les informations par produit
produit_metrics AS (
    SELECT 
        q.id_produit,
        q.quantite_vendue,
        COALESCE(np.nombre_promotions, 0) AS nombre_promotions,
        COALESCE(nf.nombre_favoris, 0) AS nombre_favoris
    FROM quantite_vendue q
    LEFT JOIN nombre_promotions np ON q.id_produit = np.id_produit
    LEFT JOIN nombre_favoris nf ON q.id_produit = nf.id_produit
)

-- Résultat final, classé par quantité vendue décroissante
SELECT 
    p.id_produit,
    p.quantite_vendue,
    p.nombre_promotions,
    p.nombre_favoris,
    pr.Produit,
    pr.`Catégorie`,
    pr.Marque
FROM produit_metrics p
JOIN `cart-trend-projet.CartTrend.stg_carttrend_produit` pr 
    ON p.id_produit = pr.ID
ORDER BY p.quantite_vendue DESC