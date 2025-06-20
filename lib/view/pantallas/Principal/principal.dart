import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cm_dayenu/controller/firestore.dart';
import 'package:cm_dayenu/main.dart';
import 'package:cm_dayenu/view/pantallas/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

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
  String? estadoSeleccionado = 'Programado';

  bool _mostrarBusqueda = false;
  final TextEditingController _busquedaController = TextEditingController();
  String _textoBusqueda = '';

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

      estadoSeleccionado = datos['estado'] ?? 'Programado';
    } else {
      nombreController.clear();
      motivoController.clear();
      salaController.clear();
      telefonoController.clear();
      precioController.clear();
      fechaSeleccionada = null;
      horaSeleccionada = null;

      estadoSeleccionado = 'Programado';
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

                    DropdownButtonFormField<String>(
                      value: estadoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items:
                          ['Programado', 'Completado', 'Cancelado'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          estadoSeleccionado = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona un estado';
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
                      'estado': estadoSeleccionado ?? 'Programado',
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

  void abrirGestionDeExtras(String docID, Map<String, dynamic> data) {
    List<dynamic> extras = List.from(data['extras'] ?? []);

    final _formKey = GlobalKey<FormState>();
    final descripcionController = TextEditingController();
    final montoController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Servicios extra'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: extras.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                Map<String, dynamic> extra = extras[index];
                                return ListTile(
                                  title: Text(extra['descripcion']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('\$${extra['monto']}'),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          extras.removeAt(index);
                                          await FirebaseFirestore.instance
                                              .collection('citas')
                                              .doc(docID)
                                              .update({'extras': extras});
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(),
                          TextFormField(
                            controller: descripcionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa una descripción';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: montoController,
                            decoration: const InputDecoration(
                              labelText: 'Monto',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa un monto';
                              }
                              final monto = double.tryParse(value.trim());
                              if (monto == null || monto <= 0) {
                                return 'Monto inválido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String desc = descripcionController.text.trim();
                          double monto = double.parse(
                            montoController.text.trim(),
                          );

                          extras.add({'descripcion': desc, 'monto': monto});
                          await FirebaseFirestore.instance
                              .collection('citas')
                              .doc(docID)
                              .update({'extras': extras});

                          descripcionController.clear();
                          montoController.clear();
                          setState(() {});
                        }
                      },
                      child: const Text('Agregar servicio extra'),
                    ),
                  ],
                ),
          ),
    );
  }

  void enviarWhatsApp(
    String telefono,
    String nombre,
    DateTime fechaCita,
  ) async {
    final fechaStr = '${fechaCita.day}/${fechaCita.month}/${fechaCita.year}';
    final mensaje =
        'Hola $nombre, somos del Centro Médico Dayenú 😊. Solo queremos recordarte que tienes una cita pendiente el $fechaStr. ¡No faltes, te esperamos con gusto!';

    final telefonoFormateado = '504$telefono';

    final url = Uri.parse(
      'https://wa.me/$telefonoFormateado?text=${Uri.encodeComponent(mensaje)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('No se pudo abrir WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dayenú'),
        actions: [
          if (!_mostrarBusqueda)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _mostrarBusqueda = true;
                });
              },
            ),

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

      // busqueda
      body: Column(
        children: [
          if (_mostrarBusqueda)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _busquedaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        _busquedaController.clear();
                        setState(() {
                          _textoBusqueda = '';
                          _mostrarBusqueda = false;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) {
                    setState(() => _textoBusqueda = value.toLowerCase());
                  },
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.obtenerFlujoDeCitas(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List listaCitas = snapshot.data!.docs;

                  if (_textoBusqueda.isNotEmpty) {
                    listaCitas =
                        listaCitas.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final nombre =
                              data['nombre']?.toString().toLowerCase() ?? '';
                          return nombre.contains(_textoBusqueda);
                        }).toList();
                  }

                  if (listaCitas.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron citas con ese nombre.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: listaCitas.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = listaCitas[index];
                      String docID = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      String nombre =
                          data['nombre']?.toString() ?? 'Sin nombre';
                      String motivo =
                          data['motivo']?.toString() ?? 'Sin motivo';
                      String sala = data['sala']?.toString() ?? 'Sin sala';
                      String telefono =
                          data['telefono']?.toString() ?? 'Sin teléfono';

                      Timestamp ts = data['fechaHora'];
                      DateTime fechaHora = ts.toDate();

                      String fechaStr =
                          '${fechaHora.day}/${fechaHora.month}/${fechaHora.year}';
                      String horaStr =
                          '${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}';
                      String estado =
                          data['estado']?.toString() ?? 'Programado';

                      double precioBase =
                          (data['precio'] != null)
                              ? double.tryParse(data['precio'].toString()) ??
                                  0.0
                              : 0.0;

                      List<dynamic> extras = data['extras'] ?? [];
                      double totalExtras = extras.fold(
                        0.0,
                        (suma, item) => suma + (item['monto'] ?? 0.0),
                      );

                      double total = precioBase + totalExtras;

                      return ListTile(
                        title: Text(nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha: $fechaStr  Hora: $horaStr'),
                            Text('Motivo: $motivo'),
                            Text('Sala: $sala'),
                            Text('Teléfono: $telefono'),
                            Text(
                              'Precio base: \$${precioBase.toStringAsFixed(2)}',
                            ),
                            Text('Extras: \$${totalExtras.toStringAsFixed(2)}'),
                            Text('Total: \$${total.toStringAsFixed(2)}'),
                            Text(
                              'Estado: $estado',
                              style: TextStyle(
                                color:
                                    estado == 'Completado'
                                        ? Colors.blue
                                        : estado == 'Cancelado'
                                        ? Colors.red
                                        : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.notifications,
                                color: Colors.yellow,
                              ),
                              onPressed: () {
                                Timestamp ts = data['fechaHora'];
                                DateTime fechaHora = ts.toDate();

                                enviarWhatsApp(telefono, nombre, fechaHora);
                              },
                            ),

                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed:
                                  () =>
                                      abrirCajaCita(docID: docID, datos: data),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
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
                                            firestoreService.eliminarCita(
                                              docID,
                                            );
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.medical_services_outlined),
                              onPressed:
                                  () => abrirGestionDeExtras(docID, data),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
