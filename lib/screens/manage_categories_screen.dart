import 'package:flutter/material.dart';

import '../controllers/finance_controller.dart';
import '../models/finance_models.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key, required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Categories')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: controller.categories.map((category) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: category.color, child: const Icon(Icons.category, color: Colors.white)),
                  title: Text(category.name),
                  subtitle: Text(category.type == 'income' ? 'Revenu' : 'Depense'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openCategoryDialog(context, controller, category: category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, controller, category),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openCategoryDialog(context, controller),
            backgroundColor: const Color(0xFF0F766E),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, FinanceController controller, CategoryItem category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la categorie'),
        content: Text('Supprimer "${category.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (result == true) {
      try {
        await controller.archiveCategory(category.id);
      } on StateError catch (error) {
        if (error.message == 'CATEGORIE_UTILISEE') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Suppression impossible: categorie utilisee.')),
          );
          return;
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Impossible de supprimer cette categorie.')));
      } catch (_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Impossible de supprimer cette categorie.')));
      }
    }
  }

  Future<void> _openCategoryDialog(BuildContext context, FinanceController controller, {CategoryItem? category}) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    String type = category?.type ?? 'expense';
    Color color = category?.color ?? const Color(0xFFF97316);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Nouvelle categorie' : 'Modifier la categorie'),
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
                  DropdownMenuItem(value: 'expense', child: Text('Depense')),
                  DropdownMenuItem(value: 'income', child: Text('Revenu')),
                ],
                onChanged: (value) => type = value ?? type,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Color>(
                value: color,
                decoration: const InputDecoration(labelText: 'Couleur'),
                items: const [
                  DropdownMenuItem(value: Color(0xFFF97316), child: Text('Orange')),
                  DropdownMenuItem(value: Color(0xFF0EA5E9), child: Text('Bleu')),
                  DropdownMenuItem(value: Color(0xFF10B981), child: Text('Vert')),
                  DropdownMenuItem(value: Color(0xFFEF4444), child: Text('Rouge')),
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
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nom requis.')));
        return;
      }
      final nextCategory = CategoryItem(
        id: category?.id ?? 0,
        name: name,
        type: type,
        color: color,
      );
      if (category == null) {
        await controller.createCategory(nextCategory);
      } else {
        await controller.updateCategory(nextCategory);
      }
    }
  }
}
