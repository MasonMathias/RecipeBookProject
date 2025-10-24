import 'package:flutter/material.dart';

class RecipeDetails {
  final List<String> nutritionFacts;
  final List<String> ingredients;
  final List<String> instructions;

  const RecipeDetails({
    required this.nutritionFacts,
    required this.ingredients,
    required this.instructions,
  });
}

const Map<String, RecipeDetails> kRecipeDetailsById = {
  '1': RecipeDetails(
    nutritionFacts: ['1 serving', '100 kcal', '25g carbs', '6g protein'],
    ingredients: ['Ingredient 1', 'Ingredient 2', 'Ingredient 3', 'Ingredient 4', 'Ingredient 5'],
    instructions: [
      'Instruction 1',
      'Instruction 2',
      'Instruction 3',
    ],
  ),
  '2': RecipeDetails(
    nutritionFacts: ['2 servings', '100 kcal', '25g carbs', '6g protein'],
    ingredients: ['Ingredient 1', 'Ingredient 2', 'Ingredient 3', 'Ingredient 4', 'Ingredient 5'],
    instructions: [
      'Instruction 1',
      'Instruction 2',
      'Instruction 3',
    ],
  ),
  '3': RecipeDetails(
    nutritionFacts: ['3 servings', '100 kcal', '25g carbs', '6g protein'],
    ingredients: ['Ingredient 1', 'Ingredient 2', 'Ingredient 3', 'Ingredient 4', 'Ingredient 5'],
    instructions: [
      'Instruction 1',
      'Instruction 2',
      'Instruction 3',
    ],
  ),
  '4': RecipeDetails(
    nutritionFacts: ['4 servings', '100 kcal', '25g carbs', '6g protein'],
    ingredients: ['Ingredient 1', 'Ingredient 2', 'Ingredient 3', 'Ingredient 4', 'Ingredient 5'],
    instructions: [
      'Instruction 1',
      'Instruction 2',
      'Instruction 3',
    ],
  ),
  '5': RecipeDetails(
    nutritionFacts: ['5 servings', '100 kcal', '25g carbs', '6g protein'],
    ingredients: ['Ingredient 1', 'Ingredient 2', 'Ingredient 3', 'Ingredient 4', 'Ingredient 5'],
    instructions: [
      'Instruction 1',
      'Instruction 2',
      'Instruction 3',
    ],
  ),
};

class DetailsScreen extends StatelessWidget {
  final String id;
  final String title;
  const DetailsScreen({super.key, required this.id, required this.title});

  @override
  Widget build(BuildContext context) {
    final data = kRecipeDetailsById[id];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: data == null
          ? const Center(child: Text('No details found for this item.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader('Nutrition Facts'),
                ..._bullets(data.nutritionFacts),
                const SizedBox(height: 16),
                _SectionHeader('Ingredients'),
                ..._bullets(data.ingredients),
                const SizedBox(height: 16),
                _SectionHeader('Instructions'),
                ..._numbered(data.instructions),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

List<Widget> _bullets(List<String> items) => items
.map((t) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(t)),
        ],
      ),
    ))
.toList();

List<Widget> _numbered(List<String> items) => [
  for (int i = 0; i < items.length; i++)
    Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${i + 1}. '),
          Expanded(child: Text(items[i])),
        ],
      ),
    )
];
