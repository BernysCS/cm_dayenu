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
          (_) => AlertDialog(
            title: Text(
              pacienteExistente == null
                  ? 'Agregar Paciente'
                  : 'Editar Paciente',
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese un nombre';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _edadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Edad'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese la edad';
                        }
                        final edad = int.tryParse(value.trim());
                        if (edad == null) {
                          return 'Edad inválida';
                        }
                        if (edad <= 0) {
                          return 'Edad debe ser mayor a cero';
                        }
                        if (edad > 120) {
                          return 'Edad debe ser menor de 120';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _pesoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Peso (kg)'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el peso';
                        }
                        final peso = double.tryParse(value.trim());
                        if (peso == null) {
                          return 'Peso inválido';
                        }
                        if (peso <= 0 || peso > 300) {
                          return 'Ingrese un peso mayor a 0 y menor 300';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _alturaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Altura (cm)',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Debe ingresar la altura';
                        }
                        final altura = double.tryParse(value.trim());
                        if (altura == null) {
                          return 'Altura inválida';
                        }
                        if (altura <= 0) {
                          return 'La altura debe ser mayor a 0 cm';
                        }
                        if (altura > 300) {
                          return 'La altura debe ser  menor a 300cm';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _dniController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'DNI'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el DNI';
                        }
                        final dni = int.tryParse(value);
                        if (dni == null || dni <= 0) {
                          return 'DNI debe ser mayot a cero';
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final nombre = _nombreController.text.trim();
                    final edad = int.tryParse(_edadController.text.trim()) ?? 0;
                    final peso =
                        double.tryParse(_pesoController.text.trim()) ?? 0.0;
                    final altura =
                        double.tryParse(_alturaController.text.trim()) ?? 0.0;
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
          if (snapshot.hasError) return const Text('Error al cargar pacientes');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final pacientes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final paciente = pacientes[index];
              return ListTile(
                title: Text(paciente['nombre']),
                subtitle: Text(
                  'Edad: ${paciente['edad']} - Peso: ${paciente['peso']}kg - Altura: ${paciente['altura']}cm\nDNI: ${paciente['dni']}',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed:
                          () => _mostrarFormulario(pacienteExistente: paciente),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('¿Eliminar Paciente?'),
                              content: const Text(
                                '¿Estás seguro de que deseas eliminar este paciente? Una vez eliminado no puede revertir la acción.',
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
                                    _eliminarPaciente(paciente.id);
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
