import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://j12c201.p.ssafy.io/api';

class AuthApi {
  Future<bool> checkIdAvailability(String loginId) async {
    final url = Uri.parse('$baseUrl/users/check-id?login_id=$loginId');

    try {
      final response = await http.get(url);
      debugPrint("응답 코드: ${response.statusCode}");

      // 인코딩 문제
      final decodedBody = utf8.decode(response.bodyBytes);
      debugPrint("응답 바디 (UTF-8 디코딩): $decodedBody");

      final json = jsonDecode(decodedBody);

      if (response.statusCode == 200) {
        final message = json['data']?.toString().trim();
        debugPrint("아이디 중복체크 메시지: $message");

        return message == "사용 가능한 아이디입니다.";
      } else {
        debugPrint("응답 코드 문제: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("아이디 중복 체크 중 오류 발생: $e");
      return false;
    }
  }

  Future<bool> sendVerificationCode(String email) async {
    final url = Uri.parse('$baseUrl/users/request-verification');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(url, headers: headers, body: body);
      debugPrint("인증번호 전송 응답 코드: ${response.statusCode}");
      debugPrint("인증번호 전송 응답 바디: ${response.body}");

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint("인증번호 전송 성공: ${json['message']}");
        return true;
      } else {
        debugPrint("인증번호 전송 실패: ${json['message']}");
        return false;
      }
    } catch (e) {
      debugPrint("인증번호 전송 중 예외 발생: $e");
      return false;
    }
  }

  Future<bool> signUp({
    required String loginId,
    required String password,
    required String email,
    required String nickname,
  }) async {
    final url = Uri.parse('$baseUrl/users/signup');
    final headers = {'Content-Type': 'application/json'};
    final birthDay =
        '${DateTime.now().toUtc().toIso8601String().split('.').first}Z';
    final body = jsonEncode({
      "loginId": loginId,
      "password": password,
      "email": email,
      "nickname": nickname,
      "birthday": birthDay,
      "loginType": "E",
      "has_deleted": false,
    });

    debugPrint("회원가입 요청 전 - loginId: $loginId");
    debugPrint("회원가입 요청 전 - email: $email");
    debugPrint("회원가입 요청 전 - nickname: $nickname");
    debugPrint("회원가입 요청 전 - birthDay: $birthDay");
    debugPrint("최종 요청 바디: $body");

    try {
      final response = await http.post(url, headers: headers, body: body);
      debugPrint("응답 코드: ${response.statusCode}");
      debugPrint("응답 바디: ${response.body}");

      if (response.body.isEmpty) {
        debugPrint("응답 바디가 비어있음, 왜 비어있냐고");
        debugPrint("요청 바디: $body");
        return response.statusCode == 200;
      }

      final json = jsonDecode(response.body);
      debugPrint("회원가입 성공: ${json['message']}");
      return true;
    } catch (e) {
      debugPrint("회원가입 오류 발생: $e");
      return false;
    }
  }

  Future<bool> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse('$baseUrl/users/verify-code');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'code': code});

    try {
      final response = await http.post(url, headers: headers, body: body);
      final decodedBody = utf8.decode(response.bodyBytes);
      final json = jsonDecode(decodedBody);

      debugPrint("이메일 인증 응답 코드: ${response.statusCode}");
      debugPrint("이메일 인증 응답 메시지: ${json['message']}");

      // 영문 또는 한글 메시지 모두 대응
      if (response.statusCode == 200 &&
          (json['message'].toString().toLowerCase().contains("success") ||
              json['message'].toString().contains("성공"))) {
        debugPrint("이메일 인증 성공");
        return true;
      } else {
        debugPrint("이메일 인증 실패");
        return false;
      }
    } catch (e) {
      debugPrint("이메일 인증 중 예외 발생: $e");
      return false;
    }
  }
}
