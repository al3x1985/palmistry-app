import 'package:get_it/get_it.dart';

import '../core/services/rule_engine.dart';
import '../data/local/database.dart';
import '../data/remote/claude_api_client.dart';
import '../data/remote/cv_api_client.dart';

final GetIt getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<RuleEngine>(() => RuleEngine());
  getIt.registerLazySingleton<CvApiClient>(() => CvApiClient());
  getIt.registerLazySingleton<ClaudeApiClient>(() => ClaudeApiClient());
}
