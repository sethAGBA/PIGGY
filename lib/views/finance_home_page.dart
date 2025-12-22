import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../models/finance_models.dart';
import '../screens/budgets_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/transactions_screen.dart';

class FinanceHomePage extends StatefulWidget {
  const FinanceHomePage({super.key});

  @override
  State<FinanceHomePage> createState() => _FinanceHomePageState();
}

class _FinanceHomePageState extends State<FinanceHomePage> {
  late final FinanceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FinanceController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openAddTransaction() {
    if (_controller.isLoading) {
      return;
    }
    if (_controller.categories.isEmpty || _controller.accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez d abord des comptes et categories.')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TransactionForm(
          categories: _controller.categories,
          accounts: _controller.accounts,
          onAdd: _controller.addTransaction,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          floatingActionButton: FloatingActionButton(
            onPressed: _openAddTransaction,
            backgroundColor: const Color(0xFF0F766E),
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _controller.activeTabIndex,
            selectedItemColor: const Color(0xFF0F766E),
            unselectedItemColor: Colors.grey,
            onTap: _controller.setActiveTab,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transactions'),
              BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Budgets'),
              BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Rapports'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Parametres'),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _HeaderSection(onBellTap: () {}),
                Expanded(
                  child: _controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          child: _buildActiveTab(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveTab() {
    switch (_controller.activeTabIndex) {
      case 1:
        return TransactionsScreen(controller: _controller);
      case 2:
        return BudgetsScreen(controller: _controller);
      case 3:
        return ReportsScreen(controller: _controller);
      case 4:
        return SettingsScreen(controller: _controller);
      default:
        return DashboardScreen(controller: _controller);
    }
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.onBellTap});

  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        gradient: LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PIGGY', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Gerez vos finances facilement', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onBellTap,
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white24,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _HeaderChip(icon: Icons.calendar_today, label: 'Ce mois'),
                  const SizedBox(width: 8),
                  _HeaderChip(icon: Icons.lock, label: 'Local'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

class TransactionForm extends StatefulWidget {
  const TransactionForm({
    super.key,
    required this.categories,
    required this.accounts,
    required this.onAdd,
  });

  final List<CategoryItem> categories;
  final List<AccountItem> accounts;
  final ValueChanged<TransactionItem> onAdd;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'expense';
  int? _categoryId;
  int? _accountId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _categoryId = widget.categories.firstWhere((c) => c.type == _type).id;
    _accountId = widget.accounts.first.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = widget.categories.where((c) => c.type == _type).toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Nouvelle transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Montant (FCFA)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        _type = 'expense';
                        _categoryId = widget.categories.firstWhere((c) => c.type == _type).id;
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _type == 'expense' ? const Color(0xFFEF4444) : Colors.grey.shade200,
                        foregroundColor: _type == 'expense' ? Colors.white : Colors.black87,
                      ),
                      child: const Text('Depense'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        _type = 'income';
                        _categoryId = widget.categories.firstWhere((c) => c.type == _type).id;
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _type == 'income' ? const Color(0xFF22C55E) : Colors.grey.shade200,
                        foregroundColor: _type == 'income' ? Colors.white : Colors.black87,
                      ),
                      child: const Text('Revenu'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Categorie', border: OutlineInputBorder()),
                items: filteredCategories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))).toList(),
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _accountId,
                decoration: const InputDecoration(labelText: 'Compte', border: OutlineInputBorder()),
                items: widget.accounts.map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.name))).toList(),
                onChanged: (value) => setState(() => _accountId = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text('${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _date = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E)),
                  child: const Text('Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    final rawAmount = _amountController.text.trim();
    if (rawAmount.isEmpty) {
      _showMessage('Montant requis');
      return;
    }
    final amountValue = double.tryParse(rawAmount.replaceAll(',', '.'));
    if (amountValue == null || amountValue == 0) {
      _showMessage('Montant invalide');
      return;
    }
    final signedAmount = _type == 'expense' ? -amountValue.abs() : amountValue.abs();

    final newTransaction = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch,
      amount: signedAmount,
      type: _type,
      categoryId: _categoryId ?? widget.categories.first.id,
      accountId: _accountId ?? widget.accounts.first.id,
      date: _date,
      description: _descriptionController.text.isEmpty ? 'Transaction' : _descriptionController.text,
    );

    widget.onAdd(newTransaction);
    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
