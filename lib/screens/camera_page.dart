import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription>? cameras;

  Uint8List? _imageBytes;
  String? _resultado;
  String? _imagemSimilar;

  bool _loading = false;
  bool _modoEscolhido = false;
  bool _usarCamera = false;
  bool _cameraDisponivel = false;

  final picker = ImagePicker();

  // =========================
  // ESCOLHA MODO
  // =========================
  void escolherModo(bool camera) async {
    setState(() {
      _modoEscolhido = true;
      _usarCamera = camera;
    });

    if (camera) {
      await iniciarCamera();
    } else {
      await pegarDaGaleria();
    }
  }

  // =========================
  // CAMERA
  // =========================
  Future<void> iniciarCamera() async {
    try {
      cameras = await availableCameras();

      if (!mounted) return;

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

      if (!mounted) return;

      setState(() => _cameraDisponivel = true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraDisponivel = false;
        _usarCamera = false;
      });
    }
  }

  // =========================
  // FOTO CAMERA
  // =========================
  Future<void> tirarFoto() async {
    if (_loading) return;
    if (controller == null || !controller!.value.isInitialized) return;

    final foto = await controller!.takePicture();
    final bytes = await foto.readAsBytes();

    if (!mounted) return;

    setState(() {
      _imageBytes = bytes;
      _resultado = null;
      _imagemSimilar = null;
    });

    await identificarPlanta();
  }

  // =========================
  // GALERIA (WEB + MOBILE)
  // =========================
  Future<void> pegarDaGaleria() async {
    if (_loading) return;

    final XFile? foto =
        await picker.pickImage(source: ImageSource.gallery);

    if (foto == null) return;

    final bytes = await foto.readAsBytes();

    if (!mounted) return;

    setState(() {
      _imageBytes = bytes;
      _resultado = null;
      _imagemSimilar = null;
    });

    await identificarPlanta();
  }

  // =========================
  // API PLANT.ID (CORRIGIDA)
  // =========================
  Future<void> identificarPlanta() async {
    if (_imageBytes == null || _loading) return;

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
          "images": ["data:image/jpeg;base64,$base64Image"],
          "similar_images": true
        }),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        setState(() {
          _resultado = "Erro API: ${data['error'] ?? response.body}";
        });
        return;
      }

      final suggestions =
          data['result']?['classification']?['suggestions'];

      setState(() {
        if (suggestions == null || suggestions.isEmpty) {
          _resultado = "Nenhuma planta identificada";
          _imagemSimilar = null;
        } else {
          final s = suggestions[0];

          _resultado =
              "🌿 ${s['name']}\n"
              "Confiança: ${(s['probability'] * 100).toStringAsFixed(2)}%";

          _imagemSimilar =
              (s['similar_images'] != null &&
                      s['similar_images'].isNotEmpty)
                  ? s['similar_images'][0]['url']
                  : null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultado = "Erro: $e";
      });
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // =========================
  // UI INICIAL
  // =========================
  @override
  Widget build(BuildContext context) {
    if (!_modoEscolhido) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    "Escolha como enviar a imagem",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => escolherModo(true),
                      child: const Text("Usar Câmera"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => escolherModo(false),
                      child: const Text("Escolher da Galeria"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget cameraWidget;

    if (_usarCamera &&
        _cameraDisponivel &&
        controller != null &&
        controller!.value.isInitialized) {
      cameraWidget = CameraPreview(controller!);
    } else {
      cameraWidget = const Center(
        child: Text("Câmera não disponível"),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          cameraWidget,

          // IMAGEM PREVIEW
          if (_imageBytes != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(
                  _imageBytes!,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // RESULTADO
          if (_resultado != null)
            Positioned(
              top: 220,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(15),
                color: Colors.black54,
                child: Column(
                  children: [
                    Text(
                      _resultado!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (_imagemSimilar != null)
                      Image.network(_imagemSimilar!, height: 120),
                  ],
                ),
              ),
            ),

          // LOADING
          if (_loading)
            const Center(child: CircularProgressIndicator()),

          // BOTÃO
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _usarCamera ? tirarFoto : pegarDaGaleria,
                child: const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}