import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaTareas extends StatefulWidget {
  final String docID;
  final String nombre;

  const PantallaTareas({Key? key, required this.docID, required this.nombre})
      : super(key: key);

  @override
  State<PantallaTareas> createState() => _PantallaTareasState();
}

class _PantallaTareasState extends State<PantallaTareas> {
  @override
  void initState() {
    super.initState();
  }

  CollectionReference getTareasRef() {
    return FirebaseFirestore.instance
        .collection('citas')
        .doc(widget.docID)
        .collection('tareas');
  }

  Future<void> agregarTarea(String descripcion) async {
    await getTareasRef().add({
      'descripcion': descripcion,
      'realizada': false,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> actualizarDescripcion(String tareaID, String nuevaDesc) async {
    await getTareasRef().doc(tareaID).update({'descripcion': nuevaDesc});
  }

  Future<void> actualizarEstado(String tareaID, bool estado) async {
    await getTareasRef().doc(tareaID).update({'realizada': estado});
  }

  Future<void> eliminarTarea(String tareaID) async {
    await getTareasRef().doc(tareaID).delete();
  }

  void mostrarDialogoAgregar() {
    TextEditingController controlador = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo pendiente'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Escribe la tarea'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Guardar'),
            onPressed: () {
              final texto = controlador.text.trim();
              if (texto.isNotEmpty) {
                agregarTarea(texto);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void mostrarDialogoEditar(String tareaID, String descripcionActual) {
    TextEditingController controlador =
        TextEditingController(text: descripcionActual);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar tarea'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nueva descripción'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Actualizar'),
            onPressed: () {
              final texto = controlador.text.trim();
              if (texto.isNotEmpty) {
                actualizarDescripcion(tareaID, texto);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pendientes de ${widget.nombre}'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: mostrarDialogoAgregar,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getTareasRef().orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final tareas = snapshot.data!.docs;

            if (tareas.isEmpty) {
              return const Center(child: Text('Sin pendientes aún.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: tareas.length,
              itemBuilder: (context, index) {
                final tarea = tareas[index];
                final data = tarea.data() as Map<String, dynamic>;
                final tareaID = tarea.id;
                final descripcion = data['descripcion'] ?? '';
                final realizada = data['realizada'] ?? false;

                return Card(
                  color: realizada ? null : Color(0xFFFFE6EC),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: CheckboxListTile(
                    activeColor: Colors.teal,
                    value: realizada,
                    title: Text(
                      descripcion,
                      style: TextStyle(
                        decoration:
                            realizada ? TextDecoration.lineThrough : null,
                        color: realizada ? Colors.grey : Colors.black,
                        fontStyle:
                            realizada ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        actualizarEstado(tareaID, value);
                      }
                    },
                    secondary: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF41A2AE)),
                      onPressed: () {
                        mostrarDialogoEditar(tareaID, descripcion);
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
