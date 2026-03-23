import 'package:audioplayers/audioplayers.dart';
import 'package:prm393/services/shared_pref.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isMusicEnabled = true;

  bool get isMusicEnabled => _isMusicEnabled;

  Future<void> initBackgroundMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    bool? isEnabled = await SharedPreferenceHelper().getMusicEnabled();
    if (isEnabled != null) {
      _isMusicEnabled = isEnabled;
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;
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

  Future<void> toggleMusic(bool enable) async {
    _isMusicEnabled = enable;
    await SharedPreferenceHelper().saveMusicEnabled(enable);
    if (enable) {
      await playBackgroundMusic();
    } else {
      await pauseBackgroundMusic();
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
