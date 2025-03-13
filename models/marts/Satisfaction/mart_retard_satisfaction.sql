WITH commandes AS (
    SELECT 
        c.id_commande,
        c.`délai_livraison_jours`,
        DATE_TRUNC(c.`date_commande`, MONTH) AS `mois_date`  -- Ajout de la date tronquée au mois
    FROM {{ ref('stg_carttrend_commandes') }} c
),

satisfaction AS (
    SELECT 
        s.id_commande,
        s.note_client
    FROM {{ ref('stg_carttrend_satisfaction') }} s
)

-- Calcul des notes moyennes
SELECT 
    c.`mois_date`,  -- Ajout de la colonne mois_date
    ROUND(AVG(s.note_client), 3) AS note_moyenne_totale,  
    ROUND(AVG(CASE WHEN c.`délai_livraison_jours` > 7 THEN s.note_client END), 3) AS note_moyenne_delai_plus_7_jours,  
    ROUND(AVG(CASE WHEN c.`délai_livraison_jours` > 14 THEN s.note_client END), 3) AS note_moyenne_delai_plus_14_jours,  
    ROUND(AVG(CASE WHEN c.`délai_livraison_jours` > 21 THEN s.note_client END), 3) AS note_moyenne_delai_plus_21_jours,  
    ROUND(AVG(CASE WHEN c.`délai_livraison_jours` > 28 THEN s.note_client END), 3) AS note_moyenne_delai_plus_28_jours
FROM commandes c
LEFT JOIN satisfaction s 
    ON c.id_commande = s.id_commande
GROUP BY c.`mois_date`  
ORDER BY c.`mois_date`
