import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'core/services/rule_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init — gracefully handles unconfigured projects
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured — analytics will be silently disabled.
  }

  setupDependencies();

  // Pre-load rule engine from assets
  final ruleEngine = getIt<RuleEngine>();
  await ruleEngine.loadRules(rootBundle);

  // Check onboarding flag
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(PalmistryApp(onboardingCompleted: onboardingDone));
}
