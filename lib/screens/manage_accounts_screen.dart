import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../models/finance_models.dart';
import '../screens/screen_helpers.dart';

class ManageAccountsScreen extends StatelessWidget {
  const ManageAccountsScreen({super.key, required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Comptes')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: controller.accounts.map((account) {
              return Card(
                child: ListTile(
                  leading:
                      CircleAvatar(backgroundColor: account.color, child: const Icon(Icons.account_balance, color: Colors.white)),
                  title: Text(account.name),
                  subtitle: Text('${account.type} • ${formatCurrency(account.balance)} FCFA'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openAccountDialog(context, controller, account: account),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, controller, account),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAccountDialog(context, controller),
            backgroundColor: const Color(0xFF0F766E),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, FinanceController controller, AccountItem account) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: Text('Supprimer "${account.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (result == true) {
      try {
        await controller.deleteAccount(account.id);
      } on StateError catch (error) {
        if (error.message == 'COMPTE_UTILISE') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Suppression impossible: compte utilise.')),
          );
          return;
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Impossible de supprimer ce compte.')));
      } catch (_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Impossible de supprimer ce compte.')));
      }
    }
  }

  Future<void> _openAccountDialog(BuildContext context, FinanceController controller, {AccountItem? account}) async {
    final nameController = TextEditingController(text: account?.name ?? '');
    final balanceController = TextEditingController(text: account?.balance.toString() ?? '');
    String type = account?.type ?? 'checking';
    Color color = account?.color ?? const Color(0xFF3B82F6);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account == null ? 'Nouveau compte' : 'Modifier le compte'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(labelText: 'Solde'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'checking', child: Text('Checking')),
                  DropdownMenuItem(value: 'savings', child: Text('Savings')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                ],
                onChanged: (value) => type = value ?? type,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Color>(
                value: color,
                decoration: const InputDecoration(labelText: 'Couleur'),
                items: const [
                  DropdownMenuItem(value: Color(0xFF3B82F6), child: Text('Bleu')),
                  DropdownMenuItem(value: Color(0xFF10B981), child: Text('Vert')),
                  DropdownMenuItem(value: Color(0xFFF59E0B), child: Text('Orange')),
                  DropdownMenuItem(value: Color(0xFF6366F1), child: Text('Indigo')),
                ],
                onChanged: (value) => color = value ?? color,
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
      final balance = double.tryParse(balanceController.text.replaceAll(',', '.')) ?? 0;
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nom requis.')));
        return;
      }
      final nextAccount = AccountItem(
        id: account?.id ?? 0,
        name: name,
        type: type,
        balance: balance,
        color: color,
      );
      if (account == null) {
        await controller.createAccount(nextAccount);
      } else {
        await controller.updateAccount(nextAccount);
      }
    }
  }
}
