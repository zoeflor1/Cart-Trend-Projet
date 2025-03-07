-- Création d'une CTE "details" pour récupérer les informations des détails de commande
WITH details AS (
    SELECT 
        dc.`id_commande`,  -- Identifiant de la commande
        dc.`id_produit`,   -- Identifiant du produit commandé
        dc.`quantite`      -- Quantité de ce produit dans la commande
    FROM {{ ref('stg_carttrend_details_commandes') }} dc
),

-- Création d'une CTE "produits_achetes" pour associer les produits achetés ensemble dans une même commande
produits_achetes AS (
    SELECT
        d1.`id_commande`,     -- Identifiant de la commande
        d1.`id_produit` AS `produit_1`,  -- Premier produit dans la commande
        d2.`id_produit` AS `produit_2`   -- Deuxième produit dans la même commande
    FROM details d1
    JOIN details d2
        ON d1.`id_commande` = d2.`id_commande`  -- Associer les produits d'une même commande
        AND d1.`id_produit` != d2.`id_produit`  -- S'assurer que ce ne sont pas deux fois le même produit
)

-- Requête finale pour compter combien de fois chaque paire de produits a été achetée ensemble
SELECT
    `produit_1`,  -- Premier produit dans la paire
    `produit_2`,  -- Deuxième produit dans la paire
    COUNT(*) AS `nombre_de_fois_achetes_ensemble`  -- Nombre total de fois où cette paire a été commandée ensemble
FROM produits_achetes
GROUP BY
    `produit_1`,
    `produit_2`
ORDER BY
    `nombre_de_fois_achetes_ensemble` DESC  -- Trier du plus grand au plus petit nombre d'achats ensemble