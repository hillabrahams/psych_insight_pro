// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../utils/journal_database.dart';
import '../models/journal_entry.dart';

class JournalAnalyzerScreen extends StatefulWidget {
  const JournalAnalyzerScreen({super.key});

  @override
  _JournalAnalyzerScreenState createState() => _JournalAnalyzerScreenState();
}

// bool isNeglectFuzzy(String text, {int threshold = 20}) {
//   final lower = text.toLowerCase();
//   final List<String> neglectPhrases = [
//     "no one noticed",
//     "nobody cared",
//     "ignored",
//     "forgotten",
//     "no one asked",
//     "you didn’t ask",
//     "i was upset but",
//     "you didn’t respond",
//     "no one called",
//     "i felt invisible",
//     "i was left out",
//     "you didn’t say goodnight",
//     "you didn’t listen",
//     "you didn’t see me",
//     "i don’t think you noticed",
//     "they didn’t care",
//     "nobody showed up",
//     "i didn’t matter",
//   ];

//   for (var phrase in neglectPhrases) {
//     if (kDebugMode) {
//       print("Comparing: $phrase with $lower");
//       print("Ratio: ${ratio(phrase, lower)}");
//     }
//     if (ratio(phrase, lower) > threshold) return true;
//   }

//   return false;
// }

// bool isRepairFuzzy(String text, {int threshold = 20}) {
//   final lower = text.toLowerCase();
//   final List<String> repairPhrases = [
//     "sorry",
//     "apologize",
//     "forgive",
//     "make up",
//     "fix this",
//     "repair",
//     "reconcile",
//     "regret",
//     "understand",
//     "didn't mean to",
//     "move forward",
//     "want to make things right",
//     "what can I do",
//   ];

//   for (var phrase in repairPhrases) {
//     if (kDebugMode) {
//       print("Comparing: $phrase with $lower");
//       print("Ratio: ${ratio(phrase, lower)}");
//     }
//     if (ratio(phrase, lower) > threshold) return true;
//   }

//   return false;
// }

class _JournalAnalyzerScreenState extends State<JournalAnalyzerScreen> {
  final TextEditingController _controller = TextEditingController();
  String? score;
  String? text;
  String? reasoning;
  String? confidence;
  int? sentimentScore;
  int? neglect_true = 0;
  int? repair_true = 0;
  int? isNeglect = 0;
  int? isRepair = 0;

  void _submitText() async {
    final entryInput = _controller.text;
    final result = await analyzeEntry(entryInput);

    if (result != null) {
      // final detectedNeglect = isNeglectFuzzy(entryInput);
      // final detectedRepair = isRepairFuzzy(entryInput);
      final newEntry = JournalEntry(
        entry_text: entryInput,
        score: result['score'],
        reasoning: result['reasoning'],
        confidence: result['confidence'].toString(),
        isNeglect: result['neglect_true'] ? 1 : 0,
        isRepair: result['repair_true'] ? 1 : 0,
      );

      await JournalDatabase.instance.insertEntry(newEntry);

      setState(() {
        score = result['score'].toString();
        text = result['text'];
        sentimentScore = result['score'];
        reasoning = result['reasoning'];
        confidence = result['confidence'].toString();
        isNeglect = result['neglect_true'] ? 1 : 0;
        isRepair = result['repair_true'] ? 1 : 0;
      });
    } else {
      setState(() {
        score = "Error";
        reasoning = "Could not get response from API.";
        confidence = "";
      });
    }
  }

  // Future<Map<String, dynamic>?> analyzeEntry(String entryText) async {
  //   final url = Uri.parse("http://192.168.5.88:8000/analyze");
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({"text": entryText}),
  //   );

  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     return null;
  //   }
  // }
  Future<Map<String, dynamic>?> analyzeEntry(String entryText) async {
    const String url = "http://192.168.5.88:8000/analyze/";
    if (kDebugMode) {
      //print('[0] Entry Text: $entryText'); // Debug
      print('[1] Preparing to call API. URL: $url'); // Debug 1
    }

    try {
      // Encode the request body

      final String requestBody = jsonEncode({"entry": entryText});
      if (kDebugMode) {
        //print('[1] Request Body: $requestBody'); // Debug 1
        print('[2] Request Body: $requestBody'); // Debug 2
        // Add to your try block:
        print('Resolved URL: ${Uri.parse(url).host}');
        print(
          'DNS Lookup: ${await InternetAddress.lookup(Uri.parse(url).host)}',
        );
      }

      // Make the POST request
      if (kDebugMode) {
        print('[3] Sending POST request...'); // Debug 3
      }
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'accept': 'application/json',
              'Connection': 'close',
            },
            body: requestBody,
          )
          .timeout(Duration(seconds: 45));

      if (kDebugMode) {
        print(
          '[4] Request completed. Status Code: ${response.statusCode}',
        ); // Debug 4
        print('[5] Response Body: ${response.body}'); // Debug 5
      }

      if (response.statusCode == 307 || response.statusCode == 301) {
        // Server wants to redirect
        String? redirectLocation = response.headers['location'];
        if (kDebugMode) {
          print('[5] Redirecting to: $redirectLocation'); // Debug 5
        }
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('[6] Success! Parsing JSON...'); // Debug 6
        }
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print('[7] Error: Non-200 status code'); // Debug 7
        }
        return null;
      }
    } on TimeoutException {
      if (kDebugMode) {
        print('[X] Timeout: Server did not respond in 45 seconds.'); // Error 1
        //print('[X] Timeout: Server did not respond in 10 seconds.'); // Error 1
      }

      return null;
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('[X] Client Exception: $e'); // Error 2
        print('[X] Network Error: $e'); // Error 2
        print('[X] Is the device on the same network as the server?');
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('[X] Unexpected Error: $e'); // Error 3
      }
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: _submitText,
              child: const Text("Analyze and Save"),
            ),
            if (score != null) ...[
              const SizedBox(height: 20),
              if (sentimentScore != null && sentimentScore! >= 1) ...[
                Image.asset('assets/images/care1.png'),
              ],
              if (sentimentScore != null && sentimentScore! <= -1) ...[
                Image.asset('assets/images/abuse1.png'),
              ],
              if (isNeglect != null && isNeglect! == 1) ...[
                Image.asset('assets/images/neglect1.png'),
              ],
              if (isRepair != null && isRepair! == 1) ...[
                Image.asset('assets/images/repair1.png'),
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
