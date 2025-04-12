// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../styles.dart';
import '../utils/db_helper.dart';
import '../utils/notification_service.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  TextEditingController entryController = TextEditingController();
  final DBHelper dbHelper = DBHelper();

  Future<void> _saveEntry(BuildContext context) async {
    String content = entryController.text;

    if (content.isEmpty) {
      NotificationService.showErrorDialog(context, 'Entry cannot be empty.');
      return;
    }

    Map<String, dynamic> entryData = {
      'content': content,
      'score':
          5.0, // Example score - Replace this with your sentiment analysis score
      'timestamp': DateTime.now().toIso8601String(),
    };

    int result = await dbHelper.insertEntry(entryData);

    if (result == -1) {
      NotificationService.showErrorDialog(context, 'Failed to save entry.');
    } else {
      NotificationService.showSuccessDialog(
        context,
        'Entry saved successfully.',
      );
      entryController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Entry', style: AppStyles.heading)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: entryController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: 'Enter your journal entry',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: AppStyles.buttonStyle,
              onPressed: () => _saveEntry(context),
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
