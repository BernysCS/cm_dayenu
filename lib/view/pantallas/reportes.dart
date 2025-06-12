import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PantallaReportes extends StatefulWidget {
  const PantallaReportes({super.key});

  @override
  State<PantallaReportes> createState() => _PantallaReportesState();
}

class _PantallaReportesState extends State<PantallaReportes> {
  int _mesSeleccionado = DateTime.now().month;
  int _anioSeleccionado = DateTime.now().year;

  // Rango fecha para filtro de citas
  DateTime get _inicioMes => DateTime(_anioSeleccionado, _mesSeleccionado, 1);
  DateTime get _finMes => DateTime(
    _anioSeleccionado,
    _mesSeleccionado + 1,
    1,
  ).subtract(const Duration(seconds: 1));

  Stream<QuerySnapshot> _obtenerCitasPorMes() {
    return FirebaseFirestore.instance
        .collection('citas')
        .where(
          'fechaHora',
          isGreaterThanOrEqualTo: Timestamp.fromDate(_inicioMes),
        )
        .where('fechaHora', isLessThanOrEqualTo: Timestamp.fromDate(_finMes))
        .snapshots();
  }

  Stream<QuerySnapshot> _obtenerUsuarios() {
    return FirebaseFirestore.instance.collection('usuarios').snapshots();
  }

  Stream<QuerySnapshot> _obtenerPacientes() {
    return FirebaseFirestore.instance.collection('pacientes').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte mensual')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Selector mes y año
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: _mesSeleccionado,
                  items: List.generate(12, (index) {
                    final mes = index + 1;
                    return DropdownMenuItem(
                      value: mes,
                      child: Text(
                        [
                          'Ene',
                          'Feb',
                          'Mar',
                          'Abr',
                          'May',
                          'Jun',
                          'Jul',
                          'Ago',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dic',
                        ][index],
                      ),
                    );
                  }),
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() => _mesSeleccionado = valor);
                    }
                  },
                ),
                const SizedBox(width: 20),
                DropdownButton<int>(
                  value: _anioSeleccionado,
                  items: List.generate(5, (index) {
                    final anio = DateTime.now().year - index;
                    return DropdownMenuItem(
                      value: anio,
                      child: Text(anio.toString()),
                    );
                  }),
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() => _anioSeleccionado = valor);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Reporte citas y usuarios con StreamBuilder
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: _obtenerCitasPorMes(),
                      builder: (context, snapshotCitas) {
                        if (snapshotCitas.hasError) {
                          return const Text('Error al cargar citas');
                        }
                        if (snapshotCitas.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final citas = snapshotCitas.data!.docs;

                        // Calcular total ingresos
                        double totalIngresos = 0;
                        for (var doc in citas) {
                          final precio = (doc['precio'] ?? 0).toDouble();
                          totalIngresos += precio;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total citas en ${_mesSeleccionado.toString().padLeft(2, '0')}/$_anioSeleccionado: ${citas.length}',
                            ),
                            Text(
                              'Ingresos totales: \$${totalIngresos.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 20),

                            // Usuarios y pacientes también en otro StreamBuilder
                            StreamBuilder<QuerySnapshot>(
                              stream: _obtenerUsuarios(),
                              builder: (context, snapshotUsuarios) {
                                if (snapshotUsuarios.hasError) {
                                  return const Text('Error al cargar usuarios');
                                }
                                if (snapshotUsuarios.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final usuarios = snapshotUsuarios.data!.docs;

                                // Contar usuarios por rol
                                final Map<String, int> conteoRoles = {};
                                for (var u in usuarios) {
                                  final rol = u['rol'] ?? 'desconocido';
                                  conteoRoles[rol] =
                                      (conteoRoles[rol] ?? 0) + 1;
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total usuarios: ${usuarios.length}'),
                                    for (var rol in conteoRoles.keys)
                                      Text(' - $rol: ${conteoRoles[rol]}'),

                                    const SizedBox(height: 20),

                                    // Pacientes
                                    StreamBuilder<QuerySnapshot>(
                                      stream: _obtenerPacientes(),
                                      builder: (context, snapshotPacientes) {
                                        if (snapshotPacientes.hasError) {
                                          return const Text(
                                            'Error al cargar pacientes',
                                          );
                                        }
                                        if (snapshotPacientes.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        final pacientes =
                                            snapshotPacientes.data!.docs;

                                        return Text(
                                          'Total pacientes: ${pacientes.length}',
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
