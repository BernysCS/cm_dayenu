import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaUsuarios extends StatefulWidget {
  const PantallaUsuarios({super.key});

  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  String _rolSeleccionado = 'admin';

  Future<void> agregarUsuario() async {
    String usuario = _usuarioController.text.trim();
    String contrasena = _contrasenaController.text.trim();

    if (usuario.isNotEmpty && contrasena.isNotEmpty) {
      await FirebaseFirestore.instance.collection('usuarios').add({
        'usuario': usuario,
        'contrasena': contrasena,
        'rol': _rolSeleccionado,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario agregado correctamente')),
      );

      _usuarioController.clear();
      _contrasenaController.clear();
      setState(() => _rolSeleccionado = 'admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Usuarios'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Personal'),
              Tab(text: 'Pacientes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _usuarioController,
                    decoration: const InputDecoration(labelText: 'Usuario'),
                  ),
                  TextField(
                    controller: _contrasenaController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                  ),
                  DropdownButton<String>(
                    value: _rolSeleccionado,
                    onChanged: (String? nuevoValor) {
                      setState(() {
                        _rolSeleccionado = nuevoValor!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                      DropdownMenuItem(value: 'recepcionista', child: Text('Recepcionista')),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: agregarUsuario,
                    child: const Text('Agregar Usuario'),
                  ),
                ],
              ),
            ),
            const Center(child: Icon(Icons.supervised_user_circle_sharp)),
          ],
        ),
      ),
    );
  }
}