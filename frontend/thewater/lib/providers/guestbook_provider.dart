import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://j12c201.p.ssafy.io/api';

class GuestBookProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> get token async {
    return await _storage.read(key: 'token');
  }

  Future<List<dynamic>> fetchGuestBookEntries(int aquariumId) async {
    final tokenValue = await token;
    final url = Uri.parse('$baseUrl/guest-book/read/$aquariumId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $tokenValue',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return body['data'];
    } else {
      throw Exception(
        'Failed to load guestbook entries: ${response.statusCode}',
      );
    }
  }

  Future<bool> writeGuestBook(int aquariumId, String content) async {
    final tokenValue = await token;
    debugPrint("방명록 작성 시 사용되는 토큰: $tokenValue");
    debugPrint("방명록 작성 시 사용되는 aquariumId : $aquariumId");
    final url = Uri.parse('$baseUrl/guest-book/write/$aquariumId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $tokenValue',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"guestBookComment": content}),
    );

    if (response.statusCode == 200) {
      notifyListeners();
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint('방명록 작성 성공!!!${response.statusCode},$body');
      return true;
    } else {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint("방명록 작성 실패 : ${response.statusCode},$body");
      return false;
    }
  }

  Future<bool> editGuestBook(int guestBookId, String newContent) async {
    final tokenValue = await token;
    final url = Uri.parse('$baseUrl/guest-book/edit/$guestBookId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $tokenValue',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"guestBookComment": newContent}),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteGuestBook(int guestBookId) async {
    final tokenValue = await token;
    final url = Uri.parse('$baseUrl/guest-book/remove/$guestBookId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $tokenValue',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  Future<List<dynamic>> fetchMyGuestBook() async {
    final tokenValue = await token;
    // debugPrint("fetchMyGuestBook 함수에서 토큰 들어오나 ? : $tokenValue"); 확인완료
    final url = Uri.parse('$baseUrl/guest-book/read/me');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $tokenValue',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return body['data'];
    } else {
      throw Exception(
        'Failed to load my guestbook entries: ${response.statusCode}',
      );
    }
  }
}
