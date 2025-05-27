import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:thewater/main.dart';
import 'package:thewater/providers/aquarium_provider.dart';
import 'package:thewater/providers/fish_provider.dart';
import 'package:thewater/providers/guestbook_provider.dart';
import 'package:thewater/providers/user_provider.dart';
import 'package:thewater/screens/border_model.dart';
import 'package:thewater/screens/model_screen_2.dart';
import 'package:thewater/screens/fish_point.dart';
import 'package:thewater/screens/collection.dart';
import 'package:thewater/screens/fish_modal.dart';
import 'fish_swimming.dart';
import 'package:thewater/screens/guestbook.dart';
import 'package:thewater/screens/ranking.dart';
import 'package:thewater/screens/mypage.dart';
import 'package:thewater/providers/search_provider.dart';
import 'package:thewater/screens/chat_screen.dart';
import 'package:http/http.dart' as http;


class TheWater extends StatefulWidget {
  final int pageIndex;
  const TheWater({super.key, required this.pageIndex});

  @override
  State<TheWater> createState() => _TheWaterState();
}

class _TheWaterState extends State<TheWater> with RouteAware {
  int bottomNavIndex = 0;
  int pageIndex = 0;
  String? userComment;

  @override
  void initState() {
    super.initState();
    pageIndex = widget.pageIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userModel = Provider.of<UserModel>(context, listen: false);
      final aquariumModel = Provider.of<AquariumModel>(context, listen: false);
      final searchProvider = Provider.of<SearchProvider>(
        context,
        listen: false,
      );
      // user id 확인 후 수족관정보 가져오는거에 userid 대입해서 가져오는거
      if (userModel.id != 0) {
        await aquariumModel.fetchAquariumInfo(userModel.id);
        debugPrint("수족관 정보 불러오기 성공, userId : ${userModel.id}");
      } else {
        debugPrint("사용자 id가 아직 0입니다.");
      }

      await searchProvider.searchUsersByNickname(userModel.nickname);
      if (searchProvider.searchResults.isNotEmpty) {
        setState(() {
          userComment = searchProvider.searchResults.first.comment;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshUserData();
    _refreshMyAquariumInfo();
  }

  void _refreshMyAquariumInfo() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final aquariumModel = Provider.of<AquariumModel>(context, listen: false);
    if (userModel.id != 0) {
      await aquariumModel.fetchAquariumInfo(userModel.id);
      setState(() {}); // 화면 갱신
    }
  }

  void _refreshUserData() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    await userModel.fetchUserInfo();
    // 필요한 Provider들도 갱신해야 한다면 여기에 추가해서 호출

    // setState()를 호출할 경우 UI 갱신 여부 확인
    setState(() {});
  }

  LatLng? _userCenter;

  void onBottomNavTap(int newIndex) async {
    setState(() {
      bottomNavIndex = newIndex;
      pageIndex = newIndex;
    });
    if (newIndex == 2 && _userCenter == null) {
      final location = await _getCurrentLocation();
      setState(() {
        _userCenter = location;
      });
    }
  }

  Future<LatLng?> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (!status.isGranted) return null;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }

  void showCollectionPage() {
    setState(() {
      pageIndex = 1;
    });
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (pageIndex != 0) {
          setState(() {
            pageIndex = 0;
            bottomNavIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,//카메라 버튼 고정
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0XFF176B87)),
                child: Text("그물", style: TextStyle(fontSize: 30)),
              ),
              ListTile(
                title: const Text("회원가입"),
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
              ),
              if (!Provider.of<UserModel>(context).isLoggedIn)
                ListTile(
                  title: const Text("로그인"),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              if (Provider.of<UserModel>(context).isLoggedIn)
                ListTile(
                  title: const Text("로그아웃"),
                  onTap: () {
                    Provider.of<UserModel>(
                      context,
                      listen: false,
                    ).logout(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
            ],
          ),
        ),
        body: IndexedStack(
          index: pageIndex,
          children: [
            FirstPage(userComment: userComment, formatPrice: _formatPrice),
            SecondPage(), //도김
            ThirdPage(center: _userCenter),
            FourthPage(), //챗봇
            CollectionPage(),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ModelScreen2()),
              );
            },
            child: const Icon(
              Icons.camera_alt,
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
          ),
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: bottomNavIndex,
          onTap: onBottomNavTap,
          selectedItemColor: Color(0XFFA5C8B8),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.grey[100],
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0),
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    bottomNavIndex == 0
                        ? 'assets/image/어항 클릭.png'
                        : 'assets/image/어항.png',
                    width: 27,
                    height: 27,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(right: 50.0, top: 0, bottom: 0),
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    bottomNavIndex == 1
                        ? 'assets/image/도감클릭.png'
                        : 'assets/image/도감.png',
                    width: 27,
                    height: 27,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              label: "",
            ), //도감 아이콘
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(left: 50.0, top: 0, bottom: 0),
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    bottomNavIndex == 2
                        ? 'assets/image/지도 클릭.png'
                        : 'assets/image/지도.png',
                    width: 27,
                    height: 27,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0),
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    bottomNavIndex == 3
                        ? 'assets/image/챗봇 클릭.png'
                        : 'assets/image/챗봇.png',

                    width: 27,
                    height: 27,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              label: "",
            ), //챗봇
          ],
        ),
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  final String? userComment;
  final String Function(int) formatPrice;
  const FirstPage({Key? key, this.userComment, required this.formatPrice})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/background.gif'),
              fit: BoxFit.cover,
            ),
          ),
          child: MainPage(userComment: userComment, formatPrice: formatPrice),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final String? userComment;
  final String Function(int) formatPrice;
  const MainPage({super.key, this.userComment, required this.formatPrice});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late FishSwimmingManager fishManager;
  bool fishManagerInitialized = false;
  bool showMoreMenu = false;

  late AnimationController _menuController;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;
  List<GuestBookEntry> guestBookEntries = [];

  final List<Map<String, String>> menuItems = [
    {"label": "어항", "icon": "assets/icon/어항.png"},
    {"label": "도감", "icon": "assets/icon/도감.png"},
    {"label": "방명록", "icon": "assets/icon/방명록.png"},
    {"label": "랭킹", "icon": "assets/icon/랭킹.png"},
    {"label": "공유", "icon": "assets/icon/카카오공유아이콘.png"},
  ];

  // 수족관에 추가된 물고기 imagePath를 저장하는 집합
  Set<String> _selectedFish = {};

  @override
  void initState() {
    super.initState();
    _initMenuAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fishModel = Provider.of<FishModel>(context, listen: false);
      await fishModel.getFishCardList();

      fishManager = FishSwimmingManager(
        tickerProvider: this,
        context: context,
        update: () {
          if (mounted) setState(() {});
        },
      );
      fishManager.startFishMovement();

      final visibleFishList =
          fishModel.fishCardList
              .where((fish) => fish["hasVisible"] == true)
              .toList();

      setState(() {
        fishManagerInitialized = true;
      });

      for (var fish in visibleFishList) {
        var fishName = fish["fishName"];
        String path;
        if (fishName == "문어" ||
            fishName == "감성돔" ||
            fishName == "문절망둑" ||
            fishName == "광어" ||
            fishName == "농어" ||
            fishName == "볼락" ||
            fishName == "성대" ||
            fishName == "복섬" ||
            fishName == "숭어" ||
            fishName == "우럭") {
          path = "assets/image/$fishName.gif";
        } else {
          path = "assets/image/$fishName.png";
        }
        fishManager.addFallingFish(path, fishName);

        await Future.delayed(const Duration(milliseconds: 500));
      }
    });
  }

  //Provider.of<CounterProvider>(context).count

  void _openGuestBookModal() async {
    final guestBookProvider = Provider.of<GuestBookProvider>(
      context,
      listen: false,
    );
    try {
      List<GuestBookEntry> fetchedEntries =
          (await guestBookProvider.fetchMyGuestBook())
              .map<GuestBookEntry>((data) => GuestBookEntry.fromJson(data))
              .toList();
      setState(() {
        guestBookEntries = fetchedEntries;
      });
    } catch (e) {
      debugPrint("방명록 데이터를 불러오는데 실패했습니다: $e");
    }

    final double topOffset = 200;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: screenHeight - topOffset,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GuestBookModal(entries: guestBookEntries),
          ),
        );
      },
    );
  }

  void _openRankingModal() {
    final double topOffset = 200;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: screenHeight - topOffset,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: RankingModal(),
        );
      },
    );
  }

  void _openFishSelectModal() async {
    final fishModel = Provider.of<FishModel>(context, listen: false);

    // 최신 서버 데이터 가져오기 (중요!)
    await fishModel.getFishCardList();
    final fishCardList = fishModel.fishCardList;

    final fishDataList =
        fishCardList
            .map(
              (card) => {
                "id": card["id"],
                "fishName": card["fishName"],
                "hasVisible": card["hasVisible"] ?? false,
              },
            )
            .toList();

    final fishImages =
        fishDataList
            .map((data) => "assets/image/${data["fishName"]}.png")
            .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => FishSelectModal(
            fishDataList: fishDataList,
            fishImages: fishImages,
            selectedFish:
                fishDataList
                    .where((fish) => fish["hasVisible"])
                    .map((fish) => "assets/image/${fish["fishName"]}.png")
                    .toSet(),
            onToggleFish: (
              String path,
              int fishId,
              bool currentHasVisible,
            ) async {
              setState(() {
                String fishName = path.split('/').last.split('.').first;
                if (fishName == "문어" ||
                    fishName == "감성돔" ||
                    fishName == "문절망둑" ||
                    fishName == "광어" ||
                    fishName == "농어" ||
                    fishName == "볼락" ||
                    fishName == "성대" ||
                    fishName == "복섬" ||
                    fishName == "숭어" ||
                    fishName == "우럭") {
                  // 물고기 추후 추가 예정 gif 로 변환한 것들
                  path = "assets/image/${fishName}.gif";
                }
                if (currentHasVisible) {
                  fishManager.removeFishWithFishingLine(path);
                  _selectedFish.remove(path);
                } else {
                  fishManager.addFallingFish(path, fishName);
                  _selectedFish.add(path);
                }
                debugPrint("선택된 물고기 목록 : $_selectedFish");
              });

              await fishModel.toggleFishVisibility(fishId);

              final userModel = Provider.of<UserModel>(context, listen: false);
              final aquariumModel = Provider.of<AquariumModel>(
                context,
                listen: false,
              );
              await aquariumModel.fetchAquariumInfo(userModel.id);
            },
          ),
    );
  }

  void _initMenuAnimation() {
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimations = [];
    _fadeAnimations = [];

    for (int i = 0; i < menuItems.length; i++) {
      double start = i * 0.15;
      double end = (start + 0.4).clamp(0.0, 1.0);

      final slideAnim = Tween<Offset>(
        begin: const Offset(0, -0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _menuController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );

      final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _menuController,
          curve: Interval(start, end, curve: Curves.easeIn),
        ),
      );

      _slideAnimations.add(slideAnim);
      _fadeAnimations.add(fadeAnim);
    }
  }

  @override
  void dispose() {
    fishManager.dispose();
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 상단 UI: 유저 정보, 수족관 가치 등
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, size: 30),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyPageScreen(),
                                ),
                              );
                            },
                            child: Text(
                              Provider.of<UserModel>(context).nickname,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Consumer<AquariumModel>(
                            builder: (context, aquarium, _) {
                              return Text(
                                '수족관 가치 : ${widget.formatPrice(aquarium.totalPrice)}원',
                                style: const TextStyle(fontSize: 15),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Text("Today ", style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Consumer<AquariumModel>(
                            builder: (context, aquariumModel, child) {
                              return Text(
                                '${aquariumModel.visitCount}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 0.1),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// 좋아요 로직
                          Consumer<AquariumModel>(
                            builder: (context, aquariumModel, child) {
                              return Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await aquariumModel.toggleLikeAquarium();
                                    },
                                    child: Icon(
                                      aquariumModel.likedByMe
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          aquariumModel.likedByMe
                                              ? Color(0XFFf0A8A8)
                                              : Colors.grey,
                                      size: 16.0,
                                    ),
                                    // onPressed: () async {
                                    //   await aquariumModel.toggleLikeAquarium();
                                    // },
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${aquariumModel.likeCount}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showMoreMenu = !showMoreMenu;
                        if (showMoreMenu) {
                          _menuController.forward();
                        } else {
                          _menuController.reverse();
                        }
                      });
                    },
                    child: const Text(
                      "더 많은..",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // 펼쳐지는 메뉴
        if (fishManagerInitialized) ...fishManager.buildFallingFishes(),
        if (fishManagerInitialized) ...fishManager.buildSwimmingFishes(),
        if (fishManagerInitialized) ...fishManager.buildRemovalAnimations(),

        if (showMoreMenu)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showMoreMenu = false;
                  _menuController.reverse();
                });
              },
              child: Container(color: Colors.transparent),
            ),
          ),

        Positioned(
          top: 120,
          right: 16,
          child: IgnorePointer(
            ignoring: !showMoreMenu,
            child: _buildStaggeredMenu(),
          ),
        ),
        // 물고기 애니메이션 위젯들
      ],
    );
  }

  Widget _buildStaggeredMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(menuItems.length, (i) {
        return _buildStaggeredMenuItem(i);
      }),
    );
  }

  Widget _buildStaggeredMenuItem(int index) {
    final label = menuItems[index]["label"]!;
    final iconPath = menuItems[index]["icon"]!;
    double iconSize = (label == "공유") ? 43 : 60;

    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: GestureDetector(
          onTap: () {
            if (label == "도감") {
              final parentState =
                  context.findAncestorStateOfType<_TheWaterState>();
              parentState?.showCollectionPage();
            }
            if (label == "어항") {
              _openFishSelectModal();
            }
            if (label == "방명록") {
              _openGuestBookModal();
            }
            if (label == "랭킹") {
              _openRankingModal();
            }

            debugPrint("$label 메뉴 클릭");

            setState(() {
              showMoreMenu = false;
              _menuController.reverse();
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(iconPath, width: iconSize, height: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}
