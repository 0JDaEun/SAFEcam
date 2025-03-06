import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRearCameraSelected = true;
  bool _isWatermarkEnabled = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera(widget.cameras.first);
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    _controller = CameraController(camera, ResolutionPreset.medium);
    try {
      await _controller.initialize();
      setState(() {});
    } catch (e) {
      print('카메라 초기화 실패: $e');
    }
  }

  void _switchCamera() async {
    setState(() {
      _isRearCameraSelected = !_isRearCameraSelected;
    });
    await _initializeCamera(
      widget.cameras[_isRearCameraSelected ? 0 : 1],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndSave() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      File processedImage = File(image.path);
      if (_isWatermarkEnabled) {
        processedImage = await compute(_applyInvisibleWatermark, image.path);
      }

      final result = await ImageGallerySaver.saveFile(processedImage.path);
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('워터마크가 적용된 사진이 갤러리에 저장되었습니다.')),
        );
      } else {
        throw Exception('저장 실패: ${result['errorMessage']}');
      }

      // 임시 파일 삭제
      await processedImage.delete();
    } catch (e) {
      print('사진 촬영 및 저장 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 저장 중 오류가 발생했습니다.')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildIconButton(Icons.filter_none, "필터", () {}),
              _buildIconButton(Icons.flash_off, "플래시", () {}),
              _buildIconButton(Icons.help_outline, "정보", () {}),
              _buildIconButton(_isRearCameraSelected ? Icons.camera_front : Icons.camera_rear, "전환", _switchCamera),
              _buildIconButton(Icons.access_time, "타이머", () {}),
              _buildIconButton(Icons.view_quilt, "비율", () {}),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CameraPreview(_controller),
                      if (_isProcessing)
                        CircularProgressIndicator(),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('카메라 초기화 실패'));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Container(
            color: Colors.white,
            height: 120,
            child: Center(
              child: FloatingActionButton(
                onPressed: _isProcessing ? null : _takePictureAndSave,
                child: Icon(Icons.camera, color: Colors.black),
                backgroundColor: _isProcessing ? Colors.grey : Colors.white,
                elevation: 4.0,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isWatermarkEnabled = !_isWatermarkEnabled;
          });
        },
        child: Icon(
          _isWatermarkEnabled ? Icons.copyright : Icons.clear,
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(onPressed: onPressed, icon: Icon(icon)),
        Text(label, style: TextStyle(fontSize: 15, color: Colors.black)),
      ],
    );
  }
}

Future<File> _applyInvisibleWatermark(String imagePath) async {
  final bytes = await File(imagePath).readAsBytes();
  final image = img.decodeImage(bytes);

  if (image == null) throw Exception('이미지를 불러올 수 없습니다.');

  final watermark = _generateWatermarkPattern(image.width, image.height);

  for (int y = 0; y < image.height; y += 2) {
    for (int x = 0; x < image.width; x += 2) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      final newR = (r + (watermark[y ~/ 2][x ~/ 2] ? 1 : -1)).clamp(0, 255);
      final newG = (g + (watermark[y ~/ 2][x ~/ 2] ? 1 : -1)).clamp(0, 255);
      final newB = (b + (watermark[y ~/ 2][x ~/ 2] ? 1 : -1)).clamp(0, 255);

      final newColor = (newR << 16) | (newG << 8) | newB;
      image.setPixel(x, y, img.ColorInt8(newColor));
    }
  }

  final tempDir = await getTemporaryDirectory();
  final tempPath = '${tempDir.path}/watermarked_image.jpg';
  final watermarkedFile = File(tempPath);
  await watermarkedFile.writeAsBytes(img.encodeJpg(image, quality: 90));

  return watermarkedFile;
}

List<List<bool>> _generateWatermarkPattern(int width, int height) {
  final random = Random(42);
  final pattern = List.generate(
      (height / 2).ceil(),
          (_) => List.generate((width / 2).ceil(), (_) => random.nextBool())
  );
  return pattern;
}
