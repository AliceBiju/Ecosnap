import 'package:cloud_firestore/cloud_firestore.dart';

class PlantScan {
  final String id;
  final String scientificName;
  final String commonName;
  final String description;
  final String watering;
  final double confidence;
  final DateTime scannedAt;
  final String? imageUrl;

  PlantScan({
    required this.id,
    required this.scientificName,
    required this.commonName,
    required this.description,
    required this.watering,
    required this.confidence,
    required this.scannedAt,
    this.imageUrl,
  });

  factory PlantScan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlantScan(
      id: doc.id,
      scientificName: data['scientificName'] ?? '',
      commonName: data['commonName'] ?? '',
      description: data['description'] ?? '',
      watering: data['watering'] ?? '',
      confidence: (data['confidence'] ?? 0).toDouble(),
      scannedAt: (data['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'scientificName': scientificName,
      'commonName': commonName,
      'description': description,
      'watering': watering,
      'confidence': confidence,
      'scannedAt': Timestamp.fromDate(scannedAt),
      'imageUrl': imageUrl,
    };
  }
}
