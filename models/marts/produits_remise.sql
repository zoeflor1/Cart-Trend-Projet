WITH Promotions AS (
    SELECT 
        p.ID,  
        pr.type_promotion
    FROM {{ ref('stg_carttrend_promotions') }} pr
    JOIN {{ ref('stg_carttrend_produits') }} p 
        ON pr.id_produit = p.ID  
),
TotalProduits AS (
    SELECT COUNT(*) AS total_produits
    FROM {{ ref('stg_carttrend_produits') }} p
)
SELECT 
    type_promotion, 
    COUNT(*) AS nombre_promotions,  -- On compte chaque promotion individuellement
    COUNT(*) * 1.0 / (SELECT total_produits FROM TotalProduits) AS part_promotions  -- Calcul du pourcentage
FROM Promotions
WHERE type_promotion IN ('Pourcentage', 'Remise fixe')
GROUP BY type_promotion