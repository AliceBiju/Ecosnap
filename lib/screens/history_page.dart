import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../services/history_service.dart';
import '../models/plant_scan.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _historyService = HistoryService();
  Stream<List<PlantScan>>? _stream;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final stream = await _historyService.getHistory();
    setState(() {
      _stream = stream;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stream == null
              ? _emptyState('Faça login para ver seu histórico.')
              : StreamBuilder<List<PlantScan>>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }

                    final scans = snapshot.data ?? [];

                    if (scans.isEmpty) {
                      return _emptyState(
                          'Nenhuma planta escaneada ainda.\nUse a câmera para identificar plantas!');
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: scans.length,
                      itemBuilder: (context, index) =>
                          _ScanCard(scan: scans[index]),
                    );
                  },
                ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final PlantScan scan;

  const _ScanCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    final displayName =
        scan.commonName.isNotEmpty ? scan.commonName : scan.scientificName;
    final date = scan.scannedAt;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/plant-details',
            arguments: scan,
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto do scan à esquerda
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: scan.imageUrl != null
                      ? Image.network(
                          scan.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
              ),
              const SizedBox(width: 14),

              // Detalhes à direita
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome e confiança
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7BB88D).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${scan.confidence.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Nome científico (se tiver nome comum diferente)
                    if (scan.commonName.isNotEmpty &&
                        scan.scientificName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        scan.scientificName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 6),

                    // Irrigação
                    if (scan.watering.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.water_drop,
                                size: 14, color: Colors.lightBlue),
                            const SizedBox(width: 4),
                            Text(
                              'Rega: ${scan.watering}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),

                    // Descrição resumida
                    if (scan.description.isNotEmpty)
                      Text(
                        scan.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),

                    const SizedBox(height: 8),

                    // Data
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.access_time,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: const Icon(
        Icons.local_florist,
        size: 32,
        color: Color(0xFF7BB88D),
      ),
    );
  }
}
