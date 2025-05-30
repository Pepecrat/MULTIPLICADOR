import 'package:flutter/material.dart';
import '../constants/colors.dart';

class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool isDisabled;
  final double width;
  final double height;
  final IconData? icon;

  const GameButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.java,
    this.isDisabled = false,
    this.width = double.infinity,
    this.height = 50,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          disabledBackgroundColor: Colors.grey,
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14),
                const SizedBox(width: 6),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
