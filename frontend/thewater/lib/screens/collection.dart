import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/models/fish_provider.dart';
import 'package:thewater/providers/fish_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return const CollectionPage();
  }
}

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}


late BitmapDescriptor markerIcon;

class _CollectionPageState extends State<CollectionPage> {
  @override
  void initState() {
    debugPrint("collectionPage initState 실행됨");
    super.initState();
    rootBundle.loadString('assets/map_style.json').then((string) {
    _mapStyle = string;
    });

    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/image/marker.png',
    ).then((icon) {
      setState(() {
        markerIcon = icon;
      });
    });

    Provider.of<FishModel>(context, listen: false).getFishCardList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("도감", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
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
                  mainAxisSpacing: 12, // 세로 간격
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${fishCard["fishSize"].toStringAsFixed(1)}cm",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
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

  late GoogleMapController mapController;
  late String _mapStyle;


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController!.setMapStyle(_mapStyle);
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

  Widget buildLabelValue(String label, String value) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3), // ⬅️ 위아래 margin 3
      child: RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(
              text: "$label:   ",
              style: baseStyle.merge(const TextStyle(fontSize: 15)),
            ),
            TextSpan(
              text: value,
              style: baseStyle.merge(
                const TextStyle(fontSize: 15, color: Colors.blueGrey),
              ),
            ),
          ],
        ),
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
          child: Stack(
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/image/paper.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  height: 800,
                  width: 400,
                ),
              ),

              Center(
                child: SizedBox(
                  height: 400,
                  width: 300,
                  child: SingleChildScrollView(
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
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabelValue("잡은날", "${fishCard["collectDate"]}"),
                            SizedBox(height: 8),
                            if (fishCard["sky"] == 1)
                              buildLabelValue("날씨", "맑음 ☀️")
                            else if (fishCard["sky"] == 2)
                              buildLabelValue("날씨","구름조금 🌤️")
                            else if (fishCard["sky"] == 3)
                              buildLabelValue("날씨","구름 🌥️")
                            else if (fishCard["sky"] == 4)
                              buildLabelValue("날씨","구름 많음 ☁️"),
                            SizedBox(height: 8),
                            buildLabelValue("기온", "${fishCard["temperature"]} °C"),
                            SizedBox(height: 8),
                            buildLabelValue("길이", "${fishCard["fishSize"].toStringAsFixed(1)} cm"),
                            SizedBox(height: 8),
                            buildLabelValue("수온", "${fishCard["waterTemperature"]} °C"),
                            SizedBox(height: 8),
                            buildLabelValue("물때", "${fishCard["tide"]} m"),
                            SizedBox(height: 8),
                            buildLabelValue("메모", "${fishCard["comment"]}"),
                            SizedBox(height: 8),
                            buildLabelValue("잡은 위치", " "),

                            fishCard['latitude'] == null || fishCard['longitude'] == null
                            ? Container(
                                height: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '위치 정보 없음',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                        fishCard['latitude'],
                                        fishCard['longitude'],
                                      ),
                                      zoom: 14,
                                    ),
                                    zoomControlsEnabled: false,
                                    liteModeEnabled: true,
                                    mapType: MapType.normal,
                                    onMapCreated: _onMapCreated,
                                    myLocationEnabled: false,
                                    myLocationButtonEnabled: false,
                                    markers: {
                                      Marker(
                                        markerId: MarkerId('fish_location'),
                                        position: LatLng(
                                          fishCard['latitude'],
                                          fishCard['longitude'],
                                        ),
                                        icon: markerIcon,
                                      ),
                                    },
                                  ),
                                ),
                              ),



                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
