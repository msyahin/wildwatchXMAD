import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();

  late AudioPlayer _clickPlayer;

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal() {
    _clickPlayer = AudioPlayer();
  }

  Future<void> playClickEffect() async {
    await _clickPlayer.setSource(AssetSource('audio/click_effect2.mp3'));
    await _clickPlayer.setVolume(1.0); // High volume for the click sound
    await _clickPlayer.resume();
  }
}
