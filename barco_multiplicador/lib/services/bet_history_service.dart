import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BetRecord {
  final double betAmount;
  final double multiplier;
  final double winAmount;
  final bool won;
  final DateTime timestamp;

  BetRecord({
    required this.betAmount,
    required this.multiplier,
    required this.winAmount,
    required this.won,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'betAmount': betAmount,
      'multiplier': multiplier,
      'winAmount': winAmount,
      'won': won,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BetRecord.fromJson(Map<String, dynamic> json) {
    return BetRecord(
      betAmount: json['betAmount'],
      multiplier: json['multiplier'],
      winAmount: json['winAmount'],
      won: json['won'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class BetHistoryService {
  static const String _storageKey = 'bet_history';

  // Guardar un registro de apuesta en el historial
  Future<void> saveBetRecord(BetRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_storageKey) ?? [];

    // Añadir el nuevo registro
    historyJson.add(jsonEncode(record.toJson()));

    // Limitar a los últimos 50 registros
    if (historyJson.length > 50) {
      historyJson.removeAt(0);
    }

    await prefs.setStringList(_storageKey, historyJson);
  }

  // Obtener todos los registros del historial
  Future<List<BetRecord>> getBetHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_storageKey) ?? [];

    return historyJson
        .map((json) => BetRecord.fromJson(jsonDecode(json)))
        .toList();
  }

  // Limpiar todo el historial
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
