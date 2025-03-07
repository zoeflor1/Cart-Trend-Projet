-- models/staging/stg_carttrend_entreprots_machines.sql

SELECT
       -- Si id_entrepot_machine est vide, on le met à la valeur concaténée
        COALESCE(NULLIF(id, ''), CONCAT(`id_entrepôt`, '-', id_machine, '-', mois)) AS id_entrepot_machine,
        
        -- Gérer les valeurs NULL pour id_entrepot et id_machine (supprimer les lignes où l'un des deux est NULL)
        id_machine,
        `id_entrepôt`,

        -- Si type_machine, etat_machine, temps_d'arrêt, volume_traité, mois sont vides, les mettre à NaN
        coalesce(nullif(type_machine, ''), 'NaN') as type_machine,
        coalesce(nullif(`état_machine`, ''), 'NaN') as etat_machine,
        
        -- Remplacer les valeurs NULL de temps_darrêt et volume_traité par 0
        coalesce(`temps_darrêt`, 0) as temps_darret,
        coalesce(`volume_traité`, 0) as volume_traite,
        
        -- Normaliser le mois en format 'YYYY-mm'
        CASE
            WHEN LENGTH(mois) >= 7 THEN -- Si la longueur de la chaîne est au moins 'YYYY-mm'
                SUBSTR(mois, 1, 7)  -- Prendre les 7 premiers caractères (format 'YYYY-mm')
            ELSE
                'NaN' -- Si le mois est mal formaté, on le remplace par 'NaN'
        END AS mois

FROM `cart-trend-projet.CartTrend.Carttrend_Entrepots_Machines`

-- Filtrer les lignes où id_entrepot ou id_machine sont NULL
WHERE `id_entrepôt` is not null
AND id_machine is not null