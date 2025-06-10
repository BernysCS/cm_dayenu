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
      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Principal',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Reportes',
        ),
      ];
    } else if (widget.tipoUsuario == "doctor") {
      pantallas = [const PantallaPrincipal(), const PantallaMensajes()];
      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Principal',
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
          label: 'Principal',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
      ];
    }

    return Scaffold(
      body: pantallas[_indiceActual],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        currentIndex: _indiceActual,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _indiceActual = index;
          });
        },
        items: items,
      ),
    );
  }
}
