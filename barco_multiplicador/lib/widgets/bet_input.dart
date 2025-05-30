import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/game_model.dart';
import '../utils/currency_formatter.dart';

class BetInput extends StatefulWidget {
  final Function(double) onBetSubmitted;
  final bool isEnabled;

  const BetInput({
    Key? key,
    required this.onBetSubmitted,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<BetInput> createState() => _BetInputState();
}

class _BetInputState extends State<BetInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Auto-submit cuando pierde el foco
        _submitBet();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitBet() {
    if (!widget.isEnabled) return;

    // Ocultar el teclado explícitamente
    FocusScope.of(context).unfocus();

    // Convertir el texto a un valor numérico usando nuestro formateador
    double bet = CurrencyFormatter.parse(_controller.text);

    // Validar la apuesta con el modelo de juego
    final gameModel = Provider.of<GameModel>(context, listen: false);

    setState(() {
      _errorText = null; // Resetear mensaje de error
    });

    if (bet <= 0) {
      setState(() {
        _errorText = 'Ingresa un monto válido';
      });
      return;
    }

    if (bet > gameModel.balance) {
      setState(() {
        _errorText = 'Saldo insuficiente';
      });
      return;
    }

    // Si llegamos aquí, la apuesta es válida
    widget.onBetSubmitted(bet);
  }

  @override
  Widget build(BuildContext context) {
    final gameModel = Provider.of<GameModel>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Usar el ancho disponible para determinar el tamaño máximo de los elementos
        final maxWidth = constraints.maxWidth;
        final isCompact = maxWidth < 150;

        // Envolver en GestureDetector para cerrar el teclado al tocar fuera del campo
        return GestureDetector(
          onTap: () {
            // Cerrar el teclado al tocar fuera del campo
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título de la apuesta
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'TU APUESTA',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      color: AppColors.java,
                      fontSize: isCompact ? 8 : 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 10 : 12),
              // Campo de entrada
              Container(
                height: isCompact ? 40 : 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  // Si hay un error, mostrar un borde rojo
                  border:
                      _errorText != null
                          ? Border.all(color: AppColors.red, width: 1.5)
                          : null,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.isEnabled,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: isCompact ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackPearl,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontFamily: 'PressStart2P',
                      color: AppColors.blackPearl.withOpacity(0.5),
                      fontSize: isCompact ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    prefixIcon:
                        isCompact
                            ? null
                            : Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Image.asset(
                                'assets/coin.png',
                                width: 48,
                                height: 48,
                              ),
                            ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 48,
                      maxWidth: 48,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 4 : 8,
                      vertical: isCompact ? 12 : 16,
                    ),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                    LengthLimitingTextInputFormatter(10), // Limitar la longitud
                  ],
                  onSubmitted: (_) => _submitBet(),
                ),
              ),
              // Mostrar mensaje de error si existe
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      color: AppColors.red,
                      fontSize: isCompact ? 8 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: _errorText != null ? 6 : (isCompact ? 10 : 14)),
              // Botón de apuesta
              SizedBox(
                height: isCompact ? 28 : 35,
                child: ElevatedButton(
                  onPressed: widget.isEnabled ? _submitBet : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.java,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isCompact ? 6 : 10,
                      horizontal: isCompact ? 10 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey,
                    elevation: 3,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'APOSTAR',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isCompact ? 8 : 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
