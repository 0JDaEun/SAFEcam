import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRearCameraSelected = true;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera(widget.cameras.first);
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    _controller = CameraController(camera, ResolutionPreset.high);
    await _controller.initialize();
    setState(() {});
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
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      // 워터마크 삽입
      final watermarkedImage = await _addImperceptibleWatermark(image.path);

      // 워터마크가 삽입된 이미지 저장
      final result = await ImageGallerySaver.saveFile(watermarkedImage.path);
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('워터마크가 삽입된 사진이 갤러리에 저장되었습니다.')),
        );
      }
    } catch (e) {
      print('사진 촬영 및 저장 실패: $e');
    }
  }

  Future<File> _addImperceptibleWatermark(String imagePath) async {
    // 이미지 로드
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('이미지를 불러올 수 없습니다.');

    // 워터마크 패턴 생성 (예: 미세한 점들의 패턴)
    final watermark = img.Image(width: image.width, height: image.height);
    for (int y = 0; y < watermark.height; y += 10) {
      for (int x = 0; x < watermark.width; x += 10) {
        watermark.setPixel(x, y, img.ColorRgba8(255, 255, 255, 1)); // 매우 연한 흰색 점
      }
    }

    // 워터마크 적용
    img.compositeImage(image, watermark, dstX: 0, dstY: 0, blend: img.BlendMode.lighten);

    // 처리된 이미지 저장
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/watermarked_image.jpg';
    final watermarkedFile = File(tempPath);
    await watermarkedFile.writeAsBytes(img.encodeJpg(image));

    return watermarkedFile;
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
              Column(
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.filter_none)),
                  Text("필터", style: TextStyle(fontSize: 15, color: Colors.black),)
                ],
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.flash_off),
                  ),
                  Text("플래시", style: TextStyle(fontSize: 15, color: Colors.black),)
                ],
              ),
              Column(
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.help_outline)),
                  Text("정보", style: TextStyle(fontSize: 15, color: Colors.black),)
                ],
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: _switchCamera,
                    icon: Icon(_isRearCameraSelected ? Icons.camera_front : Icons.camera_rear),
                  ),
                  Text("전환", style: TextStyle(fontSize: 15, color: Colors.black),)
                ],
              ),
              Column(
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.access_time)),
                  Text("타이머", style: TextStyle(fontSize: 15, color: Colors.black),)
                ],
              ),
              Column(
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.view_quilt)),
                  Text("비율", style: TextStyle(fontSize: 15, color: Colors.black),)
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 중앙 카메라 프리뷰 영역
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: CameraPreview(_controller),
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


          // 하단 촬영 버튼
          Container(
            color: Colors.white, // 흰색 배경
            height: 120, // 전체 높이
            child: Center(
              child: FloatingActionButton(
                onPressed: _takePictureAndSave,
                child: Icon(Icons.camera, color: Colors.black),
                backgroundColor: Colors.white,
                elevation: 4.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
