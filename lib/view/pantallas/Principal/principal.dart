import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cm_dayenu/controller/firestore.dart';
import 'package:cm_dayenu/view/pantallas/login/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();

  //controladores
  final TextEditingController textoControlador = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController motivoController = TextEditingController();
  final TextEditingController salaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  //abre un cuadro de dialogo para agregar una cita
  void abrirCajaCita({String? docID, Map<String, dynamic>? datos}) {
    if (datos != null) {
      // Carga los otros datos
      nombreController.text = datos['nombre'] ?? '';
      motivoController.text = datos['motivo'] ?? '';
      salaController.text = datos['sala'] ?? '';
      telefonoController.text = datos['telefono'] ?? '';
      precioController.text = datos['precio']?.toString() ?? '';

      // Carga fecha y hora si existen
      Timestamp? ts = datos['fechaHora'];
      if (ts != null) {
        fechaSeleccionada = ts.toDate();
        horaSeleccionada = TimeOfDay(
          hour: fechaSeleccionada!.hour,
          minute: fechaSeleccionada!.minute,
        );
      }
    } else {
      nombreController.clear();
      motivoController.clear();
      salaController.clear();
      telefonoController.clear();
      precioController.clear();
      fechaSeleccionada = null;
      horaSeleccionada = null;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(docID == null ? 'Agregar cita' : 'Editar cita'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: motivoController,
                    decoration: InputDecoration(labelText: 'Motivo'),
                  ),
                  TextField(
                    controller: salaController,
                    decoration: InputDecoration(labelText: 'Sala'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: telefonoController,
                    decoration: InputDecoration(labelText: 'Teléfono'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: precioController,
                    decoration: InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: 10),
                  // Botón para elegir fecha
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? fecha = await showDatePicker(
                        context: context,
                        initialDate: fechaSeleccionada ?? DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2100),
                      );
                      if (fecha != null) {
                        setState(() {
                          fechaSeleccionada = fecha;
                        });
                      }
                    },
                    child: Text(
                      fechaSeleccionada == null
                          ? 'Seleccionar fecha'
                          : 'Fecha: ${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}',
                    ),
                  ),

                  // Botón para elegir hora
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? hora = await showTimePicker(
                        context: context,
                        initialTime: horaSeleccionada ?? TimeOfDay.now(),
                      );
                      if (hora != null) {
                        setState(() {
                          horaSeleccionada = hora;
                        });
                      }
                    },
                    child: Text(
                      horaSeleccionada == null
                          ? 'Seleccionar hora'
                          : 'Hora: ${horaSeleccionada!.format(context)}',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // boton descartar anadi este boton aca
              ElevatedButton(
                onPressed: () {
                  // descartar
                  nombreController.clear();
                  motivoController.clear();
                  salaController.clear();
                  telefonoController.clear();
                  precioController.clear();
                  fechaSeleccionada = null;
                  horaSeleccionada = null;

                  // cerra el dialofo
                  Navigator.pop(context);
                },
                child: const Text('Descartar'),
              ),

              ElevatedButton(
                onPressed: () async {
                  DateTime fechaHora = DateTime(
                    fechaSeleccionada?.year ?? DateTime.now().year,
                    fechaSeleccionada?.month ?? DateTime.now().month,
                    fechaSeleccionada?.day ?? DateTime.now().day,
                    horaSeleccionada?.hour ?? 0,
                    horaSeleccionada?.minute ?? 0,
                  );

                  // Verificar si ya existe una cita en la misma fecha y hora
                  bool existe = await firestoreService.existeCitaEnFechaHora(
                    fechaHora,
                  );

                  // Si es una nueva cita y ya existe, mostrar error
                  if (existe && docID == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ya existe una cita en esa fecha y hora.',
                        ),
                      ),
                    );
                    return;
                  }

                  // Si es una edición, verificar si el nuevo horario no choca con otra cita (distinta)
                  if (existe && docID != null) {
                    // Traer todas las citas con esa fechaHora
                    QuerySnapshot duplicados =
                        await FirebaseFirestore.instance
                            .collection('citas')
                            .where(
                              'fechaHora',
                              isEqualTo: Timestamp.fromDate(fechaHora),
                            )
                            .get();

                    // Si hay otra cita con esa fecha y NO es esta misma que estamos editando
                    bool hayConflicto = duplicados.docs.any(
                      (doc) => doc.id != docID,
                    );
                    if (hayConflicto) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Otra cita ya está agendada en esa fecha y hora.',
                          ),
                        ),
                      );
                      return;
                    }
                  }

                  // Guardar o actualizar cita
                  if (docID == null) {
                    await firestoreService.agregarCita(
                      nombre: nombreController.text,
                      motivo: motivoController.text,
                      sala: salaController.text,
                      telefono: telefonoController.text,
                      precio: double.tryParse(precioController.text) ?? 0,
                      fechaHora: fechaHora,
                    );
                  } else {
                    await firestoreService.actualizarCita(
                      docID,
                      nombreController.text,
                      motivoController.text,
                      salaController.text,
                      telefonoController.text,
                      double.tryParse(precioController.text) ?? 0,
                      fechaHora,
                    );
                  }

                  // Limpiar campos
                  nombreController.clear();
                  motivoController.clear();
                  salaController.clear();
                  telefonoController.clear();
                  precioController.clear();
                  fechaSeleccionada = null;
                  horaSeleccionada = null;

                  Navigator.pop(context);
                },

                child: Text(docID == null ? 'Guardar' : 'Actualizar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dayenú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Limpia la sesión

              // Volver a pantalla de login
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PantallaLogin()),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Información'),
                    content: const Text(
                      'Página principal de creación de citas.',
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirCajaCita(),
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
                String nombre = data['nombre']?.toString() ?? 'Sin nombre';
                String motivo = data['motivo']?.toString() ?? 'Sin motivo';
                String sala = data['sala']?.toString() ?? 'Sin sala';
                String telefono =
                    data['telefono']?.toString() ?? 'Sin teléfono';
                double precio =
                    (data['precio'] != null)
                        ? double.tryParse(data['precio'].toString()) ?? 0.0
                        : 0.0;

                Timestamp ts = data['fechaHora'];
                DateTime fechaHora = ts.toDate();

                String fechaStr =
                    '${fechaHora.day}/${fechaHora.month}/${fechaHora.year}';
                String horaStr =
                    '${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}';

                //mostrar como un elemento de lista
                return ListTile(
                  title: Text(nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha: $fechaStr  Hora: $horaStr'),
                      Text('Motivo: $motivo'),
                      Text('Sala: $sala'),
                      Text('Teléfono: $telefono'),
                      Text('Precio: \$${precio.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //boton editar
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed:
                            () => abrirCajaCita(docID: docID, datos: data),
                      ),

                      //boton eliminar
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('¿Elimiacion de cita?'),
                                content: const Text(
                                  '¿Estás seguro de que deseas eliminar dicha cita?',
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      firestoreService.eliminarCita(docID);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete),
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