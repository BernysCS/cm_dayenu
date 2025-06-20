import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaPacientes extends StatefulWidget {
  const PantallaPacientes({super.key});

  @override
  State<PantallaPacientes> createState() => _PantallaPacientesState();
}

class _PantallaPacientesState extends State<PantallaPacientes> {
  void _mostrarFormulario({DocumentSnapshot? pacienteExistente}) {
    final _formKey = GlobalKey<FormState>();

    final TextEditingController _nombreController = TextEditingController(
      text: pacienteExistente != null ? pacienteExistente['nombre'] : '',
    );
    final TextEditingController _edadController = TextEditingController(
      text:
          pacienteExistente != null ? pacienteExistente['edad'].toString() : '',
    );
    final TextEditingController _pesoController = TextEditingController(
      text:
          pacienteExistente != null ? pacienteExistente['peso'].toString() : '',
    );
    final TextEditingController _alturaController = TextEditingController(
      text:
          pacienteExistente != null
              ? pacienteExistente['altura'].toString()
              : '',
    );
    final TextEditingController _dniController = TextEditingController(
      text: pacienteExistente != null ? pacienteExistente['dni'] : '',
    );

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: Center(
                    child: Text(
                      pacienteExistente == null
                          ? 'Agregar Paciente'
                          : 'Editar Paciente',
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
                            controller: _nombreController,
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingrese un nombre';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _edadController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Edad',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingrese la edad';
                              }
                              final edad = int.tryParse(value.trim());
                              if (edad == null || edad <= 0 || edad > 120) {
                                return 'Edad inválida';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _pesoController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Peso (kg)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingrese el peso';
                              }
                              final peso = double.tryParse(value.trim());
                              if (peso == null || peso <= 0 || peso > 300) {
                                return 'Peso inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _alturaController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Altura (cm)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingrese la altura';
                              }
                              final altura = double.tryParse(value.trim());
                              if (altura == null ||
                                  altura <= 0 ||
                                  altura > 300) {
                                return 'Altura inválida';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dniController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'DNI',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingrese el DNI';
                              }
                              final dni = int.tryParse(value);
                              if (dni == null || dni <= 0) {
                                return 'DNI inválido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
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
                          final nombre = _nombreController.text.trim();
                          final edad =
                              int.tryParse(_edadController.text.trim()) ?? 0;
                          final peso =
                              double.tryParse(_pesoController.text.trim()) ??
                              0.0;
                          final altura =
                              double.tryParse(_alturaController.text.trim()) ??
                              0.0;
                          final dni = _dniController.text.trim();

                          if (pacienteExistente == null) {
                            await FirebaseFirestore.instance
                                .collection('pacientes')
                                .add({
                                  'nombre': nombre,
                                  'edad': edad,
                                  'peso': peso,
                                  'altura': altura,
                                  'dni': dni,
                                });
                          } else {
                            await FirebaseFirestore.instance
                                .collection('pacientes')
                                .doc(pacienteExistente.id)
                                .update({
                                  'nombre': nombre,
                                  'edad': edad,
                                  'peso': peso,
                                  'altura': altura,
                                  'dni': dni,
                                });
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

  Future<void> _eliminarPaciente(String id) async {
    await FirebaseFirestore.instance.collection('pacientes').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pacientes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar pacientes'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pacientes = snapshot.data!.docs;
          if (pacientes.isEmpty) {
            return const Center(child: Text('No hay pacientes registrados.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final paciente = pacientes[index];
              final data = paciente.data() as Map<String, dynamic>;

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
                            const Icon(Icons.person, color: Color(0xFF009688)),
                            const SizedBox(width: 8),
                            Text(
                              data['nombre'] ?? '',
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
                            const Icon(Icons.cake, color: Color(0xFF009688)),
                            const SizedBox(width: 8),
                            Text('Edad: ${data['edad']} años'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.monitor_weight,
                              color: Color(0xFF009688),
                            ),
                            const SizedBox(width: 8),
                            Text('Peso: ${data['peso']} kg'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.height, color: Color(0xFF009688)),
                            const SizedBox(width: 8),
                            Text('Altura: ${data['altura']} cm'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.badge, color: Color(0xFF009688)),
                            const SizedBox(width: 8),
                            Text('DNI: ${data['dni']}'),
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
                                    pacienteExistente: paciente,
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
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: const Text(
                                          '¿Eliminar Paciente?',
                                        ),
                                        content: const Text(
                                          'Esta acción no se puede revertir.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
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
                                              _eliminarPaciente(paciente.id);
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
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
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF009688),
          onPressed: () => _mostrarFormulario(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
