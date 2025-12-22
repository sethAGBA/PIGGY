import 'package:flutter/material.dart';

class CategoryItem {
  CategoryItem({
    required this.id,
    required this.name,
    required this.color,
    required this.type,
  });

  final int id;
  final String name;
  final Color color;
  final String type;
}

class AccountItem {
  AccountItem({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
  });

  final int id;
  final String name;
  final String type;
  final double balance;
  final Color color;

  AccountItem copyWith({double? balance}) {
    return AccountItem(
      id: id,
      name: name,
      type: type,
      balance: balance ?? this.balance,
      color: color,
    );
  }
}

class TransactionItem {
  TransactionItem({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.date,
    required this.description,
  });

  final int id;
  final double amount;
  final String type;
  final int categoryId;
  final int accountId;
  final DateTime date;
  final String description;
}

class BudgetItem {
  BudgetItem({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.spent,
    required this.period,
  });

  final int id;
  final int categoryId;
  final double amount;
  final double spent;
  final String period;

  BudgetItem copyWith({double? spent}) {
    return BudgetItem(
      id: id,
      categoryId: categoryId,
      amount: amount,
      spent: spent ?? this.spent,
      period: period,
    );
  }
}

class GoalItem {
  GoalItem({
    required this.id,
    required this.name,
    required this.target,
    required this.current,
    required this.deadline,
  });

  final int id;
  final String name;
  final double target;
  final double current;
  final DateTime? deadline;
}

class CategorySpend {
  CategorySpend({required this.name, required this.value, required this.color});

  final String name;
  final double value;
  final Color color;
}

class MonthlyTrend {
  MonthlyTrend({required this.monthLabel, required this.income, required this.expenses});

  final String monthLabel;
  final int income;
  final int expenses;
}
