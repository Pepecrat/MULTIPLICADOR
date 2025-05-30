import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../models/game_model.dart';
import '../services/bet_history_service.dart';
import '../widgets/game_button.dart';
import '../utils/currency_formatter.dart';
import '../widgets/coin_text.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.blackPearl,
      appBar: AppBar(
        title: const Text(
          'HISTORIAL',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: AppColors.blackPearl,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppColors.white),
            onPressed: () {
              _showConfirmationDialog(context, () async {
                await gameModel.clearHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Historial borrado'),
                      backgroundColor: AppColors.funBlue,
                    ),
                  );
                  // Para forzar la reconstrucción de la pantalla
                  Navigator.pop(context);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  }
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<BetRecord>>(
        future: gameModel.getBetHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.java),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar el historial',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GameButton(
                    text: 'Reintentar',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                    width: 200,
                    color: AppColors.funBlue,
                  ),
                ],
              ),
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    color: AppColors.white.withOpacity(0.3),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay historial de apuestas',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.7),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Comienza a jugar para generar un historial!',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Ordenar registros por fecha (más reciente primero)
          records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];

              // Formatear la fecha
              final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
              final formattedDate = dateFormat.format(record.timestamp);

              // Determinar color por resultado
              final resultColor = record.won ? AppColors.green : AppColors.red;

              // Formatear montos
              final betAmount = CurrencyFormatter.format(record.betAmount);
              final winAmount = CurrencyFormatter.format(record.winAmount);

              return Card(
                color: AppColors.blackPearl.withOpacity(0.7),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: resultColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: resultColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: resultColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              record.won ? 'GANADO' : 'PERDIDO',
                              style: TextStyle(
                                color: resultColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Apuesta',
                                style: TextStyle(
                                  color: AppColors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              CoinText(
                                value: record.betAmount,
                                iconSize: 14,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Multiplicador',
                                style: TextStyle(
                                  color: AppColors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'x${record.multiplier.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: _getMultiplierColor(record.multiplier),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Ganancia',
                                style: TextStyle(
                                  color: AppColors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              CoinText(
                                value: record.won ? record.winAmount : 0.00,
                                iconSize: 14,
                                style: TextStyle(
                                  color:
                                      record.won
                                          ? AppColors.green
                                          : AppColors.white.withOpacity(0.5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Obtener color según el multiplicador
  Color _getMultiplierColor(double multiplier) {
    if (multiplier >= 5.0) {
      return AppColors.mediumPurple;
    } else if (multiplier >= 2.0) {
      return AppColors.funBlue;
    } else {
      return AppColors.java;
    }
  }

  // Mostrar diálogo de confirmación para borrar historial
  void _showConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.blackPearl,
            title: const Text(
              '¿Borrar historial?',
              style: TextStyle(color: AppColors.white),
            ),
            content: const Text(
              'Esta acción eliminará todo el historial de apuestas de manera permanente.',
              style: TextStyle(color: AppColors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.red),
                child: const Text('Borrar'),
              ),
            ],
          ),
    );
  }
}
