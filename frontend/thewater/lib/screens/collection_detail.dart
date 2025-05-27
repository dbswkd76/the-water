import 'package:flutter/material.dart';

class CollectionDetailPage extends StatelessWidget {
  const CollectionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 예시 더미 데이터
    final String fishName = "돌돔"; // 물고기 이름
    final String fishType = "바다물고기"; // '민물고기' / '바다물고기'
    final String fishDescription =
        "먹이로 일반 바다 낚시에서 쓰는 크릴새우를 파워는 안 쓰다. 보통 섭취를 한 상자 가득 담아오고 쓴다.";
    final String fishSize = "40cm";
    final String fishLocation = "여수";
    final String fishDate = "2023-03-09";
    final String fishClosedSeason = "없음";

    // 같은 어종 목록(가로 스크롤 이미지)
    final List<String> sameSpeciesImages = [
      "assets/갈치.png",
      "assets/갈치.png",
      "assets/갈치.png",
      "assets/갈치.png",
      "assets/갈치.png",
      "assets/갈치.png",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("도감"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
      ),
      body: SingleChildScrollView(
        // 세로 스크롤이 가능하도록
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 물고기 메인 이미지
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.asset("assets/갈치.png", fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),

              // 물고기 이름 (중앙 정렬)
              Text(
                fishName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // 물고기 유형 (민물/바다 등) - 왼쪽 정렬
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  fishType,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 8),

              // 물고기 설명
              Text(fishDescription, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              // 크기, 포획장소 (좌/우 배치)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("크기 : $fishSize"),
                  Text("포획장소 : $fishLocation"),
                ],
              ),
              const SizedBox(height: 8),

              // 포획일, 금어기 (좌/우 배치)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("포획일 : $fishDate"),
                  Text("금어기 : $fishClosedSeason"),
                ],
              ),
              const SizedBox(height: 16),

              // 같은 어종 이미지 목록 (가로 스크롤)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sameSpeciesImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 80,
                      height: 80,
                      child: Image.asset(
                        sameSpeciesImages[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
