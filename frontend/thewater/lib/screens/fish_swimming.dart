import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:thewater/providers/fish_provider.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';

class RemovalAnimationData {
  final String imagePath;
  final double startX;
  final double startY;
  final AnimationController controller;

  RemovalAnimationData({
    required this.imagePath,
    required this.startX,
    required this.startY,
    required this.controller,
  });
}

enum FishState { moving, idle }

class SwimmingFish {
  final String imagePath;
  final String fishName;
  double x;
  double y;
  double speed;
  FishState state;
  double dx;
  double dy;
  double stateTime;
  double stateDuration;
  bool isPaused;
  bool isDragging;

  Timer? longPressTimer;

  SwimmingFish({
    required this.imagePath,
    required this.fishName,
    required this.x,
    required this.y,
    required this.speed,
    required this.state,
    required this.dx,
    required this.dy,
    required this.stateTime,
    required this.stateDuration,
    this.isPaused = false,
    this.isDragging = false,
  });
}

class FallingFish {
  final String imagePath;
  double top;
  bool landed;

  FallingFish({required this.imagePath, this.top = -100, this.landed = false});
}

class FishSwimmingManager {
  List<SwimmingFish> swimmingFishes = [];
  List<FallingFish> fallingFishes = [];
  List<RemovalAnimationData> removalAnimations = [];
  Timer? timer;

  final TickerProvider tickerProvider;
  final BuildContext context;
  final VoidCallback update;
  final Random random = Random();

  // 8방향 (상, 상우, 우, 우하, 하, 하좌, 좌, 좌상)
  final List<Map<String, double>> directions = [];

  FishSwimmingManager({
    required this.tickerProvider,
    required this.context,
    required this.update,
  }) {
    double invSqrt2 = 1 / sqrt(2);
    directions.addAll([
      {'dx': 0, 'dy': -1}, // 상
      {'dx': invSqrt2, 'dy': -invSqrt2}, // 상우
      {'dx': 1, 'dy': 0}, // 우
      {'dx': invSqrt2, 'dy': invSqrt2}, // 우하
      {'dx': 0, 'dy': 1}, // 하
      {'dx': -invSqrt2, 'dy': invSqrt2}, // 하좌
      {'dx': -1, 'dy': 0}, // 좌
      {'dx': -invSqrt2, 'dy': -invSqrt2}, // 좌상
    ]);
  }

  void startFishMovement() {
    timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      update();
      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;
      const double fishSize = 80.0;
      const double topBoundary = 120.0;
      const double bottomBarHeight = 60.0;
      final double bottomBoundary =
          screenHeight - fishSize - bottomBarHeight;

      for (var fish in swimmingFishes) {
        if (fish.isPaused || fish.isDragging) continue;
        fish.stateTime += 0.03;

        if (fish.state == FishState.moving) {
          double t = fish.stateTime / fish.stateDuration;
          double factor = sin(pi * t);
          double effectiveSpeed = fish.speed * factor;

          fish.x += fish.dx * effectiveSpeed;
          fish.y += fish.dy * effectiveSpeed;

          // 좌우 경계 체크
          if (fish.x < 0) {
            fish.x = 0;
            fish.dx = fish.dx.abs();
          } else if (fish.x > screenWidth - fishSize) {
            fish.x = screenWidth - fishSize;
            fish.dx = -fish.dx.abs();
          }
          // 상단 경계
          if (fish.y < topBoundary) {
            fish.y = topBoundary;
            fish.dy = fish.dy.abs();
          }
          // 하단 경계
          else if (fish.y > bottomBoundary) {
            fish.y = bottomBoundary;
            fish.dy = -fish.dy.abs();
          }

          if (fish.stateTime >= fish.stateDuration) {
            fish.state = FishState.idle;
            fish.stateTime = 0.0;
            fish.stateDuration = random.nextDouble() * 2.0;
          }
        } else {
          if (fish.stateTime >= fish.stateDuration) {
            int index = random.nextInt(directions.length);
            fish.dx = directions[index]['dx']!;
            fish.dy = directions[index]['dy']!;
            fish.state = FishState.moving;
            fish.stateTime = 0.0;
            fish.stateDuration = 2.0 + random.nextDouble() * 2.0;
          }
        }
      }
    });
  }

  void addFallingFish(String imagePath, String fishName) {
    // debugPrint("addFallingFish() 실행됨 : $fishName");
    final newFish = FallingFish(imagePath: imagePath);
    fallingFishes.add(newFish);
    update();

    Future.delayed(Duration.zero, () {
      animateFishFall(newFish, fishName);
    });
  }

  void animateFishFall(FallingFish fish, String fishName) {
    const double targetY = 400;
    const double baseSpeed = 20;
    const double fishSize = 80.0;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      update();
      double progress = (fish.top / targetY).clamp(0.0, 1.0);
      double currentSpeed = baseSpeed * (1 - progress);

      // debugPrint("낙하진행중 : top=${fish.top},speed=$currentSpeed");

      if (fish.top <= targetY - 2) {
        fish.top += currentSpeed;
      } else {
        debugPrint("낙하완료 : $fishName 수영시작");
        fish.landed = true;
        timer.cancel();

        // 낙하 완료 후, 수영하는 물고기로 전환 (랜덤 방향 선택)
        int index = random.nextInt(directions.length);
        double dx = directions[index]['dx']!;
        double dy = directions[index]['dy']!;
        double movingDuration = 1.0 + random.nextDouble() * 2.0; // 이동시간

        SwimmingFish newSwimmingFish = SwimmingFish(
          imagePath: fish.imagePath,
          fishName: fishName,
          x: MediaQuery.of(context).size.width / 2 - fishSize / 2,
          y: fish.top,
          speed: 1.2 + random.nextDouble(),
          state: FishState.moving,
          dx: dx,
          dy: dy,
          stateTime: 0.0,
          stateDuration: movingDuration,
        );
        swimmingFishes.add(newSwimmingFish);
        fallingFishes.remove(fish);
        update();
      }
    });
  }

  void removeFishWithFishingLine(String imagePath) {
    debugPrint("물고기 제거 : $imagePath");
    final index = swimmingFishes.indexWhere(
      (fish) => fish.imagePath == imagePath,
    );
    if (index == -1) return;
    final fish = swimmingFishes[index];
    swimmingFishes.removeAt(index);

    final removalController = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 2000),
    );
    final removalData = RemovalAnimationData(
      imagePath: fish.imagePath,
      startX: fish.x,
      startY: fish.y,
      controller: removalController,
    );
    removalAnimations.add(removalData);

    removalController.addListener(() {
      update();
    });
    removalController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        removalAnimations.remove(removalData);
        removalController.dispose();
        update();
      }
    });
    removalController.forward();
  }

  void removeFish(String imagePath) {
    swimmingFishes.removeWhere((fish) => fish.imagePath == imagePath);
    fallingFishes.removeWhere((fish) => fish.imagePath == imagePath);
    update();
  }

  // 꾹 눌렀을때 정보나오게
  void showFishDetailDialog(SwimmingFish fish) {
    final fishProvider = Provider.of<FishModel>(context, listen: false);
    final fishData = fishProvider.fishCardList.firstWhere(
      (element) => element['fishName'] == fish.fishName,
      orElse: () => null,
    );
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (fishData != null && fishData['cardImg'] != null)
                    FutureBuilder<Uint8List>(
                      future: fishProvider.fetchImageBytes(fishData['cardImg']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            height: 100,
                            fit: BoxFit.contain,
                          );
                        } else {
                          return Container(
                            height: 100,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                    )
                  else
                    Container(
                      height: 100,
                      child: const Center(child: Text('No Image')),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    fishData != null ? fishData['fishName'] : fish.fishName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  if (fishData != null) ...[
                    Text(
                      "크기: ${fishData['fishSize']}",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "잡은날짜: ${fishData['collectDate']}",
                      textAlign: TextAlign.center,
                    ),
                    Text(fishData['comment'] != null ? "내용: 내용이 없습니다." : 
                      "내용: ${fishData['comment']}",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "물 온도: ${fishData['waterTemperature']}",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "공기 온도: ${fishData['temperature']}",
                      textAlign: TextAlign.center,
                    ),
                  ] else
                    const Text(
                      "상세 정보를 찾을 수 없습니다.",
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> buildRemovalAnimations() {
    const double fishSize = 80.0;
    const double lineHeight = 600.0;
    const double lineWidth = 30.0;

    return removalAnimations.map((data) {
      double t = data.controller.value; // 0 ~ 1 사이의 값
      double fishingLineBottomY;
      double fishY;
      if (t < 0.8) {
        // 낚시줄 내려오기 (0 ~ 0.8초)
        double stageT = t / 0.8; // 0~1 범위로 보정
        double easeT = 1 - pow(1 - stageT, 2).toDouble(); // ease-out 효과 적용
        fishingLineBottomY = lerpDouble(-lineHeight, data.startY + 50, easeT)!;
        fishY = data.startY; // 물고기는 고정
      } else {
        // 낚시줄과 함께 위로 이동 (0.8 ~ 1초)
        double stageT = (t - 0.8) / 0.2; // 0 ~ 1 범위로
        fishY = data.startY + (-data.startY - fishSize) * stageT;
        // 낚시줄의 bottom도 같이 이동
        fishingLineBottomY =
            data.startY + (-data.startY + 50 - fishSize) * stageT;
      }
      // 낚시줄의 x 위치: 물고기 중앙 기준
      double lineX = data.startX + fishSize / 2 - lineWidth / 2;
      return Stack(
        children: [
          // 낚시줄 이미지
          Positioned(
            left: lineX,
            top: fishingLineBottomY - lineHeight,
            child: Image.asset(
              'assets/image/낚시줄.png',
              width: lineWidth,
              height: lineHeight,
              fit: BoxFit.fill,
            ),
          ),
          // 물고기 이미지
          Positioned(
            left: data.startX,
            top: fishY,
            child: Image.asset(data.imagePath, width: fishSize),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> buildSwimmingFishes() {
    const double fishSize = 80;
    return swimmingFishes.map((fish) {
      return Positioned(
        top: fish.y,
        left: fish.x,
        child: GestureDetector(
          onTapDown: (details) {
            fish.longPressTimer = Timer(const Duration(seconds: 1), () {
              showFishDetailDialog(fish);
            });
          },
          onTapUp: (_) {
            fish.longPressTimer?.cancel();
            fish.longPressTimer = null;
          },
          onTapCancel: () {
            fish.longPressTimer?.cancel();
            fish.longPressTimer = null;
          },
          onPanStart: (_) {
            fish.longPressTimer?.cancel();
            fish.longPressTimer = null;
            fish.isDragging = true;
            fish.isPaused = true;
          },
          onPanUpdate: (details) {
            fish.x += details.delta.dx;
            fish.y += details.delta.dy;
            update(); // 위치 갱신
          },
          onPanEnd: (_) {
            fish.isDragging = false;
            Timer(const Duration(milliseconds: 1500), () {
              fish.isPaused = false;
              update();
            });
          },
          child: Container(
            width: fishSize,
            height: fishSize + 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform:
                      fish.dx < 0 ? Matrix4.rotationY(pi) : Matrix4.identity(),
                  child: Image.asset(
                    fish.imagePath,
                    width: fishSize,
                    height: fishSize,
                    fit: BoxFit.contain,
                  ),
                ),
                if (fish.isPaused)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildFishNameOverlay(fish.fishName),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildFishNameOverlay(String fishName) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          fishName,
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  List<Widget> buildFallingFishes() {
    return fallingFishes.map((fish) {
      return Positioned(
        top: fish.top,
        left: MediaQuery.of(context).size.width / 2 - 40,
        child: Image.asset(fish.imagePath, width: 80),
      );
    }).toList();
  }

  void dispose() {
    timer?.cancel();
    for (var data in removalAnimations) {
      data.controller.dispose();
    }
  }
}
