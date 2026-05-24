import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import '../layout/main_layout.dart';
import '../services/history_service.dart';
import '../models/plant_scan.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription>? cameras;

  Uint8List? _imageBytes;
  bool _loading = false;
  String _loadingMessage = "Analisando planta...";
  bool _modoEscolhido = false;
  bool _usarCamera = false;
  bool _cameraDisponivel = false;

  final picker = ImagePicker();
  final HistoryService _historyService = HistoryService();

  void escolherModo(bool camera) async {
    setState(() {
      _modoEscolhido = true;
      _usarCamera = camera;
    });

    if (kIsWeb && camera) {
      await pegarDaCameraWeb();
      return;
    }

    if (camera) {
      await iniciarCamera();
    } else {
      await pegarDaGaleria();
    }
  }

  Future<void> pegarDaCameraWeb() async {
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if (foto == null) {
      setState(() => _modoEscolhido = false);
      return;
    }

    final bytes = await foto.readAsBytes();
    setState(() => _imageBytes = bytes);
    await identificarPlanta();
  }

  Future<void> iniciarCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        setState(() => _cameraDisponivel = false);
        return;
      }

      controller = CameraController(
        cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();
      setState(() => _cameraDisponivel = true);
    } catch (e) {
      setState(() => _cameraDisponivel = false);
    }
  }

  Future<void> tirarFoto() async {
    if (controller == null || !controller!.value.isInitialized) return;

    try {
      final foto = await controller!.takePicture();
      final bytes = await foto.readAsBytes();
      setState(() => _imageBytes = bytes);
      await identificarPlanta();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao capturar foto: $e")));
    }
  }

  Future<void> pegarDaGaleria() async {
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery);

    if (foto == null) {
      setState(() => _modoEscolhido = false);
      return;
    }

    final bytes = await foto.readAsBytes();
    setState(() => _imageBytes = bytes);
    await identificarPlanta();
  }

  Future<String?> _uploadImage(Uint8List imageBytes) async {
    const String apiKey = String.fromEnvironment(
      'IMGBB_KEY',
      defaultValue: 'CHAVE NÃO CONFIGURADA',
    );

    if (apiKey == 'SUA_API_KEY_DO_IMGBB' || apiKey.isEmpty) {
      print("Chave ImgBB não configurada ou vazia.");
      return null;
    }

    try {
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final url = data['data']['url'] as String?;
          print("Upload ImgBB realizado com sucesso! URL: $url");
          return url;
        }
      }
      print(
        "Erro no upload do ImgBB: ${response.statusCode} - ${response.body}",
      );
      return null;
    } catch (e) {
      print('Exceção ao fazer upload da imagem para ImgBB: $e');
      return null;
    }
  }

  Future<void> identificarPlanta() async {
    if (_imageBytes == null) return;

    final apiKey = const String.fromEnvironment('PLANT_ID_KEY');

    setState(() {
      _loading = true;
      _loadingMessage = "Analisando planta com IA...";
    });

    try {
      final base64Image = base64Encode(_imageBytes!);

      final response = await http.post(
        Uri.parse(
          'https://plant.id/api/v3/identification?details=common_names,description_all,watering&language=pt',
        ),
        headers: {'Content-Type': 'application/json', 'Api-Key': apiKey},
        body: jsonEncode({
          "images": [base64Image],
          "similar_images": true,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          "Falha na API Plant.id: ${response.statusCode} - ${response.body}",
        );
      }

      final data = jsonDecode(response.body);
      final s = data['result']?['classification']?['suggestions']?[0];

      if (s == null) {
        throw Exception(
          "Nenhuma planta identificada pela Inteligência Artificial.",
        );
      }

      final String scientificName = s['name'] ?? 'Espécie não identificada';
      final double confidence = (s['probability'] ?? 0) * 100;

      String description = '';
      String watering = '';
      String commonName = '';

      final details = s['details'];
      if (details != null) {
        description =
            details['description_all']?['value'] ??
            details['description']?['value'] ??
            "Nenhuma descrição adicional foi encontrada.";

        int? minWatering = details['watering']?['min'];
        int? maxWatering = details['watering']?['max'];

        String nomeNivel(int val) {
          if (val == 1) return "Seco";
          if (val == 2) return "Moderado";
          if (val == 3) return "Úmido";
          return val.toString();
        }

        if (minWatering != null && maxWatering != null) {
          watering = minWatering == maxWatering
              ? nomeNivel(minWatering)
              : "${nomeNivel(minWatering)} a ${nomeNivel(maxWatering)}";
        } else if (minWatering != null) {
          watering = nomeNivel(minWatering);
        }

        if (details['common_names'] != null &&
            (details['common_names'] as List).isNotEmpty) {
          commonName = details['common_names'][0];
        }
      }

      setState(() => _loadingMessage = "Hospedando foto no servidor...");
      final uploadUrl = await _uploadImage(_imageBytes!);

      setState(() => _loadingMessage = "Gravando histórico de plantas...");
      await _historyService.addScan(
        scientificName: scientificName,
        commonName: commonName,
        description: description,
        watering: watering,
        confidence: confidence,
        imageUrl: uploadUrl,
      );

      final scanResult = PlantScan(
        id: '',
        scientificName: scientificName,
        commonName: commonName,
        description: description,
        watering: watering,
        confidence: confidence,
        scannedAt: DateTime.now(),
        imageUrl: uploadUrl,
      );

      _resetar();

      if (mounted) {
        Navigator.pushNamed(context, '/plant-details', arguments: scanResult);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ocorreu um erro no processo: $e")),
        );
      }
      _resetar();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _resetar() {
    setState(() {
      _imageBytes = null;
      _loading = false;
      _modoEscolhido = false;
      _usarCamera = false;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MainLayout(
        body: Container(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      color: Color(0xFF7BB88D),
                      strokeWidth: 4.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _loadingMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Por favor, aguarde alguns segundos. Estamos extraindo dados botânicos e salvando no seu perfil.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_modoEscolhido) {
      return MainLayout(
        body: Container(
          color: Colors.white,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7BB88D).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_florist,
                      size: 64,
                      color: Color(0xFF5A9B6F),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Identificador de Plantas",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tire uma foto ou escolha um arquivo da sua galeria para identificar instantaneamente qualquer espécie.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton.icon(
                    onPressed: () => escolherModo(true),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Usar Câmera"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7BB88D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 14),

                  OutlinedButton.icon(
                    onPressed: () => escolherModo(false),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Escolher da Galeria"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B5E20),
                      side: const BorderSide(
                        color: Color(0xFF7BB88D),
                        width: 1.5,
                      ),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_usarCamera) {
      Widget cameraContent;

      if (kIsWeb) {
        cameraContent = const Center(
          child: Text(
            "Use a captura nativa do seu navegador.",
            style: TextStyle(fontSize: 16),
          ),
        );
      } else if (_cameraDisponivel &&
          controller != null &&
          controller!.value.isInitialized) {
        cameraContent = CameraPreview(controller!);
      } else {
        cameraContent = const Center(
          child: CircularProgressIndicator(color: Color(0xFF7BB88D)),
        );
      }

      return MainLayout(
        body: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Positioned.fill(child: cameraContent),

              Positioned(
                top: 20,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _resetar,
                  ),
                ),
              ),

              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: tirarFoto,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF7BB88D),
                          width: 4,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
