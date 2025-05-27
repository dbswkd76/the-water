import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class BorderModel extends StatefulWidget {
  const BorderModel({super.key});

  @override
  State<BorderModel> createState() => _BorderModelState();
}

class _BorderModelState extends State<BorderModel> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String result = "";
  List<double> modelResult = [];
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      modelrun(File(pickedFile.path));
      setState(() {
        _image = File(pickedFile.path); // 선택한 이미지 파일 저장
      });
    }
  }

  Future<List<List<List<double>>>> convertFileToArray(File file) async {
    try {
      Uint8List imageBytes = await file.readAsBytes();

      img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        throw Exception('이미지를 디코딩할 수 없습니다');
      }

      int width = decodedImage.width;
      int height = decodedImage.height;
      // 이미지 리사이징 (224x224)
      img.Image resizedImage = img.copyResize(
        decodedImage,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.linear,
      );

      // [height][width][3] 형태의 배열 생성
      List<List<List<double>>> imageArray = List.generate(
        224,
        (y) => List.generate(224, (x) {
          int pixel = resizedImage.getPixel(x, y);
          return [
            img.getBlue(pixel).toDouble(),
            img.getGreen(pixel).toDouble(),
            img.getRed(pixel).toDouble(),
          ];
        }),
      );

      return imageArray;
    } catch (e) {
      print('이미지 변환 중 오류 발생: $e');
      rethrow;
    }
  }

  modelrun(File file) async {
    final interpreter = await Interpreter.fromAsset(
      'assets/segment_v3_sim_float32.tflite',
    );
    final inputTensor = interpreter.getInputTensor(0);
    debugPrint("Input shape: ${inputTensor.shape}"); // 예: [1, 224, 224, 3]
    debugPrint("Input type: ${inputTensor.type}"); // 예: Float32

    // 🔹 출력 정보 출력
    final outputTensor = interpreter.getOutputTensor(2);
    debugPrint("Output shape: ${outputTensor.shape}"); // 예: [1, 26]
    debugPrint("Output type: ${outputTensor.type}"); // 예: Float32

    List<List<List<double>>> imageArray = await convertFileToArray(file);
    debugPrint(imageArray.toString());
    List<List<double>> output = List.generate(1, (index) => List.filled(26, 0));
    interpreter.run([imageArray], output);
    modelResult = output[0];
    print(modelResult);
    int resultIndex = modelResult.indexOf(
      modelResult.reduce((a, b) => a > b ? a : b),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _image == null
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 갤러리 선택 버튼
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ElevatedButton(
                          onPressed: _pickImageFromGallery,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo, size: 40, color: Colors.black),
                              SizedBox(height: 8),
                              Text(
                                '갤러리',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Image.file(_image!, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(modelResult.toString()),
                ],
              ),
    );
  }
}
