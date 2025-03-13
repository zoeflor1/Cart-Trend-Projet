WITH commandes_valides AS (
    SELECT 
        id_client,
        FORMAT_TIMESTAMP('%Y-%m', date_commande) AS mois_commande, -- Regroupement par mois
        id_produit
    FROM `cart-trend-projet.CartTrend.stg_carttrend_commandes` c
    JOIN `cart-trend-projet.CartTrend.stg_carttrend_details_commandes` dc
        ON c.id_commande = dc.id_commande
    WHERE c.statut_commande IN ('Validée', 'Livrée')
),

produit_paires AS (
    SELECT 
        cv1.id_produit AS id_produit_1,
        cv2.id_produit AS id_produit_2
    FROM
        commandes_valides cv1
    JOIN commandes_valides cv2
        ON cv1.id_client = cv2.id_client
        AND cv1.mois_commande = cv2.mois_commande
        AND cv1.id_produit < cv2.id_produit
)

SELECT
    p1.Produit AS produit_1,
    p2.Produit AS produit_2,
    COUNT(*) AS nombre_de_fois_acheter
FROM
    produit_paires pp
JOIN `cart-trend-projet.CartTrend.stg_carttrend_produits` p1
    ON pp.id_produit_1 = p1.ID
JOIN `cart-trend-projet.CartTrend.stg_carttrend_produits` p2
    ON pp.id_produit_2 = p2.ID
GROUP BY
    p1.Produit,
    p2.Produit
ORDER BY
    nombre_de_fois_acheter DESC
