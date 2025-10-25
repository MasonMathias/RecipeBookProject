import 'package:flutter/material.dart';
import 'recipe_store.dart';

class GroceryPlannerScreen extends StatefulWidget {
  final List<({String id, String title})> recipes;

  const GroceryPlannerScreen({super.key, required this.recipes});

  static Route<dynamic> routeFromArgs(RouteSettings settings) {
    final args = settings.arguments as Map?;
    final raw = (args?['recipes'] as List?) ?? const [];
    final items = <({String id, String title})>[];
    for (final e in raw) {
      if (e is Map && e['id'] is String && e['title'] is String) {
        items.add((id: e['id'] as String, title: e['title'] as String));
      }
    }
    return MaterialPageRoute(
      builder: (_) => GroceryPlannerScreen(recipes: items),
      settings: settings,
    );
  }

  @override
  State<GroceryPlannerScreen> createState() => _GroceryPlannerScreenState();
}

class _GroceryPlannerScreenState extends State<GroceryPlannerScreen> {
  final Set<String> _selectedIds = {};
  final Map<String, bool> _checked = {};

  List<String> get _ingredients {
    final seen = <String>{};
    final out = <String>[];
    for (final id in _selectedIds) {
      final d = RecipeStore.I.getById(id);
      if (d == null) continue;
      for (final ing in d.ingredients) {
        final t = ing.trim();
        if (t.isEmpty) continue;
        if (seen.add(t)) out.add(t);
      }
    }

    for (final ing in out) {
      _checked.putIfAbsent(ing, () => false);
    }
    _checked.removeWhere((k, _) => !out.contains(k));
    return out;
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _setAll(bool value) {
    setState(() {
      for (final k in _ingredients) {
        _checked[k] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grocery Planner')),
      body: LayoutBuilder(
        builder: (context, c) {
          final isNarrow = c.maxWidth < 700;
          final left = _RecipeListPane(
            recipes: widget.recipes,
            selectedIds: _selectedIds,
            onToggle: _toggleSelect,
          );
          final right = _IngredientsPane(
            ingredients: _ingredients,
            checked: _checked,
            onToggle: (k, v) => setState(() => _checked[k] = v),
            onSelectAll: () => _setAll(true),
            onClearAll: () => _setAll(false),
          );
          if (isNarrow) {
            return Column(
              children: [
                Expanded(child: left),
                const Divider(height: 1),
                Expanded(child: right),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: left),
              const VerticalDivider(width: 1),
              Expanded(child: right),
            ],
          );
        },
      ),
    );
  }
}

class _RecipeListPane extends StatelessWidget {
  final List<({String id, String title})> recipes;
  final Set<String> selectedIds;
  final void Function(String id) onToggle;

  const _RecipeListPane({
    required this.recipes,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _PaneHeader('Recipes'),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const Divider(height: 8),
            itemBuilder: (context, i) {
              final r = recipes[i];
              final selected = selectedIds.contains(r.id);
              return ListTile(
                dense: true,
                title: Text(r.title),
                subtitle: Text('ID: ${r.id}'),
                trailing: OutlinedButton.icon(
                  onPressed: () => onToggle(r.id),
                  icon: Icon(selected ? Icons.remove_circle_outline : Icons.add_circle_outline),
                  label: Text(selected ? 'Remove' : 'Select'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _IngredientsPane extends StatelessWidget {
  final List<String> ingredients;
  final Map<String, bool> checked;
  final void Function(String key, bool value) onToggle;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;

  const _IngredientsPane({
    required this.ingredients,
    required this.checked,
    required this.onToggle,
    required this.onSelectAll,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _PaneHeader('Ingredients'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              OutlinedButton(onPressed: onSelectAll, child: const Text('Select all')),
              const SizedBox(width: 8),
              TextButton(onPressed: onClearAll, child: const Text('Clear')),
            ],
          ),
        ),
        Expanded(
          child: ingredients.isEmpty
              ? const Center(child: Text('Select recipes to see ingredients'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: ingredients.length,
                  itemBuilder: (context, i) {
                    final k = ingredients[i];
                    final v = checked[k] ?? false;
                    return CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: v,
                      onChanged: (nv) => onToggle(k, nv ?? false),
                      title: Text(k),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PaneHeader extends StatelessWidget {
  final String text;
  const _PaneHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: const Border(bottom: BorderSide(width: 1, color: Color(0x22000000))),
      ),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
