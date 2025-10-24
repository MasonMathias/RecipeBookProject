
import 'package:flutter/material.dart';
import 'details_screen.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _nutritionCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ingredientsCtrl.dispose();
    _nutritionCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  List<String> _splitLines(String s) =>
      s.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;

    final details = RecipeDetails(
      nutritionFacts: _splitLines(_nutritionCtrl.text),
      ingredients: _splitLines(_ingredientsCtrl.text),
      instructions: _splitLines(_instructionsCtrl.text),
    );

    final name = _nameCtrl.text.trim();
    Navigator.pop(context, {'details': details, 'title': name});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(
                'Name',
                child: TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Name of recipe',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 1,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                'Ingredients',
                child: TextFormField(
                  controller: _ingredientsCtrl,
                  decoration: const InputDecoration(
                    hintText: 'One ingredient per line',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  validator: (v) =>
                      (v == null || _splitLines(v).isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                'Nutrition Facts',
                child: TextFormField(
                  controller: _nutritionCtrl,
                  decoration: const InputDecoration(
                    hintText:
                        'One fact per line (e.g. "2 servings", "350 kcal")',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  validator: (v) =>
                      (v == null || _splitLines(v).isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                'Instructions',
                child: TextFormField(
                  controller: _instructionsCtrl,
                  decoration: const InputDecoration(
                    hintText: 'One step per line',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  validator: (v) =>
                      (v == null || _splitLines(v).isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _confirm,
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section(this.title, {required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
