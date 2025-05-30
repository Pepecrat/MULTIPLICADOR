import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

/// Widget personalizado para mostrar valores monetarios con una imagen de moneda
class CoinText extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final double iconSize;
  final TextAlign textAlign;
  final bool showIcon;
  final double spacing;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;

  const CoinText({
    Key? key,
    required this.value,
    this.style,
    this.iconSize = 16.0,
    this.textAlign = TextAlign.start,
    this.showIcon = true,
    this.spacing = 4.0,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedValue = CurrencyFormatter.format(value);

    return Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        if (showIcon) ...[
          Image.asset(
            'assets/coin.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          SizedBox(width: spacing),
        ],
        Flexible(
          child: Text(
            formattedValue,
            style: style,
            textAlign: textAlign,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
