import 'package:flutter/material.dart';

///
/// Clase que se encarga de gestionar los colores de la aplicación.
/// Paleta basada en Centro Médico Dayenú
///
class ControllerColors {
  // Colores básicos
  static const Color transparent = Color.fromARGB(0, 229, 215, 215);
  static const Color white = Colors.white;
  static const Color black = Color.fromARGB(255, 69, 67, 67);
  static const Color grey = Colors.grey;

  // Colores de la paleta Dayenú
  static const Color dayenuPink = Color.fromRGBO(234, 153, 176, 1.0);       // PANTONE P.12-4 C
  static const Color dayenuLightBlue = Color.fromRGBO(66, 162, 174, 1.0);  // PANTONE P.128-3 C
  static const Color dayenuTeal = Color.fromRGBO(87, 158, 147, 1.0);       // PANTONE P.138-3 C
  static const Color dayenuPurple = Color.fromRGBO(133, 131, 182, 1.0);    // PANTONE P.80-4 C (ajustado)

  // Nuevo rosado pastel basado en imagen proporcionada
  static const Color softPink = Color.fromRGBO(87, 158, 147, 1.0);        // Rosado pastel
  static const Color lightSkyBlue = Color.fromRGBO(87, 158, 147, 1.0);     // Azul celeste claro

  // Nueva paleta principal
  static const Color primary = dayenuTeal;                     // Color principal
  static const Color primaryDark = Color.fromRGBO(60, 120, 110, 1.0);  // Versión oscura del teal
  static const Color primaryLight = Color.fromRGBO(180, 210, 205, 1.0); // Versión clara del teal
  static const Color accent = dayenuPink;                      // Color de acento
  static const Color secondary = dayenuLightBlue;              // Color secundario
  static const Color tertiary = dayenuPurple;                  // Color terciario

  // Colores de texto
  static const Color text = Color.fromRGBO(50, 50, 50, 1.0);      // Texto oscuro
  static const Color textLight = Color.fromRGBO(240, 240, 240, 1.0); // Texto claro
  static const Color textDark = Color.fromRGBO(30, 30, 30, 1.0);   // Texto muy oscuro

  // Elementos de UI
  static const Color divider = Color.fromRGBO(200, 200, 200, 1.0);
  static const Color icon = dayenuLightBlue;
  static const Color background = Color.fromRGBO(245, 245, 245, 1.0); // Fondo neutro para widgets con color sólido

  // Degradado principal rosado pastel a azul celeste
  static LinearGradient mainGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      softPink,
      lightSkyBlue,
    ],
  );

  // Configuración de AppBar para el fondo degradado
  static AppBarTheme gradientAppBarTheme = AppBarTheme(
    backgroundColor: primary, // Usamos el color primario de Dayenú
    elevation: 2,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      color: white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: const IconThemeData(color: white),
  );

  ///
  /// Widget que aplica el fondo degradado rosado-azul
  ///
  static Widget gradientWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: mainGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: child),
      ),
    );
  }

  ///
  /// Método que obtiene el color de contexto.
  ///
  /// [context] Contexto de la aplicación.
  ///
  static Color getContextColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  ///
  /// Método que obtiene el color de texto según el contexto.
  ///
  /// [context] Contexto de la aplicación.
  /// [isListTile] Indica si proviene de un [ListTile].
  ///
  static Color? getTextColor(BuildContext context, {bool isListTile = false}) {
    if (isListTile) {
      return Theme.of(context).listTileTheme.textColor;
    } else {
      return Theme.of(context).textTheme.titleLarge?.color;
    }
  }
}