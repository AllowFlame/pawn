import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final pawnProvider = Provider((_) => 'Welcome to the real world');

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final String value = useProvider(pawnProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('useProvider')),
        body: Center(
          child: Text(value),
        ),
      ),
    );
  }
}

