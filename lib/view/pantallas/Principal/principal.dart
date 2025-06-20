import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cm_dayenu/controller/firestore.dart';
import 'package:cm_dayenu/main.dart';
import 'package:cm_dayenu/view/pantallas/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

// pendiente de que funcione la notificación dependiendo de la cita pero la notificación que esta en el appbar si funciona

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final FirestoreService firestoreService = FirestoreService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController motivoController = TextEditingController();
  final TextEditingController salaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController precioController = TextEditingController();

  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;

  void programarNotificacion(
    DateTime fechaHora,
    String sala,
    String id,
    String horaStr,
  ) {
    try {
      final fechaNotificacion = fechaHora.subtract(const Duration(minutes: 10));

      print('Fecha original: $fechaHora');
      print('Fecha notificación: $fechaNotificacion');
      print('Ahora: ${DateTime.now()}');

      if (fechaNotificacion.isAfter(DateTime.now())) {
        flutterLocalNotificationsPlugin.zonedSchedule(
          id.hashCode,
          'Cita próxima',
          'Nueva cita en sala $sala a las $horaStr. Tenlo en cuenta.',
          tz.TZDateTime.from(fechaNotificacion, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'canal_citas',
              'Citas',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
        print('Notificación programada correctamente');
      } else {
        print('No se programa notificación: fechaNotificacion ya pasó');
      }
    } catch (e, stack) {
      print('Error al programar notificación: $e');
      print(stack);
    }
  }

  void abrirCajaCita({String? docID, Map<String, dynamic>? datos}) {
    if (datos != null) {
      nombreController.text = datos['nombre'] ?? '';
      motivoController.text = datos['motivo'] ?? '';
      salaController.text = datos['sala'] ?? '';
      telefonoController.text = datos['telefono'] ?? '';
      precioController.text = datos['precio']?.toString() ?? '';
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: InputDecoration(labelText: 'Nombre'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debe de ingresar un nombre';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: motivoController,
                      decoration: InputDecoration(labelText: 'Motivo'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debe de ingresar un motivo';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: salaController,
                      decoration: InputDecoration(labelText: 'Sala'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debe ingresar una sala';
                        }
                        final numero = int.tryParse(value);
                        //esta variable final hace que
                        //int.tryParse(value) convierte el texto a número, o da null si el texto no es válido.
                        if (numero == null || numero <= 0) {
                          return 'Numero de sala invalido';
                        }
                        return null;
                      },
                    ),

                    TextFormField(
                      controller: telefonoController,
                      decoration: InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'Debe ingresar un teléfono valido';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: precioController,
                      decoration: InputDecoration(labelText: 'Precio'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa un precio';
                        }
                        final precio = double.tryParse(value);
                        if (precio == null || precio <= 0) {
                          return 'Debe ingresar un numero mayor a cero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
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
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  nombreController.clear();
                  motivoController.clear();
                  salaController.clear();
                  telefonoController.clear();
                  precioController.clear();
                  fechaSeleccionada = null;
                  horaSeleccionada = null;
                  Navigator.pop(context);
                },
                child: const Text('Descartar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final sala = salaController.text.trim();

                    // Combina fecha y hora seleccionada en un solo DateTime
                    DateTime fechaHora = DateTime(
                      fechaSeleccionada?.year ?? DateTime.now().year,
                      fechaSeleccionada?.month ?? DateTime.now().month,
                      fechaSeleccionada?.day ?? DateTime.now().day,
                      horaSeleccionada?.hour ?? 0,
                      horaSeleccionada?.minute ?? 0,
                    );

                    // Busca si ya existe una cita en la misma fecha y hora
                    QuerySnapshot duplicados =
                        await FirebaseFirestore.instance
                            .collection('citas')
                            .where(
                              'fechaHora',
                              isEqualTo: Timestamp.fromDate(fechaHora),
                            )
                            .get();

                    // Evalúa si hay conflicto con la sala (misma fechaHora y misma sala)
                    bool hayConflicto = duplicados.docs.any((doc) {
                      final datos = doc.data() as Map<String, dynamic>;
                      final salaDoc = datos['sala'];
                      final mismoID =
                          (docID != null && doc.id == docID); // edición propia
                      return salaDoc == sala && !mismoID;
                    });

                    // Si hay conflicto de sala, se bloquea
                    if (hayConflicto) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ya hay una cita en esa sala a esa fecha y hora.',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    // Si NO hay conflicto, se puede guardar o actualizar la cita
                    final nuevaCita = {
                      'nombre': nombreController.text.trim(),
                      'motivo': motivoController.text.trim(),
                      'telefono': telefonoController.text.trim(),
                      'precio':
                          double.tryParse(precioController.text.trim()) ?? 0,
                      'sala': sala,
                      'fechaHora': Timestamp.fromDate(fechaHora),
                      'timestamp': FieldValue.serverTimestamp(),
                    };

                    // Crear nueva cita
                    if (docID == null) {
                      final docRef = await FirebaseFirestore.instance
                          .collection('citas')
                          .add(nuevaCita);

                      // Generar hora en formato texto
                      String horaStr =
                          '${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}';

                      // Programar notificación con el nuevo ID
                      programarNotificacion(
                        fechaHora,
                        sala,
                        docRef.id,
                        horaStr,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Cita creada exitosamente!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      await FirebaseFirestore.instance
                          .collection('citas')
                          .doc(docID)
                          .update(nuevaCita);

                      // Generar hora en formato texto
                      String horaStr =
                          '${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}';

                      // Programar notificación con el ID existente
                      programarNotificacion(
                        fechaHora,
                        nombreController.text.trim(),
                        docID,
                        horaStr,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Cita actualizada exitosamente!'),
                          backgroundColor: Colors.blue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }

                    // Limpia y cierra el formulario
                    nombreController.clear();
                    motivoController.clear();
                    salaController.clear();
                    telefonoController.clear();
                    precioController.clear();
                    fechaSeleccionada = null;
                    horaSeleccionada = null;

                    Navigator.pop(context);
                  }
                },
                child: Text(docID == null ? 'Guardar Cita' : 'Actualizar Cita'),
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
          if (snapshot.hasData) {
            List listaCitas = snapshot.data!.docs;
            return ListView.builder(
              itemCount: listaCitas.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = listaCitas[index];
                String docID = document.id;
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
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed:
                            () => abrirCajaCita(docID: docID, datos: data),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('¿Elimiación de cita?'),
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
          } else {
            return const Text('No notes...');
          }
        },
      ),
    );
  }
}
