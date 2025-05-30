import 'package:intl/intl.dart';

/// Clase para formatear valores de moneda sin símbolo de divisa
/// para permitir mostrar una imagen de moneda personalizada en su lugar
class CurrencyFormatter {
  /// Formatea un valor a formato de moneda sin el símbolo
  /// Ej: 1000 -> "1,000.00"
  static String format(double value) {
    // Usamos NumberFormat pero con símbolo vacío
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '');
    // Retornamos el valor formateado, trimmeando espacios adicionales
    return formatter.format(value).trim();
  }

  /// Parsea un texto con formato de moneda a un valor doble
  /// Ej: "1,000.00" -> 1000.0
  static double parse(String text) {
    // Quitamos cualquier símbolo no numérico excepto . y ,
    String cleanText = text.replaceAll(RegExp(r'[^\d.,]'), '');
    // Quitamos las comas
    cleanText = cleanText.replaceAll(',', '');
    // Intentamos convertir a doble
    return double.tryParse(cleanText) ?? 0.0;
  }
}
