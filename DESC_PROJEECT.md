# Application Mobile de Gestion Financière Personnelle

## 📱 Fonctionnalités Principales

### 🏠 **Tableau de Bord**
- **Vue d'ensemble financière**
  - Solde total (tous comptes confondus)
  - Revenus du mois en cours
  - Dépenses du mois en cours
  - Épargne réalisée
- **Graphiques interactifs**
  - Évolution du solde sur 6-12 mois
  - Répartition des dépenses par catégorie (camembert)
  - Comparaison revenus vs dépenses (courbes)
- **Alertes intelligentes**
  - Budget mensuel dépassé
  - Factures à venir dans les 7 jours
  - Objectifs d'épargne proches
- **Accès rapides**
  - Bouton flottant : Nouvelle transaction
  - Recherche globale de transactions

### 💰 **Gestion des Transactions**
- **Liste complète**
  - Filtrage par : Type (revenus/dépenses), Catégorie, Période, Compte
  - Recherche par libellé ou montant
  - Tri : Date, Montant, Catégorie
  - Affichage chronologique avec solde courant
- **Ajout rapide de transaction**
  - Montant avec calculatrice intégrée
  - Type : Revenu / Dépense / Transfert
  - Catégorie avec icônes (Alimentation, Transport, Logement, etc.)
  - Compte source/destination
  - Date et heure
  - Note optionnelle
  - Photo du reçu (capture/galerie)
  - Localisation automatique (optionnelle)
- **Transactions récurrentes**
  - Définir fréquence (quotidien, hebdomadaire, mensuel, annuel)
  - Notifications avant exécution
  - Gestion automatique

### 🏦 **Gestion des Comptes**
- **Multi-comptes**
  - Compte courant
  - Compte épargne
  - Espèces
  - Carte de crédit
  - Mobile Money
  - Cryptomonnaies
- **Détails par compte**
  - Solde actuel
  - Historique des transactions
  - Graphique d'évolution
  - Couleur personnalisée
- **Transferts entre comptes**
  - Interface simple de transfert
  - Historique des transferts

### 📊 **Catégories & Budgets**
- **Catégories personnalisables**
  - Catégories prédéfinies avec icônes
  - Création de nouvelles catégories
  - Sous-catégories possibles
  - Code couleur par catégorie
- **Gestion de budgets**
  - Budget mensuel par catégorie
  - Indicateur visuel de consommation (jauge)
  - Alertes de dépassement
  - Suggestions d'optimisation

### 🎯 **Objectifs d'Épargne**
- **Création d'objectifs**
  - Nom de l'objectif (Vacances, Voiture, Urgence, etc.)
  - Montant cible
  - Date limite (optionnelle)
  - Image illustrative
- **Suivi visuel**
  - Barre de progression
  - Montant restant
  - Estimation de date d'atteinte
- **Contributions**
  - Ajout manuel de fonds
  - Versement automatique mensuel

### 📈 **Rapports & Analyses**
- **Rapports prédéfinis**
  - Bilan mensuel (revenus - dépenses)
  - Répartition des dépenses
  - Évolution du patrimoine net
  - Top dépenses
  - Analyse par catégorie
- **Périodes personnalisables**
  - Jour, Semaine, Mois, Année
  - Période personnalisée
  - Comparaison entre périodes
- **Exports**
  - Export PDF des rapports
  - Export CSV/Excel des transactions
  - Partage par email/messagerie

### 🔔 **Factures & Rappels**
- **Gestion des factures récurrentes**
  - Loyer, Électricité, Internet, Abonnements, etc.
  - Montant et fréquence
  - Date de paiement
- **Notifications**
  - Rappel X jours avant échéance
  - Confirmation de paiement manuel
  - Historique des paiements

### 🔐 **Sécurité & Paramètres**
- **Protection des données**
  - Code PIN / Empreinte digitale / Face ID
  - Chiffrement de la base de données SQLite
  - Verrouillage automatique
- **Sauvegarde & Restauration**
  - Backup automatique local
  - Export manuel de la base
  - Import de sauvegarde
  - Synchronisation cloud (optionnelle)
- **Paramètres généraux**
  - Devise principale
  - Format de date
  - Langue
  - Thème (Clair/Sombre)
  - Notifications activées/désactivées

### 📸 **Fonctionnalités Avancées**
- **Scan de reçus**
  - OCR pour extraction automatique du montant
  - Association à une transaction
- **Calculatrice intégrée**
  - Calculs rapides lors de la saisie
- **Mode hors-ligne complet**
  - Toutes les données en local (SQLite)
  - Aucune connexion requise
- **Statistiques intelligentes**
  - Dépense moyenne par catégorie
  - Jour de la semaine le plus dépensier
  - Prédiction de fin de mois
- **Export multi-formats**
  - PDF pour rapports
  - CSV pour analyse Excel
  - JSON pour backup

---

## 🗄️ Architecture de Base de Données SQLite

### **Tables Principales**

```sql
-- Table: utilisateurs (pour sécurité et multi-utilisateurs futur)
CREATE TABLE utilisateurs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    email TEXT UNIQUE,
    code_pin TEXT,
    biometrie_activee INTEGER DEFAULT 0,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_derniere_connexion DATETIME,
    theme TEXT DEFAULT 'light', -- light/dark
    devise TEXT DEFAULT 'XOF',
    langue TEXT DEFAULT 'fr'
);

-- Table: comptes
CREATE TABLE comptes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL,
    nom TEXT NOT NULL,
    type TEXT NOT NULL, -- courant, epargne, especes, carte_credit, mobile_money, crypto
    solde_initial REAL DEFAULT 0,
    solde_actuel REAL DEFAULT 0,
    devise TEXT DEFAULT 'XOF',
    couleur TEXT DEFAULT '#2196F3',
    icone TEXT DEFAULT 'account_balance',
    inclure_dans_total INTEGER DEFAULT 1,
    actif INTEGER DEFAULT 1,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
);

-- Table: categories
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER,
    nom TEXT NOT NULL,
    type TEXT NOT NULL, -- revenu, depense
    icone TEXT DEFAULT 'category',
    couleur TEXT DEFAULT '#9E9E9E',
    parent_id INTEGER, -- pour sous-catégories
    ordre INTEGER DEFAULT 0,
    par_defaut INTEGER DEFAULT 0, -- catégories système
    actif INTEGER DEFAULT 1,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Table: transactions
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL,
    compte_id INTEGER NOT NULL,
    categorie_id INTEGER NOT NULL,
    type TEXT NOT NULL, -- revenu, depense, transfert
    montant REAL NOT NULL,
    libelle TEXT NOT NULL,
    description TEXT,
    date_transaction DATETIME NOT NULL,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME,
    localisation TEXT,
    photo_recu TEXT, -- chemin vers l'image
    recurrente INTEGER DEFAULT 0,
    recurrence_id INTEGER, -- lien vers transaction_recurrentes
    compte_destination_id INTEGER, -- pour les transferts
    validee INTEGER DEFAULT 1,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (compte_id) REFERENCES comptes(id) ON DELETE CASCADE,
    FOREIGN KEY (categorie_id) REFERENCES categories(id) ON DELETE RESTRICT,
    FOREIGN KEY (compte_destination_id) REFERENCES comptes(id) ON DELETE SET NULL,
    FOREIGN KEY (recurrence_id) REFERENCES transactions_recurrentes(id) ON DELETE SET NULL
);

-- Table: transactions_recurrentes
CREATE TABLE transactions_recurrentes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL,
    compte_id INTEGER NOT NULL,
    categorie_id INTEGER NOT NULL,
    type TEXT NOT NULL,
    montant REAL NOT NULL,
    libelle TEXT NOT NULL,
    description TEXT,
    frequence TEXT NOT NULL, -- quotidien, hebdomadaire, mensuel, annuel
    jour_execution INTEGER, -- jour du mois (1-31) ou jour de la semaine (1-7)
    date_debut DATE NOT NULL,
    date_fin DATE,
    prochaine_execution DATE NOT NULL,
    actif INTEGER DEFAULT 1,
    notification_jours_avant INTEGER DEFAULT 1,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (compte_id) REFERENCES comptes(id) ON DELETE CASCADE,
    FOREIGN KEY (categorie_id) REFERENCES categories(id) ON DELETE RESTRICT
);

-- Table: budgets
CREATE TABLE budgets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL,
    categorie_id INTEGER NOT NULL,
    montant_budget REAL NOT NULL,
    periode TEXT NOT NULL, -- mensuel, annuel
    mois INTEGER, -- 1-12 si mensuel
    annee INTEGER NOT NULL,
    alerte_pourcentage INTEGER DEFAULT 80, -- alerter à 80% du budget
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (categorie_id) REFERENCES categories(id) ON DELETE CASCADE,
    UNIQUE(utilisateur_id, categorie_id, mois, annee)
);

-- Table: objectifs_epargne
CREATE TABLE objectifs_epargne (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL,
    nom TEXT NOT NULL,
    montant_cible REAL NOT NULL,
    montant_actuel REAL DEFAULT 0,
    date_debut DATE NOT NULL,
    date_cible DATE,
    image TEXT, -- chemin vers image illustrative
    couleur TEXT DEFAULT '#4CAF50',
    contribution_mensuelle_auto REAL DEFAULT 0,
    statut TEXT DEFAULT 'en_cours', -- en_cours, atteint, abandonne
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_completion DATETIME,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
);

-- Table: contributions_objectifs
CREATE TABLE contributions_objectifs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    objectif_id INTEGER NOT NULL,
    montant REAL NOT NULL,
    date_contribution DATE NOT NULL,
    note TEXT,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (objectif_id) REFERENCES objectifs_epargne(id) ON DELETE CASCADE
);

-- Table: factures_recurrentes
CREATE TABLE factures_recurrentes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL,
    nom TEXT NOT NULL, -- Loyer, Electricité, Internet, etc.
    montant REAL NOT NULL,
    categorie_id INTEGER NOT NULL,
    compte_id INTEGER NOT NULL,
    frequence TEXT NOT NULL, -- mensuel, trimestriel, annuel
    jour_paiement INTEGER NOT NULL, -- jour du mois
    prochaine_echeance DATE NOT NULL,
    notification_jours_avant INTEGER DEFAULT 3,
    auto_creer_transaction INTEGER DEFAULT 0,
    actif INTEGER DEFAULT 1,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (categorie_id) REFERENCES categories(id) ON DELETE RESTRICT,
    FOREIGN KEY (compte_id) REFERENCES comptes(id) ON DELETE CASCADE
);

-- Table: paiements_factures
CREATE TABLE paiements_factures (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    facture_id INTEGER NOT NULL,
    transaction_id INTEGER,
    montant_paye REAL NOT NULL,
    date_paiement DATE NOT NULL,
    statut TEXT DEFAULT 'paye', -- paye, en_retard, annule
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (facture_id) REFERENCES factures_recurrentes(id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE SET NULL
);

-- Table: transferts (historique des transferts entre comptes)
CREATE TABLE transferts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL,
    compte_source_id INTEGER NOT NULL,
    compte_destination_id INTEGER NOT NULL,
    montant REAL NOT NULL,
    frais REAL DEFAULT 0,
    libelle TEXT,
    date_transfert DATETIME NOT NULL,
    transaction_source_id INTEGER, -- lien vers transaction de débit
    transaction_destination_id INTEGER, -- lien vers transaction de crédit
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (compte_source_id) REFERENCES comptes(id) ON DELETE CASCADE,
    FOREIGN KEY (compte_destination_id) REFERENCES comptes(id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_source_id) REFERENCES transactions(id) ON DELETE SET NULL,
    FOREIGN KEY (transaction_destination_id) REFERENCES transactions(id) ON DELETE SET NULL
);

-- Table: sauvegardes
CREATE TABLE sauvegardes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL,
    nom_fichier TEXT NOT NULL,
    chemin TEXT NOT NULL,
    taille INTEGER, -- taille en octets
    type TEXT DEFAULT 'manuel', -- manuel, automatique
    date_sauvegarde DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
);

-- Table: notifications
CREATE TABLE notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL,
    type TEXT NOT NULL, -- budget_depasse, facture_echeance, objectif_atteint
    titre TEXT NOT NULL,
    message TEXT NOT NULL,
    lue INTEGER DEFAULT 0,
    action_lien TEXT, -- lien vers l'écran concerné
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
);

-- Table: tags (étiquettes personnalisées pour transactions)
CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL,
    nom TEXT NOT NULL,
    couleur TEXT DEFAULT '#607D8B',
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    UNIQUE(utilisateur_id, nom)
);

-- Table: transaction_tags (relation many-to-many)
CREATE TABLE transaction_tags (
    transaction_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (transaction_id, tag_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Table: parametres_app
CREATE TABLE parametres_app (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL,
    cle TEXT NOT NULL,
    valeur TEXT,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    UNIQUE(utilisateur_id, cle)
);
```

### **Index pour optimisation des performances**

```sql
-- Index pour améliorer les performances des requêtes fréquentes

CREATE INDEX idx_transactions_date ON transactions(date_transaction);
CREATE INDEX idx_transactions_compte ON transactions(compte_id);
CREATE INDEX idx_transactions_categorie ON transactions(categorie_id);
CREATE INDEX idx_transactions_utilisateur ON transactions(utilisateur_id);
CREATE INDEX idx_transactions_type ON transactions(type);

CREATE INDEX idx_comptes_utilisateur ON comptes(utilisateur_id);
CREATE INDEX idx_comptes_actif ON comptes(actif);

CREATE INDEX idx_categories_utilisateur ON categories(utilisateur_id);
CREATE INDEX idx_categories_type ON categories(type);

CREATE INDEX idx_budgets_periode ON budgets(mois, annee);
CREATE INDEX idx_budgets_categorie ON budgets(categorie_id);

CREATE INDEX idx_objectifs_statut ON objectifs_epargne(statut);
CREATE INDEX idx_factures_prochaine_echeance ON factures_recurrentes(prochaine_echeance);

CREATE INDEX idx_notifications_lue ON notifications(lue);
CREATE INDEX idx_notifications_utilisateur ON notifications(utilisateur_id);
```

### **Vues SQL pour requêtes complexes**

```sql
-- Vue: Solde par compte avec nombre de transactions
CREATE VIEW vue_soldes_comptes AS
SELECT 
    c.id,
    c.nom,
    c.type,
    c.solde_actuel,
    c.devise,
    c.couleur,
    COUNT(t.id) as nb_transactions,
    MAX(t.date_transaction) as derniere_transaction
FROM comptes c
LEFT JOIN transactions t ON c.id = t.compte_id
WHERE c.actif = 1
GROUP BY c.id;

-- Vue: Budget vs Dépenses réelles par catégorie
CREATE VIEW vue_budgets_vs_depenses AS
SELECT 
    b.id,
    b.categorie_id,
    cat.nom as categorie_nom,
    cat.icone,
    cat.couleur,
    b.montant_budget,
    b.mois,
    b.annee,
    COALESCE(SUM(t.montant), 0) as montant_depense,
    b.montant_budget - COALESCE(SUM(t.montant), 0) as reste,
    ROUND((COALESCE(SUM(t.montant), 0) * 100.0 / b.montant_budget), 2) as pourcentage_utilise
FROM budgets b
JOIN categories cat ON b.categorie_id = cat.id
LEFT JOIN transactions t ON 
    t.categorie_id = b.categorie_id 
    AND t.type = 'depense'
    AND strftime('%m', t.date_transaction) = printf('%02d', b.mois)
    AND strftime('%Y', t.date_transaction) = CAST(b.annee AS TEXT)
GROUP BY b.id;

-- Vue: Progression des objectifs d'épargne
CREATE VIEW vue_progression_objectifs AS
SELECT 
    o.id,
    o.nom,
    o.montant_cible,
    o.montant_actuel,
    o.date_cible,
    o.statut,
    o.couleur,
    ROUND((o.montant_actuel * 100.0 / o.montant_cible), 2) as pourcentage_atteint,
    o.montant_cible - o.montant_actuel as reste_a_epargner,
    julianday(o.date_cible) - julianday('now') as jours_restants
FROM objectifs_epargne o
WHERE o.statut = 'en_cours';

-- Vue: Transactions récentes avec détails
CREATE VIEW vue_transactions_recentes AS
SELECT 
    t.id,
    t.type,
    t.montant,
    t.libelle,
    t.description,
    t.date_transaction,
    c.nom as compte_nom,
    c.couleur as compte_couleur,
    cat.nom as categorie_nom,
    cat.icone as categorie_icone,
    cat.couleur as categorie_couleur,
    t.photo_recu
FROM transactions t
JOIN comptes c ON t.compte_id = c.id
JOIN categories cat ON t.categorie_id = cat.id
ORDER BY t.date_transaction DESC;
```

---

## 🎨 Interface Utilisateur

### Navigation
- **Bottom Navigation Bar** (5 onglets max)
  - Accueil (Dashboard)
  - Transactions
  - Budgets
  - Rapports
  - Paramètres
- **Swipe gestures**
  - Swipe pour supprimer transaction
  - Pull to refresh
- **Design Material 3**
  - Animations fluides
  - Mode sombre/clair
  - Couleurs personnalisables

### Écrans principaux
1. **Dashboard** - Vue synthétique
2. **Transactions** - Liste détaillée
3. **Budgets** - Suivi par catégorie
4. **Rapports** - Analyses graphiques
5. **Paramètres** - Configuration

## 💾 Architecture Technique

- **Framework** : Flutter
- **Base de données** : SQLite (stockage local)
- **État** : Provider ou Riverpod
- **Charts** : fl_chart
- **PDF** : pdf package
- **OCR** : google_ml_kit (optionnel)
- **Sécurité** : sqflite_encryption

Cette app serait 100% offline, rapide, sécurisée et adaptée aux besoins personnels de gestion financière quotidienne.