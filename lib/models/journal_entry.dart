class JournalEntry {
  final int? id;
  final String text;
  final int score;
  final String reasoning;
  final String confidence;
  final bool isNeglect;

  JournalEntry({
    this.id,
    required this.text,
    required this.score,
    required this.reasoning,
    required this.confidence,
    required this.isNeglect,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'score': score,
      'reasoning': reasoning,
      'confidence': confidence,
      'isNeglect': isNeglect ? 1 : 0,
    };
  }
}
