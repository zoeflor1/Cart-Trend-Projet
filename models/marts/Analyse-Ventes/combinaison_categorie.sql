WITH commandes_avec_date AS (
    -- Récupération des commandes avec les produits achetés le même jour par un client
    SELECT
        c.id_client,
        c.id_commande,
        c.date_commande,
        d.id_produit,
        d.quantite
    FROM {{ ref('stg_carttrend_commandes') }} c
    JOIN {{ ref('stg_carttrend_details_commandes') }} d
        ON c.id_commande = d.id_commande
    -- Assurez-vous de considérer toutes les commandes le même jour comme une seule
),

commandes_journalieres AS (
    -- Rassembler les produits achetés le même jour par client
    SELECT
        id_client,
        DATE(date_commande) AS date_commande,
        ARRAY_AGG(id_produit ORDER BY id_produit) AS produits_achetes
    FROM commandes_avec_date
    GROUP BY id_client, DATE(date_commande)
),

combinations_produits AS (
    -- Créer les combinaisons de produits pour chaque client le même jour
    SELECT
        id_client,
        date_commande,
        -- Crée des combinaisons de produits sous forme de paires
        ARRAY(SELECT AS STRUCT p1, p2 FROM UNNEST(produits_achetes) AS p1, UNNEST(produits_achetes) AS p2 WHERE p1 < p2) AS produit_combination
    FROM commandes_journalieres
),

combinations_freq AS (
    -- Compter la fréquence des combinaisons de produits
    SELECT
        produit_combination,
        COUNT(*) AS frequency
    FROM combinations_produits
    GROUP BY produit_combination
),

combinations_top AS (
    -- Trier et obtenir les combinaisons les plus fréquentes
    SELECT
        produit_combination,
        frequency
    FROM combinations_freq
    ORDER BY frequency DESC
    LIMIT 10  -- Nombre de combinaisons les plus fréquentes que vous souhaitez récupérer
)

-- Final result: afficher les combinaisons les plus fréquentes
SELECT 
    combinaison.produit_combination,
    combinaison.frequency
FROM combinations_top combinaison