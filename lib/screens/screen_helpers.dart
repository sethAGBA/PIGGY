import 'dart:math';

import 'package:flutter/material.dart';

import '../models/finance_models.dart';

Widget sectionCard({
  required String title,
  required Widget child,
  List<Widget> actions = const [],
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
    ]),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            if (actions.isNotEmpty) ...actions,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

Widget statCard(BuildContext context, String title, String amount, IconData icon, Color color) {
  return SizedBox(
    width: (MediaQuery.of(context).size.width - 44) / 2,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [color.withOpacity(0.9), color]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$amount FCFA',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

Widget miniTrendChart(List<MonthlyTrend> data) {
  final maxValueRaw = data.map((e) => max(e.income, e.expenses)).fold(0, max);
  final maxValue = maxValueRaw == 0 ? 1.0 : maxValueRaw.toDouble();
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: data.map((point) {
      final incomeHeight = (point.income / maxValue) * 120;
      final expenseHeight = (point.expenses / maxValue) * 120;
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 8, height: incomeHeight, color: const Color(0xFF22C55E)),
                const SizedBox(width: 4),
                Container(width: 8, height: expenseHeight, color: const Color(0xFFEF4444)),
              ],
            ),
            const SizedBox(height: 6),
            Text(point.monthLabel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      );
    }).toList(),
  );
}

Widget categoryBreakdown(List<CategorySpend> data) {
  return Column(
    children: data.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name)),
            Text('${formatCurrency(item.value)} FCFA'),
          ],
        ),
      );
    }).toList(),
  );
}

Widget transactionRow(TransactionItem transaction, CategoryItem category) {
  return Column(
    children: [
      Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: category.color.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.category, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(formatDate(transaction.date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${transaction.amount > 0 ? '+' : ''}${formatCurrency(transaction.amount)} FCFA',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: transaction.amount > 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
      const Divider(),
    ],
  );
}

Widget transactionTile(TransactionItem transaction, CategoryItem category, AccountItem account) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: category.color.withOpacity(0.2), shape: BoxShape.circle),
          child: const Icon(Icons.category, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${category.name} • ${account.name}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(formatDate(transaction.date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.amount > 0 ? '+' : ''}${formatCurrency(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.amount > 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              ),
            ),
            const Text('FCFA', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    ),
  );
}

Widget budgetCard(BudgetItem budget, CategoryItem category) {
  final percentage = (budget.spent / budget.amount) * 100;
  final isOver = percentage > 100;
  final progress = min(percentage / 100, 1.0);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
    ]),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: category.color.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.category, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Text('Budget mensuel', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${formatCurrency(budget.spent)} FCFA', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('sur ${formatCurrency(budget.amount)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          color: isOver ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
          backgroundColor: const Color(0xFFE5E7EB),
          minHeight: 8,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${percentage.toStringAsFixed(0)}% utilise',
              style: TextStyle(color: isOver ? const Color(0xFFDC2626) : Colors.grey),
            ),
            if (isOver)
              const Text('Budget depasse', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
          ],
        ),
      ],
    ),
  );
}

Widget goalCard(GoalItem goal) {
  final percentage = (goal.current / goal.target) * 100;
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(Icons.flag, color: Color(0xFF0F766E)),
            const SizedBox(width: 8),
            Expanded(child: Text(goal.name, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text('${percentage.toStringAsFixed(0)}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: min(percentage / 100, 1.0),
          color: const Color(0xFF0F766E),
          backgroundColor: const Color(0xFFE5E7EB),
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${formatCurrency(goal.current)} FCFA', style: const TextStyle(fontSize: 12)),
            Text('${formatCurrency(goal.target)} FCFA', style: const TextStyle(fontSize: 12)),
          ],
        ),
        if (goal.deadline != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Objectif: ${formatDate(goal.deadline!)}',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
      ],
    ),
  );
}

Widget reportRow(String label, double amount, Color color, {bool isTotal = false}) {
  final display = amount.abs();
  final prefix = amount >= 0 ? '+' : '-';
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: isTotal ? Border.all(color: color.withOpacity(0.4), width: 1.5) : null,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text('$prefix${formatCurrency(display)} FCFA', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    ),
  );
}

Widget topExpenseRow(CategorySpend category) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: category.color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(category.name)),
        Text('${formatCurrency(category.value)} FCFA', style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

Widget accountRow(AccountItem account) {
  IconData icon;
  switch (account.type) {
    case 'checking':
      icon = Icons.credit_card;
      break;
    case 'savings':
      icon = Icons.account_balance_wallet;
      break;
    default:
      icon = Icons.payments;
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: account.color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        CircleAvatar(backgroundColor: account.color, child: Icon(icon, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(account.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(account.type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Text('${formatCurrency(account.balance)} FCFA', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget categoryPill(CategoryItem category) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: category.color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.category, size: 14),
        const SizedBox(width: 6),
        Text(category.name, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Text(category.type == 'income' ? 'Revenu' : 'Depense', style: const TextStyle(fontSize: 10)),
        ),
      ],
    ),
  );
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatCurrency(double value) {
  final negative = value < 0;
  final integerPart = value.abs().round();
  final digits = integerPart.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final indexFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write(' ');
    }
  }
  final formatted = buffer.toString();
  return negative ? '-$formatted' : formatted;
}
