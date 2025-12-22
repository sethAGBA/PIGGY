import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../screens/screen_helpers.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    final expensesByCategory = controller.expensesByCategory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            statCard(
              context,
              'Solde Total',
              formatCurrency(controller.totalBalance),
              Icons.account_balance_wallet,
              const Color(0xFF3B82F6),
            ),
            statCard(
              context,
              'Epargne',
              formatCurrency(controller.monthlySavings),
              Icons.trending_up,
              const Color(0xFF10B981),
            ),
            statCard(
              context,
              'Revenus',
              formatCurrency(controller.monthlyIncome),
              Icons.arrow_upward,
              const Color(0xFF059669),
            ),
            statCard(
              context,
              'Depenses',
              formatCurrency(controller.monthlyExpenses),
              Icons.arrow_downward,
              const Color(0xFFEF4444),
            ),
            statCard(
              context,
              'Avoir',
              formatCurrency(controller.totalReceivables),
              Icons.south_west,
              const Color(0xFF0EA5E9),
            ),
            statCard(
              context,
              'Doit',
              formatCurrency(controller.totalPayables),
              Icons.north_east,
              const Color(0xFFF97316),
            ),
          ],
        ),
        const SizedBox(height: 20),
        sectionCard(
          title: 'Evolution (6 mois)',
          child: miniTrendChart(controller.last6Months),
        ),
        if (expensesByCategory.isNotEmpty) ...[
          const SizedBox(height: 16),
          sectionCard(
            title: 'Depenses par categorie',
            child: categoryBreakdown(expensesByCategory),
          ),
        ],
        const SizedBox(height: 16),
        sectionCard(
          title: 'Transactions recentes',
          child: Column(
            children: controller.transactions.take(5).map((transaction) {
              final category = controller.categories.firstWhere((c) => c.id == transaction.categoryId);
              return transactionRow(transaction, category);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
