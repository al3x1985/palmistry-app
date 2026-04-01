import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class PalmistryApp extends StatelessWidget {
  const PalmistryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Palmistry',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
