import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/colors.dart';
import '../models/game_model.dart';
import '../widgets/animated_boat.dart';
import '../widgets/bet_input.dart';
import '../widgets/game_button.dart';
import '../widgets/multiplier_display.dart';
import '../widgets/coin_text.dart';
import '../utils/currency_formatter.dart';
import '../services/bet_history_service.dart';
import '../services/audio_service.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final AudioService _audioService = AudioService();
  bool _isFirstBuild = true;
  GameState? _previousGameState;

  @override
  void initState() {
    super.initState();
    // Iniciar sonido de agua al cargar la pantalla
    _audioService.playSound('water');
  }

  @override
  void dispose() {
    // Detener sonido de agua al salir de la pantalla
    _audioService.stopSound('water');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context);
    final size = MediaQuery.of(context).size;

    // Calcular el ancho del panel lateral basado en el tamaño de la pantalla
    final double sidebarWidth =
        size.width < 600
            ? size.width *
                0.28 // Pantallas muy pequeñas (reducido de 0.30 a 0.28)
            : size.width * 0.25; // Pantallas normales

    // Determinar si es una pantalla muy pequeña para ajustes adicionales
    final bool isSmallScreen = size.width < 500;

    // Determinar si el botón de Cash Out debe mostrarse
    final showCashoutButton = gameModel.gameState == GameState.playing;

    // Determinar si la entrada de apuesta debe estar habilitada
    final isBetInputEnabled = gameModel.gameState == GameState.ready;

    // Determine if the game is active
    final isGameActive = gameModel.gameState == GameState.playing;

    // Verificar cambios en el estado del juego para reproducir sonidos
    if (_previousGameState != gameModel.gameState) {
      _handleSounds(gameModel.gameState);
      _previousGameState = gameModel.gameState;
    }

    // Solo se ejecuta en la primera construcción
    if (_isFirstBuild) {
      _isFirstBuild = false;
    }

    return Scaffold(
      backgroundColor: AppColors.blackPearl,
      extendBodyBehindAppBar: true,
      // Evitar que el contenido se desplace cuando se abre el teclado
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70, // Aumentar altura del AppBar
        automaticallyImplyLeading: false, // Eliminar botón de regreso
        title: Container(
          width: 200, // Usar todo el ancho disponible
          height: 58,
          margin: const EdgeInsets.only(
            right: 80,
          ), // Espacio para los botones de acción
          child: Consumer<GameModel>(
            builder: (context, gameModel, child) {
              return Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      AppColors.blackPearl,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.java, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.java.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(1),
                      width: 38,
                      height: 38,
                      child: Image.asset(
                        'assets/coin.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        CurrencyFormatter.format(gameModel.balance),
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.white, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          // Cerrar el teclado al tocar cualquier parte de la pantalla
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          // Asegurar que el GestureDetector cubra toda la pantalla
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              // Fondo con el video del barco
              Positioned.fill(
                child: RepaintBoundary(
                  child: AnimatedBoat(
                    gameState: gameModel.gameState,
                    onExplosionComplete: () {
                      // Reiniciar el juego automáticamente cuando
                      // el video de explosión ha terminado
                      gameModel.resetGame();
                    },
                  ),
                ),
              ),

              // Multiplicador superpuesto en el centro
              Positioned.fill(
                child: Center(
                  // Usamos un Repaint Boundary para aislar las actualizaciones del multiplicador
                  // y evitar reconstrucciones innecesarias del resto de widgets
                  child: RepaintBoundary(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 24,
                        vertical: isSmallScreen ? 10 : 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blackPearl.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: MultiplierDisplay(
                        multiplier: gameModel.multiplier,
                        isAnimated: isGameActive,
                        isCashedOut:
                            gameModel.gameState == GameState.cashed_out,
                        isExploded: gameModel.gameState == GameState.exploded,
                        fontSize: isSmallScreen ? 48 : 64,
                      ),
                    ),
                  ),
                ),
              ),

              // Panel lateral de controles (derecha)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: sidebarWidth,
                child: Container(
                  color: AppColors.blackPearl.withOpacity(0.8),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 16,
                    vertical: isSmallScreen ? 16 : 24,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: SizedBox(
                          // Establecer una altura mínima igual a la altura disponible
                          // para evitar el error de layout
                          height: constraints.maxHeight - 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (gameModel.gameState ==
                                  GameState.cashed_out) ...[
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '¡Has ganado!',
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    CurrencyFormatter.format(
                                      gameModel.winAmount,
                                    ),
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontSize: isSmallScreen ? 16 : 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Apuesta: ${CurrencyFormatter.format(gameModel.betAmount)}',
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.8),
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'x ${gameModel.finalMultiplier.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.8),
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],

                              if (gameModel.gameState ==
                                  GameState.exploded) ...[
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Boom!',
                                    style: TextStyle(
                                      color: AppColors.red,
                                      fontSize: isSmallScreen ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'El barco explotó',
                                    style: TextStyle(
                                      color: AppColors.red,
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Apuesta perdida:',
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.8),
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    CurrencyFormatter.format(
                                      gameModel.betAmount,
                                    ),
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.8),
                                      fontSize: isSmallScreen ? 8 : 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],

                              SizedBox(height: isSmallScreen ? 8 : 16),

                              // Controles del juego
                              if (gameModel.gameState == GameState.ready ||
                                  gameModel.gameState == GameState.cashed_out ||
                                  gameModel.gameState ==
                                      GameState.exploded) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: BetInput(
                                    onBetSubmitted:
                                        (value) => gameModel.startGame(value),
                                    isEnabled: isBetInputEnabled,
                                  ),
                                ),
                              ],
                              if (showCashoutButton) ...[
                                const SizedBox(height: 8), // Reducido de 8 a 4
                                SizedBox(
                                  height: 35, // Altura específica reducida
                                  child: GameButton(
                                    text: 'CASH OUT',
                                    color: AppColors.green,
                                    onPressed: () {
                                      _audioService.playSound('cashout');
                                      gameModel.cashOut();

                                      // Mostrar diálogo de confirmación
                                      _showCashoutDialog(
                                        context,
                                        gameModel.winAmount,
                                      );
                                    },
                                    icon: Icons.monetization_on,
                                  ),
                                ),
                              ],

                              if (gameModel.gameState == GameState.cashed_out ||
                                  gameModel.gameState ==
                                      GameState.exploded) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 30, // Altura específica reducida
                                  child: GameButton(
                                    text: 'JUGAR DE NUEVO',
                                    color: AppColors.funBlue,
                                    onPressed: () => gameModel.resetGame(),
                                    icon: Icons.replay,
                                  ),
                                ),
                              ],

                              const Spacer(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSounds(GameState state) {
    // Reproducir sonidos en función del estado del juego
    switch (state) {
      case GameState.exploded:
        _audioService.playSound('explosion');
        break;
      case GameState.playing:
        // Si se inicia el juego, asegurarse de que el agua está sonando
        _audioService.playSound('water');
        break;
      default:
        break;
    }
  }

  void _showCashoutDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.blackPearl,
            title: const Text(
              '¡Bien hecho!',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Has retirado tu dinero a tiempo',
                  style: TextStyle(color: AppColors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ganancia: ',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset('assets/coin.png', width: 64, height: 64),
                    const SizedBox(width: 4),
                    Text(
                      CurrencyFormatter.format(amount),
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CONTINUAR',
                  style: TextStyle(
                    color: AppColors.java,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
