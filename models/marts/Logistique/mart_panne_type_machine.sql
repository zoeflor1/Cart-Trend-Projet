SELECT
    type_machine,
    EXTRACT(YEAR FROM mois) AS annee,
    COUNT(*) AS nombre_pannes,
    COUNT(DISTINCT id_machine) AS nombre_total_machines,
    ROUND(COUNT(*) / COUNT(DISTINCT id_machine), 2) AS taux_pannes_par_machine
FROM {{ ref('stg_cartrend_entrepots_machines') }}
WHERE etat_machine = 'En panne'
GROUP BY annee, type_machine