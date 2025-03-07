-- models/logistique_mart.sql

WITH volume_par_entrepot AS (
    -- Calcul du volume traité par entrepôt
    SELECT
        e.`id_entrepôt`,
        SUM(m.volume_traite) AS volume_traite
    FROM 
        {{ ref('stg_cartrend_entrepots_machines') }} m
    JOIN 
        {{ ref('stg_cartrend_entrepots') }} e
        ON m.`id_entrepôt` = e.`id_entrepôt`
    GROUP BY
        e.`id_entrepôt`
),

temps_arret_par_entrepot AS (
    -- Calcul du temps d'arrêt par entrepôt
    SELECT
        e.`id_entrepôt`,
        SUM(m.temps_darret) AS temps_arret_total
    FROM
        {{ ref('stg_cartrend_entrepots_machines') }} m
    JOIN
        {{ ref('stg_cartrend_entrepots') }} e
        ON m.`id_entrepôt` = e.`id_entrepôt`
    GROUP BY
        e.`id_entrepôt`
),

pannes_par_entrepot AS (
    -- Calcul du nombre de pannes par entrepôt
    SELECT
        m.`id_entrepôt`,
        COUNT(*) AS nombre_pannes
    FROM
        {{ ref('stg_cartrend_entrepots_machines') }} m
    WHERE
        m.etat_machine = 'En panne'
    GROUP BY
        m.`id_entrepôt`
),

stockage_et_volume_par_entrepot AS (
    -- Informations sur le stockage et volume traité par entrepôt
    SELECT
        e.`id_entrepôt`,
        e.capacite_max,
        SUM(m.volume_traite) AS volume_traite,  -- volume_traite pris de stg_cartrend_entreprots_machines
        e.taux_remplissage,
        e.volume_stocke AS stockage_effectif  -- Correction : stockage_effectif = volume_stocke
    FROM
        {{ ref('stg_cartrend_entrepots') }} e
    LEFT JOIN 
        {{ ref('stg_cartrend_entrepots_machines') }} m
        ON e.`id_entrepôt` = m.`id_entrepôt`
    GROUP BY
        e.`id_entrepôt`, e.capacite_max, e.taux_remplissage, e.volume_stocke
),

commandes_par_entrepot AS (
    -- Calcul du nombre de commandes par entrepôt
    SELECT
        c.`id_entrepôt_départ` AS `id_entrepôt`,
        COUNT(c.id_commande) AS nombre_commandes
    FROM
        {{ ref('stg_carttrend_commandes') }} c
    GROUP BY
        c.`id_entrepôt_départ`
)

-- Final result: Consolidation de toutes les métriques
SELECT
    v.`id_entrepôt`,
    v.volume_traite,
    t.temps_arret_total,
    COALESCE(p.nombre_pannes, 0) AS nombre_pannes,  -- Gestion des entrepôts sans panne
    s.stockage_effectif,  -- Correction : stockage_effectif = volume_stocke
    s.capacite_max AS stockage_max,
    c.nombre_commandes
FROM
    volume_par_entrepot v
JOIN
    temps_arret_par_entrepot t ON v.`id_entrepôt` = t.`id_entrepôt`
LEFT JOIN
    pannes_par_entrepot p ON v.`id_entrepôt` = p.`id_entrepôt`
JOIN
    stockage_et_volume_par_entrepot s ON v.`id_entrepôt` = s.`id_entrepôt`
JOIN
    commandes_par_entrepot c ON v.`id_entrepôt` = c.`id_entrepôt`