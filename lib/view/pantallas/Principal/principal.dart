import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cm_dayenu/controller/firestore.dart';
import 'package:cm_dayenu/main.dart';
import 'package:cm_dayenu/view/pantallas/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cm_dayenu/controller/controller_colors.dart';
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Bordes redondeados
            ),
            title: Center(
              child: Text(
                docID == null ? 'Agregar cita' : 'Editar cita',
                style: const TextStyle(
                  color: Color(0xFF009688), // Verde
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo Nombre
                    TextFormField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debe de ingresar un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Campo Motivo
                    TextFormField(
                      controller: motivoController,
                      decoration: InputDecoration(
                        labelText: 'Motivo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debe de ingresar un motivo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Campo Sala
                    TextFormField(
                      controller: salaController,
                      decoration: InputDecoration(
                        labelText: 'Sala',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debe ingresar una sala';
                        }
                        final numero = int.tryParse(value);
                        if (numero == null || numero <= 0) {
                          return 'Numero de sala invalido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Campo Teléfono
                    TextFormField(
                      controller: telefonoController,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'Debe ingresar un teléfono valido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Campo Precio
                    TextFormField(
                      controller: precioController,
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
              // Botón Descartar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F1F1), // Gris claro
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // limpiar formulario
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

              // Botón Actualizar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF009688), // Verde
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
                    if (fechaSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Debes seleccionar una fecha.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (horaSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Debes seleccionar una hora.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

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
                      final mismoID = (docID != null && doc.id == docID);
                      return salaDoc == sala && !mismoID;
                    });

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
                      programarNotificacion(fechaHora, sala, docID, horaStr);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Cita actualizada exitosamente!'),
                          backgroundColor: Color.fromARGB(255, 15, 154, 189),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }

                    // limpiar
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
                child: Text(docID == null ? 'Guardar' : 'Actualizar'),
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
        title: const Text('Dayenú'),
        centerTitle: false,
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF009688), // color teal
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12, // altura
                          ),
                          elevation: 2, // misma sombra que los botones del form
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold, // mismo peso que el form
                          ),
                        ),
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
        backgroundColor: Color(0xFF009688),

        onPressed: () => abrirCajaCita(),

        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          if (_mostrarBusqueda)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _busquedaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        _busquedaController.clear();
                        setState(() {
                          _textoBusqueda = '';
                          _mostrarBusqueda = false;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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

                      Color estadoColor;
                      if (estado == 'Completado') {
                        estadoColor = const Color(0xFF41A2AE); // azul
                      } else if (estado == 'Cancelado') {
                        estadoColor = const Color(0xFFF599B0); // rosa
                      } else {
                        estadoColor = const Color(0xFF579E93); // verde
                      }

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.teal),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      nombre,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      estado,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: estadoColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 6),
                                  Text('Fecha: $fechaStr'),
                                  SizedBox(width: 12),
                                  Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(width: 6),
                                  Text('Hora: $horaStr'),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Motivo: $motivo'),
                              Text('Sala: $sala'),
                              Text('Teléfono: $telefono'),
                              const Divider(thickness: 1, color: Colors.grey),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Precio base: \$${precioBase.toStringAsFixed(2)}',
                                        ),
                                        Text(
                                          'Extras: \$${totalExtras.toStringAsFixed(2)}',
                                        ),
                                        Text(
                                          'Total: \$${total.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.notifications,
                                              color: Colors.amber,
                                            ),
                                            tooltip: 'Enviar recordatorio',
                                            onPressed: () {
                                              enviarWhatsApp(
                                                telefono,
                                                nombre,
                                                fechaHora,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.blueGrey,
                                            ),
                                            tooltip: 'Editar cita',
                                            onPressed:
                                                () => abrirCajaCita(
                                                  docID: docID,
                                                  datos: data,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                            tooltip: 'Eliminar cita',
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (
                                                  BuildContext context,
                                                ) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      '¿Eliminar cita?',
                                                    ),
                                                    content: const Text(
                                                      '¿Estás seguro de que deseas eliminar esta cita?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        child: const Text(
                                                          'Cancelar',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          firestoreService
                                                              .eliminarCita(
                                                                docID,
                                                              );
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        child: const Text(
                                                          'Eliminar',
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.medical_services_outlined,
                                              color: Colors.deepPurple,
                                            ),
                                            tooltip: 'Ver extras',
                                            onPressed:
                                                () => abrirGestionDeExtras(
                                                  docID,
                                                  data,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
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
          ),
        ],
      ),
    );
  }
}
