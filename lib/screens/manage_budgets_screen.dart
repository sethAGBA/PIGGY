import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../models/finance_models.dart';
import '../screens/screen_helpers.dart';

class ManageBudgetsScreen extends StatelessWidget {
  const ManageBudgetsScreen({super.key, required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Budgets')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: controller.budgets.map((budget) {
              final category = controller.categories.firstWhere((c) => c.id == budget.categoryId);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: category.color, child: const Icon(Icons.flag, color: Colors.white)),
                  title: Text(category.name),
                  subtitle: Text('Budget: ${formatCurrency(budget.amount)} FCFA'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openBudgetDialog(context, controller, budget: budget),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, controller, budget),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openBudgetDialog(context, controller),
            backgroundColor: const Color(0xFF0F766E),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, FinanceController controller, BudgetItem budget) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le budget'),
        content: const Text('Supprimer ce budget ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (result == true) {
      try {
        await controller.deleteBudget(budget.id);
      } catch (_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Impossible de supprimer ce budget.')));
      }
    }
  }

  Future<void> _openBudgetDialog(BuildContext context, FinanceController controller, {BudgetItem? budget}) async {
    final amountController = TextEditingController(text: budget?.amount.toString() ?? '');
    int categoryId = budget?.categoryId ?? controller.categories.first.id;
    String period = budget?.period ?? 'monthly';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(budget == null ? 'Nouveau budget' : 'Modifier le budget'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: categoryId,
                decoration: const InputDecoration(labelText: 'Categorie'),
                items: controller.categories
                    .map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name)))
                    .toList(),
                onChanged: (value) => categoryId = value ?? categoryId,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Montant'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: period,
                decoration: const InputDecoration(labelText: 'Periode'),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Mensuel')),
                  DropdownMenuItem(value: 'yearly', child: Text('Annuel')),
                ],
                onChanged: (value) => period = value ?? period,
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
      final nextBudget = BudgetItem(
        id: budget?.id ?? 0,
        categoryId: categoryId,
        amount: amount,
        spent: budget?.spent ?? 0,
        period: period,
      );
      if (budget == null) {
        await controller.createBudget(nextBudget);
      } else {
        await controller.updateBudget(nextBudget);
      }
    }
  }
}
