import 'package:cm_dayenu/firebase_options.dart';
import 'package:cm_dayenu/view/navegacion.dart';
import 'package:cm_dayenu/view/pantallas/login/login.dart';
import 'package:cm_dayenu/controller/controller_colors.dart'; // Importamos el controlador de colores
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Aseguramos que los widgets estén correctamente enlazados antes de inicializar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos Firebase con las opciones para la plataforma actual
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ejecutamos la aplicación principal
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  /// Método para verificar si el usuario ya ha iniciado sesión
  Future<Widget> _verificarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final logueado = prefs.getBool('logueado') ?? false;
    final rol = prefs.getString('rol') ?? '';

    // Si está logueado y tiene un rol, lo redirigimos según su tipo de usuario
    if (logueado && rol.isNotEmpty) {
      return Navegacion(tipoUsuario: rol);
    } else {
      // De lo contrario, lo llevamos a la pantalla de login
      return const PantallaLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dayenú',
      debugShowCheckedModeBanner: false,

      // Tema global de la aplicación (incluye el estilo de AppBar definido en ControllerColors)
      theme: ThemeData(
        appBarTheme: ControllerColors.gradientAppBarTheme,
      ),

      // Pantalla inicial envuelta en el fondo degradado rosado-azul
      home: FutureBuilder(
        future: _verificarSesion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras se carga la sesión, mostramos un indicador
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            // Envolvemos la pantalla resultante con el gradiente visual
            return ControllerColors.gradientWrapper(
              child: snapshot.data!,
            );
          }
        },
      ),
    );
  }
}