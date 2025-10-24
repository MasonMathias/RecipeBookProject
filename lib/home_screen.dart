import 'package:flutter/material.dart';
import 'details_screen.dart';
import 'recipe_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Dietary tags
enum DietTag { vegetarian, vegan, glutenFree, dairyFree, nutFree }
extension on DietTag {
  String get label {
    switch (this) {
      case DietTag.vegetarian: return 'Vegetarian';
      case DietTag.vegan: return 'Vegan';
      case DietTag.glutenFree: return 'Gluten-free';
      case DietTag.dairyFree: return 'Dairy-free';
      case DietTag.nutFree: return 'Nut-free';
    }
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final List<_RecipeItem> _recipes = [
    _RecipeItem(id: '1', title: 'Recipe 1', tags: {DietTag.vegetarian}),
    _RecipeItem(id: '2', title: 'Recipe 2', tags: {DietTag.vegan, DietTag.glutenFree}),
    _RecipeItem(id: '3', title: 'Recipe 3', tags: {DietTag.glutenFree, DietTag.dairyFree}),
    _RecipeItem(id: '4', title: 'Recipe 4', tags: {DietTag.nutFree}),
    _RecipeItem(id: '5', title: 'Recipe 5', tags: {DietTag.vegetarian, DietTag.nutFree}),
  ];

  // Filter state
  final Set<DietTag> _selectedTags = {};
  bool _favoritesOnly = false;

  // ---------- (4) ADD THIS HELPER INSIDE _HomeScreenState ----------
  String get _filterLabel {
    final tags = _selectedTags.map((t) => t.label).toList()..sort();
    final parts = <String>[];
    if (_favoritesOnly) parts.add('Favorites');
    if (tags.isNotEmpty) parts.addAll(tags);
    return parts.isEmpty ? 'Filters' : 'Filters: ${parts.join(', ')}';
  }
  // ---------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    RecipeStore.init(kRecipeDetailsById);
  }

  List<_RecipeItem> get _visible {
    return _recipes.where((r) {
      final favOk = !_favoritesOnly || r.favorite;
      final tagsOk = _selectedTags.isEmpty || _selectedTags.every(r.tags.contains);
      return favOk && tagsOk;
    }).toList();
  }

  void _goToDetails(BuildContext context, String id, String title) {
    Navigator.pushNamed(context, '/details', arguments: {'id': id, 'title': title});
  }

  Future<void> _goToAdd() async {
    final result = await Navigator.pushNamed(context, '/add');
    if (!mounted) return;
    if (result is Map && result['details'] is RecipeDetails && result['title'] is String) {
      final details = result['details'] as RecipeDetails;
      final title = (result['title'] as String).trim();
      final added = RecipeStore.I.add(details, title: title);
      setState(() => _recipes.add(_RecipeItem(id: added.id, title: added.title)));
      _goToDetails(context, added.id, added.title);
    }
  }

  void _removeAt(int indexInVisible) {
    final item = _visible[indexInVisible];
    final realIndex = _recipes.indexWhere((r) => r.id == item.id);
    if (realIndex >= 0) setState(() => _recipes.removeAt(realIndex));
  }

  void _toggleFavorite(int indexInVisible) {
    final item = _visible[indexInVisible];
    final realIndex = _recipes.indexWhere((r) => r.id == item.id);
    if (realIndex >= 0) {
      setState(() {
        _recipes[realIndex] =
            _recipes[realIndex].copyWith(favorite: !_recipes[realIndex].favorite);
      });
    }
  }

  void _editTags(_RecipeItem item) async {
    final current = Set<DietTag>.from(item.tags);
    final updated = await showModalBottomSheet<Set<DietTag>>(
      context: context,
      builder: (ctx) {
        final temp = Set<DietTag>.from(current);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Dietary tags')),
              const Divider(height: 1),
              ...DietTag.values.map((t) => StatefulBuilder(
                    builder: (ctx, setSB) => CheckboxListTile(
                      value: temp.contains(t),
                      onChanged: (v) => setSB(() {
                        if (v == true) { temp.add(t); } else { temp.remove(t); }
                      }),
                      title: Text(t.label),
                    ),
                  )),
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 8),
                  TextButton(onPressed: () => Navigator.pop(ctx, current), child: const Text('Cancel')),
                  const Spacer(),
                  FilledButton(onPressed: () => Navigator.pop(ctx, temp), child: const Text('Done')),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (updated != null) {
      final idx = _recipes.indexWhere((r) => r.id == item.id);
      if (idx >= 0) setState(() => _recipes[idx] = _recipes[idx].copyWith(tags: updated));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---------- (3) REPLACE YOUR OLD FILTER UI WITH THIS DROPDOWN ----------
            SizedBox(
              width: 360,
              child: Align(
                alignment: Alignment.centerLeft,
                child: PopupMenuButton<int>(
                  onSelected: (v) {
                    setState(() {
                      if (v == -1) {
                        _favoritesOnly = !_favoritesOnly;
                      } else {
                        final tag = DietTag.values[v];
                        if (_selectedTags.contains(tag)) {
                          _selectedTags.remove(tag);
                        } else {
                          _selectedTags.add(tag);
                        }
                      }
                    });
                  },
                  itemBuilder: (ctx) => <PopupMenuEntry<int>>[
                    PopupMenuItem<int>(
                      value: -1,
                      child: Row(
                        children: [
                          Checkbox(value: _favoritesOnly, onChanged: null),
                          const SizedBox(width: 8),
                          const Text('Favorites'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    for (var i = 0; i < DietTag.values.length; i++)
                      PopupMenuItem<int>(
                        value: i,
                        child: Row(
                          children: [
                            Checkbox(value: _selectedTags.contains(DietTag.values[i]), onChanged: null),
                            const SizedBox(width: 8),
                            Text(DietTag.values[i].label),
                          ],
                        ),
                      ),
                  ],
                  child: OutlinedButton.icon(
                    onPressed: null, // handled by PopupMenuButton
                    icon: const Icon(Icons.filter_list),
                    label: Text(_filterLabel),
                  ),
                ),
              ),
            ),
            // ----------------------------------------------------------------------

            const SizedBox(height: 8),

            Container(
              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 380),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(blurRadius: 8, color: Color(0x22000000))],
              ),
              child: Scrollbar(
                child: ListView.separated(
                  itemCount: _visible.length,
                  separatorBuilder: (_, __) => const Divider(height: 2),
                  itemBuilder: (context, i) {
                    final r = _visible[i];
                    return ListTile(
                      dense: true,
                      title: Text(r.title),
                      subtitle: r.tags.isEmpty ? null : Text(r.tags.map((t) => t.label).join(' • ')),
                      onTap: () => _goToDetails(context, r.id, r.title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: r.favorite ? 'Unfavorite' : 'Favorite',
                            child: IconButton(
                              onPressed: () => _toggleFavorite(i),
                              icon: Icon(r.favorite ? Icons.star : Icons.star_border),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit dietary tags',
                            onPressed: () => _editTags(r),
                            icon: const Icon(Icons.label_outline),
                          ),
                          Tooltip(
                            message: 'Delete',
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                              onPressed: () => _removeAt(i),
                              child: const Icon(Icons.remove),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _goToAdd, child: const Icon(Icons.add)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeItem {
  final String id;
  final String title;
  final bool favorite;
  final Set<DietTag> tags;

  _RecipeItem({
    required this.id,
    required this.title,
    this.favorite = false,
    Set<DietTag>? tags,
  }) : tags = tags ?? {};

  _RecipeItem copyWith({
    String? id,
    String? title,
    bool? favorite,
    Set<DietTag>? tags,
  }) =>
      _RecipeItem(
        id: id ?? this.id,
        title: title ?? this.title,
        favorite: favorite ?? this.favorite,
        tags: tags ?? this.tags,
      );
}
