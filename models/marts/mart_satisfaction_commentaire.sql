
WITH satisfaction AS (
    SELECT 
        `id_satisfaction`,
        `id_commande`,
        `note_client`,
        LOWER(`commentaire`) AS commentaire  -- Mise en minuscule pour uniformiser
    FROM `CartTrend.stg_carttrend_satisfaction`
    WHERE `commentaire` IS NOT NULL  
),

classification AS (
    SELECT 
        id_satisfaction,
        id_commande,
        note_client,
        commentaire,
        CASE 
            WHEN note_client >= 4 THEN 'positif'
            WHEN note_client < 3 THEN 'négatif'
            ELSE 'neutre'
        END AS sentiment
    FROM satisfaction
),

split_words AS (
    -- Tokenisation et nettoyage des mots
    SELECT 
        sentiment,
        TRIM(REGEXP_REPLACE(word, r'[^a-zA-Z0-9]', '')) AS word  -- Supprime la ponctuation
    FROM classification, 
    UNNEST(SPLIT(commentaire, ' ')) AS word
    WHERE LENGTH(word) > 2  -- Exclure les mots trop courts
),

word_count AS (
    -- Comptage des mots les plus fréquents par type de sentiment
    SELECT 
        sentiment,
        word,
        COUNT(*) AS occurrences
    FROM split_words
    WHERE word NOT IN ('the', 'and', 'was', 'for', 'with', 'too', 'this', 'that', 'are', 'but', 'you', 'not', 'can', 'had', 'has', 'have', 'on', 'at', 'by', 'is', 'it')  
    GROUP BY sentiment, word
    ORDER BY sentiment, occurrences DESC
)

SELECT *
FROM word_count
ORDER BY sentiment, occurrences DESC

