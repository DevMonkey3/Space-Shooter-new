import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'account.dart';

/// Thrown when a player picks a name somebody else already uses.
class NameTakenException implements Exception {
  final String name;
  const NameTakenException(this.name);

  @override
  String toString() => 'The name "$name" is already taken';
}

/// All online features (accounts + scoreboard) go through this class.
///
/// If Firebase could not be initialised (no config yet, unsupported
/// platform), [isAvailable] is false and the game runs offline.
class FireBase {
  static bool isAvailable = false;

  static const String collection = 'account';

  CollectionReference<Map<String, dynamic>> get _db =>
      FirebaseFirestore.instance.collection(collection);

  /// Initialises Firebase. Returns false (and keeps the game offline)
  /// when that fails, instead of crashing on start-up.
  static Future<bool> init(FirebaseOptions options) async {
    try {
      await Firebase.initializeApp(options: options);
      isAvailable = true;
    } catch (e) {
      // ignore: avoid_print
      print('Firebase unavailable, running offline: $e');
      isAvailable = false;
    }
    return isAvailable;
  }

  /// Creates a new account and returns its document id.
  /// Throws [NameTakenException] if the name is already in use.
  Future<String> createAccount(String name) async {
    final existing = await _db.where('name', isEqualTo: name).limit(1).get();
    if (existing.docs.isNotEmpty) {
      throw NameTakenException(name);
    }
    final doc = await _db.add({'name': name, 'score': 0});
    return doc.id;
  }

  /// Returns the account with the given id, or null if it does not exist.
  Future<Account?> getAccount(String id) async {
    if (id.isEmpty) return null;
    final snapshot = await _db.doc(id).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return Account.fromMap(snapshot.id, data);
  }

  /// Saves [score] for the account, but only if it beats the stored best.
  Future<void> submitScore(String id, int score) async {
    if (id.isEmpty) return;
    final ref = _db.doc(id);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) return;
      final best = (snapshot.data()?['score'] as num?)?.toInt() ?? 0;
      if (score > best) {
        tx.update(ref, {'score': score});
      }
    });
  }

  /// Live list of the top [limit] players, best first.
  Stream<List<Account>> topScores({int limit = 20}) {
    return _db.orderBy('score', descending: true).limit(limit).snapshots().map(
        (query) => query.docs
            .map((doc) => Account.fromMap(doc.id, doc.data()))
            .toList());
  }
}
