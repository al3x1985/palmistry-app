import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('История', style: TextStyle(color: Colors.white70, fontSize: 18)),
      ),
    );
  }
}
