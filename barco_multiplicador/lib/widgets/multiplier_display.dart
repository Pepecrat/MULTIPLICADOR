import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/colors.dart';

class MultiplierDisplay extends StatefulWidget {
  final double multiplier;
  final double fontSize;
  final bool isAnimated;
  final bool isCashedOut;
  final bool isExploded;

  const MultiplierDisplay({
    Key? key,
    required this.multiplier,
    this.fontSize = 48,
    this.isAnimated = false,
    this.isCashedOut = false,
    this.isExploded = false,
  }) : super(key: key);

  @override
  State<MultiplierDisplay> createState() => _MultiplierDisplayState();
}

class _MultiplierDisplayState extends State<MultiplierDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _displayMultiplier = 1.0;
  Timer? _smoothAnimationTimer;
  double _lastRealMultiplier = 1.0;

  // Tasa fija de incremento: 0.03 por cada 100ms
  final double _incrementRatePerSecond = 0.3; // 0.03 * 10 por segundo
  DateTime _lastUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Inicializar con el valor actual
    _displayMultiplier = widget.multiplier;
    _lastRealMultiplier = widget.multiplier;

    // Controlador para el efecto de pulso para eventos especiales
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Iniciar la animación suave si estamos en modo de juego
    _startSmoothAnimation();
  }

  @override
  void didUpdateWidget(MultiplierDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Actualizar el valor real de referencia
    _lastRealMultiplier = widget.multiplier;

    // Ajustar la animación según el estado
    if (widget.isAnimated && !oldWidget.isAnimated) {
      _startSmoothAnimation();
    } else if (!widget.isAnimated && oldWidget.isAnimated) {
      _stopSmoothAnimation();
      // Actualizar inmediatamente al valor real
      _displayMultiplier = widget.multiplier;
    }

    // Si cambiamos a un estado final (cashout o explosión)
    if ((widget.isCashedOut && !oldWidget.isCashedOut) ||
        (widget.isExploded && !oldWidget.isExploded)) {
      _stopSmoothAnimation();
      _displayMultiplier = widget.multiplier;
      // Hacer un pulso para destacar el valor final
      _pulseController.forward(from: 0.0);
    }
  }

  void _startSmoothAnimation() {
    // Detener cualquier animación previa
    _stopSmoothAnimation();

    // Guardar el tiempo de inicio
    _lastUpdateTime = DateTime.now();

    // Crear un timer que actualice el valor mostrado cada 16ms (~60fps)
    _smoothAnimationTimer = Timer.periodic(const Duration(milliseconds: 16), (
      timer,
    ) {
      if (!widget.isAnimated) {
        // Si ya no estamos en estado de juego, detener la animación
        _stopSmoothAnimation();
        return;
      }

      // Calcular el tiempo transcurrido desde la última actualización
      final now = DateTime.now();
      final elapsedSeconds =
          now.difference(_lastUpdateTime).inMilliseconds / 1000.0;
      _lastUpdateTime = now;

      // Calcular el incremento basado en la tasa constante por segundo
      final increment = _incrementRatePerSecond * elapsedSeconds;

      // Solo actualizar si estamos jugando
      if (mounted && widget.isAnimated) {
        setState(() {
          // Incrementar el valor mostrado a una tasa constante
          _displayMultiplier += increment;

          // Aseguramos que el multiplicador mostrado no se desvíe demasiado del valor real
          // pero permitimos una pequeña diferencia para mantener la fluidez visual
          if (_displayMultiplier > _lastRealMultiplier + 0.5) {
            _displayMultiplier = _lastRealMultiplier + 0.5;
          }
        });
      }
    });
  }

  void _stopSmoothAnimation() {
    _smoothAnimationTimer?.cancel();
    _smoothAnimationTimer = null;
  }

  @override
  void dispose() {
    _stopSmoothAnimation();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determinar el color basado en el estado
    Color textColor;
    if (widget.isExploded) {
      textColor = AppColors.red;
    } else if (widget.isCashedOut) {
      textColor = AppColors.green;
    } else if (_displayMultiplier >= 5.0) {
      textColor = AppColors.mediumPurple;
    } else if (_displayMultiplier >= 2.0) {
      textColor = AppColors.funBlue;
    } else {
      textColor = AppColors.java;
    }

    // Ajustando tamaños de fuente para PressStart2P que es más ancha
    final adjustedFontSize = widget.fontSize * 0.8;
    final labelFontSize = adjustedFontSize * 0.2;

    // Crear el texto principal del multiplicador
    Widget displayText = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            // Crear un efecto de pulso suave para eventos especiales
            final pulseScale = 1.0 + _pulseController.value * 0.05;

            return Transform.scale(
              scale: pulseScale,
              child: Text(
                'x${_displayMultiplier.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: adjustedFontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.0,
                  height: 0.9,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(3, 3),
                    ),
                    Shadow(
                      blurRadius: 5.0,
                      color: textColor.withOpacity(0.3),
                      offset: const Offset(-1, -1),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10), // Espacio adicional para separar
        // Texto de etiqueta debajo del multiplicador
        Text(
          _getMultiplierLabel(_displayMultiplier),
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: labelFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                blurRadius: 5.0,
                color: Colors.black.withOpacity(0.7),
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
      ],
    );

    // Si está animado, aplicar un contenedor decorado
    if (widget.isAnimated) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: textColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: displayText,
      );
    }

    return displayText;
  }

  // Obtener una etiqueta descriptiva según el valor del multiplicador
  String _getMultiplierLabel(double multiplier) {
    if (widget.isExploded) {
      return 'EXPLOSIÓN';
    } else if (widget.isCashedOut) {
      return 'CASHOUT EXITOSO';
    } else if (multiplier >= 10.0) {
      return 'MULTIPLICADOR LEGENDARIO';
    } else if (multiplier >= 5.0) {
      return 'MULTIPLICADOR ÉPICO';
    } else if (multiplier >= 2.0) {
      return 'MULTIPLICADOR BUENO';
    } else {
      return 'MULTIPLICADOR';
    }
  }
}
