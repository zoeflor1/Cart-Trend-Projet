WITH commandes AS (
    SELECT 
        c.id_commande,
        c.id_client,
        c.date_commande
    FROM {{ ref('stg_carttrend_commandes') }} c
),

satisfaction AS (
    SELECT 
        s.id_commande,
        s.note_client
    FROM {{ ref('stg_carttrend_satisfaction') }} s
),

detail_commandes AS (
    SELECT 
        d.id_commande,
        d.id_produit
    FROM {{ ref('stg_carttrend_details_commandes') }} d
),

produits AS (
    SELECT 
        p.ID,
        p.`Catégorie`
    FROM {{ ref('stg_carttrend_produits') }} p
)

-- Calcul de la note moyenne par catégorie de produit
SELECT 
    p.`Catégorie` AS categorie_produit,
    ROUND(AVG(s.note_client), 2) AS note_moyenne_categorie
FROM {{ ref('stg_carttrend_details_commandes') }} c
-- Joindre satisfaction avec les commandes
LEFT JOIN `CartTrend.stg_carttrend_satisfaction` s 
    ON c.id_commande = s.id_commande
-- Joindre detail_commandes pour lier les produits aux commandes
LEFT JOIN `cart-trend-projet.CartTrend.stg_carttrend_details_commandes` d 
    ON c.id_commande = d.id_commande
-- Joindre produits pour obtenir la catégorie des produits
LEFT JOIN `cart-trend-projet.CartTrend.stg_carttrend_produits` p 
    ON d.id_produit = p.ID
GROUP BY p.`Catégorie`
ORDER BY note_moyenne_categorie DESC