import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> initBackgroundMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBackgroundMusic() async {
    if (!_isPlaying) {
      try {
        // Mặc định audioplayers sẽ tìm trong thư mục assets/ (do đó path là audio/background.mp3)
        await _audioPlayer.play(AssetSource('audio/background.mp3'));
        _isPlaying = true;
      } catch (e) {
        print("Error playing background music: $e");
      }
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isPlaying) {
      await _audioPlayer.resume();
      _isPlaying = true;
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }
}
