import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //obtener la colección de citas
  final CollectionReference citas = FirebaseFirestore.instance.collection(
    'citas',
  );

  //CREAR: agregar una nueva cita
  Future<void> agregarCita(String cita) {
    return citas.add({'cita': cita, 'timestamp': Timestamp.now()});
  }

  //LEER: obtener citas de la base de datos
  Stream<QuerySnapshot> obtenerFlujoDeCitas() {
    final flujoDeCitas =
        citas.orderBy('timestamp', descending: true).snapshots();
    return flujoDeCitas;
  }

  //ACTUALIZAR: actualizar citas dado un id de documento
  Future<void> actualizarCita(String docID, String nuevaCita) {
    return citas.doc(docID).update({
      'cita': nuevaCita,
      'timestamp': Timestamp.now(),
    });
  }

  //ELIMINAR: borrar citas dado un id de documento
  Future<void> eliminarCita(String docID) {
    return citas.doc(docID).delete();
  }
}
