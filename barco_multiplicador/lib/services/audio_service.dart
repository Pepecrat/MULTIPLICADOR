import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer =
      AudioPlayer(); // Para el sonido continuo del agua
  bool _soundEnabled = true;
  bool _isWaterSoundPlaying = false;

  // Inicializar el servicio
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
  }

  // Reproducir sonido
  Future<void> playSound(String soundType) async {
    if (!_soundEnabled) return;

    switch (soundType) {
      case 'water':
        if (!_isWaterSoundPlaying) {
          await _ambientPlayer.play(AssetSource('sounds/water_sound.mp3'));
          await _ambientPlayer.setReleaseMode(
            ReleaseMode.loop,
          ); // Reproducir en bucle
          _isWaterSoundPlaying = true;
        }
        break;
      case 'explosion':
        await _audioPlayer.play(AssetSource('sounds/explosion_sound.mp3'));
        break;
      case 'cashout':
        await _audioPlayer.play(AssetSource('sounds/cashout_sound.mp3'));
        break;
    }
  }

  // Detener sonido específico
  Future<void> stopSound(String soundType) async {
    if (soundType == 'water' && _isWaterSoundPlaying) {
      await _ambientPlayer.stop();
      _isWaterSoundPlaying = false;
    }
  }

  // Activar/desactivar sonido
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);

    if (!_soundEnabled) {
      // Si se desactiva el sonido, detener todas las reproducciones
      await _audioPlayer.stop();
      await _ambientPlayer.stop();
      _isWaterSoundPlaying = false;
    } else if (_isWaterSoundPlaying) {
      // Si se activa el sonido y el agua estaba sonando, reiniciar
      await playSound('water');
    }
  }

  // Getter para verificar si el sonido está activado
  bool get isSoundEnabled => _soundEnabled;

  // Liberar recursos
  void dispose() {
    _audioPlayer.dispose();
    _ambientPlayer.dispose();
  }
}
