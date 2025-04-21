class JournalEntry {
  final int? id;
  final String text;
  final int score;
  final String reasoning;
  final String confidence;
  final int isNeglect;
  final int isRepair;
  final String? timestamp; // ✅ New field (nullable for safety)

  JournalEntry({
    this.id,
    required this.text,
    required this.score,
    required this.reasoning,
    required this.confidence,
    required this.isNeglect,
    required this.isRepair,
    this.timestamp, // ✅ Include in constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'score': score,
      'reasoning': reasoning,
      'confidence': confidence,
      'isNeglect': isNeglect == 1 ? 1 : 0,
      'isRepair': isRepair == 1 ? 1 : 0,
      'timestamp':
          timestamp ??
          DateTime.now().toString(), // ✅ Default to current time if null
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      text: map['text'],
      score: map['score'],
      reasoning: map['reasoning'],
      confidence: map['confidence'],
      isNeglect: map['isNeglect'] == 1 ? 1 : 0,
      isRepair: map['isRepair'] == 1 ? 1 : 0,
      timestamp: map['timestamp'], // ✅ Retrieve from DB
    );
  }
}
