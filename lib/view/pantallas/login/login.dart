import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cm_dayenu/view/navegacion.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  String _error = '';

  Future<void> _iniciarSesion() async {
    final usuario = _usuarioController.text.trim();
    final contrasena = _contrasenaController.text.trim();

    if (usuario.isEmpty || contrasena.isEmpty) {
      setState(() {
        _error = 'Por favor, llena todos los campos.';
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('usuario', isEqualTo: usuario)
          .where('contrasena', isEqualTo: contrasena)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _error = 'Usuario o contraseña incorrectos.';
        });
      } else {
        final userData = snapshot.docs.first.data();
        final tipoUsuario = userData['rol'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Navegacion(tipoUsuario: tipoUsuario),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error al iniciar sesión: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usuarioController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contrasenaController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _iniciarSesion,
              child: const Text('Ingresar'),
            ),
            const SizedBox(height: 20),
            Text(
              _error,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
