// // 👇 전체 수정된 코드
// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;
// import 'package:ar_flutter_plugin/widgets/ar_view.dart';
// import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
// import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
// import 'package:path_provider/path_provider.dart';

// void main() => runApp(const MaterialApp(home: ARDistanceMeasureTapPage()));

// class ARDistanceMeasureTapPage extends StatefulWidget {
//   const ARDistanceMeasureTapPage({super.key});
//   @override
//   State<ARDistanceMeasureTapPage> createState() =>
//       _ARDistanceMeasureTapPageState();
// }

// class _ARDistanceMeasureTapPageState extends State<ARDistanceMeasureTapPage> {
//   late ARSessionManager arSessionManager;
//   late ARObjectManager arObjectManager;
//   late ARAnchorManager arAnchorManager;
//   late ARLocationManager arLocationManager;

//   double? lastDistanceMeters;
//   String resultText = "👆 화면을 탭하여 거리 측정";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           ARView(
//             onARViewCreated: onARViewCreated,
//             planeDetectionConfig: PlaneDetectionConfig.horizontal,
//           ),
//           Positioned(
//             top: 40,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 color: Colors.black54,
//                 child: Text(
//                   resultText,
//                   style: const TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: ElevatedButton.icon(
//                 onPressed: captureAndPredict,
//                 icon: const Icon(Icons.camera_alt),
//                 label: const Text("📸 촬영하고 길이 측정"),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void onARViewCreated(
//     ARSessionManager sessionManager,
//     ARObjectManager objectManager,
//     ARAnchorManager anchorManager,
//     ARLocationManager locationManager,
//   ) {
//     arSessionManager = sessionManager;
//     arObjectManager = objectManager;
//     arAnchorManager = anchorManager;
//     arLocationManager = locationManager;

//     arSessionManager.onInitialize(
//       showFeaturePoints: false,
//       showPlanes: true,
//       handleTaps: true,
//     );
//     arObjectManager.onInitialize();

//     arSessionManager.onPlaneOrPointTap = (List<ARHitTestResult> hits) {
//       if (hits.isNotEmpty) {
//         final result = hits.first;
//         final t = result.worldTransform;
//         final d = sqrt(t[12] * t[12] + t[13] * t[13] + t[14] * t[14]);
//         setState(() {
//           lastDistanceMeters = d;
//           resultText = "📏 거리: ${d.toStringAsFixed(2)} m";
//         });
//       } else {
//         setState(() {
//           resultText = "❌ 물체 감지 안됨";
//         });
//       }
//     };
//   }

//   void showResult(String msg) {
//     setState(() => resultText = msg);
//   }

//   List<Point<int>> _findCenterWeightedLargestContour(img.Image mask) {
//     final visited = <Point<int>>{};
//     final center = Point(mask.width ~/ 2, mask.height ~/ 2);

//     List<Point<int>> bestContour = [];
//     double bestScore = -1;

//     for (int y = 0; y < mask.height; y++) {
//       for (int x = 0; x < mask.width; x++) {
//         final point = Point(x, y);
//         if (visited.contains(point)) continue;

//         final pixel = mask.getPixel(x, y);
//         if (img.getRed(pixel) > 200) {
//           List<Point<int>> queue = [point];
//           List<Point<int>> contour = [];
//           visited.add(point);

//           while (queue.isNotEmpty) {
//             final p = queue.removeLast();
//             contour.add(p);

//             for (var dx in [-1, 0, 1]) {
//               for (var dy in [-1, 0, 1]) {
//                 if (dx == 0 && dy == 0) continue;
//                 final nx = p.x + dx;
//                 final ny = p.y + dy;
//                 final np = Point(nx, ny);
//                 if (nx >= 0 &&
//                     ny >= 0 &&
//                     nx < mask.width &&
//                     ny < mask.height &&
//                     !visited.contains(np) &&
//                     img.getRed(mask.getPixel(nx, ny)) > 128) {
//                   visited.add(np);
//                   queue.add(np);
//                 }
//               }
//             }
//           }

//           if (contour.length > 50) {
//             final avgX =
//                 contour.map((p) => p.x).reduce((a, b) => a + b) /
//                 contour.length;
//             final avgY =
//                 contour.map((p) => p.y).reduce((a, b) => a + b) /
//                 contour.length;
//             final distance = sqrt(
//               pow(avgX - center.x, 2) + pow(avgY - center.y, 2),
//             );

//             final weight = 1.0 / (1.0 + distance);
//             final score = contour.length * weight;

//             if (score > bestScore) {
//               bestContour = contour;
//               bestScore = score;
//             }
//           }
//         }
//       }
//     }

//     return bestContour;
//   }

//   void captureAndPredict() async {
//     try {
//       final imageProvider = await arSessionManager.snapshot();
//       final memoryImage = imageProvider as MemoryImage;
//       final bytes = memoryImage.bytes;

//       final image = img.decodeImage(bytes);
//       if (image == null) throw Exception("이미지 디코딩 실패");

//       // ✅ 이미지 회전 (시계 방향으로 90도 회전 → 카메라를 왼쪽으로 눕힌 경우)
//       final rotatedImage = img.copyRotate(image, 270);
//       final workingImage = rotatedImage; // ✅ 그대로 사용
//       final originalWidth = rotatedImage.width;
//       final originalHeight = rotatedImage.height;
//       final resized = img.copyResize(workingImage, width: 640, height: 640);

//       //final resized = img.copyResize(rotatedImage, width: 640, height: 640);
//       final input = Float32List(1 * 640 * 640 * 3);
//       int i = 0;
//       for (int y = 0; y < 640; y++) {
//         for (int x = 0; x < 640; x++) {
//           final p = resized.getPixel(x, y);
//           input[i++] = img.getRed(p) / 255.0;
//           input[i++] = img.getGreen(p) / 255.0;
//           input[i++] = img.getBlue(p) / 255.0;
//         }
//       }

//       final interpreter = await Interpreter.fromAsset(
//         'assets/segment_v3_sim_float32.tflite',
//       );

//       final outputCls = List.generate(
//         1 * 8400 * 2,
//         (_) => 0.0,
//       ).reshape([1, 8400, 2]);
//       final outputMask = List.generate(
//         1 * 8400 * 32,
//         (_) => 0.0,
//       ).reshape([1, 8400, 32]);
//       final outputProto = List.generate(
//         1 * 160 * 160 * 32,
//         (_) => 0.0,
//       ).reshape([1, 160, 160, 32]);

//       const clsIndex = 0;
//       const maskIndex = 1;
//       const protoIndex = 2;

//       final outputs = <int, Object>{
//         clsIndex: outputCls,
//         maskIndex: outputMask,
//         protoIndex: outputProto,
//       };

//       interpreter.runForMultipleInputs([
//         input.reshape([1, 640, 640, 3]),
//       ], outputs);

//       final cls = outputCls[0];
//       final maskVecs = outputMask[0];
//       final proto = outputProto[0];

//       final List<double> confidences =
//           cls.map<double>((e) => 1 / (1 + exp(-e[1]))).toList();

//       // 중심 위치 설정
//       const imageCenter = Point(320, 320);

//       // 가중치 적용한 confidence 리스트 만들기
//       final weighted =
//           confidences.asMap().entries.where((e) => e.value > 0.3).map((entry) {
//               final idx = entry.key;
//               final conf = entry.value;

//               // YOLO의 박스 index → x, y 중심 추정 (anchor 없이 단순히 그리드 기반으로)
//               final row = idx ~/ 80; // 80 = sqrt(8400) 가정
//               final col = idx % 80;
//               final centerX = (col + 0.5) * (640.0 / 80); // 예: stride = 8.0
//               final centerY = (row + 0.5) * (640.0 / 80);
//               final dx = (centerX - imageCenter.x);
//               final dy = (centerY - imageCenter.y);
//               final dist = sqrt(dx * dx + dy * dy);

//               // 거리에 따른 가중치 (가까울수록 점수 증가)
//               final weight = 1.0 / (1.0 + dist / 100); // 100px마다 반감
//               return MapEntry(idx, conf * weight);
//             }).toList()
//             ..sort((a, b) => b.value.compareTo(a.value)); // 가중치 적용 점수 기준 정렬

//       if (weighted.isEmpty) {
//         showResult("❌ 물고기 감지 안됨");
//         return;
//       }

//       final int topIdx = weighted.first.key;

//       final vector = maskVecs[topIdx];
//       // ✅ [변경] 마스크 생성 (더 유연하게 조정 가능)
//       const double sigmoidScale = 3.5;
//       const double maskThreshold = 0.4;

//       final protoReshaped = List.generate(160 * 160, (i) {
//         final y = i ~/ 160;
//         final x = i % 160;
//         final dot = List.generate(
//           32,
//           (j) => proto[y][x][j] * vector[j],
//         ).reduce((a, b) => a + b);
//         final sigmoid = 1 / (1 + exp(-dot / sigmoidScale));
//         return sigmoid > maskThreshold ? 255 : 0;
//       });

//       // ✅ 이 부분은 그대로 유지해도 됩니다
//       final maskImage = img.Image(160, 160);
//       for (int i = 0; i < 160 * 160; i++) {
//         final x = i % 160;
//         final y = i ~/ 160;
//         final v = protoReshaped[i];
//         maskImage.setPixel(x, y, img.getColor(v, v, v));
//       }

//       // final upscaled = img.copyResize(maskImage, width: 640, height: 640);
//       final upscaled = img.copyResize(
//         maskImage,
//         width: 640,
//         height: 640,
//         interpolation: img.Interpolation.average,
//       );
//       final largestContour = _findCenterWeightedLargestContour(upscaled);
//       if (largestContour.isEmpty) {
//         showResult("❌ 윤곽 없음");
//         return;
//       }

//       final left = largestContour.reduce((a, b) => a.x < b.x ? a : b);
//       final right = largestContour.reduce((a, b) => a.x > b.x ? a : b);
//       final intersection = Point(right.x, left.y);
//       final lengthPx = (intersection.x - left.x).abs().toDouble();

//       // 1. 해상도 스케일 계산 (가로 촬영 + 회전 → 실제 가로는 originalHeight 기준)
//       final scaleX = originalWidth / 640.0;
//       final correctedPx = lengthPx;

//       // 2. 픽셀 → 미터 환산 (이건 그대로)
//       final distance = lastDistanceMeters ?? 0.5;
//       const fovDegrees = 60.0;
//       final fovRadians = fovDegrees * pi / 180.0;
//       final widthMeters = 2 * distance * tan(fovRadians / 2);
//       final pixelToMeter = widthMeters / 640.0;

//       // 3. 최종 길이 계산
//       const correctionFactor = 1.18;
//       final lengthCm = correctedPx * pixelToMeter * 100 * correctionFactor;

//       debugPrint("픽셀 길이 (640 기준): ${lengthPx.toStringAsFixed(1)} px");
//       debugPrint("측정 거리(m): $distance");
//       debugPrint("원본 해상도: $originalWidth x $originalHeight");
//       debugPrint("회전 반영 scaleX: $scaleX");
//       debugPrint("보정 후 픽셀 길이: ${correctedPx.toStringAsFixed(1)} px");
//       debugPrint("계산된 실측 길이: ${lengthCm.toStringAsFixed(2)} cm");

//       showResult("📏 물고기 길이: ${lengthCm.toStringAsFixed(1)} cm");

//       final vis = img.Image.from(upscaled);
//       for (final p in largestContour) {
//         vis.setPixelSafe(p.x, p.y, img.getColor(255, 255, 0));
//       }

//       for (int x = left.x; x <= intersection.x; x++) {
//         vis.setPixelSafe(x, intersection.y, img.getColor(0, 255, 0));
//       }

//       for (int y = 0; y <= intersection.y; y++) {
//         vis.setPixelSafe(intersection.x, y, img.getColor(255, 0, 255));
//       }

//       img.drawString(
//         vis,
//         img.arial_24,
//         10,
//         10,
//         "Length: ${lengthCm.toStringAsFixed(1)} cm",
//         color: img.getColor(0, 128, 255),
//       );

//       final png = img.encodePng(vis);
//       // ✅ 1. 앱 전용 외부 저장소 경로 가져오기 (Android에서 권한 없이 사용 가능)
//       final directory =
//           await getExternalStorageDirectory(); // 예: /storage/emulated/0/Android/data/com.example.app/files
//       if (directory == null) {
//         showResult("❌ 저장 경로를 가져올 수 없습니다");
//         return;
//       }

//       // ✅ 2. 디버깅 마스크 이미지 저장
//       final debugPath = '${directory.path}/result_debug_overlay.png';
//       final debugFile = File(debugPath);
//       await debugFile.writeAsBytes(png);

//       // ✅ 3. 촬영한 원본 이미지 저장
//       final originalPath = '${directory.path}/captured_original.png';
//       final originalFile = File(originalPath);
//       await originalFile.writeAsBytes(img.encodePng(image));

//       // ✅ 4. 저장 경로 안내 (콘솔 확인용)
//       debugPrint("🟢 디버깅 이미지 저장 완료: $debugPath");
//       debugPrint("🟢 원본 이미지 저장 완료: $originalPath");

//       // 📥 adb pull 예시
//       // adb pull /storage/emulated/0/Android/data/com.example.test/files/result_debug_overlay.png
//       // adb pull /storage/emulated/0/Android/data/com.example.test/files/captured_original.png
//     } catch (e, stack) {
//       debugPrint("❌ 처리 실패: $e");
//       debugPrint("📍 스택트레이스:\n$stack");
//       showResult("에러 발생: $e");
//     }
//   }
// }
