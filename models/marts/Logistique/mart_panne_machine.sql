WITH panne_par_machine AS (
    SELECT
        id_machine,
        EXTRACT(YEAR FROM mois) AS annee,  -- Extraction de l'année directement depuis la colonne DATE
        COUNT(*) AS nombre_de_pannes
    FROM {{ ref('stg_cartrend_entrepots_machines') }} 
    WHERE etat_machine = 'En panne'
    GROUP BY
        id_machine,
        EXTRACT(YEAR FROM mois)  -- Extraction de l'année directement depuis la colonne DATE
)

SELECT
    id_machine,
    annee,
    nombre_de_pannes
FROM panne_par_machine
ORDER BY id_machine, annee