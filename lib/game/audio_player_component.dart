import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import 'game.dart';

class AudioPlayerComponent extends Component
    with HasGameReference<SpaceShooterGame> {
  // Music files that are actually bundled with the app. The background
  // music ("9. Space Invaders.wav" from VOiD1 Gaming's free synthwave pack,
  // https://void1gaming.itch.io/free-synthwave-music-pack) is not
  // redistributable, so it may be missing; then the game plays without music.
  final Set<String> _availableMusic = {};

  @override
  Future<void> onLoad() async {
    FlameAudio.bgm.initialize();

    await FlameAudio.audioCache
        .loadAll(['laser1.ogg', 'powerUp6.ogg', 'laserSmall_001.ogg']);

    const music = '9. Space Invaders.wav';
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    if (manifest.listAssets().contains('assets/audio/$music')) {
      await FlameAudio.audioCache.load(music);
      _availableMusic.add(music);
    } else {
      // ignore: avoid_print
      print('Background music not bundled, playing without music: '
          'https://void1gaming.itch.io/free-synthwave-music-pack');
    }
  }

  bool _isEnabled(bool Function(Settings settings) setting) {
    final context = game.buildContext;
    if (context == null) return false;
    return setting(Provider.of<Settings>(context, listen: false));
  }

  void playBgm(String filename) {
    if (!_availableMusic.contains(filename)) return;
    if (_isEnabled((s) => s.backgroundMusic)) {
      FlameAudio.bgm.play(filename).catchError((Object e) {
        // ignore: avoid_print
        print('Could not play music: $e');
      });
    }
  }

  void playSfx(String filename) {
    if (_isEnabled((s) => s.soundEffects)) {
      FlameAudio.play(filename).catchError((Object e) {
        // ignore: avoid_print
        print('Could not play sound: $e');
        return AudioPlayer();
      });
    }
  }

  void stopBgm() {
    if (_availableMusic.isEmpty) return;
    FlameAudio.bgm.stop();
  }
}
