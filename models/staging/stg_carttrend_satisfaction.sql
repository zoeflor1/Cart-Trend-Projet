WITH raw_data AS (
    SELECT 
        `id_satisfaction`,
        `id_commande`,
        `note_client`,
        `commentaire`,
        `plainte`,
        `temps_réponse_support`,
        COALESCE(`type_plainte`, 'Others') AS `type_plainte`, -- Remplace NULL par "Others"
        COALESCE(`employé_support`, 'NO_employee') AS `employé_support` -- Remplace NULL par "NO_employee"
    FROM `cart-trend-projet.CartTrend.Carttrend_Satisfaction`
)

SELECT 
    `id_satisfaction`,
    `id_commande`,
    `note_client`,
    `commentaire`,
    `plainte`,
    `temps_réponse_support`,
    `type_plainte`,
    `employé_support`
FROM raw_data
WHERE 
    -- Suppression des données aberrantes
    `note_client` BETWEEN 1 AND 5 -- La note client doit être entre 1 et 5
    AND `temps_réponse_support` >= 0 -- Pas de temps de réponse négatif
    AND `id_satisfaction` IS NOT NULL
    AND `id_commande` IS NOT NULL
