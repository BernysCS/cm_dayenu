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
    final _formKey = GlobalKey<FormState>();

    final TextEditingController _usuarioController = TextEditingController(
      text: usuarioExistente != null ? usuarioExistente['usuario'] : '',
    );
    final TextEditingController _contrasenaController = TextEditingController(
      text: usuarioExistente != null ? usuarioExistente['contrasena'] : '',
    );
    final TextEditingController _confirmarContrasenaController =
        TextEditingController();

    String _rolSeleccionado =
        usuarioExistente != null ? usuarioExistente['rol'] : 'admin';

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: Center(
                    child: Text(
                      usuarioExistente == null
                          ? 'Agregar Usuario'
                          : 'Editar Usuario',
                      style: const TextStyle(
                        color: Color(0xFF009688),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _usuarioController,
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa un nombre de usuario';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _contrasenaController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmarContrasenaController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirmación de contraseña',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor confirma la contraseña';
                              }
                              if (value.trim() !=
                                  _contrasenaController.text.trim()) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _rolSeleccionado,
                            decoration: InputDecoration(
                              labelText: 'Rol',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (String? nuevoValor) {
                              if (nuevoValor != null) {
                                setStateDialog(() {
                                  _rolSeleccionado = nuevoValor;
                                });
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
                  ),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F1F1),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final usuario = _usuarioController.text.trim();
                          final contrasena = _contrasenaController.text.trim();

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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  '¡Usuario actualizado exitosamente!',
                                ),
                                backgroundColor: Colors.lightGreen,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Información'),
                      content: const Text(
                        'Página de información sobre usuarios: personal y paciente.',
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF009688),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cerrar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [Tab(text: 'Personal'), Tab(text: 'Pacientes')],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('usuarios').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar usuarios'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final usuarios = snapshot.data!.docs;

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: usuarios.length,
                      itemBuilder: (context, index) {
                        final usuario = usuarios[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 6.0,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Color(0xFF009688),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        usuario['usuario'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.verified_user,
                                        color: Color(0xFF009688),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Rol: ${usuario['rol']}'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.orange,
                                        ),
                                        onPressed:
                                            () => _mostrarFormulario(
                                              usuarioExistente: usuario,
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () async {
                                          final confirmar = await showDialog<
                                            bool
                                          >(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: const Text(
                                                    '¿Eliminar usuario?',
                                                  ),
                                                  content: const Text(
                                                    '¿Estás seguro de que deseas eliminar este usuario? Esta acción no se puede deshacer.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text(
                                                        'Cancelar',
                                                      ),
                                                      onPressed:
                                                          () => Navigator.of(
                                                            context,
                                                          ).pop(false),
                                                    ),
                                                    TextButton(
                                                      child: const Text(
                                                        'Eliminar',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      onPressed:
                                                          () => Navigator.of(
                                                            context,
                                                          ).pop(true),
                                                    ),
                                                  ],
                                                ),
                                          );

                                          if (confirmar == true) {
                                            await _eliminarUsuario(usuario.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FloatingActionButton(
                          backgroundColor: const Color(0xFF009688),
                          onPressed: () => _mostrarFormulario(),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const PantallaPacientes(),
          ],
        ),
      ),
    );
  }
}
