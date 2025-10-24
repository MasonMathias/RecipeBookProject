import 'package:flutter/material.dart';
import 'details_screen.dart';
import 'recipe_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<_RecipeItem> _recipes = List.generate(
    5,
    (i) => _RecipeItem(id: '${i + 1}', title: 'Recipe ${i + 1}'),
  );

  @override
  void initState() {
    super.initState();
    RecipeStore.init(kRecipeDetailsById);
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
      setState(() {
        _recipes.add(_RecipeItem(id: added.id, title: added.title));
      });
      _goToDetails(context, added.id, added.title);
    }
  }

  void _removeAt(int index) {
    setState(() => _recipes.removeAt(index));
  }

  void _toggleFavorite(int index) {
    setState(() => _recipes[index] = _recipes[index].copyWith(favorite: !_recipes[index].favorite));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  itemCount: _recipes.length,
                  separatorBuilder: (_, __) => const Divider(height: 2),
                  itemBuilder: (context, i) {
                    final r = _recipes[i];
                    return ListTile(
                      dense: true,
                      title: Text(r.title),
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
                          const SizedBox(width: 4),
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
  _RecipeItem({required this.id, required this.title, this.favorite = false});
  _RecipeItem copyWith({String? id, String? title, bool? favorite}) => _RecipeItem(
        id: id ?? this.id,
        title: title ?? this.title,
        favorite: favorite ?? this.favorite,
      );
}
