import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cm_dayenu/controller/firestore.dart';
import 'package:cm_dayenu/view/pantallas/login/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cm_dayenu/controller/controller_colors.dart';

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

  // Método para abrir el diálogo de agregar/editar cita
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
                    const SizedBox(height: 15),

                    // Botón Seleccionar Fecha
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.grey),
                          backgroundColor: const Color(
                            0xFFF1F1F1,
                          ), // Gris claro
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                          style: const TextStyle(
                            color: Color(0xFF009688), // Verde
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Botón Seleccionar Hora
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.grey),
                          backgroundColor: const Color(
                            0xFFF1F1F1,
                          ), // Gris claro
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                          style: const TextStyle(
                            color: Color(0xFF009688), // Verde
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                    };

                    if (docID == null) {
                      await FirebaseFirestore.instance
                          .collection('citas')
                          .add(nuevaCita);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dayenú'),
        actions: [
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

                // Diseño de la tarjeta como en la imagen
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre y precio
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.teal[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '\$${precio.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Detalles con íconos
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16,color: Color(0xFF009688)),
                              const SizedBox(width: 6),
                              Text('Fecha: $fechaStr'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16,color: Color(0xFF009688)),
                              const SizedBox(width: 6),
                              Text('Hora: $horaStr'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.medical_services, size: 16,color: Color(0xFF009688)),
                              const SizedBox(width: 6),
                              Text('Motivo: $motivo'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.meeting_room, size: 16,color: Color(0xFF009688)),
                              const SizedBox(width: 6),
                              Text('Sala: $sala'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16,color: Color(0xFF009688)),
                              const SizedBox(width: 6),
                              Text('Teléfono: $telefono'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Botones Editar / Eliminar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed:
                                    () => abrirCajaCita(
                                      docID: docID,
                                      datos: data,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('¿Eliminar cita?'),
                                        content: const Text(
                                          '¿Estás seguro de que deseas eliminar esta cita?',
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFF1F1F1,
                                              ), // Gris claro
                                              foregroundColor: Colors.black87,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF009688,
                                              ), // Verde
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay citas...'));
          }
        },
      ),
    );
  }
}
