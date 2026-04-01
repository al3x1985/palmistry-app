import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'app/router.dart';
import 'core/services/rule_engine.dart';
import 'features/onboarding/ui/onboarding_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init — gracefully handles unconfigured projects (e.g. CI)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase not configured — analytics will be silently disabled.
  }

  setupDependencies();

  // Pre-load rule engine from assets
  final ruleEngine = getIt<RuleEngine>();
  await ruleEngine.loadRules(rootBundle);

  // Check onboarding flag
  final onboardingDone = await isOnboardingDone();
  if (!onboardingDone) {
    appRouter.go('/onboarding');
  }

  runApp(const PalmistryApp());
}
