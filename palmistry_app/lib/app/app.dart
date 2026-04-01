import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme.dart';

class PalmistryApp extends StatelessWidget {
  final bool onboardingCompleted;

  const PalmistryApp({super.key, this.onboardingCompleted = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Palmistry',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: buildRouter(onboardingCompleted: onboardingCompleted),
    );
  }
}
