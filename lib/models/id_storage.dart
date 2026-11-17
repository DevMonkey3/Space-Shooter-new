import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Stores the player's online account id in a small file on the device,
/// so the player only has to create an account once.
class IDStorage {
  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/ID.txt');
  }

  /// Returns the saved account id, or an empty string if there is none.
  Future<String> readID() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return '';
      return (await file.readAsString()).trim();
    } catch (_) {
      return '';
    }
  }

  Future<void> writeID(String id) async {
    final file = await _localFile;
    await file.writeAsString(id);
  }

  Future<void> clearID() async {
    final file = await _localFile;
    if (await file.exists()) await file.delete();
  }
}
