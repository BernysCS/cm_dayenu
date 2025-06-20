import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //obtener la colección de citas
  final CollectionReference citas = FirebaseFirestore.instance.collection(
    'citas',
  );

  //CREAR: agregar una nueva cita
  Future<void> agregarCita({
    required String nombre,
    required String motivo,
    required String sala,
    required String telefono,
    required double precio,
    required DateTime fechaHora,
    String estado = 'Programado',
  }) {
    return citas.add({
      'nombre': nombre,
      'motivo': motivo,
      'sala': sala,
      'telefono': telefono,
      'precio': precio,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'timestamp': Timestamp.now(),
      'estado': estado,
    });
  }

  //LEER: obtener citas de la base de datos
  Stream<QuerySnapshot> obtenerFlujoDeCitas() {
    final flujoDeCitas =
        citas.orderBy('timestamp', descending: true).snapshots();
    return flujoDeCitas;
  }

  //ACTUALIZAR: actualizar citas dado un id de documento
  Future<void> actualizarCita(
    String docID,
    String nombre,
    String motivo,
    String sala,
    String telefono,
    double precio,
    DateTime fechaHora,
  ) {
    return citas.doc(docID).update({
      'nombre': nombre,
      'motivo': motivo,
      'sala': sala,
      'telefono': telefono,
      'precio': precio,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'timestamp': Timestamp.now(),
    });
  }

  //ELIMINAR: borrar citas dado un id de documento
  Future<void> eliminarCita(String docID) {
    return citas.doc(docID).delete();
  }

  //consulta a la base de datos si existe una cita en la misma hora y fecha
  Future<bool> existeCitaEnFechaHora(DateTime fechaHora) async {
    QuerySnapshot query =
        await citas
            .where('fechaHora', isEqualTo: Timestamp.fromDate(fechaHora))
            .get();

    return query.docs.isNotEmpty;
  }
}
