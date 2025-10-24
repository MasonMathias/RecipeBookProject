import 'details_screen.dart';
import 'dart:collection';

class RecipeStore {
  RecipeStore._(this._defaults);
  static RecipeStore? _inst;

  final Map<String, RecipeDetails> _defaults;
  final Map<String, RecipeDetails> _user = {};
  final Map<String, String> _userTitles = {};
  int _nextId = 6;

  static RecipeStore init(Map<String, RecipeDetails> defaults) {
    _inst ??= RecipeStore._(defaults);
    return _inst!;
  }

  static RecipeStore get I => _inst!;

  RecipeDetails? getById(String id) => _user[id] ?? _defaults[id];

  ({String id, String title}) add(RecipeDetails details, {required String title}) {
    final id = (_nextId++).toString();
    _userTitles[id] = title;
    _user[id] = details;
    return (id: id, title: title);
  }

  UnmodifiableListView<({String id, String title})> allTitles() {
    final items = <({String id, String title})>[];
    for (final id in _defaults.keys) {
      items.add((id: id, title: 'Recipe $id'));
    }
    for (final id in _user.keys) {
      items.add((id: id, title: 'Recipe $id'));
    }
    return UnmodifiableListView(items);
  }
}
