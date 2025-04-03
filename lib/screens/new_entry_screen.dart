import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/notification_service.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  TextEditingController entryController = TextEditingController();
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    try {
      _database = await openDatabase(
        join(await getDatabasesPath(), 'psychinsightpro.db'),
        version: 1,
      );
      NotificationService.showSuccessDialog(
        context as BuildContext,
        'Database Loaded Successfully',
      );
    } catch (e) {
      NotificationService.showErrorDialog(
        context as BuildContext,
        'Failed to load database.',
      );
    }
  }

  Future<void> _saveEntry(String entry) async {
    if (entry.isEmpty) {
      NotificationService.showWarningDialog(
        context as BuildContext,
        'Entry cannot be empty.',
      );
      return;
    }

    try {
      await _database!.insert('entries', {
        'content': entry,
        'timestamp': DateTime.now().toIso8601String(),
      });
      NotificationService.showSuccessDialog(
        context as BuildContext,
        'Entry saved successfully.',
      );
      entryController.clear();
    } catch (e) {
      NotificationService.showErrorDialog(
        context as BuildContext,
        'Failed to save entry.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: entryController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: 'Enter your journal entry',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveEntry(entryController.text),
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
