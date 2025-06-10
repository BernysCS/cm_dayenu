import 'package:flutter/material.dart';

class PantallaUsuarios extends StatefulWidget {
  const PantallaUsuarios({super.key});

  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Usuarios'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Doctores'),
              Tab(text: 'Pacientes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Icon(Icons.local_hospital),
            Icon(Icons.supervised_user_circle_sharp),
          ],
        ),
      ),
    );
  }
}
