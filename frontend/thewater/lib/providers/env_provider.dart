import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://j12c201.p.ssafy.io';

class EnvModel extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  Future<dynamic> getNowEnv(double lat, double lon) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        debugPrint("getNowEnv() Token is null");
        return null;
      }
      final url = Uri.parse('$baseUrl/api/env-info/now?lat=$lat&lon=$lon');
      final header = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: header);

      if (response.statusCode == 200) {
        debugPrint("getNowEnv() 성공 (${response.statusCode})");
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data'];
      } else {
        debugPrint("getNowEnv() 실패 (${response.statusCode})");
        return {};
      }
    } catch (e) {
      debugPrint("Error fetching nowEnv data: $e");
      return {};
    }
  }

  Future<List<dynamic>> getLunarTideList() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        debugPrint("getLunarTideList() Token is null");
        return [];
      }
      final url = Uri.parse('$baseUrl/api/env-info/lunar-tide');
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        debugPrint("getLunarTideList() 성공 (${response.statusCode})");
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data'];
      } else {
        throw Exception('Failed to load lunar tide data');
      }
    } catch (e) {
      debugPrint("Error fetching lunar tide data: $e");
      return [];
    }
  }

  Future<dynamic> getTide(double lat, double lon) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        debugPrint("getTideList() Token is null");
        return null;
      }
      final url = Uri.parse('$baseUrl/api/env-info/tide?lat=$lat&lon=$lon');
      debugPrint("getTideList() URL: $url"); // URL 확인
      debugPrint("getTideList() Token: $token"); // 토큰 값 확인
      final header = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: header);
      if (response.statusCode == 200) {
        debugPrint("getTideList() 성공 (${response.statusCode})");
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data'];
      } else {
        debugPrint("getTideList() 실패 (${response.statusCode})");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching tide data: $e");
      return null;
    }
  }

  Future<List<dynamic>> getRiseSetList(double lat, double lon) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        debugPrint("getWeatherList() Token is null");
        return [];
      }
      final url = Uri.parse('$baseUrl/api/env-info/rise-set?lat=$lat&lon=$lon');
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        debugPrint("getRiseSetList() 성공 (${response.statusCode})");
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data'];
      } else {
        throw Exception('Failed to load rise set data');
      }
    } catch (e) {
      debugPrint("Error fetching rise set data: $e");
      return [];
    }
  }

  Future<List<dynamic>> getWeatherList(double lat, double lon) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        debugPrint("getWeatherList() Token is null");
        return [];
      }

      final url = Uri.parse(
        '$baseUrl/api/env-info/predict/weather?lat=$lat&lon=$lon',
      );
      debugPrint("getWeatherList() URL: $url");
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        debugPrint("getWeatherList() 성공 (${response.statusCode})");
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data'];
      } else {
        debugPrint(
          "getWeatherList() 실패 (${response.statusCode}): ${response.body}",
        );
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching weather data: $e");
      return [];
    }
  }

  Future<dynamic> getWaterTempList(double lat, double lon) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        debugPrint("getWaterTempList() Token is null");
        return null;
      }

      final url = Uri.parse(
        '$baseUrl/api/env-info/predict/water-temp?lat=$lat&lon=$lon',
      );
      debugPrint("getWaterTempList() URL: $url");
      final headers = {'Authorization': 'Bearer $token'};

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        debugPrint("getWaterTempList() 성공 (${response.statusCode})");
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data'];
      } else {
        debugPrint(
          "getWaterTempList() 실패 (${response.statusCode}): ${response.body}",
        );
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching water temperature data: $e");
      return null;
    }
  }

  Future<dynamic> getCurrentWeatherList(double lat, double lon) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        debugPrint("getCurrentWeatherList() Token is null");
        return null;
      }

      final url = Uri.parse(
        '$baseUrl/api/env-info/now/weather?lat=$lat&lon=$lon',
      );
      debugPrint("getCurrentWeatherList() URL: $url");
      final headers = {'Authorization': 'Bearer $token'};

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data'];
      } else {
        debugPrint(
          "getCurrentWeatherList() 실패 (${response.statusCode}): ${response.body}",
        );
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching current weather data: $e");
      return null;
    }
  }

  Future<String?> get token async {
    return await _storage.read(key: 'token');
  }
}
