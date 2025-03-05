import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screen/camera_screen.dart';

late List<CameraDescription> cameras;

void main() async {
  // 플러터 바인딩 초기화를 보장합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // 사용 가능한 카메라 목록을 가져옵니다.
  cameras = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '딥페이크 방지 카메라',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: CameraScreen(cameras: cameras), // 카메라 목록 전달
    );
  }
}
