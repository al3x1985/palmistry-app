import 'package:flutter/material.dart';

class EditorScreen extends StatelessWidget {
  final int scanId;

  const EditorScreen({super.key, required this.scanId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактор линий')),
      body: Center(
        child: Text(
          'Редактор #$scanId',
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }
}
