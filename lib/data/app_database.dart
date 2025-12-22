import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static const _dbName = 'piggy.db';
  static const _dbVersion = 2;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _dbName);
    return openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchema(db);
        await _seedDefaults(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _runMigrations(db, oldVersion, newVersion);
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE utilisateurs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        email TEXT UNIQUE,
        code_pin TEXT,
        biometrie_activee INTEGER DEFAULT 0,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        date_derniere_connexion DATETIME,
        theme TEXT DEFAULT 'light',
        devise TEXT DEFAULT 'XOF',
        langue TEXT DEFAULT 'fr'
      )
    ''');

    await db.execute('''
      CREATE TABLE comptes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        nom TEXT NOT NULL,
        type TEXT NOT NULL,
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
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER,
        nom TEXT NOT NULL,
        type TEXT NOT NULL,
        icone TEXT DEFAULT 'category',
        couleur TEXT DEFAULT '#9E9E9E',
        parent_id INTEGER,
        ordre INTEGER DEFAULT 0,
        par_defaut INTEGER DEFAULT 0,
        archived INTEGER DEFAULT 0,
        actif INTEGER DEFAULT 1,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
        FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        compte_id INTEGER NOT NULL,
        categorie_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        montant REAL NOT NULL,
        libelle TEXT NOT NULL,
        description TEXT,
        date_transaction DATETIME NOT NULL,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        date_modification DATETIME,
        localisation TEXT,
        photo_recu TEXT,
        recurrente INTEGER DEFAULT 0,
        recurrence_id INTEGER,
        compte_destination_id INTEGER,
        validee INTEGER DEFAULT 1,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
        FOREIGN KEY (compte_id) REFERENCES comptes(id) ON DELETE CASCADE,
        FOREIGN KEY (categorie_id) REFERENCES categories(id) ON DELETE RESTRICT,
        FOREIGN KEY (compte_destination_id) REFERENCES comptes(id) ON DELETE SET NULL,
        FOREIGN KEY (recurrence_id) REFERENCES transactions_recurrentes(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions_recurrentes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        compte_id INTEGER NOT NULL,
        categorie_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        montant REAL NOT NULL,
        libelle TEXT NOT NULL,
        description TEXT,
        frequence TEXT NOT NULL,
        jour_execution INTEGER,
        date_debut DATE NOT NULL,
        date_fin DATE,
        prochaine_execution DATE NOT NULL,
        actif INTEGER DEFAULT 1,
        notification_jours_avant INTEGER DEFAULT 1,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
        FOREIGN KEY (compte_id) REFERENCES comptes(id) ON DELETE CASCADE,
        FOREIGN KEY (categorie_id) REFERENCES categories(id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        categorie_id INTEGER NOT NULL,
        montant_budget REAL NOT NULL,
        periode TEXT NOT NULL,
        mois INTEGER,
        annee INTEGER NOT NULL,
        alerte_pourcentage INTEGER DEFAULT 80,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        date_modification DATETIME,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
        FOREIGN KEY (categorie_id) REFERENCES categories(id) ON DELETE CASCADE,
        UNIQUE(utilisateur_id, categorie_id, mois, annee)
      )
    ''');

    await db.execute('''
      CREATE TABLE objectifs_epargne (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        nom TEXT NOT NULL,
        montant_cible REAL NOT NULL,
        montant_actuel REAL DEFAULT 0,
        date_debut DATE NOT NULL,
        date_cible DATE,
        image TEXT,
        couleur TEXT DEFAULT '#4CAF50',
        contribution_mensuelle_auto REAL DEFAULT 0,
        statut TEXT DEFAULT 'en_cours',
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        date_completion DATETIME,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE contributions_objectifs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        objectif_id INTEGER NOT NULL,
        montant REAL NOT NULL,
        date_contribution DATE NOT NULL,
        note TEXT,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (objectif_id) REFERENCES objectifs_epargne(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE factures_recurrentes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        nom TEXT NOT NULL,
        montant REAL NOT NULL,
        categorie_id INTEGER NOT NULL,
        compte_id INTEGER NOT NULL,
        frequence TEXT NOT NULL,
        jour_paiement INTEGER NOT NULL,
        prochaine_echeance DATE NOT NULL,
        notification_jours_avant INTEGER DEFAULT 3,
        auto_creer_transaction INTEGER DEFAULT 0,
        actif INTEGER DEFAULT 1,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
        FOREIGN KEY (categorie_id) REFERENCES categories(id) ON DELETE RESTRICT,
        FOREIGN KEY (compte_id) REFERENCES comptes(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE paiements_factures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        facture_id INTEGER NOT NULL,
        transaction_id INTEGER,
        montant_paye REAL NOT NULL,
        date_paiement DATE NOT NULL,
        statut TEXT DEFAULT 'paye',
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (facture_id) REFERENCES factures_recurrentes(id) ON DELETE CASCADE,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transferts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        compte_source_id INTEGER NOT NULL,
        compte_destination_id INTEGER NOT NULL,
        montant REAL NOT NULL,
        frais REAL DEFAULT 0,
        libelle TEXT,
        date_transfert DATETIME NOT NULL,
        transaction_source_id INTEGER,
        transaction_destination_id INTEGER,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
        FOREIGN KEY (compte_source_id) REFERENCES comptes(id) ON DELETE CASCADE,
        FOREIGN KEY (compte_destination_id) REFERENCES comptes(id) ON DELETE CASCADE,
        FOREIGN KEY (transaction_source_id) REFERENCES transactions(id) ON DELETE SET NULL,
        FOREIGN KEY (transaction_destination_id) REFERENCES transactions(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sauvegardes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        nom_fichier TEXT NOT NULL,
        chemin TEXT NOT NULL,
        taille INTEGER,
        type TEXT DEFAULT 'manuel',
        date_sauvegarde DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        titre TEXT NOT NULL,
        message TEXT NOT NULL,
        lue INTEGER DEFAULT 0,
        action_lien TEXT,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        nom TEXT NOT NULL,
        couleur TEXT DEFAULT '#607D8B',
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
        UNIQUE(utilisateur_id, nom)
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_tags (
        transaction_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (transaction_id, tag_id),
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE parametres_app (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateur_id INTEGER NOT NULL,
        cle TEXT NOT NULL,
        valeur TEXT,
        date_modification DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
        UNIQUE(utilisateur_id, cle)
      )
    ''');

    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date_transaction)');
    await db.execute('CREATE INDEX idx_transactions_compte ON transactions(compte_id)');
    await db.execute('CREATE INDEX idx_transactions_categorie ON transactions(categorie_id)');
    await db.execute('CREATE INDEX idx_transactions_utilisateur ON transactions(utilisateur_id)');
    await db.execute('CREATE INDEX idx_transactions_type ON transactions(type)');
    await db.execute('CREATE INDEX idx_comptes_utilisateur ON comptes(utilisateur_id)');
    await db.execute('CREATE INDEX idx_comptes_actif ON comptes(actif)');
    await db.execute('CREATE INDEX idx_categories_utilisateur ON categories(utilisateur_id)');
    await db.execute('CREATE INDEX idx_categories_type ON categories(type)');
    await db.execute('CREATE INDEX idx_budgets_periode ON budgets(mois, annee)');
    await db.execute('CREATE INDEX idx_budgets_categorie ON budgets(categorie_id)');
    await db.execute('CREATE INDEX idx_objectifs_statut ON objectifs_epargne(statut)');
    await db.execute('CREATE INDEX idx_factures_prochaine_echeance ON factures_recurrentes(prochaine_echeance)');
    await db.execute('CREATE INDEX idx_notifications_lue ON notifications(lue)');
    await db.execute('CREATE INDEX idx_notifications_utilisateur ON notifications(utilisateur_id)');

    await db.execute('''
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
      GROUP BY c.id
    ''');

    await db.execute('''
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
      GROUP BY b.id
    ''');

    await db.execute('''
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
      WHERE o.statut = 'en_cours'
    ''');

    await db.execute('''
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
      ORDER BY t.date_transaction DESC
    ''');
  }

  Future<void> _runMigrations(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE categories ADD COLUMN archived INTEGER DEFAULT 0');
    }
  }

  Future<void> _seedDefaults(Database db) async {
    final userId = await db.insert('utilisateurs', {
      'nom': 'Utilisateur',
      'email': null,
      'theme': 'light',
      'devise': 'XOF',
      'langue': 'fr',
    });

    final now = DateTime.now().toIso8601String();

    final categories = [
      {'utilisateur_id': userId, 'nom': 'Alimentation', 'type': 'expense', 'icone': 'restaurant', 'couleur': '#F97316'},
      {'utilisateur_id': userId, 'nom': 'Transport', 'type': 'expense', 'icone': 'directions_car', 'couleur': '#6366F1'},
      {'utilisateur_id': userId, 'nom': 'Logement', 'type': 'expense', 'icone': 'home', 'couleur': '#0EA5E9'},
      {'utilisateur_id': userId, 'nom': 'Restaurant', 'type': 'expense', 'icone': 'local_dining', 'couleur': '#EF4444'},
      {'utilisateur_id': userId, 'nom': 'Sante', 'type': 'expense', 'icone': 'health_and_safety', 'couleur': '#14B8A6'},
      {'utilisateur_id': userId, 'nom': 'Salaire', 'type': 'income', 'icone': 'attach_money', 'couleur': '#10B981'},
      {'utilisateur_id': userId, 'nom': 'Freelance', 'type': 'income', 'icone': 'work', 'couleur': '#06B6D4'},
    ];

    for (final category in categories) {
      await db.insert('categories', category);
    }

    final accounts = [
      {
        'utilisateur_id': userId,
        'nom': 'Compte Courant',
        'type': 'checking',
        'solde_initial': 0,
        'solde_actuel': 0,
        'couleur': '#3B82F6',
        'date_creation': now,
      },
      {
        'utilisateur_id': userId,
        'nom': 'Epargne',
        'type': 'savings',
        'solde_initial': 0,
        'solde_actuel': 0,
        'couleur': '#10B981',
        'date_creation': now,
      },
      {
        'utilisateur_id': userId,
        'nom': 'Especes',
        'type': 'cash',
        'solde_initial': 0,
        'solde_actuel': 0,
        'couleur': '#F59E0B',
        'date_creation': now,
      },
    ];

    for (final account in accounts) {
      await db.insert('comptes', account);
    }
  }
}
