// ... 기존 import 유지 ...
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:ar_flutter_plugin/widgets/ar_view.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' show Point, min, max; // Rectangle 제거
import 'dart:ui'; // Rect를 쓰기 위한 import

void main() => runApp(const MaterialApp(home: ARDistanceMeasureTapPage()));

class ARDistanceMeasureTapPage extends StatefulWidget {
  const ARDistanceMeasureTapPage({super.key});
  @override
  State<ARDistanceMeasureTapPage> createState() =>
      _ARDistanceMeasureTapPageState();
}

class _ARDistanceMeasureTapPageState extends State<ARDistanceMeasureTapPage> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  late ARLocationManager arLocationManager;

  late Interpreter classifyInterpreter;
  late Interpreter segInterpreter;

  @override
  void initState() {
    super.initState();
    loadModels();
  }

  Future<void> loadModels() async {
    classifyInterpreter = await Interpreter.fromAsset('assets/QAT_50model_mixed.tflite');
    segInterpreter = await Interpreter.fromAsset('assets/segment_v3_sim_float32.tflite');
  }
  double? lastDistanceMeters;
  String resultText = "👆 화면을 탭하여 거리 측정";

  final List<String> fishList = [
    '학공치',
    '문절망둑',
    '광어',
    '복섬',
    '문어',
    '주꾸미',
    '노래미',
    '무늬오징어',
    '농어',
    '갈치',
    '붕장어',
    '고등어',
    '독가시치',
    '감성돔',
    '고등어어',
    '성대',
    '양태',
    '갑오징어',
    '고등어',
    '망상어',
    '숭어',
    '볼락',
    '우럭',
    '돌돔',
    '벵에돔',
    '참돔',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontal,
          ),
          // 🔹 결과 텍스트 표시
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black54,
                child: Text(
                  resultText,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
          // 🔹 촬영 버튼
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: captureAndPredict,
                icon: const Icon(Icons.camera_alt),
                label: const Text("📸 촬영하고 길이 + 종 예측"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _simpleFloodFill(img.Image mask, int x, int y, int fillColor) {
    final target = mask.getPixel(x, y);
    if (target == fillColor) return;

    final stack = <Point<int>>[Point(x, y)];
    final w = mask.width, h = mask.height;

    while (stack.isNotEmpty) {
      final p = stack.removeLast();
      final px = p.x, py = p.y;

      if (px < 0 || py < 0 || px >= w || py >= h) continue;
      if (mask.getPixel(px, py) != target) continue;

      mask.setPixel(px, py, fillColor);
      stack.addAll([
        Point(px + 1, py),
        Point(px - 1, py),
        Point(px, py + 1),
        Point(px, py - 1),
      ]);
    }
  }

  void onARViewCreated(
    ARSessionManager s,
    ARObjectManager o,
    ARAnchorManager a,
    ARLocationManager l,
  ) {
    arSessionManager = s;
    arObjectManager = o;
    arAnchorManager = a;
    arLocationManager = l;

    arSessionManager.onInitialize(
      showAnimatedGuide: true,
      showFeaturePoints: false,
      showPlanes: true,
      handleTaps: true,
    );
    arObjectManager.onInitialize();

    arSessionManager.onPlaneOrPointTap = (List<ARHitTestResult> hits) {
      if (hits.isNotEmpty) {
        final t = hits.first.worldTransform;
        final d = sqrt(t[12] * t[12] + t[13] * t[13] + t[14] * t[14]);
        setState(() => lastDistanceMeters = d);
        showResult("📏 거리: ${d.toStringAsFixed(2)} m");
      } else {
        showResult("❌ 물체 감지 안됨");
      }
    };
  }

  void showResult(String msg) {
    setState(() => resultText = msg);
  }

  Future<void> captureAndPredict() async {
    try {
      await arSessionManager.onInitialize(
        showAnimatedGuide: false,
        showFeaturePoints: false,
        showPlanes: false,
        handleTaps: true,
      );

      final imageProvider = await arSessionManager.snapshot();
      final memoryImage = imageProvider as MemoryImage;
      final bytes = memoryImage.bytes;

      final image = img.decodeImage(bytes);
      if (image == null) throw Exception("이미지 디코딩 실패");

      final rotatedImage = img.copyRotate(image, 270);
      final resized = img.copyResize(rotatedImage, width: 640, height: 640);

      final input = Float32List(1 * 640 * 640 * 3);
      int i = 0;
      for (int y = 0; y < 640; y++) {
        for (int x = 0; x < 640; x++) {
          final p = resized.getPixel(x, y);
          input[i++] = img.getRed(p) / 255.0;
          input[i++] = img.getGreen(p) / 255.0;
          input[i++] = img.getBlue(p) / 255.0;
        }
      }

      final outputCls = List.generate(
        1 * 8400 * 2,
        (_) => 0.0,
      ).reshape([1, 8400, 2]);
      final outputMask = List.generate(
        1 * 8400 * 32,
        (_) => 0.0,
      ).reshape([1, 8400, 32]);
      final outputProto = List.generate(
        1 * 160 * 160 * 32,
        (_) => 0.0,
      ).reshape([1, 160, 160, 32]);

      segInterpreter.runForMultipleInputs(
        [
          input.reshape([1, 640, 640, 3]),
        ],
        {0: outputCls, 1: outputMask, 2: outputProto},
      );

      final cls = outputCls[0];
      final maskVecs = outputMask[0];
      final proto = outputProto[0];

      final List<double> confidences =
          cls.map<double>((e) => 1 / (1 + exp(-e[1]))).toList();

      // 중심 위치 설정
      const imageCenter = Point(320, 320);

      // 가중치 적용한 confidence 리스트 만들기
      final weighted =
          confidences.asMap().entries.where((e) => e.value > 0.3).map((entry) {
              final idx = entry.key;
              final conf = entry.value;

              // YOLO의 박스 index → x, y 중심 추정
              final row = idx ~/ 80;
              final col = idx % 80;
              final centerX = (col + 0.5) * (640.0 / 80);
              final centerY = (row + 0.5) * (640.0 / 80);
              final dx = (centerX - imageCenter.x);
              final dy = (centerY - imageCenter.y);
              final dist = sqrt(dx * dx + dy * dy);

              // 거리에 따른 가중치 (가까울수록 점수 증가)
              final weight = 1.0 / (1.0 + dist / 100);
              return MapEntry(idx, conf * weight);
            }).toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      if (weighted.isEmpty) {
        showResult("❌ 물고기 감지 안됨");
        return;
      }

      final topIdx = weighted.first.key;
      final vector = maskVecs[topIdx];

      // 마스크 생성
      final protoReshaped = List.generate(160 * 160, (i) {
        final y = i ~/ 160, x = i % 160;
        final dot = List.generate(
          32,
          (j) => proto[y][x][j] * vector[j],
        ).reduce((a, b) => a + b);
        final sigmoid = 1 / (1 + exp(-dot / 3.0));
        return sigmoid > 0.4 ? 255 : 0;
      });

      final maskImage = img.Image(160, 160);
      for (int i = 0; i < 160 * 160; i++) {
        final x = i % 160, y = i ~/ 160, v = protoReshaped[i];
        maskImage.setPixel(x, y, img.getColor(v, v, v));
      }

      final upscaled = img.copyResize(maskImage, width: 640, height: 640);
      final largestContour = _findCenterWeightedLargestContour(upscaled);
      if (largestContour.isEmpty) {
        showResult("❌ 윤곽 없음");
        return;
      }

      final left = largestContour.reduce((a, b) => a.x < b.x ? a : b);
      final right = largestContour.reduce((a, b) => a.x > b.x ? a : b);
      final intersection = Point(right.x, left.y);
      final lengthPx = (intersection.x - left.x).abs().toDouble();
      final correctedPx = lengthPx;

      final distance = lastDistanceMeters ?? 0.5;
      final fovRadians = 60.0 * pi / 180.0;
      final widthMeters = 2 * distance * tan(fovRadians / 2);
      final pixelToMeter = widthMeters / 640.0;
      const correctionFactor = 1.18;
      final lengthCm = correctedPx * pixelToMeter * 100 * correctionFactor;

      // ✅ 여기서부터 종 분류 모델 실행
      // 🎯 [1] 마스크 기반 RGB 이미지 생성
      final resizedOriginal = img.copyResize(
        rotatedImage,
        width: 640,
        height: 640,
      );
      final binaryMaskRaw = fillContourMask(largestContour, 640, 640);
      final binaryMask = _morphClose(binaryMaskRaw, radius: 3); // 내부 구멍 메움
      final maskedImage = img.Image(640, 640);
      for (int y = 0; y < 640; y++) {
        for (int x = 0; x < 640; x++) {
          // [정확한 마스킹 기준 - upscaled 마스크 사용]
          final isFish = img.getRed(binaryMask.getPixel(x, y)) > 128;
          final pixel = resizedOriginal.getPixel(x, y);
          maskedImage.setPixel(x, y, isFish ? pixel : img.getColor(0, 0, 0));
        }
      }

      final box = _getBoundingBoxFromContour(largestContour);
      final croppedRGB = img.copyCrop(
        resizedOriginal,
        box.left.toInt(),
        box.top.toInt(),
        box.width.toInt(),
        box.height.toInt(),
      );
      // 🎯 [2] 분류 입력 이미지: 마스킹 없이 원본 RGB를 BBox로 자름
      final resizedForClassify = img.copyResize(
        croppedRGB,
        width: 224,
        height: 224,
      );

      // final maskedCropped = img.Image(box.width.toInt(), box.height.toInt());
      // for (int y = 0; y < box.height; y++) {
      //   for (int x = 0; x < box.width; x++) {
      //     final maskValue = img.getRed(croppedMask.getPixel(x, y));
      //     final rgbPixel = croppedRGB.getPixel(x, y);
      //     maskedCropped.setPixel(x, y, maskValue > 128 ? rgbPixel : img.getColor(0, 0, 0));
      //   }
      // }

      // final resizedForClassify = img.copyResize(maskedCropped, width: 224, height: 224);

      // 🎯 [3] 디버깅 저장
      final imageArray = List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resizedForClassify.getPixel(x, y);
          return [
            img.getRed(pixel).toDouble(),
            img.getGreen(pixel).toDouble(),
            img.getBlue(pixel).toDouble(),
          ];
        }),
      );
      final output = List.generate(1, (_) => List.filled(26, 0.0));

      classifyInterpreter.run([imageArray], output);

      final probs = output[0];
      final bestIdx = probs.indexOf(probs.reduce(max));
      final confidence = probs[bestIdx];
      final name = confidence > 0.5 ? fishList[bestIdx] : "모름";

      // 최종 결과 출력
      showResult(
        "📏 길이: ${lengthCm.toStringAsFixed(1)} cm\n🎣 종: $name (${(confidence * 100).toStringAsFixed(1)}%)",
      );
      await Future.delayed(Duration(seconds: 3));
      Navigator.pop(context, {
        "result": name,
        "fishSize": lengthCm,
        "image": image,
        "resultList": probs,
      });
    } catch (e, stack) {
      debugPrint("❌ 에러 발생: $e");
      debugPrint("📍 $stack");
      showResult("에러 발생: $e");
    }
  }

  List<Point<int>> _findCenterWeightedLargestContour(img.Image mask) {
    final visited = <Point<int>>{};
    final center = Point(mask.width ~/ 2, mask.height ~/ 2);
    List<Point<int>> best = [];
    double bestScore = -1;

    for (int y = 0; y < mask.height; y++) {
      for (int x = 0; x < mask.width; x++) {
        final p = Point(x, y);
        if (visited.contains(p) || img.getRed(mask.getPixel(x, y)) < 200)
          continue;

        List<Point<int>> q = [p], contour = [];
        visited.add(p);

        while (q.isNotEmpty) {
          final cur = q.removeLast();
          contour.add(cur);
          for (var dx in [-1, 0, 1]) {
            for (var dy in [-1, 0, 1]) {
              final nx = cur.x + dx, ny = cur.y + dy;
              final np = Point(nx, ny);
              if (nx >= 0 &&
                  ny >= 0 &&
                  nx < mask.width &&
                  ny < mask.height &&
                  !visited.contains(np) &&
                  img.getRed(mask.getPixel(nx, ny)) > 128) {
                visited.add(np);
                q.add(np);
              }
            }
          }
        }

        if (contour.length > 50) {
          final avgX =
              contour.map((p) => p.x).reduce((a, b) => a + b) / contour.length;
          final avgY =
              contour.map((p) => p.y).reduce((a, b) => a + b) / contour.length;
          final dist = sqrt(pow(avgX - center.x, 2) + pow(avgY - center.y, 2));
          final score = contour.length / (1.0 + dist);
          if (score > bestScore) {
            best = contour;
            bestScore = score;
          }
        }
      }
    }

    return best;
  }

  img.Image fillContourMask(List<Point<int>> contour, int width, int height) {
    final mask = img.Image(width, height);
    img.fill(mask, img.getColor(0, 0, 0));

    for (final point in contour) {
      mask.setPixel(point.x, point.y, img.getColor(255, 255, 255));
    }

    final centerX =
        contour.map((p) => p.x).reduce((a, b) => a + b) ~/ contour.length;
    final centerY =
        contour.map((p) => p.y).reduce((a, b) => a + b) ~/ contour.length;
    _simpleFloodFill(mask, centerX, centerY, img.getColor(255, 255, 255));

    return mask;
  }

  img.Image _dilateMask(img.Image mask, {int radius = 1}) {
    final result = img.Image.from(mask);
    for (int y = 0; y < mask.height; y++) {
      for (int x = 0; x < mask.width; x++) {
        if (img.getRed(mask.getPixel(x, y)) > 128) {
          for (int dy = -radius; dy <= radius; dy++) {
            for (int dx = -radius; dx <= radius; dx++) {
              final nx = x + dx;
              final ny = y + dy;
              if (nx >= 0 && ny >= 0 && nx < mask.width && ny < mask.height) {
                result.setPixel(nx, ny, img.getColor(255, 255, 255));
              }
            }
          }
        }
      }
    }
    return result;
  }

  // 마스크 침식 (Erosion)
  img.Image _erodeMask(img.Image mask, {int radius = 1}) {
    final result = img.Image.from(mask);
    for (int y = 0; y < mask.height; y++) {
      for (int x = 0; x < mask.width; x++) {
        bool erode = false;
        for (int dy = -radius; dy <= radius; dy++) {
          for (int dx = -radius; dx <= radius; dx++) {
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= mask.width || ny >= mask.height)
              continue;
            if (img.getRed(mask.getPixel(nx, ny)) < 128) {
              erode = true;
              break;
            }
          }
          if (erode) break;
        }
        result.setPixel(
          x,
          y,
          erode ? img.getColor(0, 0, 0) : img.getColor(255, 255, 255),
        );
      }
    }
    return result;
  }

  // 클로징 연산 (dilate → erode)
  img.Image _morphClose(img.Image mask, {int radius = 1}) {
    final dilated = _dilateMask(mask, radius: radius);
    return _erodeMask(dilated, radius: radius);
  }

  Rect _getBoundingBoxFromContour(List<Point<int>> contour) {
    final xs = contour.map((p) => p.x);
    final ys = contour.map((p) => p.y);
    final left = xs.reduce(min);
    final right = xs.reduce(max);
    final top = ys.reduce(min);
    final bottom = ys.reduce(max);
    return Rect.fromLTWH(
      left.toDouble(),
      top.toDouble(),
      (right - left + 1).toDouble(),
      (bottom - top + 1).toDouble(),
    );
  }
}
