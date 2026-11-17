/// An online player account stored in the Firestore `account` collection.
class Account {
  final String id;
  final String name;

  /// The best score this player has uploaded.
  final int score;

  const Account({required this.id, required this.name, this.score = 0});

  factory Account.fromMap(String id, Map<String, dynamic> map) {
    return Account(
      id: id,
      name: (map['name'] as String?) ?? 'Unknown',
      score: (map['score'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'score': score};
}
