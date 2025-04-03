import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styles.dart';
import '../utils/notification_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isDataLoaded = true;
      });
    });
  }

  void _simulateError() {
    NotificationService.showErrorDialog(
      context,
      'Failed to load data. Please try again.',
    );
  }

  void _simulateSuccess() {
    NotificationService.showSuccessDialog(context, 'Data loaded successfully!');
  }

  void _simulateWarning() {
    NotificationService.showWarningDialog(
      context,
      'Incomplete data. Some entries may be missing.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports', style: AppStyles.heading)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _simulateError,
              child: Text('Simulate Error'),
            ),
            ElevatedButton(
              onPressed: _simulateSuccess,
              child: Text('Simulate Success'),
            ),
            ElevatedButton(
              onPressed: _simulateWarning,
              child: Text('Simulate Warning'),
            ),
            isDataLoaded
                ? Text(
                  'Data Loaded',
                  style: AppStyles.subheading,
                ).animate().fadeIn(duration: 1000.ms)
                : CircularProgressIndicator().animate().scale(duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
