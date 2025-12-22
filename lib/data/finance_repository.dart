import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/finance_models.dart';
import 'app_database.dart';

class FinanceSnapshot {
  FinanceSnapshot({
    required this.categories,
    required this.accounts,
    required this.transactions,
    required this.budgets,
    required this.goals,
  });

  final List<CategoryItem> categories;
  final List<AccountItem> accounts;
  final List<TransactionItem> transactions;
  final List<BudgetItem> budgets;
  final List<GoalItem> goals;
}

class FinanceRepository {
  FinanceRepository({AppDatabase? database}) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<FinanceSnapshot> fetchSnapshot() async {
    final db = await _database.database;
    final categoriesRows = await db.query(
      'categories',
      where: 'actif = 1 AND (archived IS NULL OR archived = 0)',
      orderBy: 'id ASC',
    );
    final accountsRows = await db.query('comptes', where: 'actif = 1', orderBy: 'id ASC');
    final transactionsRows = await db.query('transactions', orderBy: 'date_transaction DESC');
    final budgetsRows = await db.query('budgets', orderBy: 'id ASC');
    final goalsRows = await db.query('objectifs_epargne', orderBy: 'id ASC');

    final categories = categoriesRows.map(_categoryFromRow).toList();
    final accounts = accountsRows.map(_accountFromRow).toList();
    final transactions = transactionsRows.map(_transactionFromRow).toList();
    final budgets = budgetsRows.map((row) => _budgetFromRow(row, transactions)).toList();
    final goals = goalsRows.map(_goalFromRow).toList();

    return FinanceSnapshot(
      categories: categories,
      accounts: accounts,
      transactions: transactions,
      budgets: budgets,
      goals: goals,
    );
  }

  Future<void> addTransaction(TransactionItem transaction) async {
    final db = await _database.database;

    await db.transaction((txn) async {
      await txn.insert('transactions', {
        'utilisateur_id': 1,
        'compte_id': transaction.accountId,
        'categorie_id': transaction.categoryId,
        'type': transaction.type,
        'montant': transaction.amount,
        'libelle': transaction.description,
        'description': transaction.description,
        'date_transaction': transaction.date.toIso8601String(),
      });

      await txn.rawUpdate(
        'UPDATE comptes SET solde_actuel = solde_actuel + ?, date_modification = CURRENT_TIMESTAMP WHERE id = ?',
        [transaction.amount, transaction.accountId],
      );
    });
  }

  Future<int> createAccount(AccountItem account) async {
    final db = await _database.database;
    return db.insert('comptes', {
      'utilisateur_id': 1,
      'nom': account.name,
      'type': account.type,
      'solde_initial': account.balance,
      'solde_actuel': account.balance,
      'devise': 'XOF',
      'couleur': _colorToHex(account.color),
      'date_creation': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateAccount(AccountItem account) async {
    final db = await _database.database;
    await db.update(
      'comptes',
      {
        'nom': account.name,
        'type': account.type,
        'solde_actuel': account.balance,
        'couleur': _colorToHex(account.color),
        'date_modification': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> deleteAccount(int id) async {
    final db = await _database.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(1) FROM transactions WHERE compte_id = ?',
      [id],
    ));
    if ((count ?? 0) > 0) {
      throw StateError('COMPTE_UTILISE');
    }
    await db.delete('comptes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> createCategory(CategoryItem category) async {
    final db = await _database.database;
    return db.insert('categories', {
      'utilisateur_id': 1,
      'nom': category.name,
      'type': category.type,
      'icone': 'category',
      'couleur': _colorToHex(category.color),
      'archived': 0,
      'actif': 1,
      'date_creation': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateCategory(CategoryItem category) async {
    final db = await _database.database;
    await db.update(
      'categories',
      {
        'nom': category.name,
        'type': category.type,
        'couleur': _colorToHex(category.color),
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> archiveCategory(int id) async {
    final db = await _database.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(1) FROM transactions WHERE categorie_id = ?',
      [id],
    ));
    if ((count ?? 0) > 0) {
      throw StateError('CATEGORIE_UTILISEE');
    }
    await db.update('categories', {'archived': 1, 'actif': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> createBudget(BudgetItem budget) async {
    final db = await _database.database;
    return db.insert('budgets', {
      'utilisateur_id': 1,
      'categorie_id': budget.categoryId,
      'montant_budget': budget.amount,
      'periode': budget.period,
      'mois': DateTime.now().month,
      'annee': DateTime.now().year,
    });
  }

  Future<void> updateBudget(BudgetItem budget) async {
    final db = await _database.database;
    await db.update(
      'budgets',
      {
        'categorie_id': budget.categoryId,
        'montant_budget': budget.amount,
        'periode': budget.period,
        'date_modification': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> deleteBudget(int id) async {
    final db = await _database.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> createTransaction(TransactionItem transaction) async {
    final db = await _database.database;
    return db.transaction<int>((txn) async {
      final id = await txn.insert('transactions', {
        'utilisateur_id': 1,
        'compte_id': transaction.accountId,
        'categorie_id': transaction.categoryId,
        'type': transaction.type,
        'montant': transaction.amount,
        'libelle': transaction.description,
        'description': transaction.description,
        'date_transaction': transaction.date.toIso8601String(),
      });
      await txn.rawUpdate(
        'UPDATE comptes SET solde_actuel = solde_actuel + ?, date_modification = CURRENT_TIMESTAMP WHERE id = ?',
        [transaction.amount, transaction.accountId],
      );
      return id;
    });
  }

  Future<void> updateTransaction(TransactionItem transaction) async {
    final db = await _database.database;
    await db.update(
      'transactions',
      {
        'compte_id': transaction.accountId,
        'categorie_id': transaction.categoryId,
        'type': transaction.type,
        'montant': transaction.amount,
        'libelle': transaction.description,
        'description': transaction.description,
        'date_transaction': transaction.date.toIso8601String(),
        'date_modification': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(TransactionItem transaction) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete('transactions', where: 'id = ?', whereArgs: [transaction.id]);
      await txn.rawUpdate(
        'UPDATE comptes SET solde_actuel = solde_actuel - ?, date_modification = CURRENT_TIMESTAMP WHERE id = ?',
        [transaction.amount, transaction.accountId],
      );
    });
  }

  CategoryItem _categoryFromRow(Map<String, Object?> row) {
    return CategoryItem(
      id: (row['id'] as int?) ?? 0,
      name: (row['nom'] as String?) ?? '',
      color: _parseColor(row['couleur'] as String?),
      type: (row['type'] as String?) ?? 'expense',
    );
  }

  AccountItem _accountFromRow(Map<String, Object?> row) {
    return AccountItem(
      id: (row['id'] as int?) ?? 0,
      name: (row['nom'] as String?) ?? '',
      type: (row['type'] as String?) ?? 'checking',
      balance: (row['solde_actuel'] as num?)?.toDouble() ?? 0,
      color: _parseColor(row['couleur'] as String?),
    );
  }

  TransactionItem _transactionFromRow(Map<String, Object?> row) {
    return TransactionItem(
      id: (row['id'] as int?) ?? 0,
      amount: (row['montant'] as num?)?.toDouble() ?? 0,
      type: (row['type'] as String?) ?? 'expense',
      categoryId: (row['categorie_id'] as int?) ?? 0,
      accountId: (row['compte_id'] as int?) ?? 0,
      date: _parseDate(row['date_transaction']),
      description: (row['description'] as String?) ?? (row['libelle'] as String?) ?? 'Transaction',
    );
  }

  BudgetItem _budgetFromRow(Map<String, Object?> row, List<TransactionItem> transactions) {
    final categoryId = (row['categorie_id'] as int?) ?? 0;
    final spent = transactions
        .where((t) => t.type == 'expense' && t.categoryId == categoryId)
        .fold(0.0, (sum, t) => sum + t.amount.abs());

    return BudgetItem(
      id: (row['id'] as int?) ?? 0,
      categoryId: categoryId,
      amount: (row['montant_budget'] as num?)?.toDouble() ?? 0,
      spent: spent,
      period: (row['periode'] as String?) ?? 'monthly',
    );
  }

  GoalItem _goalFromRow(Map<String, Object?> row) {
    return GoalItem(
      id: (row['id'] as int?) ?? 0,
      name: (row['nom'] as String?) ?? '',
      target: (row['montant_cible'] as num?)?.toDouble() ?? 0,
      current: (row['montant_actuel'] as num?)?.toDouble() ?? 0,
      deadline: row['date_cible'] == null ? null : _parseDate(row['date_cible']),
    );
  }

  DateTime _parseDate(Object? value) {
    if (value == null) {
      return DateTime.now();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  Color _parseColor(String? value) {
    if (value == null || value.isEmpty) {
      return const Color(0xFF9CA3AF);
    }
    final hex = value.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color(0xFF9CA3AF);
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
