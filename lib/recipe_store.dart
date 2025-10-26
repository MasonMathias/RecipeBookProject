import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'details_screen.dart';

class RecipeMeta {
  String id;
  String title;
  bool favorite;
  Set<String> tags;
  RecipeMeta({
    required this.id,
    required this.title,
    this.favorite = false,
    Set<String>? tags,
  }) : tags = tags ?? {};

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'favorite': favorite,
    'tags': tags.toList(),
  };
  
  factory RecipeMeta.fromJson(Map<String, dynamic> m) => RecipeMeta(
    id: m['id'] as String,
    title: m['title'] as String,
    favorite: m['favorite'] as bool? ?? false,
    tags: {...((m['tags'] as List?)?.cast<String>() ?? const <String>[])},
  );
}

class GroceryState {
  final Set<String> selectedIds;
  final Map<String, bool> checked;
  GroceryState({Set<String>? selectedIds, Map<String, bool>? checked})
    : selectedIds = selectedIds ?? {},
      checked = checked ?? {};
  Map<String, dynamic> toJson() => {
    'selectedIds': selectedIds.toList(),
    'checked': checked,
  };
  factory GroceryState.fromJson(Map<String, dynamic> m) => GroceryState(
    selectedIds: {
      ...((m['selectedIds'] as List?)?.cast<String>() ?? const <String>[]),
    },
    checked: Map<String, bool>.from(m['checked'] as Map? ?? const {}),
  );
}

class RecipeStore {
  RecipeStore._(this._defaults) {
    _metas = [
      for (final id in _defaults.keys) RecipeMeta(id: id, title: 'Recipe $id'),
    ];
  }
  static RecipeStore? _inst;
  static RecipeStore init(Map<String, RecipeDetails> defaults) {
    _inst ??= RecipeStore._(defaults);
    return _inst!;
  }

  static RecipeStore get I => _inst!;

  final Map<String, RecipeDetails> _defaults;

  final Map<String, RecipeDetails> _user = {};
  late List<RecipeMeta> _metas;
  int _nextId = 6;

  GroceryState _grocery = GroceryState();

  List<RecipeMeta> get metas => List.unmodifiable(_metas);
  RecipeDetails? getById(String id) => _user[id] ?? _defaults[id];
  GroceryState get grocery => _grocery;

  ({String id, String title}) add(
    RecipeDetails details, {
    required String title,
  }) {
    final id = (_nextId++).toString();
    _user[id] = details;
    _metas.add(RecipeMeta(id: id, title: title));
    return (id: id, title: title);
  }

  void remove(String id) {
    _user.remove(id);
    _metas.removeWhere((m) => m.id == id);
  }

  void toggleFavorite(String id) {
    final i = _metas.indexWhere((m) => m.id == id);
    if (i >= 0) _metas[i].favorite = !_metas[i].favorite;
  }

  void setTags(String id, Set<String> tags) {
    final i = _metas.indexWhere((m) => m.id == id);
    if (i >= 0) _metas[i].tags = {...tags};
  }

  static const _kMetas = 'recipes_metas_v1';
  static const _kUserDetails = 'recipes_user_details_v1';
  static const _kNextId = 'recipes_next_id_v1';
  static const _kGrocery = 'grocery_state_v1';

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();

    final metasRaw = sp.getString(_kMetas);
    if (metasRaw != null) {
      final list = (jsonDecode(metasRaw) as List)
          .map((e) => RecipeMeta.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      _metas = list;
    }

    final detailsRaw = sp.getString(_kUserDetails);
    if (detailsRaw != null) {
      final map = Map<String, dynamic>.from(jsonDecode(detailsRaw) as Map);
      _user
        ..clear()
        ..addAll(
          map.map((k, v) {
            final m = Map<String, dynamic>.from(v as Map);
            return MapEntry(
              k,
              RecipeDetails(
                nutritionFacts: (m['nutritionFacts'] as List).cast<String>(),
                ingredients: (m['ingredients'] as List).cast<String>(),
                instructions: (m['instructions'] as List).cast<String>(),
              ),
            );
          }),
        );
    }

    _nextId = sp.getInt(_kNextId) ?? _nextId;

    final gRaw = sp.getString(_kGrocery);
    if (gRaw != null) {
      _grocery = GroceryState.fromJson(
        Map<String, dynamic>.from(jsonDecode(gRaw) as Map),
      );
    }
  }

  Future<void> save() async {
    final sp = await SharedPreferences.getInstance();

    await sp.setString(
      _kMetas,
      jsonEncode(_metas.map((m) => m.toJson()).toList()),
    );

    await sp.setString(
      _kUserDetails,
      jsonEncode(
        _user.map(
          (k, d) => MapEntry(k, {
            'nutritionFacts': d.nutritionFacts,
            'ingredients': d.ingredients,
            'instructions': d.instructions,
          }),
        ),
      ),
    );

    await sp.setInt(_kNextId, _nextId);

    await sp.setString(_kGrocery, jsonEncode(_grocery.toJson()));
  }

  void setGrocerySelected(Set<String> ids) {
    _grocery = GroceryState(
      selectedIds: ids,
      checked: Map.of(_grocery.checked),
    );
  }

  void setGroceryChecked(Map<String, bool> checked) {
    _grocery = GroceryState(
      selectedIds: Set.of(_grocery.selectedIds),
      checked: checked,
    );
  }
}
