import 'package:flutter/material.dart';
import 'package:piggy/models/finance_models.dart';

import '../controllers/finance_controller.dart';
import '../screens/screen_helpers.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, required this.controller});

  final FinanceController controller;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _query = '';
  String _typeFilter = 'all';
  int? _categoryId;
  int? _accountId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final filtered = _applyFilters(widget.controller);
        return sectionCard(
          title: 'Toutes les transactions',
          actions: [
            TextButton.icon(
              onPressed: () => _openFilterDialog(context),
              icon: const Icon(Icons.filter_list),
              label: const Text('Filtrer'),
            ),
            TextButton.icon(
              onPressed: () => _openSearchDialog(context),
              icon: const Icon(Icons.search),
              label: const Text('Rechercher'),
            ),
          ],
          child: Column(
            children: filtered.isEmpty
                ? [
                    const SizedBox(height: 12),
                    Icon(Icons.filter_list, size: 36, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const Text('Aucune donnee', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Reinitialiser'),
                    ),
                    const SizedBox(height: 4),
                  ]
                : filtered.map((transaction) {
                    final category = widget.controller.categories.firstWhere((c) => c.id == transaction.categoryId);
                    final account = widget.controller.accounts.firstWhere((a) => a.id == transaction.accountId);
                    return transactionTile(transaction, category, account);
                  }).toList(),
          ),
        );
      },
    );
  }

  List<TransactionItem> _applyFilters(FinanceController controller) {
    return controller.transactions.where((transaction) {
      final matchesType = _typeFilter == 'all' || transaction.type == _typeFilter;
      final matchesCategory = _categoryId == null || transaction.categoryId == _categoryId;
      final matchesAccount = _accountId == null || transaction.accountId == _accountId;
      final matchesQuery = _query.isEmpty || transaction.description.toLowerCase().contains(_query.toLowerCase());
      return matchesType && matchesCategory && matchesAccount && matchesQuery;
    }).toList();
  }

  Future<void> _openSearchDialog(BuildContext context) async {
    final controller = TextEditingController(text: _query);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Description'),
          textInputAction: TextInputAction.search,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Appliquer')),
        ],
      ),
    );

    if (result == true) {
      setState(() => _query = controller.text.trim());
    }
  }

  Future<void> _openFilterDialog(BuildContext context) async {
    String type = _typeFilter;
    int? categoryId = _categoryId;
    int? accountId = _accountId;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tous')),
                  DropdownMenuItem(value: 'expense', child: Text('Depense')),
                  DropdownMenuItem(value: 'income', child: Text('Revenu')),
                ],
                onChanged: (value) => type = value ?? type,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: categoryId,
                decoration: const InputDecoration(labelText: 'Categorie'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Toutes')),
                  ...widget.controller.categories.map(
                    (cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name)),
                  ),
                ],
                onChanged: (value) => categoryId = value,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: accountId,
                decoration: const InputDecoration(labelText: 'Compte'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tous')),
                  ...widget.controller.accounts.map(
                    (acc) => DropdownMenuItem(value: acc.id, child: Text(acc.name)),
                  ),
                ],
                onChanged: (value) => accountId = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _typeFilter = type;
        _categoryId = categoryId;
        _accountId = accountId;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _typeFilter = 'all';
      _categoryId = null;
      _accountId = null;
    });
  }
}
