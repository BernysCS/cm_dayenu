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

  Widget _crearTarjetaMetrica(
    IconData icono,
    String titulo,
    String valor,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Container(
        width: 160,
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icono, color: Color(0xFF009688)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(valor, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte Mensual'),
        backgroundColor: Color(0xFF009688),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Información'),
                    content: const Text(
                      'Información sobre los reportes: citas, usuarios, pacientes e ingresos mensuales.',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Selector de mes y año
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE6EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _mesSeleccionado,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF009688),
                        ),
                        dropdownColor: Colors.white,
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
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }),
                        onChanged: (valor) {
                          if (valor != null) {
                            setState(() => _mesSeleccionado = valor);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE6EC),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _anioSeleccionado,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF009688),
                        ),
                        dropdownColor: Colors.white,
                        items: List.generate(5, (index) {
                          final anio = DateTime.now().year - index;
                          return DropdownMenuItem(
                            value: anio,
                            child: Text(
                              anio.toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }),
                        onChanged: (valor) {
                          if (valor != null) {
                            setState(() => _anioSeleccionado = valor);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Métricas principales
            StreamBuilder<QuerySnapshot>(
              stream: _obtenerCitasPorMes(),
              builder: (context, snapshotCitas) {
                if (!snapshotCitas.hasData)
                  return const CircularProgressIndicator();

                final citas = snapshotCitas.data!.docs;
                double totalIngresos = 0;

                for (var doc in citas) {
                  final data = doc.data() as Map<String, dynamic>;
                  double precioBase =
                      (data['precio'] != null)
                          ? double.tryParse(data['precio'].toString()) ?? 0.0
                          : 0.0;
                  List<dynamic> extras = data['extras'] ?? [];
                  double totalExtras = extras.fold(
                    0.0,
                    (suma, item) => suma + (item['monto'] ?? 0.0),
                  );
                  totalIngresos += precioBase + totalExtras;
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: _obtenerPacientes(),
                  builder: (context, snapshotPacientes) {
                    if (!snapshotPacientes.hasData)
                      return const CircularProgressIndicator();

                    final totalPacientes = snapshotPacientes.data!.docs.length;

                    return StreamBuilder<QuerySnapshot>(
                      stream: _obtenerUsuarios(),
                      builder: (context, snapshotUsuarios) {
                        if (!snapshotUsuarios.hasData)
                          return const CircularProgressIndicator();

                        final totalUsuarios =
                            snapshotUsuarios.data!.docs.length;

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _crearTarjetaMetrica(
                              Icons.event,
                              'Citas',
                              citas.length.toString(),
                              Color(0xFFFFE6EC),
                            ),
                            _crearTarjetaMetrica(
                              Icons.attach_money,
                              'Ingresos',
                              'L${totalIngresos.toStringAsFixed(2)}',
                              Color(0xFFFFE6EC),
                            ),
                            _crearTarjetaMetrica(
                              Icons.people,
                              'Pacientes',
                              totalPacientes.toString(),
                              Color(0xFFFFE6EC),
                            ),
                            _crearTarjetaMetrica(
                              Icons.person_pin,
                              'Usuarios',
                              totalUsuarios.toString(),
                              Color(0xFFFFE6EC),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
