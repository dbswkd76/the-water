import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';

const String baseUrl = 'http://j12c201.p.ssafy.io';

class PointModel extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _pointList = [];
  List<dynamic> _myPointList = []; // 내 포인트 리스트

  List<dynamic> get pointList => _pointList; // getter 함수로 pointList를 가져옴
  List<dynamic> get myPointList => _myPointList; // 내 포인트 리스트 getter

  Future<void> getPointList() async {
    // await _storage.deleteAll();
    String? token;
    try {
      token = await _storage.read(key: 'token');
    } catch (e) {
      debugPrint("토큰 읽기 실패: $e");
      return;
    }
    debugPrint("getPointList() Token: $token"); // 토큰 값 확인
    if (token == null) {
      debugPrint("getPointList() Token is null"); // 토큰이 없을 경우 처리
      return;
    }
    try {
      final url = Uri.parse('$baseUrl/api/fishing-points/all');
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        debugPrint("getPointList() 성공: ${response.body}");
        _pointList = jsonDecode(utf8.decode(response.bodyBytes))['data'];
      } else {
        debugPrint("getPointList() 실패 (${response.statusCode})");
      }
      notifyListeners(); // 상태 변경 알림
    } catch (e) {
      debugPrint("getPointList() 예외 발생: $e"); // 예외 발생 시 처리
    }
  }

  Future<void> getMyPointList() async {
    String? token;
    try {
      token = await _storage.read(key: 'token');
    } catch (e) {
      debugPrint("토큰 읽기 실패: $e");
      return;
    }
    if (token == null) {
      debugPrint("getMyPointList() Token is null");
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/api/fishing-points/me');
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        debugPrint("getMyPointList() 성공: ${response.body}");
        _myPointList = jsonDecode(utf8.decode(response.bodyBytes))['data'];
      } else {
        debugPrint("getMyPointList() 실패 (${response.statusCode})");
      }

      notifyListeners();
    } catch (e) {
      debugPrint("getMyPointList() 예외 발생: $e");
    }
  }

  Future<void> addPoint(
    String pointName,
    double latitude,
    double longitude,
    String comment,
  ) async {
    String? token;
    try {
      token = await _storage.read(key: 'token');
    } catch (e) {
      debugPrint("토큰 읽기 실패: $e");
      return;
    }
    if (token == null) {
      debugPrint("addPoint() Token is null");
      return;
    }

    try {
      final url = Uri.parse(
        '$baseUrl/api/fishing-points/add'
        '?pointName=${Uri.encodeComponent(pointName)}'
        '&latitude=$latitude'
        '&longitude=$longitude'
        '&comment=${Uri.encodeComponent(comment)}',
      );
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        debugPrint("addPoint() 성공");
      } else {
        debugPrint("addPoint() 실패 (${response.statusCode})");
      }

      notifyListeners();
    } catch (e) {
      debugPrint("addPoint() 예외 발생: $e");
    }
  }

  Future<void> deletePoint(int pointId) async {
    String? token;
    try {
      token = await _storage.read(key: 'token');
    } catch (e) {
      debugPrint("토큰 읽기 실패: $e");
      return;
    }
    if (token == null) {
      debugPrint("deletePoint() Token is null");
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/api/fishing-points/$pointId');
      final headers = {'Authorization': 'Bearer $token'};

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        debugPrint("deletePoint() 성공");
      } else {
        debugPrint("deletePoint() 실패 (${response.statusCode})");
      }

      notifyListeners();
    } catch (e) {
      debugPrint("deletePoint() 예외 발생: $e");
    }
  }

  Future<void> editPoint(int pointId, String pointName, String comment) async {
    String? token;
    try {
      token = await _storage.read(key: 'token');
    } catch (e) {
      debugPrint("토큰 읽기 실패: $e");
      return;
    }
    if (token == null) {
      debugPrint("editPoint() Token is null");
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/api/fishing-points/edit/$pointId');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({'pointName': pointName, 'comment': comment});

      final response = await http.patch(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        debugPrint("editPoint() 성공");
      } else {
        debugPrint("editPoint() 실패 (${response.statusCode})");
      }

      notifyListeners();
    } catch (e) {
      debugPrint("editPoint() 예외 발생: $e");
    }
  }

  void clearPointList() {
    _pointList = [];
    _myPointList = []; // 내 포인트 리스트 초기화
    notifyListeners();
  }
}
