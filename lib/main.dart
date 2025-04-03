import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_menu.dart';
import 'screens/onboarding_screen.dart';
import 'utils/theme_provider.dart' as utils;
import 'styles.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => utils.ThemeProvider(),
      child: PsychInsightPro(),
    ),
  );
}

class PsychInsightPro extends StatelessWidget {
  const PsychInsightPro({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'PsychInsightPro',
      theme: AppStyles.lightTheme,
      darkTheme: AppStyles.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
