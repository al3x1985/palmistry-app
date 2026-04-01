import 'package:flutter/material.dart';

class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Справочник', style: TextStyle(color: Colors.white70, fontSize: 18)),
      ),
    );
  }
}
