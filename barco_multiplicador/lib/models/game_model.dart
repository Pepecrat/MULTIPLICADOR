import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/bet_history_service.dart';

enum GameState {
  ready, // Esperando apuesta
  playing, // Juego en curso
  exploded, // Barco explotó
  cashed_out, // Jugador hizo cashout a tiempo
}

class GameModel extends ChangeNotifier {
  // Estado del juego
  GameState _gameState = GameState.ready;
  GameState get gameState => _gameState;

  // Valores del juego
  double _betAmount = 0.0;
  double _multiplier = 1.0;
  double _finalMultiplier = 1.0;
  double _winAmount = 0.0;

  // Saldo del jugador (inicialmente 1000)
  double _balance = 1000.0;
  double get balance => _balance;

  // Timers y tiempos
  Timer? _multiplierTimer;
  Timer? _explosionTimer;
  Timer? _autoRestartTimer;
  int _explosionTimeMillis = 0;

  // Servicio de historial
  final BetHistoryService _historyService = BetHistoryService();

  // Getters
  double get betAmount => _betAmount;
  double get multiplier => _multiplier;
  double get finalMultiplier => _finalMultiplier;
  double get winAmount => _winAmount;

  // Factor de incremento del multiplicador (cada 0.1 segundos)
  final double _multiplierIncrement = 0.03;

  // Validar si una apuesta es válida (menor o igual al saldo)
  bool isValidBet(double bet) {
    return bet > 0 && bet <= _balance;
  }

  // Iniciar el juego con una apuesta
  void startGame(double bet) {
    if (_gameState != GameState.ready || !isValidBet(bet)) return;

    // Descontar la apuesta del saldo
    _balance -= bet;
    _betAmount = bet;
    _multiplier = 1.0;

    // Cambiar el estado y notificar una sola vez al inicio
    _gameState = GameState.playing;
    notifyListeners();

    // Generar tiempo aleatorio para la explosión (entre 1 y 30 segundos)
    final random = Random();
    _explosionTimeMillis = random.nextInt(29000) + 1000; // 1000 a 30000 ms

    // Iniciar contador del multiplicador cada 0.1 segundos
    // Este timer solo actualiza el valor interno sin notificar en cada tick
    _multiplierTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      _multiplier += _multiplierIncrement;

      // Notificar con mucha menos frecuencia, solo para actualizar el valor de referencia
      // El componente visual realizará su propia animación fluida
      if (timer.tick % 10 == 0) {
        // Cada 1 segundo (10 ticks de 100ms)
        notifyListeners();
      }
    });

    // Programar la explosión
    _explosionTimer = Timer(Duration(milliseconds: _explosionTimeMillis), () {
      _gameState = GameState.exploded;
      _finalMultiplier = _multiplier;
      _stopTimers();

      // Guardar resultado en historial (perdido)
      _saveToHistory(false);

      // Notificar el cambio de estado
      notifyListeners();
    });
  }

  // Realizar cashout
  void cashOut() {
    if (_gameState != GameState.playing) return;

    _gameState = GameState.cashed_out;
    _finalMultiplier = _multiplier;
    _winAmount = _betAmount * _finalMultiplier;

    // Sumar la ganancia al saldo
    _balance += _winAmount;

    _stopTimers();

    // Guardar resultado en historial (ganado)
    _saveToHistory(true);

    notifyListeners();
  }

  // Guardar registro en el historial
  void _saveToHistory(bool won) {
    final record = BetRecord(
      betAmount: _betAmount,
      multiplier: _finalMultiplier,
      winAmount: won ? _winAmount : 0.0,
      won: won,
      timestamp: DateTime.now(),
    );

    _historyService.saveBetRecord(record);
  }

  // Obtener historial de apuestas
  Future<List<BetRecord>> getBetHistory() {
    return _historyService.getBetHistory();
  }

  // Limpiar historial
  Future<void> clearHistory() {
    return _historyService.clearHistory();
  }

  // Reiniciar el juego
  void resetGame() {
    _stopTimers();

    // Configuramos los valores antes de notificar
    _betAmount = 0.0;
    _multiplier = 1.0;
    _finalMultiplier = 1.0;
    _winAmount = 0.0;

    // Añadimos un pequeño retraso antes de cambiar el estado
    // para permitir que las animaciones se completen
    Future.delayed(const Duration(milliseconds: 50), () {
      _gameState = GameState.ready;
      notifyListeners();
    });
  }

  // Detener todos los timers
  void _stopTimers() {
    _multiplierTimer?.cancel();
    _explosionTimer?.cancel();
    _autoRestartTimer?.cancel();
  }

  // Solo para fines de prueba/depuración
  void resetBalance() {
    _balance = 1000.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}
