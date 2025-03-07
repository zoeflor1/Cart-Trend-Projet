

WITH commandes AS (
    SELECT 
        `id_commande`,
        `date_commande`
    FROM `CartTrend.stg_carttrend_commandes`
),  

satisfaction AS (
    SELECT 
        `id_commande`,
        `note_client`
    FROM `CartTrend.stg_carttrend_satisfaction`
),

satisfaction_mensuelle AS (
    SELECT 
        FORMAT_DATE('%Y-%m', c.`date_commande`) AS `mois`,  -- Regroupement par mois
        AVG(s.`note_client`) AS `note_moyenne_mois`  -- Moyenne des notes clients par mois
    FROM commandes c
    LEFT JOIN satisfaction s 
        ON c.`id_commande` = s.`id_commande`
    GROUP BY mois
)

SELECT *
FROM satisfaction_mensuelle
ORDER BY mois

