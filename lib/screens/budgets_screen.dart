import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../screens/screen_helpers.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key, required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...controller.budgets.map((budget) {
          final category = controller.categories.firstWhere((c) => c.id == budget.categoryId);
          return budgetCard(budget, category);
        }),
        const SizedBox(height: 16),
        sectionCard(
          title: 'Objectifs d epargne',
          child: Column(children: controller.goals.map(goalCard).toList()),
        ),
      ],
    );
  }
}
