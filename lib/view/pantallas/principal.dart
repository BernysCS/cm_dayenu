import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cm_dayenu/controller/firestore.dart';
import 'package:flutter/material.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();

  //controlador de texto
  final TextEditingController textoControlador = TextEditingController();

  //abre un cuadro de dialogo para agregar una cita
  void abrirCajaCita(String? docID) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(controller: textoControlador),
            actions: [
              //boton para guardar
              ElevatedButton(
                onPressed: () {
                  // agregar una nueva cita
                  if (docID == null) {
                    firestoreService.agregarCita(textoControlador.text);
                  }
                  //actualizando una cita existente
                  else {
                    firestoreService.actualizarCita(
                      docID,
                      textoControlador.text,
                    );
                  }
                  // limpiar el texto del controlador
                  textoControlador.clear();
                  //cerrar la caja
                  Navigator.pop(context);
                },
                child: Text('Agregar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dayenú')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirCajaCita(null),
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.obtenerFlujoDeCitas(),
        builder: (context, snapshot) {
          //si tenemos datos, obtenemos todo
          if (snapshot.hasData) {
            List listaCitas = snapshot.data!.docs;

            //mostrar una lista
            return ListView.builder(
              itemCount: listaCitas.length,
              itemBuilder: (context, index) {
                //obtener cada documento individual
                DocumentSnapshot document = listaCitas[index];
                String docID = document.id;

                //obtener nota de cada documento
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String textoCita = data['cita'];

                //mostrar como un elemento de lista
                return ListTile(
                  title: Text(textoCita),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //boton actualizar
                      IconButton(
                        onPressed: () => abrirCajaCita(docID),
                        icon: Icon(Icons.edit),
                      ),
                      //boton eliminar
                      IconButton(
                        onPressed: () => firestoreService.eliminarCita(docID),
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          //si no hay datos, no devuelvas nada
          else {
            return const Text('No notes...');
          }
        },
      ),
    );
  }
}
