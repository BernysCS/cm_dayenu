import 'package:cm_dayenu/view/pantallas/mensajes.dart';
import 'package:cm_dayenu/view/pantallas/Principal/principal.dart';
import 'package:cm_dayenu/view/pantallas/reportes.dart';
import 'package:cm_dayenu/view/pantallas/usuarios/usuarios.dart';
import 'package:flutter/material.dart';

class Navegacion extends StatefulWidget {
  final String tipoUsuario;
  const Navegacion({super.key, required this.tipoUsuario});

  @override
  State<Navegacion> createState() => _NavegacionState();
}

class _NavegacionState extends State<Navegacion> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pantallas;
    List<BottomNavigationBarItem> items;

    if (widget.tipoUsuario == "admin") {
      pantallas = [
        const PantallaPrincipal(),
        const PantallaMensajes(),
        const PantallaUsuarios(),
        const PantallaReportes(),
      ];
      items = [
        BottomNavigationBarItem(
          icon: Icon(
            _indiceActual == 0
                ? Icons.calendar_today
                : Icons.calendar_today_outlined,
          ),
          label: 'Citas',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _indiceActual == 1 ? Icons.message : Icons.message_outlined,
          ),
          label: 'Mensajes',
        ),
        if (widget.tipoUsuario != 'doctor')
          BottomNavigationBarItem(
            icon: Icon(
              _indiceActual == 2 ? Icons.people : Icons.people_outline,
            ),
            label: 'Usuarios',
          ),
        if (widget.tipoUsuario == 'admin')
          BottomNavigationBarItem(
            icon: Icon(
              _indiceActual == 3
                  ? Icons.description
                  : Icons.description_outlined,
            ),
            label: 'Reportes',
          ),
      ];
    } else if (widget.tipoUsuario == "doctor") {
      pantallas = [const PantallaPrincipal(), const PantallaMensajes()];
      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Citas',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
      ];
    } else {
      pantallas = [
        const PantallaPrincipal(),
        const PantallaMensajes(),
        const PantallaUsuarios(),
      ];
      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Citas',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
      ];
    }

    return Scaffold(
      body: pantallas[_indiceActual],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300, // color de la línea
              width: 1.0, // grosor de la línea
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Color(0xFF579E93),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          currentIndex: _indiceActual,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _indiceActual = index;
            });
          },
          items: items,
        ),
      ),
    );
  }
}
