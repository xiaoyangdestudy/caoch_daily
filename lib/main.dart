import 'package:caoch_daily/app/app.dart';
import 'package:caoch_daily/app/bootstrap.dart';
import 'package:caoch_daily/shared/providers/preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await bootstrap(() async {
    final prefs = await SharedPreferences.getInstance();

    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const LifeCoachApp(),
    );
  });
}
