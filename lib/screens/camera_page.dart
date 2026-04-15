import 'dart:convert';
import 'dart:io';
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

  File? _image;
  String? _resultado;
  String? _imagemSimilar;
  bool _loading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    iniciarCamera();
  }

  Future<void> iniciarCamera() async {
    cameras = await availableCameras();

    controller = CameraController(cameras![0], ResolutionPreset.medium);

    await controller!.initialize();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> tirarFoto() async {
    if (!controller!.value.isInitialized) return;

    final foto = await controller!.takePicture();

    setState(() {
      _image = File(foto.path);
      _resultado = null;
      _imagemSimilar = null;
    });

    await identificarPlanta();
  }

  Future<void> pegarDaGaleria() async {
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery);

    if (foto != null) {
      setState(() {
        _image = File(foto.path);
        _resultado = null;
        _imagemSimilar = null;
      });

      await identificarPlanta();
    }
  }

  Future<void> identificarPlanta() async {
    if (_image == null) return;

    setState(() => _loading = true);

    final bytes = await _image!.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://plant.id/api/v3/identification'),
      headers: {
        'Content-Type': 'application/json',
        'Api-Key': '0Unj3uZ9PGXuuNx84L4CqqVKzgozwEtqtRFnKjq0suYo83VP9I',
      },
      body: jsonEncode({
        "images": [base64Image],
        "organs": ["leaf"],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final sugestao = data['result']['classification']['suggestions'][0];

      setState(() {
        _resultado =
            "🌿 ${sugestao['name']}\nConfiança: ${(sugestao['probability'] * 100).toStringAsFixed(2)}%";

        _imagemSimilar = sugestao['similar_images']?[0]?['url'];
      });
    } else {
      setState(() => _resultado = "Erro ao identificar");
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          /// 📸 CAMERA AO VIVO
          CameraPreview(controller!),

          /// RESULTADO BONITO (OVERLAY)
          if (_resultado != null)
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      _resultado!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    if (_imagemSimilar != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(_imagemSimilar!, height: 120),
                      ),
                  ],
                ),
              ),
            ),

          /// LOADING
          if (_loading) const Center(child: CircularProgressIndicator()),

          /// BOTÕES (ESTILO CÂMERA)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// GALERIA
                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.white, size: 35),
                  onPressed: pegarDaGaleria,
                ),

                /// BOTÃO PRINCIPAL
                GestureDetector(
                  onTap: tirarFoto,
                  child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),

                /// ESPAÇO (pode virar trocar câmera depois)
                const SizedBox(width: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
