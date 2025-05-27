import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/models/fish_provider.dart';
import 'package:thewater/providers/fish_provider.dart';

class FishSave extends StatefulWidget {
  const FishSave({super.key});

  @override
  State<FishSave> createState() => _FishSaveState();
}

class _FishSaveState extends State<FishSave> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("도감"), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 0.45,
            image: AssetImage('assets/image/도감배경.jpg'), // 도감 배경
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // 상단에 이번달 포획한 횟수 표시
            const SizedBox(height: 16),
            Text(
              "포획한 횟수 : ${Provider.of<FishModel>(context, listen: false).fishCardList.length}마리",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 물고기 목록을 3열(Grid)로 표시
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                // 3열 배치
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 한 줄에 3개
                  crossAxisSpacing: 10, // 가로 간격
                  mainAxisSpacing: 10, // 세로 간격
                  childAspectRatio: 0.7, // 카드(가로:세로) 비율 조정
                ),
                itemCount:
                    Provider.of<FishModel>(
                      context,
                      listen: true,
                    ).fishCardList.length,
                itemBuilder: (context, index) {
                  final fishCard =
                      Provider.of<FishModel>(
                        context,
                        listen: false,
                      ).fishCardList[index];
                  return GestureDetector(
                    onLongPress: () => _showFishDeleteDialog(context, fishCard),
                    onTap: () => _showFishDetailDialog(context, fishCard),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 물고기 이미지
                        Image.asset(
                          "assets/image/${fishCard["fishName"]}.png",
                          height: 100,
                        ),
                        const SizedBox(height: 8),
                        // 물고기 이름
                        Text(
                          fishCard["fishName"]!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "${fishCard["fishSize"].toString()}cm",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFishDeleteDialog(
    BuildContext context,
    Map<String, dynamic> fishCard,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: const Text("물고기를 삭제하시겠습니까?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // 취소
                child: const Text("취소"),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<FishModel>(
                    context,
                    listen: false,
                  ).deleteFishCard(context, fishCard['id']);
                },
                child: const Text("확인"),
              ),
            ],
          ),
    );
  }

  void _showFishDetailDialog(
    BuildContext context,
    Map<String, dynamic> fishCard,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 탭하면 닫히도록 설정
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 둥근 모서리 적용
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  fishCard["fishName"]!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  child: FutureBuilder<Uint8List>(
                    future: Provider.of<FishModel>(
                      context,
                    ).fetchImageBytes(fishCard['cardImg']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('에러 발생: ${snapshot.error}');
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                          ),
                        ); // ← 바로 화면에 표시
                      }
                    },
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("잡은날 ${fishCard["collectDate"]}"),
                          SizedBox(height: 8),
                          Text("날씨 ${fishCard["sky"]}"),
                          SizedBox(height: 8),
                          Text("기온 ${fishCard["temperature"]}"),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("길이 ${fishCard["fishSize"]} cm"),
                          SizedBox(height: 8),
                          Text("수온 ${fishCard["waterTemperature"]}"),
                          SizedBox(height: 8),
                          Text("물때 ${fishCard["tide"]}"),
                          // SizedBox(height: 8),
                          // Text("위도 ${fishCard["latitude"]}"),
                          // SizedBox(height: 8),
                          // Text("경도 ${fishCard["longitude"]}"),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 16),
                    Expanded(child: Text("메모 ${fishCard["comment"]}")),
                    SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
