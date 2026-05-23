import 'package:ecosnap/models/plant_scan.dart';
import 'package:ecosnap/repository/history_repository.dart';
import 'session_manager.dart';

class HistoryService {
  final HistoryRepository _repository = HistoryRepository();

  Future<String?> _getCurrentUserId() async {
    return await SessionManager.get();
  }

  /// Adiciona um scan ao histórico do usuário logado.
  /// Se não houver usuário logado, não faz nada.
  Future<void> addScan({
    required String scientificName,
    required String commonName,
    required String description,
    required String watering,
    required double confidence,
    String? imageUrl,
  }) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return;

    final scan = PlantScan(
      id: '',
      scientificName: scientificName,
      commonName: commonName,
      description: description,
      watering: watering,
      confidence: confidence,
      scannedAt: DateTime.now(),
      imageUrl: imageUrl,
    );

    await _repository.addScan(userId, scan);
  }

  /// Retorna o stream do histórico do usuário logado.
  Future<Stream<List<PlantScan>>?> getHistory() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return null;
    return _repository.getHistory(userId);
  }
}
