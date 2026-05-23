import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecosnap/models/plant_scan.dart';

class HistoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _historyRef(String userId) {
    return _db.collection('users').doc(userId).collection('history');
  }

  /// Salva um scan no histórico do usuário.
  Future<void> addScan(String userId, PlantScan scan) async {
    await _historyRef(userId).add(scan.toFirestore());
  }

  /// Retorna o histórico do usuário, do mais recente ao mais antigo.
  Stream<List<PlantScan>> getHistory(String userId) {
    return _historyRef(userId)
        .orderBy('scannedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => PlantScan.fromFirestore(doc)).toList());
  }
}
