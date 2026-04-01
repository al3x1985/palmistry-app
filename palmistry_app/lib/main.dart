import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'core/services/rule_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupDependencies();

  // Pre-load rule engine from assets
  final ruleEngine = getIt<RuleEngine>();
  await ruleEngine.loadRules(rootBundle);

  runApp(const PalmistryApp());
}
