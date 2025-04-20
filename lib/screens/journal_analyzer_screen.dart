import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/journal_database.dart';
import '../models/journal_entry.dart';

class JournalAnalyzerScreen extends StatefulWidget {
  const JournalAnalyzerScreen({super.key});

  @override
  _JournalAnalyzerScreenState createState() => _JournalAnalyzerScreenState();
}

bool isNeglectFuzzy(String text, {int threshold = 60}) {
  final lower = text.toLowerCase();
  final List<String> neglectPhrases = [
    "no one noticed",
    "nobody cared",
    "ignored",
    "forgotten",
    "no one asked",
    "you didn’t ask",
    "i was upset but",
    "you didn’t respond",
    "no one called",
    "i felt invisible",
    "i was left out",
    "you didn’t say goodnight",
    "you didn’t listen",
    "you didn’t see me",
    "i don’t think you noticed",
    "they didn’t care",
    "nobody showed up",
    "i didn’t matter",
  ];

  for (var phrase in neglectPhrases) {
    if (kDebugMode) {
      print("Comparing: $phrase with $lower");
      print("Ratio: \${ratio(phrase, lower)}");
    }
    if (ratio(phrase, lower) > threshold) return true;
  }

  return false;
}

class _JournalAnalyzerScreenState extends State<JournalAnalyzerScreen> {
  final TextEditingController _controller = TextEditingController();
  String? score;
  String? text;
  String? reasoning;
  String? confidence;
  int? sentimentScore;
  bool? isNeglect = false;

  void _submitText() async {
    final entryInput = _controller.text;
    final result = await analyzeEntry(entryInput);

    if (result != null) {
      final detectedNeglect = isNeglectFuzzy(entryInput);
      final newEntry = JournalEntry(
        text: entryInput,
        score: result['score'],
        reasoning: result['reasoning'],
        confidence: result['confidence'].toString(),
        isNeglect: detectedNeglect,
      );

      await JournalDatabase.instance.insertEntry(newEntry);

      setState(() {
        score = result['score'].toString();
        text = result['text'];
        sentimentScore = result['score'];
        reasoning = result['reasoning'];
        confidence = result['confidence'].toString();
        isNeglect = detectedNeglect;
      });
    } else {
      setState(() {
        score = "Error";
        reasoning = "Could not get response from API.";
        confidence = "";
      });
    }
  }

  Future<Map<String, dynamic>?> analyzeEntry(String entryText) async {
    final url = Uri.parse("http://localhost:8000/auto_label");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"text": entryText}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analyze Journal Entry")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: "Enter your journal entry",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitText,
              child: const Text("Analyze and Save"),
            ),
            if (score != null) ...[
              const SizedBox(height: 20),
              if (sentimentScore! >= 1) ...[
                Image.asset('assets/images/care1.png'),
              ],
              if (sentimentScore! <= -1) ...[
                Image.asset('assets/images/abuse1.png'),
              ],
              if (isNeglect == true) ...[
                Image.asset('assets/images/neglect1.png'),
              ],
              Text("Score: $score", style: const TextStyle(fontSize: 18)),
              Text(
                "Reasoning: $reasoning",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "Confidence: $confidence",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
