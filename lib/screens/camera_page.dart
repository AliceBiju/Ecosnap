import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  CameraController? controller;
  List<CameraDescription>? cameras;

  Uint8List? _imageBytes;
  String? _resultado;
  double _confianca = 0;

  bool _loading = false;
  bool _modoEscolhido = false;
  bool _usarCamera = false;
  bool _cameraDisponivel = false;

  final picker = ImagePicker();

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  // =========================
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

  // =========================
  Future<void> pegarDaCameraWeb() async {
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if (foto == null) return;

    final bytes = await foto.readAsBytes();

    setState(() {
      _imageBytes = bytes;
      _resultado = null;
    });

    await identificarPlanta();
  }

  // =========================
  Future<void> iniciarCamera() async {
    try {
      cameras = await availableCameras();

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
    final foto = await controller!.takePicture();
    final bytes = await foto.readAsBytes();

    setState(() {
      _imageBytes = bytes;
      _resultado = null;
    });

    await identificarPlanta();
  }

  // =========================
  Future<void> pegarDaGaleria() async {
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery);

    if (foto == null) return;

    final bytes = await foto.readAsBytes();

    setState(() {
      _imageBytes = bytes;
      _resultado = null;
    });

    await identificarPlanta();
  }

  // =========================
  Future<void> identificarPlanta() async {
    setState(() => _loading = true);

    try {
      final base64Image = base64Encode(_imageBytes!);

      final response = await http.post(
        Uri.parse('https://plant.id/api/v3/identification'),
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': '0Unj3uZ9PGXuuNx84L4CqqVKzgozwEtqtRFnKjq0suYo83VP9I',
        },
        body: jsonEncode({
          "images": [base64Image],
          "similar_images": true,
        }),
      );

      final data = jsonDecode(response.body);
      final s = data['result']?['classification']?['suggestions']?[0];

      setState(() {
        _resultado = s['name'];
        _confianca = (s['probability'] ?? 0) * 100;
      });

      _animController.forward();
    } catch (e) {
      setState(() {
        _resultado = "Erro ao identificar";
      });
    }

    setState(() => _loading = false);
  }

  // =========================
  @override
  Widget build(BuildContext context) {
    if (!_modoEscolhido) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🌿 Identificador de Plantas",
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => escolherModo(true),
                child: const Text("Usar Câmera"),
              ),
              ElevatedButton(
                onPressed: () => escolherModo(false),
                child: const Text("Galeria"),
              ),
            ],
          ),
        ),
      );
    }

    // =========================
    // 📷 CAMERA VIEW
    // =========================
    if (_usarCamera && _resultado == null) {
      Widget cameraContent;

      if (kIsWeb) {
        cameraContent = const Center(child: Text("Use a câmera do navegador"));
      } else if (_cameraDisponivel &&
          controller != null &&
          controller!.value.isInitialized) {
        cameraContent = CameraPreview(controller!);
      } else {
        cameraContent = const Center(child: Text("Câmera indisponível"));
      }

      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(child: cameraContent),

            // BOTÃO VERDE BONITO
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _usarCamera ? tirarFoto : null,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.lightGreenAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            if (_loading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    // =========================
    // 🌿 RESULTADO / GALERIA
    // =========================
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          if (_imageBytes != null)
            Positioned(
              top: 60,
              left: 30,
              right: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  _imageBytes!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          if (_resultado != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.eco,
                        color: Colors.lightGreenAccent,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Planta identificada",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _resultado!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Confiança: ${_confianca.toStringAsFixed(1)}%",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _confianca / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.lightGreenAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
