WITH produit_performance AS (
    SELECT
        p.Produit AS produit,
        p.Catégorie AS catégorie,
        SUM(dc.quantité * p.Prix) AS revenus_produit,  -- Total des revenus par produit
        SUM(dc.quantité) AS volume_ventes_produit,    -- Quantité totale vendue par produit
        SUM(dc.quantité * (p.Prix - p.Cout)) AS marge_produit,  -- Marge brute par produit (prix - coût)
        SUM(CASE WHEN c.id_promotion_appliquée IS NOT NULL THEN dc.quantité ELSE 0 END) AS produits_en_promotion_quantité, -- Quantité des produits en promotion
        SUM(CASE WHEN c.id_promotion_appliquée IS NOT NULL THEN dc.quantité * p.Prix ELSE 0 END) AS produits_en_promotion_revenus, -- Revenus générés par les produits en promotion
        SUM(CASE WHEN dc.emballage_spécial IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS taux_ajout_panier, -- Taux d'ajout au panier
        SUM(CASE WHEN dc.id_commande IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS taux_conversion -- Taux de conversion
    FROM 
        Carttrend_Produit p
    JOIN Carttrend_Detail_Commandes dc ON p.ID = dc.id_produit
    JOIN Carttrend_Commandes c ON dc.id_commande = c.id_commande
    WHERE c.statut_commande = 'Terminée'
    GROUP BY
        p.Produit, p.Catégorie
),

categorie_performance AS (
    SELECT
        p.Catégorie AS catégorie,
        SUM(dc.quantité * p.Prix) AS revenus_categorie,  -- Total des revenus par catégorie
        SUM(dc.quantité) AS volume_ventes_categorie,    -- Quantité totale vendue par catégorie
        SUM(dc.quantité * (p.Prix - p.Cout)) AS marge_categorie,  -- Marge brute par catégorie
        COUNT(DISTINCT dc.id_commande) AS commandes_categorie
    FROM
        Carttrend_Produit p
    JOIN Carttrend_Detail_Commandes dc ON p.ID = dc.id_produit
    JOIN Carttrend_Commandes c ON dc.id_commande = c.id_commande
    WHERE c.statut_commande = 'Terminée'
    GROUP BY
        p.Catégorie
),

demographic_performance AS (
    SELECT
        CASE 
            WHEN client.âge BETWEEN 18 AND 24 THEN '18-24'
            WHEN client.âge BETWEEN 25 AND 34 THEN '25-34'
            WHEN client.âge BETWEEN 35 AND 44 THEN '35-44'
            WHEN client.âge BETWEEN 45 AND 54 THEN '45-54'
            WHEN client.âge BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65+' 
        END AS tranche_age,
        p.Produit AS produit,
        SUM(dc.quantité * p.Prix) AS revenus_par_tranche_age,  --
