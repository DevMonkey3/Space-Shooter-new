import 'package:hive_flutter/hive_flutter.dart';

/// Remembers the player's online account id on this device (or browser),
/// so the player only has to create an account once.
///
/// Uses Hive like the rest of the save data, which works on Android and
/// on the web (where it is stored in the browser's IndexedDB).
class IDStorage {
  static const String _boxName = 'AccountBox';
  static const String _idKey = 'accountId';

  Future<Box<String>> _box() => Hive.openBox<String>(_boxName);

  /// Returns the saved account id, or an empty string if there is none.
  Future<String> readID() async {
    try {
      return (await _box()).get(_idKey, defaultValue: '')!;
    } catch (_) {
      return '';
    }
  }

  Future<void> writeID(String id) async {
    await (await _box()).put(_idKey, id);
  }

  Future<void> clearID() async {
    await (await _box()).delete(_idKey);
  }
}
