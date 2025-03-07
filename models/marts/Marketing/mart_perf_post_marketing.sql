WITH posts AS (
    SELECT
        p.id_post,
        TRIM(p.canal_social) AS canal_social,  -- Utilisation de TRIM pour enlever les espaces avant et après
        p.sentiment_global,
        p.volume_mentions,
        p.contenu_post
    FROM {{ ref('stg_carttrend_posts') }} p
),

mentions_par_canal AS (
    -- Calcul du nombre total de mentions par canal social
    SELECT
        canal_social,
        SUM(volume_mentions) AS nombre_total_mentions
    FROM posts
    GROUP BY canal_social
),

sentiment_par_canal AS (
    -- Calcul du sentiment global le plus présent par canal social
    SELECT
        canal_social,
        sentiment_global,
        COUNT(*) AS sentiment_count
    FROM posts
    GROUP BY canal_social, sentiment_global
),

mot_frequent_par_canal AS (
    -- Extraction des mots de plus de 4 lettres et comptage de leur fréquence par canal social
    SELECT
        canal_social,
        LOWER(word) AS mot,
        COUNT(*) AS nrb_mot
    FROM posts,
        UNNEST(REGEXP_EXTRACT_ALL(LOWER(contenu_post), r'\b\w{5,}\b')) AS word  -- Changement ici : \b\w{5,}\b pour les mots de + de 4 caractères
    GROUP BY canal_social, word
),

sentiment_max_par_canal AS (
    -- Trouver le sentiment global le plus présent par canal social
    SELECT
        canal_social,
        sentiment_global
    FROM sentiment_par_canal sp
    WHERE (sp.sentiment_count) = (
        SELECT MAX(sentiment_count)
        FROM sentiment_par_canal
        WHERE canal_social = sp.canal_social
    )
),

mot_max_par_canal AS (
    -- Trouver le mot le plus fréquent par canal social
    SELECT
        canal_social,
        mot
    FROM mot_frequent_par_canal mf
    WHERE (mf.nrb_mot) = (
        SELECT MAX(nrb_mot)
        FROM mot_frequent_par_canal
        WHERE canal_social = mf.canal_social
    )
    -- Si plusieurs mots ont la même fréquence, on prend celui qui est le plus long
    QUALIFY ROW_NUMBER() OVER (PARTITION BY canal_social ORDER BY nrb_mot DESC, LENGTH(mot) DESC) = 1
),

moyenne_mots_par_canal AS (
    -- Calcul du nombre moyen de mots dans le contenu_post par canal social
    SELECT
        canal_social,
        ROUND(AVG(LENGTH(TRIM(contenu_post)) - LENGTH(REPLACE(contenu_post, ' ', '')) + 1)) AS nombre_mots_moyen  -- Arrondi du nombre moyen de mots
    FROM posts
    GROUP BY canal_social
)

-- Combine les résultats obtenus
SELECT 
    mpc.canal_social,
    mpc.nombre_total_mentions,
    smpc.sentiment_global AS sentiment_le_plus_present,
    mf.mot AS mot_frequent,
    avg_mots.nombre_mots_moyen
FROM mentions_par_canal mpc
-- Jointure avec le sentiment le plus présent par canal social
LEFT JOIN sentiment_max_par_canal smpc 
    ON mpc.canal_social = smpc.canal_social
-- Jointure avec le mot le plus fréquent par canal social
LEFT JOIN mot_max_par_canal mf
    ON mpc.canal_social = mf.canal_social
-- Jointure pour le nombre moyen de mots dans le contenu_post
LEFT JOIN moyenne_mots_par_canal avg_mots
    ON mpc.canal_social = avg_mots.canal_social
ORDER BY mpc.canal_social