import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../screens/screen_helpers.dart';
import 'manage_accounts_screen.dart';
import 'manage_budgets_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_transactions_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    final settings = [
      _SettingItem(icon: Icons.language, label: 'Langue', value: 'Francais'),
      _SettingItem(icon: Icons.payments, label: 'Devise', value: 'FCFA'),
      _SettingItem(icon: Icons.dark_mode, label: 'Theme', value: 'Clair'),
      _SettingItem(icon: Icons.notifications, label: 'Notifications', value: 'Activees'),
      _SettingItem(icon: Icons.lock, label: 'Securite', value: 'Configurer'),
      _SettingItem(icon: Icons.file_download, label: 'Export des donnees', value: 'CSV, PDF'),
    ];

    return Column(
      children: [
        sectionCard(
          title: 'Gestion',
          child: Column(
            children: [
              _navRow(
                context,
                icon: Icons.account_balance_wallet,
                label: 'Comptes',
                onTap: () => _openScreen(context, ManageAccountsScreen(controller: controller)),
              ),
              _navRow(
                context,
                icon: Icons.category,
                label: 'Categories',
                onTap: () => _openScreen(context, ManageCategoriesScreen(controller: controller)),
              ),
              _navRow(
                context,
                icon: Icons.flag,
                label: 'Budgets',
                onTap: () => _openScreen(context, ManageBudgetsScreen(controller: controller)),
              ),
              _navRow(
                context,
                icon: Icons.receipt_long,
                label: 'Transactions',
                onTap: () => _openScreen(context, ManageTransactionsScreen(controller: controller)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        sectionCard(
          title: 'Parametres generaux',
          child: Column(children: settings.map(_settingRow).toList()),
        ),
        const SizedBox(height: 16),
        sectionCard(
          title: 'Categories',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.categories.map(categoryPill).toList(),
          ),
        ),
        const SizedBox(height: 16),
        sectionCard(
          title: 'A propos',
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: 1.0.0'),
              SizedBox(height: 8),
              Text('Application de gestion financiere personnelle'),
              SizedBox(height: 8),
              Text('© 2024 - Tous droits reserves', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingRow(_SettingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFE5E7EB), child: Icon(item.icon, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(item.value, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _navRow(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFFE5E7EB), child: Icon(icon, size: 18)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Future<void> _openScreen(BuildContext context, Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _SettingItem {
  const _SettingItem({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;
}
