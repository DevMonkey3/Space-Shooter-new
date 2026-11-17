import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/firebase.dart';
import '../models/id_storage.dart';
import '../models/player_data.dart';
import '../models/spaceship_details.dart';
import '../widgets/overlays/game_over_menu.dart';
import '../widgets/overlays/pause_button.dart';
import '../widgets/overlays/pause_menu.dart';

import 'audio_player_component.dart';
import 'bullet.dart';
import 'command.dart';
import 'enemy.dart';
import 'enemy_manager.dart';
import 'health_bar.dart';
import 'player.dart';
import 'power_up_manager.dart';
import 'power_ups.dart';

// This class is responsible for initializing and running the game-loop.
class SpaceShooterGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  // The size of the playable area. The camera scales this to fit any screen.
  static const double gameWidth = 540;
  static const double gameHeight = 960;
  final Vector2 fixedResolution = Vector2(gameWidth, gameHeight);

  SpaceShooterGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        ) {
    // We show our own pause menu when the app goes to the background,
    // so Flame must not auto-resume the engine when it comes back.
    pauseWhenBackgrounded = false;
  }

  // Stores a reference to player component.
  late Player _player;
  late JoystickComponent joystick;

  // Stores a reference to the main spritesheet.
  late SpriteSheet spriteSheet;

  // Stores a reference to an enemy manager component.
  late EnemyManager _enemyManager;

  // Stores a reference to an power-up manager component.
  late PowerUpManager _powerUpManager;

  // Displays player score on top left.
  late TextComponent _playerScore;

  // Displays player health on top right.
  late TextComponent _playerHealth;

  late AudioPlayerComponent _audioPlayerComponent;

  // List of commands to be processed in current update.
  final _commandList = List<Command>.empty(growable: true);

  // List of commands to be processed in next update.
  final _addLaterCommandList = List<Command>.empty(growable: true);

  // True once the current round has ended.
  bool _isGameOver = false;

  // This method gets called by Flame before the game-loop begins.
  // Assets loading and adding component should be done here.
  @override
  Future<void> onLoad() async {
    // World coordinates match the 540x960 play area, with (0, 0)
    // in the top-left corner.
    camera.viewfinder.anchor = Anchor.topLeft;

    // Loads and caches all the images for later use.
    await images.loadAll([
      'simpleSpace_tilesheet@2.png',
      'freeze.png',
      'icon_plusSmall.png',
      'multi_fire.png',
      'nuke.png',
    ]);

    spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: images.fromCache('simpleSpace_tilesheet@2.png'),
      columns: 8,
      rows: 6,
    );

    // Create a basic joystick component on left.
    joystick = JoystickComponent(
      anchor: Anchor.bottomLeft,
      margin: const EdgeInsets.only(left: 20, bottom: 20),
      background: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.white.withValues(alpha: 0.5),
      ),
      knob: CircleComponent(radius: 30),
    );

    _audioPlayerComponent = AudioPlayerComponent();
    final stars = await ParallaxComponent.load(
      [ParallaxImageData('stars1.png'), ParallaxImageData('stars2.png')],
      repeat: ImageRepeat.repeat,
      baseVelocity: Vector2(0, -50),
      velocityMultiplierDelta: Vector2(0, 1.5),
      size: fixedResolution,
      priority: -10,
    );

    /// As build context is not valid in onLoad() method, we
    /// cannot get current [PlayerData] here. So initialize player
    /// with the default SpaceshipType.canary; [onAttach] fixes it.
    const spaceshipType = SpaceshipType.canary;
    final spaceship = Spaceship.getSpaceshipByType(spaceshipType);

    _player = Player(
      joystick: joystick,
      spaceshipType: spaceshipType,
      sprite: spriteSheet.getSpriteById(spaceship.spriteId),
      size: Vector2(64, 64),
      position: fixedResolution / 2,
    );

    // Makes sure that the sprite is centered.
    _player.anchor = Anchor.center;

    _enemyManager = EnemyManager(spriteSheet: spriteSheet);
    _powerUpManager = PowerUpManager();

    const hudStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontFamily: 'BungeeInline',
    );

    // Create text component for player score.
    _playerScore = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(style: hudStyle),
    );

    // Create text component for player health, anchored top right.
    _playerHealth = TextComponent(
      text: 'Health: 100%',
      position: Vector2(fixedResolution.x - 10, 10),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(style: hudStyle),
    );

    // Add the blue bar indicating health.
    final healthBar = HealthBar(
      player: _player,
      position: _playerHealth.positionOfAnchor(Anchor.topLeft),
      priority: -1,
    );

    // Create a fire button component on right
    final button = ButtonComponent(
      button: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.white.withValues(alpha: 0.5),
      ),
      anchor: Anchor.bottomRight,
      position: Vector2(fixedResolution.x - 20, fixedResolution.y - 20),
      onPressed: _player.joystickAction,
    );

    await world.addAll([
      _audioPlayerComponent,
      stars,
      _player,
      _enemyManager,
      _powerUpManager,
    ]);

    // HUD elements live on the camera viewport so they never move
    // with the world (e.g. during camera shake).
    await camera.viewport.addAll([
      joystick,
      button,
      healthBar,
      _playerScore,
      _playerHealth,
    ]);
  }

  // Called (after onLoad) every time the game is shown by a GameWidget,
  // i.e. every time the player starts playing from the hangar.
  @override
  void onMount() {
    super.onMount();
    // Use the spaceship the player picked in the hangar.
    final context = buildContext;
    if (context != null) {
      final playerData = Provider.of<PlayerData>(context, listen: false);
      _player.setSpaceshipType(playerData.spaceshipType);
    }
    _audioPlayerComponent.playBgm('9. Space Invaders.wav');
  }

  @override
  void onDetach() {
    _audioPlayerComponent.stopBgm();
    super.onDetach();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Run each command from _commandList on each
    // component from components list. The run()
    // method of Command is no-op if the command is
    // not valid for given component.
    for (final command in _commandList) {
      for (final component in world.children) {
        command.run(component);
      }
    }

    // Remove all the commands that are processed and
    // add all new commands to be processed in next update.
    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();

    if (_player.isMounted) {
      // Update score and health components with latest values.
      _playerScore.text = 'Score: ${_player.score}';
      _playerHealth.text = 'Health: ${_player.health}%';

      /// Display [GameOverMenu] when [Player.health] becomes zero.
      if (_player.health <= 0 && !_isGameOver) {
        _gameOver();
      }
    }
  }

  void _gameOver() {
    _isGameOver = true;
    pauseEngine();
    overlays.remove(PauseButton.id);
    overlays.remove(PauseMenu.id);
    overlays.add(GameOverMenu.id);
    _submitHighScore();
  }

  // Uploads the player's best score to the online scoreboard.
  // Failures are ignored: the best score is re-sent after every round.
  Future<void> _submitHighScore() async {
    final context = buildContext;
    if (!FireBase.isAvailable || context == null) return;
    final highScore = Provider.of<PlayerData>(context, listen: false).highScore;
    try {
      final id = await IDStorage().readID();
      await FireBase().submitScore(id, highScore);
    } catch (e) {
      // ignore: avoid_print
      print('Could not upload score: $e');
    }
  }

  /// Briefly shakes the camera, e.g. when the player gets hit.
  void shakeCamera() {
    final viewfinder = camera.viewfinder;
    if (viewfinder.children.whereType<MoveByEffect>().isNotEmpty) return;
    viewfinder.add(
      MoveByEffect(
        Vector2(8, 6),
        EffectController(duration: 0.04, alternate: true, repeatCount: 3),
      ),
    );
  }

  // This method handles state of app and pauses
  // the game when necessary.
  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (isAttached && !_isGameOver && !paused) {
          pauseEngine();
          overlays.remove(PauseButton.id);
          overlays.add(PauseMenu.id);
        }
        break;
    }

    super.lifecycleStateChange(state);
  }

  // Adds given command to command list.
  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  // Resets the game to initial state. Should be called
  // while restarting and exiting the game.
  void reset() {
    // Quitting a round from the pause menu (Restart / Exit) still counts:
    // upload the best score. After a game over it was already uploaded.
    if (!_isGameOver) _submitHighScore();

    _isGameOver = false;
    _commandList.clear();
    _addLaterCommandList.clear();

    // First reset player, enemy manager and power-up manager.
    _player.reset();
    _enemyManager.reset();
    _powerUpManager.reset();

    // Put the camera back in case a shake was interrupted.
    camera.viewfinder.children
        .whereType<Effect>()
        .toList()
        .forEach((effect) => effect.removeFromParent());
    camera.viewfinder.position = Vector2.zero();

    // Now remove all the enemies, bullets and power ups
    // from the game world. Note that, we are not calling
    // Enemy.destroy() because it will unnecessarily
    // run explosion effect and increase players score.
    for (final component in world.children.toList()) {
      if (component is Enemy || component is Bullet || component is PowerUp) {
        component.removeFromParent();
      }
    }
  }
}
