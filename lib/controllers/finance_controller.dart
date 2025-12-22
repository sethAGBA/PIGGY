import 'package:flutter/material.dart';

import '../data/finance_repository.dart';
import '../models/finance_models.dart';

class FinanceController extends ChangeNotifier {
  FinanceController({FinanceRepository? repository}) : _repository = repository ?? FinanceRepository() {
    _init();
  }

  final FinanceRepository _repository;

  int _activeTabIndex = 0;
  bool _isLoading = true;

  final List<TransactionItem> _transactions = [];
  final List<AccountItem> _accounts = [];
  final List<CategoryItem> _categories = [];
  final List<BudgetItem> _budgets = [];
  final List<GoalItem> _goals = [];
  final List<MonthlyTrend> _last6Months = [];

  int get activeTabIndex => _activeTabIndex;
  bool get isLoading => _isLoading;
  List<TransactionItem> get transactions => List.unmodifiable(_transactions);
  List<AccountItem> get accounts => List.unmodifiable(_accounts);
  List<CategoryItem> get categories => List.unmodifiable(_categories);
  List<BudgetItem> get budgets => List.unmodifiable(_budgets);
  List<GoalItem> get goals => List.unmodifiable(_goals);
  List<MonthlyTrend> get last6Months => List.unmodifiable(_last6Months);

  double get totalBalance => _accounts.fold(0, (sum, acc) => sum + acc.balance);

  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == 'income' && t.date.year == now.year && t.date.month == now.month)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpenses {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == 'expense' && t.date.year == now.year && t.date.month == now.month)
        .fold(0, (sum, t) => sum + t.amount.abs());
  }

  double get monthlySavings => monthlyIncome - monthlyExpenses;

  List<CategorySpend> get expensesByCategory {
    return _categories
        .where((c) => c.type == 'expense')
        .map((cat) {
          final total = _transactions
              .where((t) => t.type == 'expense' && t.categoryId == cat.id)
              .fold(0.0, (sum, t) => sum + t.amount.abs());
          return CategorySpend(name: cat.name, value: total, color: cat.color);
        })
        .where((item) => item.value > 0)
        .toList();
  }

  void setActiveTab(int index) {
    if (_activeTabIndex != index) {
      _activeTabIndex = index;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionItem transaction) async {
    await _repository.addTransaction(transaction);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> createAccount(AccountItem account) async {
    await _repository.createAccount(account);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> updateAccount(AccountItem account) async {
    await _repository.updateAccount(account);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> deleteAccount(int id) async {
    await _repository.deleteAccount(id);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> createCategory(CategoryItem category) async {
    await _repository.createCategory(category);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> updateCategory(CategoryItem category) async {
    await _repository.updateCategory(category);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> archiveCategory(int id) async {
    await _repository.archiveCategory(id);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> createBudget(BudgetItem budget) async {
    await _repository.createBudget(budget);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> updateBudget(BudgetItem budget) async {
    await _repository.updateBudget(budget);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> deleteBudget(int id) async {
    await _repository.deleteBudget(id);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> createTransaction(TransactionItem transaction) async {
    await _repository.createTransaction(transaction);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionItem transaction) async {
    await _repository.updateTransaction(transaction);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> deleteTransaction(TransactionItem transaction) async {
    await _repository.deleteTransaction(transaction);
    await _loadSnapshot();
    notifyListeners();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    await _loadSnapshot();
    _rebuildTrendData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSnapshot() async {
    final snapshot = await _repository.fetchSnapshot();
    _categories
      ..clear()
      ..addAll(snapshot.categories);
    _accounts
      ..clear()
      ..addAll(snapshot.accounts);
    _transactions
      ..clear()
      ..addAll(snapshot.transactions);
    _budgets
      ..clear()
      ..addAll(snapshot.budgets);
    _goals
      ..clear()
      ..addAll(snapshot.goals);
    _rebuildTrendData();
  }

  void _rebuildTrendData() {
    _last6Months.clear();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 5, 1);
    for (int i = 0; i < 6; i++) {
      final monthDate = DateTime(start.year, start.month + i, 1);
      final income = _sumForMonth(monthDate, 'income');
      final expenses = _sumForMonth(monthDate, 'expense');
      _last6Months.add(MonthlyTrend(
        monthLabel: _shortMonth(monthDate),
        income: income.round(),
        expenses: expenses.round(),
      ));
    }
  }

  String _shortMonth(DateTime date) {
    const months = ['Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aou', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  double _sumForMonth(DateTime month, String type) {
    return _transactions
        .where((t) => t.type == type && t.date.year == month.year && t.date.month == month.month)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }
}
