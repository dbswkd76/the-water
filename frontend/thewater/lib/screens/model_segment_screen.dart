import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelSegmentScreen extends StatefulWidget {
  const ModelSegmentScreen({super.key});

  @override
  State<ModelSegmentScreen> createState() => _ModelSegmentScreenState();
}

class _ModelSegmentScreenState extends State<ModelSegmentScreen> {
  late Interpreter interpreter;
  File? _image;
  String result = "";// 결과를 저장할 상태 변수
  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/segment_v3_sim_float32.tflite');
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // 갤러리에서 이미지 가져오기
    if (pickedFile != null) {
      // 이미지가 선택된 경우
      setState(() {
        _image = File(pickedFile.path); // 이미지 파일 저장
      });
      // 이미지 처리 및 모델 실행
      img.Image image = img.decodeImage(_image!.readAsBytesSync())!;  // 이미지 디코딩
      Float32List inputImage = preprocessImage(image);  // 전처리된 이미지

      // 모델 실행은 이미지가 설정된 후에만 호출
      setState(() {
        // 모델 실행
        runInference(inputImage);
      });
    }
  }

  Future<void> _takeImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera); // 카메라에서 이미지 가져오기
    if (pickedFile != null) {
      // 이미지가 선택된 경우
      setState(() {
        _image = File(pickedFile.path); // 이미지 파일 저장
      });
      // 이미지 처리 및 모델 실행
      img.Image image = img.decodeImage(_image!.readAsBytesSync())!;  // 이미지 디코딩
      Float32List inputImage = preprocessImage(image);  // 전처리된 이미지

      // 모델 실행은 이미지가 설정된 후에만 호출
      setState(() {
        // 모델 실행
        runInference(inputImage);
      });
    }
  }


  Float32List preprocessImage(img.Image image) {
    img.Image resized = img.copyResize(image, width: 640, height: 640);

    var buffer = Float32List(1 * 640 * 640 * 3);
    var bufferIndex = 0;

    for (int y = 0; y < 640; y++) {
      for (int x = 0; x < 640; x++) {
        var pixel = resized.getPixel(x, y);
        buffer[bufferIndex++] = img.getBlue(pixel) / 255.0;
        buffer[bufferIndex++] = img.getGreen(pixel) / 255.0;
        buffer[bufferIndex++] = img.getRed(pixel) / 255.0;
      }
    }

    return buffer;
  }

  void runInference(Float32List inputImage) {
    var output1 = List.generate(6400, (j) => List.filled(34, 0.0)); // [6400, 34]
    debugPrint("${inputImage.reshape([1,640,640,3])}");
    interpreter.run(inputImage.reshape([1, 640, 640, 3]), [output1]);

    // 결과 처리
    setState(() {
      debugPrint("모델 실행 완료");
      result = '모델 실행 완료! \n바운딩 박스: ${output1[0]}}'; // 예시 출력
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('잡은 물고기 사진을 넣어주세요')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 이미지를 선택했다면 해당 이미지를 화면에 표시
              _image == null
                  ? SizedBox(height: 15,)
                  : Image.file(_image!), // 선택한 이미지를 화면에 표시

              SizedBox(height: 20),

              // 버튼들
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('갤러리에서 이미지 선택'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _takeImage,
                child: Text('카메라로 사진 찍기'),
              ),
              _image == null ? SizedBox(height: 15,):
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: result, // 기본 텍스트
                      style: TextStyle(color: Colors.blue, fontSize: 36),
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
}
