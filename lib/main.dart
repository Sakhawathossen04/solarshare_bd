import 'package:flutter/material.dart';
import 'core/l10n/app_locale.dart';
import 'core/theme/app_theme.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SolarShareApp());
}

class SolarShareApp extends StatelessWidget {
  const SolarShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Bengali + Latin text support via bundled Hind Siliguri font.
    return ValueListenableBuilder<String>(
      valueListenable: AppLocale.current,
      builder: (context, _, __) => MaterialApp(
        title: 'SolarShare BD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const OnboardingScreen(),
      ),
    );
  }
}
