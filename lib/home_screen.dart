import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goToDetails(BuildContext context, String id, String title) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: {'id': id, 'title': title},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: () => _goToDetails(context, '1', 'Recipe 1'),
                child: const Text('1'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _goToDetails(context, '2', 'Recipe 2'),
                child: const Text('2'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _goToDetails(context, '3', 'Recipe 3'),
                child: const Text('3'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _goToDetails(context, '4', 'Recipe 4'),
                child: const Text('4'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _goToDetails(context, '5', 'Recipe 5'),
                child: const Text('5'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
