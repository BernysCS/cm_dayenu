import 'package:cm_dayenu/view/pantallas/mensajes.dart';
import 'package:cm_dayenu/view/pantallas/Principal/principal.dart';
import 'package:cm_dayenu/view/pantallas/reportes.dart';
import 'package:cm_dayenu/view/pantallas/usuarios/usuarios.dart';
import 'package:flutter/material.dart';

class Navegacion extends StatefulWidget {
  const Navegacion({super.key});

  @override
  State<Navegacion> createState() => _NavegacionState();
}

class _NavegacionState extends State<Navegacion> {
  //indice para controlar las pantallas
  int _indiceActual = 0;
  String tipoUsuario = "admin";

  @override
  Widget build(BuildContext context) {
    //arreglo para pantallas
    List<Widget> pantallas;
    //arreglo para los items que se van a mostras en pantalla dependiendo del usuario
    List<BottomNavigationBarItem> items;
    //Si el usuario es admin se muestras las pantallas: principal, crearCita, mensajes, reportes
    if (tipoUsuario == "admin") {
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
      //si el usuario es doctor se muestras las pantllas principal y mensajes
    } else if (tipoUsuario == "doctor") {
      pantallas = [const PantallaPrincipal(), const PantallaMensajes()];
      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Principal',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
      ];
    } else {
      // si es usuario es recepcionista se muestran las pantallas principal, crearcita, mensajes
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

    //Barra baja que hace la navegación de las pantallas
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
