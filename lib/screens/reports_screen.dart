import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../screens/screen_helpers.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    final topExpenses = [...controller.expensesByCategory]..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: [
        sectionCard(
          title: 'Bilan du mois',
          child: Column(
            children: [
              reportRow('Revenus', controller.monthlyIncome, const Color(0xFF22C55E)),
              reportRow('Depenses', -controller.monthlyExpenses, const Color(0xFFEF4444)),
              reportRow('Solde', controller.monthlySavings, const Color(0xFF0F766E), isTotal: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        sectionCard(
          title: 'Top depenses',
          child: Column(children: topExpenses.take(5).map(topExpenseRow).toList()),
        ),
        const SizedBox(height: 16),
        sectionCard(
          title: 'Dettes',
          child: Column(
            children: [
              reportRow('Avoir', controller.totalReceivables, const Color(0xFF0EA5E9)),
              reportRow('Doit', -controller.totalPayables, const Color(0xFFF97316)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        sectionCard(
          title: 'Mes comptes',
          child: Column(children: controller.accounts.map(accountRow).toList()),
        ),
      ],
    );
  }
}
