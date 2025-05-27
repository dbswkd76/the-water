import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/mypage_provider.dart';
import 'package:thewater/providers/user_provider.dart';
import 'package:thewater/providers/aquarium_provider.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  Future<void> _showEditDialog({
    required String title,
    required String initialText,
    required Function(String newText) onSave,
  }) async {
    final controller = TextEditingController(text: initialText);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // 화면 진입 후 마이페이지 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mypageProvider = Provider.of<MypageProvider>(
        context,
        listen: false,
      );
      mypageProvider.getMyPage();
      mypageProvider.getUserComment();
      final userModel = Provider.of<UserModel>(context, listen: false);
      final aquariumModel = Provider.of<AquariumModel>(context, listen: false);
      await userModel.fetchUserInfo();
      if (userModel.id != 0) {
        await aquariumModel.fetchAquariumInfo(userModel.id);
      }
    });
  }

  void _showPasswordDialog() {
    final TextEditingController passwordController = TextEditingController();
    final userProvider = Provider.of<UserModel>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isPasswordCorrect = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("회원탈퇴를 위해 비밀번호를 입력해주세요."),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "비밀번호를 입력하세요...",
                    ),
                  ),
                  if (isPasswordCorrect)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // 비밀번호 다이얼로그 닫기
                          _showWithdrawalConfirmationDialog();
                        },
                        child: const Text(
                          "회원탈퇴",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
                TextButton(
                  onPressed: () async {
                    final inputPassword = passwordController.text;
                    final isMatch = await userProvider.checkPassword(
                      loginId: userProvider.loginId,
                      password: inputPassword,
                    );
                    if (isMatch) {
                      setState(() {
                        isPasswordCorrect = true;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("비밀번호가 올바르지 않습니다.")),
                      );
                    }
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 회원탈퇴 확인 다이얼로그
  void _showWithdrawalConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("회원탈퇴 진행"),
          content: const Text("모든 아이템과 낚시 기록이 회원데이터와 함께 삭제됩니다.\n정말로 진행하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final userProvider = Provider.of<UserModel>(
                  context,
                  listen: false,
                );

                bool success = await userProvider.deleteUser(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("정상적으로 회원이 탈퇴되었습니다. 메인페이지로 이동합니다."),
                    ),
                  );
                  // 2초 후 로그인 화면으로 이동
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("회원탈퇴에 실패했습니다. 다시 시도해주세요.")),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("회원탈퇴"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mypageProvider = Provider.of<MypageProvider>(context);
    final userProvider = Provider.of<UserModel>(context, listen: false);
    final openMessage = mypageProvider.openAquariumMessage;
    final nickname =
        mypageProvider.nickname.isNotEmpty ? mypageProvider.nickname : "조태공";
    final comment =
        mypageProvider.comment.isNotEmpty
            ? mypageProvider.comment
            : "한줄소개가 아직 등록되어있지 않습니다.";
    final latestFishDate =
        mypageProvider.latestFishDate.isNotEmpty
            ? mypageProvider.latestFishDate
            : "출항기록 없음";
    final activityArea =
        mypageProvider.latestFishLocation == "알 수 없음"
            ? "활동기록 없음"
            : mypageProvider.latestFishLocation;

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/도감배경.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 스크롤 가능한 마이페이지 내용
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  nickname,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    _showEditDialog(
                                      title: "닉네임 수정",
                                      initialText: nickname,
                                      onSave: (newText) async {
                                        // 닉네임 중복 체크 및 업데이트 로직
                                        bool available = await mypageProvider
                                            .checkNickName(newText);
                                        if (available) {
                                          bool success = await mypageProvider
                                              .updateNickname(newText);
                                          if (!success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "닉네임 업데이트에 실패했습니다.",
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text("닉네임 변경완료!"),
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "이미 사용중인 닉네임입니다. 변경실패",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            comment,
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            _showEditDialog(
                              title: "한줄소개 수정",
                              initialText: comment,
                              onSave: (newText) async {
                                bool success = await mypageProvider
                                    .updateComment(newText);
                                if (!success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("자기소개 업데이트에 실패했습니다."),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Consumer<AquariumModel>(
                                builder: (context, aquariumModel, child) {
                                  return Text(
                                    '누적 방문수 ${aquariumModel.visitCount}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              InkWell(
                                onTap: () async {
                                  final message =
                                      await mypageProvider.openAquarium();
                                  if (message != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("수족관 공개/비공개 처리에 실패했습니다."),
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Text("수족관 공개여부"),
                                    const SizedBox(width: 4),
                                    Icon(
                                      openMessage == "어항이 공개 모드로 변경되었습니다."
                                          ? Icons.lock_open
                                          : Icons.lock,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "최근 출항일",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(latestFishDate),
                          const SizedBox(height: 12),
                          const Text(
                            "활동지역",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            children:
                                activityArea.split(", ").map((area) {
                                  return Chip(
                                    label: Text(area),
                                    backgroundColor: Colors.blue.shade100,
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "마지막으로 잡은 물고기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "가장 마지막으로 잡은 물고기 사진",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: GestureDetector(
                  onTap: _showPasswordDialog,
                  child: const Text(
                    "회원탈퇴",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.black),
                  onPressed: () {
                    debugPrint('logout 아이콘 터치');
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("로그아웃 완료")));
                    userProvider.logout(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) => AlertDialog(
                            content: const Text("로그아웃 되었습니다.\n로그인화면으로 이동합니다."),
                          ),
                    );
                    Future.delayed(const Duration(seconds: 2), () {
                      Navigator.of(context).pop();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    });
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
