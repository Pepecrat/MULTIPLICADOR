import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/game_model.dart';

class AnimatedBoat extends StatefulWidget {
  final GameState gameState;
  final double width;
  final double height;
  final VoidCallback? onExplosionComplete;

  const AnimatedBoat({
    Key? key,
    required this.gameState,
    this.width = double.infinity,
    this.height = 200,
    this.onExplosionComplete,
  }) : super(key: key);

  @override
  State<AnimatedBoat> createState() => _AnimatedBoatState();
}

class _AnimatedBoatState extends State<AnimatedBoat> {
  late VideoPlayerController _boatController;
  late VideoPlayerController _explosionController;
  late Future<void> _boatInitialized;
  late Future<void> _explosionInitialized;
  bool _isExploded = false;
  bool _hasNotifiedExplosionComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoControllers();
  }

  @override
  void didUpdateWidget(AnimatedBoat oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si el estado cambió a explosión, reproducir el video de explosión
    if (widget.gameState == GameState.exploded && !_isExploded) {
      _handleExplosion();
    }

    // Si el estado vuelve a ready, iniciar nuevamente la animación del barco
    if (widget.gameState == GameState.ready &&
        oldWidget.gameState != GameState.ready) {
      _resetAnimation();
    }

    // En lugar de reconstruir el widget para el estado de juego,
    // manejar la transición de una manera más suave
    if (widget.gameState == GameState.playing &&
        oldWidget.gameState == GameState.ready) {
      // Asegurarnos de que el video del barco siga reproduciéndose sin interrupción
      if (!_boatController.value.isPlaying) {
        _boatController.play();
      }
    }
  }

  void _initializeVideoControllers() {
    // Inicializar controlador del barco
    _boatController = VideoPlayerController.asset('assets/boat_moving.mp4');
    _boatInitialized = _boatController.initialize().then((_) {
      // Establecer reproducción en bucle para el barco
      _boatController.setLooping(true);
      _boatController.setVolume(
        0.0,
      ); // Silenciar para evitar problemas de audio

      // Iniciar reproducción si no está en estado de explosión
      if (widget.gameState != GameState.exploded) {
        _boatController.play();
      }
      if (mounted) setState(() {});
    });

    // Inicializar controlador de explosión
    _explosionController = VideoPlayerController.asset('assets/explosion.mp4');
    _explosionInitialized = _explosionController.initialize().then((_) {
      // No establecer bucle para la explosión, solo se reproduce una vez
      _explosionController.setLooping(false);
      _explosionController.setVolume(
        0.0,
      ); // Silenciar para evitar problemas de audio

      // Añadir listener para detectar cuando finaliza el video de explosión
      _explosionController.addListener(_checkExplosionCompletion);

      if (mounted) setState(() {});
    });
  }

  void _checkExplosionCompletion() {
    // Solo proceder si estamos en estado de explosión y el video está inicializado
    if (!_isExploded || !_explosionController.value.isInitialized) {
      return;
    }

    // Comprobamos con precisión si el video ha terminado
    // Usamos una pequeña tolerancia para considerar el video como terminado
    final bool isAtEnd =
        _explosionController.value.position >=
        (_explosionController.value.duration -
            const Duration(milliseconds: 300));

    // Si el video ha terminado y aún no hemos notificado la finalización
    if (isAtEnd && !_hasNotifiedExplosionComplete) {
      // Marcar que ya hemos notificado para evitar llamadas duplicadas
      _hasNotifiedExplosionComplete = true;

      // Añadir un pequeño retraso para asegurar que el último frame sea visible
      Future.delayed(const Duration(milliseconds: 500), () {
        // Verificar que el widget sigue montado antes de llamar al callback
        if (mounted && widget.onExplosionComplete != null) {
          widget.onExplosionComplete!();
        }
      });
    }
  }

  void _handleExplosion() {
    // Reiniciar la bandera que indica si ya notificamos la finalización
    _hasNotifiedExplosionComplete = false;

    // Primero preparamos el video de explosión antes de cambiar el estado
    _explosionController.seekTo(Duration.zero);

    // Aseguramos que esté listo para reproducirse
    _explosionController.pause();

    // Una vez preparado, actualizamos el estado y reproducimos
    setState(() {
      _isExploded = true;
    });

    // Después de un breve retraso para permitir que la transición se inicie,
    // comenzamos a reproducir el video de explosión
    Future.delayed(const Duration(milliseconds: 100), () {
      // Pausar el video del barco
      _boatController.pause();

      // Reproducir el video de explosión
      _explosionController.play();
    });
  }

  void _resetAnimation() {
    // Primero, pausamos el video de explosión
    _explosionController.pause();

    // Reiniciar la bandera que indica si ya notificamos la finalización
    _hasNotifiedExplosionComplete = false;

    // Preparamos el video del barco antes de cambiar el estado
    _boatController.seekTo(Duration.zero);

    // Cambiamos el estado
    setState(() {
      _isExploded = false;
    });

    // Permitimos que la transición comience y luego reproducimos el barco
    Future.delayed(const Duration(milliseconds: 100), () {
      _boatController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_boatInitialized, _explosionInitialized]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Determinar qué video mostrar basado en el estado
          final isShowingExplosion =
              widget.gameState == GameState.exploded || _isExploded;

          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              // Usamos AnimatedCrossFade en lugar de AnimatedSwitcher para una transición más suave
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState:
                    isShowingExplosion
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                firstChild: AspectRatio(
                  aspectRatio: _boatController.value.aspectRatio,
                  child: VideoPlayer(_boatController),
                ),
                secondChild: AspectRatio(
                  aspectRatio: _explosionController.value.aspectRatio,
                  child: VideoPlayer(_explosionController),
                ),
                // Usamos una curva suave para la transición
                firstCurve: Curves.easeInOut,
                secondCurve: Curves.easeInOut,
                // Aseguramos que las dimensiones coincidan para evitar saltos
                sizeCurve: Curves.easeInOut,
                layoutBuilder: (
                  topChild,
                  topChildKey,
                  bottomChild,
                  bottomChildKey,
                ) {
                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned.fill(key: bottomChildKey, child: bottomChild),
                      Positioned.fill(key: topChildKey, child: topChild),
                    ],
                  );
                },
              ),
            ),
          );
        } else {
          // Mostrar un indicador de carga mientras se inicializan los videos
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(0.1),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _explosionController.removeListener(_checkExplosionCompletion);
    _boatController.dispose();
    _explosionController.dispose();
    super.dispose();
  }
}
