import 'package:cm_dayenu/view/pantallas/usuarios/pantalla_pacientes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaUsuarios extends StatefulWidget {
  const PantallaUsuarios({super.key});

  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  void _mostrarFormulario({DocumentSnapshot? usuarioExistente}) {
    final TextEditingController _usuarioController = TextEditingController(
      text: usuarioExistente != null ? usuarioExistente['usuario'] : '',
    );
    final TextEditingController _contrasenaController = TextEditingController(
      text: usuarioExistente != null ? usuarioExistente['contrasena'] : '',
    );
    String _rolSeleccionado =
        usuarioExistente != null ? usuarioExistente['rol'] : 'admin';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder:
              (context, setStateDialog) => AlertDialog(
                title: Text(
                  usuarioExistente == null
                      ? 'Agregar Usuario'
                      : 'Editar Usuario',
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _usuarioController,
                        decoration: const InputDecoration(labelText: 'Usuario'),
                      ),
                      TextField(
                        controller: _contrasenaController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        obscureText: true,
                      ),
                      DropdownButton<String>(
                        value: _rolSeleccionado,
                        onChanged: (String? nuevoValor) {
                          if (nuevoValor != null) {
                            setStateDialog(
                              () => _rolSeleccionado = nuevoValor,
                            ); // Usamos el setState local
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: 'doctor',
                            child: Text('Doctor'),
                          ),
                          DropdownMenuItem(
                            value: 'recepcionista',
                            child: Text('Recepcionista'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final usuario = _usuarioController.text.trim();
                      final contrasena = _contrasenaController.text.trim();
                      if (usuario.isNotEmpty && contrasena.isNotEmpty) {
                        if (usuarioExistente == null) {
                          await FirebaseFirestore.instance
                              .collection('usuarios')
                              .add({
                                'usuario': usuario,
                                'contrasena': contrasena,
                                'rol': _rolSeleccionado,
                              });
                        } else {
                          await FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(usuarioExistente.id)
                              .update({
                                'usuario': usuario,
                                'contrasena': contrasena,
                                'rol': _rolSeleccionado,
                              });
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
        );
      },
    );
  }

  Future<void> _eliminarUsuario(String id) async {
    await FirebaseFirestore.instance.collection('usuarios').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Usuarios'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Personal'), Tab(text: 'Pacientes')],
          ),
        ),
        body: TabBarView(
          children: [
            // Lista de usuarios (Personal)
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('usuarios').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Text('Error al cargar usuarios');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final usuarios = snapshot.data!.docs;

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: 80,
                      ), // espacio para el botón
                      itemCount: usuarios.length,
                      itemBuilder: (context, index) {
                        final usuario = usuarios[index];
                        return ListTile(
                          title: Text(usuario['usuario']),
                          subtitle: Text('Rol: ${usuario['rol']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed:
                                    () => _mostrarFormulario(
                                      usuarioExistente: usuario,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _eliminarUsuario(usuario.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Botón de icono centrado en la parte inferior
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: IconButton(
                          iconSize: 56,
                          icon: const Icon(
                            Icons.add_circle,
                          ),
                          onPressed: () => _mostrarFormulario(),
                          tooltip: 'Agregar Usuario',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Segunda pestaña (Pacientes)
            PantallaPacientes()
          ],
        ),

      ),
    );
  }
}
