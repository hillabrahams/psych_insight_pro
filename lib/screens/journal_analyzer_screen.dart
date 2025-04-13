import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JournalAnalyzerScreen extends StatefulWidget {
  const JournalAnalyzerScreen({super.key});

  @override
  _JournalAnalyzerScreenState createState() => _JournalAnalyzerScreenState();
}

bool isNeglectFuzzy(String text, {int threshold = 85}) {
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
    if (ratio(phrase, lower) > threshold) return true;
  }

  return false;
}

class _JournalAnalyzerScreenState extends State<JournalAnalyzerScreen> {
  final TextEditingController _controller = TextEditingController();
  String? score;
  String? reasoning;
  String? confidence;
  int? sentimentScore;
  bool? isNeglect = true;
  void _submitText() async {
    final result = await analyzeEntry(_controller.text);
    if (result != null) {
      setState(() {
        score = result['score'].toString();
        sentimentScore = result['score'];
        reasoning = result['reasoning'];
        confidence = result['confidence'].toString();
        if (isNeglectFuzzy(_controller.text)) {
          isNeglect = true;
          if (kDebugMode) {
            print("Neglect detected: $isNeglect");
          } else {
            isNeglect = false;
          }
        }
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
    final url = Uri.parse(
      "http://10.0.2.2:8000/auto_label",
    ); // On Android emulator, use http://10.0.2.2:8000/auto_label instead of localhost.
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"text": entryText}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      //print("API Error: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Analyze Journal Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Enter your journal entry",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitText,
              child: Text("Analyze and Save"),
            ),

            if (score != null) ...[
              SizedBox(height: 20),
              if (sentimentScore! >= 1) ...[
                Image.asset('assets/images/care1.png'),
              ],
              if (sentimentScore! <= -1) ...[
                Image.asset('assets/images/abuse1.png'),
              ],
              if (isNeglect == true) ...[
                Image.asset('assets/images/neglect1.png'),
              ],
              Text("Score: $score, $isNeglect", style: TextStyle(fontSize: 18)),
              Text("Reasoning: $reasoning", style: TextStyle(fontSize: 16)),
              Text("Confidence: $confidence", style: TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}
