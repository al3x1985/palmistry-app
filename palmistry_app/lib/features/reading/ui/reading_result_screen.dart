import 'package:flutter/material.dart';

class ReadingResultScreen extends StatelessWidget {
  final int scanId;

  const ReadingResultScreen({super.key, required this.scanId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Результат')),
      body: Center(
        child: Text(
          'Результат чтения #$scanId',
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }
}
