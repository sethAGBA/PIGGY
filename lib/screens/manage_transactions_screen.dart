import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../models/finance_models.dart';
import '../screens/screen_helpers.dart';

class ManageTransactionsScreen extends StatelessWidget {
  const ManageTransactionsScreen({super.key, required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Transactions')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: controller.transactions.map((transaction) {
              final category = controller.categories.firstWhere((c) => c.id == transaction.categoryId);
              final account = controller.accounts.firstWhere((a) => a.id == transaction.accountId);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: category.color, child: const Icon(Icons.receipt_long, color: Colors.white)),
                  title: Text(transaction.description),
                  subtitle: Text('${category.name} • ${account.name}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${transaction.amount > 0 ? '+' : ''}${formatCurrency(transaction.amount)}',
                        style: TextStyle(
                          color: transaction.amount > 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openTransactionDialog(context, controller, transaction: transaction),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, controller, transaction),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openTransactionDialog(context, controller),
            backgroundColor: const Color(0xFF0F766E),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FinanceController controller,
    TransactionItem transaction,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la transaction'),
        content: const Text('Supprimer cette transaction ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (result == true) {
      await controller.deleteTransaction(transaction);
    }
  }

  Future<void> _openTransactionDialog(
    BuildContext context,
    FinanceController controller, {
    TransactionItem? transaction,
  }) async {
    final amountController = TextEditingController(text: transaction?.amount.abs().toString() ?? '');
    final descriptionController = TextEditingController(text: transaction?.description ?? '');
    String type = transaction?.type ?? 'expense';
    int categoryId = transaction?.categoryId ?? controller.categories.first.id;
    int accountId = transaction?.accountId ?? controller.accounts.first.id;
    DateTime date = transaction?.date ?? DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction == null ? 'Nouvelle transaction' : 'Modifier la transaction'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Montant'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Depense')),
                  DropdownMenuItem(value: 'income', child: Text('Revenu')),
                ],
                onChanged: (value) => type = value ?? type,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: categoryId,
                decoration: const InputDecoration(labelText: 'Categorie'),
                items: controller.categories
                    .where((c) => c.type == type)
                    .map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name)))
                    .toList(),
                onChanged: (value) => categoryId = value ?? categoryId,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: accountId,
                decoration: const InputDecoration(labelText: 'Compte'),
                items: controller.accounts
                    .map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.name)))
                    .toList(),
                onChanged: (value) => accountId = value ?? accountId,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text('${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          date = picked;
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enregistrer')),
        ],
      ),
    );

    if (result == true) {
      final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Montant invalide.')));
        return;
      }
      final signedAmount = type == 'expense' ? -amount.abs() : amount.abs();
      final nextTransaction = TransactionItem(
        id: transaction?.id ?? 0,
        amount: signedAmount,
        type: type,
        categoryId: categoryId,
        accountId: accountId,
        date: date,
        description: descriptionController.text.isEmpty ? 'Transaction' : descriptionController.text,
      );
      if (transaction == null) {
        await controller.createTransaction(nextTransaction);
      } else {
        await controller.updateTransaction(nextTransaction);
      }
    }
  }
}
