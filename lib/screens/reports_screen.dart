import 'package:flutter/material.dart';
import '../styles.dart';
import '../utils/notification_service.dart';
import '../utils/db_helper.dart';
import '../models/journal_entry.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<JournalEntry> _entries = [];
  final Set<int> _selectedEntryIds = {};
  final DBHelper _dbHelper = DBHelper();
  bool _loading = false;

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _toDateTimeString(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? (_startDate ?? now) : (_endDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _loadEntries() async {
    if (_startDate == null || _endDate == null) {
      NotificationService.showWarningDialog(
        context,
        'Please select both start and end dates.',
      );
      return;
    }

    setState(() {
      _loading = true;
      _entries = [];
    });

    final start = _toDateTimeString(_startDate!);
    final end = _toDateTimeString(
      _endDate!
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1)),
    );

    try {
      final results = await _dbHelper.getEntriesBetweenDates(start, end);
      setState(() {
        _entries = results;
      });
    } catch (e) {
      NotificationService.showErrorDialog(context, 'Failed to load entries.');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deleteEntry(int id) async {
    final result = await _dbHelper.deleteEntry(id);
    if (result > 0) {
      setState(() {
        _entries.removeWhere((e) => e.id == id);
        _selectedEntryIds.remove(id);
      });
    } else {
      NotificationService.showErrorDialog(context, 'Delete failed.');
    }
  }

  Widget _buildDataTable() {
    if (_entries.isEmpty) {
      return const Text('No data found for selected range.');
    }

    return DataTable(
      dataRowMinHeight: 60,
      dataRowMaxHeight: 300,
      columns: const [
        DataColumn(label: Text('Select')),
        DataColumn(label: Text('Text')),
        DataColumn(label: Text('Score')),
        DataColumn(label: Text('Reasoning')),
        DataColumn(label: Text('Confidence')),
        DataColumn(label: Text('Neglect')),
        DataColumn(label: Text('Actions')),
      ],
      rows:
          _entries.map((entry) {
            return DataRow(
              selected: _selectedEntryIds.contains(entry.id),
              cells: [
                DataCell(
                  Checkbox(
                    value: _selectedEntryIds.contains(entry.id),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedEntryIds.add(entry.id!);
                        } else {
                          _selectedEntryIds.remove(entry.id);
                        }
                      });
                    },
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 200,
                    ),
                    child: Text(
                      entry.text,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                DataCell(Text(entry.score.toString())),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 200,
                    ),
                    child: Text(
                      entry.reasoning,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                DataCell(Text(entry.confidence)),
                DataCell(Text(entry.isNeglect ? 'Yes' : 'No')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          NotificationService.showInfoDialog(
                            context,
                            'Info',
                            'Edit not implemented yet.',
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteEntry(entry.id!),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickDate(isStart: true),
                    child: Text('Start: ${_formatDate(_startDate)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickDate(isStart: false),
                    child: Text('End: ${_formatDate(_endDate)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEntries,
              child: const Text('Load Report'),
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _buildDataTable(),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
