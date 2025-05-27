import 'package:flutter/material.dart';
import 'package:thewater/services/auth_api.dart';
import 'dart:math';

String generateNickname(String prefix) {
  final random = Random();
  final randomNumber = random.nextInt(9000) + 1000; // 1000~9999
  return '$prefix\_$randomNumber';
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _signupScreenState();
}

class _signupScreenState extends State<SignupScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  String? _idCheckMessage;

  bool _isEmailVerified = false;

  void _checkIdAvailability() async {
    debugPrint("아이디 중복체크 버튼 클릭");
    bool isValid = await AuthApi().checkIdAvailability(
      _idController.text.trim(),
    );
    // bool isValid = true;
    setState(() {
      _idCheckMessage = isValid ? "사용 가능한 아이디입니다." : "이미 사용 중인 아이디입니다.";
    });
    // 아이디 중복 확인 기능 (추후 API 연결 가능)
    print("아이디 중복 확인: ${_idController.text}");
  }

  void _sendVerificationCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이메일을 입력해주세요')));
      return;
    }

    final isSent = await AuthApi().sendVerificationCode(email);

    if (isSent) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('인증번호가 전송되었습니다')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('인증번호 전송에 실패했습니다')));
    }
  }

  void _verifyCode() async {
    // 인증번호 확인 기능 (추후 API 연결 가능)
    final email = _emailController.text.trim();
    final code = _verificationCodeController.text.trim();

    if (email.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이메일과 인증번호를 모두 입력해주세요')));
      return;
    }

    final isVerified = await AuthApi().verifyEmailCode(
      email: email,
      code: code,
    );

    if (isVerified) {
      setState(() {
        _isEmailVerified = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이메일 인증이 완료되었습니다')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('인증번호가 틀렸습니다')));
    }
    print("인증번호 확인: ${_verificationCodeController.text}");
  }

  void _nextStep() async {
    final signupId = _idController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final email = _emailController.text.trim();

    if (!_isEmailVerified) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이메일 인증을 완료해주세요')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('비밀번호가 일치하지 않습니다')));
      return;
    }

    final isSuccess = await AuthApi().signUp(
      loginId: signupId,
      password: password,
      email: _emailController.text.trim(),
      nickname: generateNickname('낚시꾼'), // 임시 닉네임
    );

    if (isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('회원가입이 완료되었습니다')));
      Navigator.pop(context); // 이전 화면으로 이동
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('회원가입 실패. 다시 시도해주세요')));
    }
    print("회원가입 진행");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 50, right: 50, top: 100),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  '회원가입',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 50),
              // 1️⃣ 아이디 입력란 + 중복 확인 버튼
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: '아이디 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: _checkIdAvailability,
                    child: Text(
                      '중복 확인',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (_idCheckMessage != null)
                Text(
                  _idCheckMessage!,
                  style: TextStyle(
                    color:
                        _idCheckMessage == "사용 가능한 아이디입니다."
                            ? Colors.green
                            : Colors.red,
                    fontSize: 14,
                  ),
                ),

              // 2️⃣ 비밀번호 입력란
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호 입력',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // 3️⃣ 비밀번호 확인 입력란
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // 4️⃣ 이메일 입력란 + 인증번호 발송 버튼
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: '이메일 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _sendVerificationCode,
                    child: Text(
                      '인증번호 발송',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // 5️⃣ 인증번호 입력란 + 확인 버튼
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _verificationCodeController,
                      decoration: InputDecoration(
                        labelText: '인증번호 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: _verifyCode,
                    child: Text(
                      '확인',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),

              // 6️⃣ 다음 버튼
              TextButton(
                onPressed: _nextStep,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  '다음',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
