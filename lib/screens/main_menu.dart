import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../styles.dart';
import 'new_entry_screen.dart';
import 'reports_screen.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: AppStyles.lightTheme,
            darkTheme: AppStyles.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: Scaffold(
              appBar: AppBar(
                title: Text('PsychInsightPro', style: AppStyles.heading),
                actions: [
                  IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: AppStyles.buttonStyle,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewEntryScreen(),
                          ),
                        );
                      },
                      child: Text('New Entry'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: AppStyles.buttonStyle,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportsScreen(),
                          ),
                        );
                      },
                      child: Text('Reports'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
