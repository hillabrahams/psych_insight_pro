import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JournalAnalyzerScreen extends StatefulWidget {
  const JournalAnalyzerScreen({super.key});

  @override
  _JournalAnalyzerScreenState createState() => _JournalAnalyzerScreenState();
}

class _JournalAnalyzerScreenState extends State<JournalAnalyzerScreen> {
  final TextEditingController _controller = TextEditingController();
  String? score;
  String? reasoning;
  String? confidence;

  void _submitText() async {
    final result = await analyzeEntry(_controller.text);
    if (result != null) {
      setState(() {
        score = result['score'].toString();
        reasoning = result['reasoning'];
        confidence = result['confidence'].toString();
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
      "http://localhost:8000/auto_label",
    ); // On Android emulator, use http://10.0.2.2:8000/auto_label instead of localhost.
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"text": entryText}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("API Error: ${response.statusCode} ${response.body}");
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
            ElevatedButton(onPressed: _submitText, child: Text("Analyze")),
            if (score != null) ...[
              SizedBox(height: 20),
              Text("Score: $score", style: TextStyle(fontSize: 18)),
              Text("Reasoning: $reasoning", style: TextStyle(fontSize: 16)),
              Text("Confidence: $confidence", style: TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}
