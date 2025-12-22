import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../models/finance_models.dart';
import 'screen_helpers.dart';

class ManageDebtsScreen extends StatelessWidget {
  const ManageDebtsScreen({super.key, required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Dettes')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.debts.isEmpty)
                const Center(child: Text('Aucune dette enregistree.'))
              else
                ...controller.debts.map((debt) {
                  final account = controller.accounts.firstWhere(
                    (acc) => acc.id == debt.accountId,
                    orElse: () => AccountItem(
                      id: 0,
                      name: 'Compte',
                      type: 'checking',
                      balance: 0,
                      color: const Color(0xFF9CA3AF),
                    ),
                  );
                  final typeLabel = debt.type == 'owed_to_me' ? 'Avoir' : 'Doit';
                  final typeColor = debt.type == 'owed_to_me' ? const Color(0xFF0EA5E9) : const Color(0xFFF97316);
                  final statusLabel = debt.status == 'soldee' ? 'Soldee' : 'En cours';
                  return Card(
                    child: ListTile(
                      title: Text(debt.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$typeLabel • ${account.name}'),
                          if (debt.dueDate != null) Text('Echeance: ${formatDate(debt.dueDate!)}'),
                          Text('Statut: $statusLabel'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${formatCurrency(debt.remainingAmount)} FCFA',
                            style: TextStyle(fontWeight: FontWeight.bold, color: typeColor),
                          ),
                          Text(
                            'sur ${formatCurrency(debt.totalAmount)}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.payments_outlined),
                                onPressed: () => _openPaymentDialog(context, controller, debt),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openDebtDialog(context, controller, debt: debt),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _confirmDelete(context, controller, debt),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openDebtDialog(context, controller),
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
    DebtItem debt,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la dette'),
        content: const Text('Supprimer cette dette ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (result == true) {
      try {
        await controller.deleteDebt(debt.id);
      } on StateError {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de supprimer une dette avec des paiements.')),
        );
      }
    }
  }

  Future<void> _openDebtDialog(
    BuildContext context,
    FinanceController controller, {
    DebtItem? debt,
  }) async {
    if (controller.accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez d abord un compte.')),
      );
      return;
    }

    final nameController = TextEditingController(text: debt?.name ?? '');
    final amountController = TextEditingController(
      text: debt == null ? '' : debt.totalAmount.toStringAsFixed(0),
    );
    final noteController = TextEditingController(text: debt?.note ?? '');
    String type = debt?.type ?? 'owed_to_me';
    int accountId = debt?.accountId ?? controller.accounts.first.id;
    DateTime? dueDate = debt?.dueDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(debt == null ? 'Nouvelle dette' : 'Modifier la dette'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'owed_to_me', child: Text('Avoir')),
                  DropdownMenuItem(value: 'i_owe', child: Text('Doit')),
                ],
                onChanged: (value) => type = value ?? type,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Montant'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                readOnly: debt != null,
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
                      label: Text(
                        dueDate == null ? 'Echeance' : formatDate(dueDate!),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          dueDate = picked;
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
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
      final name = nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nom invalide.')));
        return;
      }
      final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
      if (debt == null && amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Montant invalide.')));
        return;
      }
      final totalAmount = debt?.totalAmount ?? amount;
      final remainingAmount = debt?.remainingAmount ?? totalAmount;
      final status = remainingAmount <= 0 ? 'soldee' : 'en_cours';
      final nextDebt = DebtItem(
        id: debt?.id ?? 0,
        name: name,
        type: type,
        totalAmount: totalAmount,
        remainingAmount: remainingAmount,
        accountId: accountId,
        createdAt: debt?.createdAt ?? DateTime.now(),
        dueDate: dueDate,
        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
        status: status,
      );
      if (debt == null) {
        await controller.createDebt(nextDebt);
      } else {
        await controller.updateDebt(nextDebt);
      }
    }
  }

  Future<void> _openPaymentDialog(
    BuildContext context,
    FinanceController controller,
    DebtItem debt,
  ) async {
    if (debt.remainingAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dette deja soldee.')));
      return;
    }

    final categories = controller.categories.where((c) {
      return debt.type == 'owed_to_me' ? c.type == 'income' : c.type == 'expense';
    }).toList();

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez d abord une categorie adaptee.')),
      );
      return;
    }

    final amountController = TextEditingController(text: debt.remainingAmount.toStringAsFixed(0));
    final descriptionController = TextEditingController();
    int categoryId = categories.first.id;
    int accountId = debt.accountId;
    DateTime date = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enregistrer un paiement'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Montant'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              DropdownButtonFormField<int>(
                value: categoryId,
                decoration: const InputDecoration(labelText: 'Categorie'),
                items: categories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))).toList(),
                onChanged: (value) => categoryId = value ?? categoryId,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(formatDate(date)),
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
      if (amount > debt.remainingAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Montant superieur au solde restant.')),
        );
        return;
      }
      await controller.recordDebtPayment(
        debt: debt,
        amount: amount,
        categoryId: categoryId,
        accountId: accountId,
        date: date,
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
      );
    }
  }
}
