import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'details_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (_) => DetailsScreen(id: args['id']!, title: args['title']!),
          );
        }
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      },
    );
  }
}