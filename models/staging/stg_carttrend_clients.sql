-- models/staging/stg_carttrend_clients.sql

SELECT 
    -- Filtrer les lignes où 'id_client' est NULL
    id_client,

    -- Garder le prénom, et anonymiser le nom (par exemple, le remplacer par 'Anonyme')
    prenom_client,

    'Anonyme' AS nom_client,  -- Anonymiser uniquement le nom

    -- Anonymisation du email : remplace les 3-4 derniers caractères avant @ par '****' et standardise l'email
    LOWER(CONCAT(SUBSTR(email, 1, LENGTH(email) - 4), '****', SUBSTR(email, STRPOS(email, '@')))) AS email,  

    -- Normalisation du numéro de téléphone (ajout de + indicatif pays et suppression des caractères non numériques)
    CONCAT(
        CASE 
            WHEN LEFT(REGEXP_REPLACE(`numéro_téléphone`, r'[^0-9]', ''), 1) = '0' THEN 
                CONCAT('+33 ', SUBSTR(REGEXP_REPLACE(`numéro_téléphone`, r'[^0-9]', ''), 2))
            WHEN LENGTH(REGEXP_REPLACE(`numéro_téléphone`, r'[^0-9]', '')) > 10 THEN 
                CONCAT('+', REGEXP_REPLACE(`numéro_téléphone`, r'[^0-9]', ''))
            ELSE 
                CONCAT('+33 ', REGEXP_REPLACE(`numéro_téléphone`, r'[^0-9]', ''))
        END
    ) AS `numéro_téléphone_normalisé`,

    -- Anonymisation des numéros de téléphone : masquer tout sauf les 4 derniers chiffres
    CONCAT('****', RIGHT(REGEXP_REPLACE(`numéro_téléphone`, r'[^0-9]', ''), 4)) AS `numéro_téléphone_anonymisé`, 

    -- Standardiser les valeurs pour 'genre' : Remplacer les valeurs vides ou NULL par 'Autres'
    CASE 
        WHEN genre IS NULL OR TRIM(genre) = '' THEN 'Autres'
        ELSE genre
    END AS genre,

    -- Standardiser l'âge pour éviter les valeurs aberrantes
    CASE 
        WHEN `âge` < 10 THEN 10  -- Remplacer les âges < 10 par 10
        WHEN `âge` > 150 THEN 150  -- Remplacer les âges > 150 par 150
        ELSE `âge`  -- Sinon garder la valeur originale
    END AS `âge`,

    -- Remplacer les valeurs NULL ou vides de fréquence_visites par 0
    COALESCE(`fréquence_visites`, 0) AS `fréquence_visites`,

    -- Anonymisation de l'adresse IP (en la remplaçant par un hachage)
    CAST(FARM_FINGERPRINT(adresse_ip) AS STRING) AS adresse_ip,  

    -- Standardiser la date d'inscription en format DATE
    PARSE_DATE('%Y-%m-%d', date_inscription) AS date_inscription,

    -- Garder 'favoris' tel quel
    favoris  
        
FROM `cart-trend-projet.CartTrend.Carttrend_Clients`
WHERE id_client IS NOT NULL  -- Exclure les lignes où 'id_client' est NULL
