import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const String baseUrl = "http://j12c201.p.ssafy.io/api";

class MypageProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  List<String> checknickname = [];

  String _openAquariumMessage = "";
  String get openAquariumMessage => _openAquariumMessage;

  String _nickname = '';
  String _loginId = '';
  String _latestFishDate = '없음';
  String _latestFishLocation = '';
  int _totalFishCaught = 0;
  String _comment = '';

  String get nickname => _nickname;
  String get loginId => _loginId;
  String get latestFishDate => _latestFishDate;
  String get latestFishLocation => _latestFishLocation;
  int get totalFishCaught => _totalFishCaught;
  String get comment => _comment;

  Future<String?> get token async {
    return await _storage.read(key: 'token');
  }

  Future<void> getMyPage() async {
    final tokenValue = await token;
    if (tokenValue == null) {
      debugPrint('getMyPage() : 유저 토큰 실패');
      return;
    }
    try {
      debugPrint("getMyPage() 토큰 확인 : $tokenValue");
      final url = Uri.parse("$baseUrl/users/mypage");
      final headers = {'Authorization': 'Bearer $tokenValue'};
      final response = await http.get(url, headers: headers);
      debugPrint("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        _nickname = body['data']['nickname'];
        _loginId = body['data']['loginId'];
        _latestFishDate = body['data']['latestFishDate'];
        _latestFishLocation = body['data']['latestFishLocation'];
        _totalFishCaught = body['data']['totalFishCaught'];
        notifyListeners();
      } else {
        throw Exception('getMyPage 오류 : ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("getMyPage() 오류 $error");
    }
  }

  /// 닉네임 변경 API
  Future<bool> updateNickname(String newNickname) async {
    final tokenValue = await token;
    if (tokenValue == null) {
      debugPrint('updateNickname: 유저 토큰 없음');
      return false;
    }
    try {
      final url = Uri.parse("$baseUrl/users/update-nickname");
      final headers = {
        'Authorization': 'Bearer $tokenValue',
        'Content-Type': 'application/json',
      };
      final response = await http.patch(
        url,
        headers: headers,
        body: newNickname,
      );
      debugPrint("updateNickname Response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        _nickname = newNickname;
        notifyListeners();
        return true;
      } else {
        debugPrint("updateNickname 오류: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      debugPrint("updateNickname() 오류: $error");
      return false;
    }
  }

  // 자기소개변경
  Future<bool> updateComment(String newComment) async {
    final tokenValue = await token;
    if (tokenValue == null) {
      debugPrint('updateComment: 유저 토큰 없음');
      return false;
    }
    try {
      final url = Uri.parse(
        "$baseUrl/users/update-comment?comment=${Uri.encodeComponent(newComment)}",
      );
      final headers = {
        'Authorization':
            tokenValue.startsWith("Bearer ")
                ? tokenValue
                : 'Bearer $tokenValue',
        'accept': '*/*',
      };
      final response = await http.patch(url, headers: headers);
      debugPrint("updateComment Response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        _comment = newComment;
        notifyListeners();
        return true;
      } else {
        debugPrint("updateComment 오류: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      debugPrint("updateComment() 오류: $error");
      return false;
    }
  }

  Future<String?> getMyComment() async {
    final tokenValue = await _storage.read(key: 'token');
    if (tokenValue == null) {
      debugPrint("getMyComment(): 유저 토큰 없.");
      return null;
    }
    try {
      final url = Uri.parse("$baseUrl/users/me");
      final headers = {'Authorization': 'Bearer $tokenValue'};
      final response = await http.get(url, headers: headers);
      debugPrint("getMyComment() Response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final comment = body['data']['comment'] ?? "";
        return comment;
      } else {
        throw Exception("getMyComment 오류: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("getMyComment() 오류: $e");
      return null;
    }
  }

  Future<void> getUserComment() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      debugPrint("getUserComment() 토큰 없음");
      return;
    }
    try {
      // debugPrint("getUserComment() 토큰 확인 : $token"); 확인완료 마지막에 지우길
      final url = Uri.parse('$baseUrl/users/me');
      final headers = {'Authorization': 'Bearer $token'};

      final response = await http.get(url, headers: headers);
      // debugPrint("Response status: ${response.statusCode}"); 확인완료 지워도됨 마지막에
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        // debugPrint("200 OK : $body"); 확인완료
        _comment = body['data']['comment'];
        notifyListeners();
      } else {
        throw Exception('getUserComment 오류 : ${response.statusCode}');
      }
    } catch (e) {
      // debugPrint("getUserComment() 오류 : $e"); 확인완료
    }
  }

  Future<bool> checkNickName(String nickname) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      debugPrint("checkNickName: 토큰 없음");
      return false;
    }

    final url = Uri.parse('$baseUrl/users/check-nickname?nickname=$nickname');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization':
              token.startsWith("Bearer ") ? token : 'Bearer $token',
          'accept': '*/*',
        },
      );

      debugPrint("checkNickName Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final String status = body['status'];
        final String message = body['data'];

        debugPrint("checkNickName 응답 메시지: ${message}");

        return status == "SU";
      } else {
        debugPrint("checkNickName: 서버 오류, statusCode: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("checkNickName() 오류: $e");
      return false;
    }
  }

  Future<String?> openAquarium() async {
    final tokenValue = await token;
    if (tokenValue == null) {
      debugPrint('openAquarium: 토큰 없음');
      return null;
    }

    try {
      final url = Uri.parse("$baseUrl/aquarium/open");
      final headers = {
        'Authorization':
            tokenValue.startsWith("Bearer ")
                ? tokenValue
                : 'Bearer $tokenValue',
        'accept': '*/*',
      };

      final response = await http.patch(url, headers: headers);
      debugPrint("openAquarium Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        _openAquariumMessage = body['data'];
        debugPrint("openAquarium response body: $body");
        final String message = body['data'];
        notifyListeners();
        return message;
      } else {
        debugPrint("openAquarium error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("openAquarium() 오류: $e");
      return null;
    }
  }
}
