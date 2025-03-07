WITH commandes AS (
    SELECT 
        c.id_commande,
        c.`délai_livraison_jours`
    FROM {{ ref('stg_carttrend_commandes') }} c
),

satisfaction AS (
    SELECT 
        s.id_commande,
        s.note_client
    FROM {{ ref('stg_carttrend_satisfaction') }} s
)

-- Calcul de la note moyenne totale et la note moyenne pour les commandes ayant un délai de livraison > 7 jours
SELECT 
    ROUND(AVG(s.note_client), 2) AS note_moyenne_totale,  -- Note moyenne totale
    ROUND(AVG(CASE WHEN c.`délai_livraison_jours` > 7 THEN s.note_client END), 2) AS note_moyenne_delai_plus_7_jours  -- Note moyenne pour les commandes avec délai > 7 jours
FROM {{ ref('stg_carttrend_commandes') }} c
-- Joindre satisfaction avec les commandes pour obtenir les notes
LEFT JOIN {{ ref('stg_carttrend_satisfaction') }} s 
    ON c.id_commande = s.id_commande