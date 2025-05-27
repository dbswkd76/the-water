import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://j12c201.p.ssafy.io/api';

class AquariumModel extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  int _aquariumId = 0;
  int _visitCount = 0;
  int _likeCount = 0;
  int _fishCount = 0;
  int _totalPrice = 0;
  int _member_id = 0;
  List _visibleFishCards = [];
  bool _likedByMe = false;
  bool _isFetched = false;

  // GETTERS
  int get aquariumId => _aquariumId;
  int get visitCount => _visitCount;
  int get likeCount => _likeCount;
  int get fishCount => _fishCount;
  int get totalPrice => _totalPrice;
  int get member_id => _member_id;
  List get visibleFishCards => _visibleFishCards;
  bool get likedByMe => _likedByMe;
  bool get isFetched => _isFetched;

  Future<String?> get token async {
    return await _storage.read(key: 'token');
  }

  /// 수족관 정보 불러오기
  Future<void> fetchAquariumInfo(int userId) async {
    try {
      final tk = await token;
      debugPrint("수족관 정보 불러오는데 토큰값 확인하려고 : $tk");
      debugPrint("수족관 정보에 유저아이디 잘 들어가는지. : $userId");
      final url = Uri.parse('$baseUrl/aquarium/info/$userId');
      final headers = {
        'Authorization': 'Bearer $tk',
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final data = body['data'];

        _aquariumId = data['id'] ?? 0;
        _visitCount = data['visitorCnt'] ?? 0;
        _likeCount = data['likeCnt'] ?? 0;
        _likedByMe = data['likedByMe'] ?? false;
        _fishCount = data['fishCnt'] ?? 0;
        _totalPrice = data['totalPrice'] ?? 0;
        _member_id = data['member_id'] ?? 0;
        _visibleFishCards = data['visibleFishCards'] ?? [];
        _isFetched = true;

        debugPrint("정보받기 성공 200OK : ${response.body}");

        notifyListeners();
      } else {
        throw Exception(
          'Failed to fetch aquarium info: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in fetchAquariumInfo: $e');
    }
  }

  /// 조회수 증가 기능 (POST /api/aquarium/visit)
  Future<void> incrementVisitCount() async {
    try {
      final tk = await token;
      debugPrint("토큰 값 : $tk");
      final url = Uri.parse('$baseUrl/aquarium/visit');
      final headers = {
        'Authorization': 'Bearer $tk',
        'Content-Type': 'application/json',
      };

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final data = body['data'];
        _visitCount = data['visitorCnt'] ?? _visitCount;

        notifyListeners();
      } else {
        throw Exception(
          'Failed to increment visit count: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in incrementVisitCount: $e');
      rethrow;
    }
  }

  /// 좋아요 기능 (POST /api/aquarium/like/{aquarium_id}) DELETE 까지 한번에
  Future<void> toggleLikeAquarium() async {
    try {
      final tk = await token;
      final url = Uri.parse('$baseUrl/aquarium/like/$_aquariumId');
      final headers = {
        'Authorization': 'Bearer $tk',
        'Content-Type': 'application/json',
      };

      http.Response response;

      if (_likedByMe) {
        response = await http.delete(url, headers: headers);
      } else {
        response = await http.post(url, headers: headers);
      }

      if (response.statusCode == 200) {
        // 서버 상태 업데이트 성공 후 최신 정보 받아오기
        await fetchAquariumInfo(_aquariumId);
      } else {
        debugPrint('좋아요 상태 업데이트 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in toggleLikeAquarium: $e');
    }
  }

  // 친구 수족관 좋아요 기능
  Future<void> toggleLikeFriendAquarium(int friendAquariumId) async {
    try {
      final tk = await token;
      final url = Uri.parse('$baseUrl/aquarium/like/$friendAquariumId');
      final headers = {
        'Authorization': 'Bearer $tk',
        'Content-Type': 'application/json',
      };

      http.Response response;

      // 현재 친구 수족관을 좋아요 했는지 여부를 확인
      if (_likedByMe) {
        response = await http.delete(url, headers: headers);
      } else {
        response = await http.post(url, headers: headers);
      }

      if (response.statusCode == 200) {
        // 서버 상태 업데이트 성공 후 최신 정보 다시 받아오기
        await fetchAquariumInfo(friendAquariumId);
        notifyListeners();
      } else {
        debugPrint('친구 수족관 좋아요 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in toggleLikeFriendAquarium: $e');
    }
  }

  /// 수족관 정보 리셋 (회원 탈퇴 등)
  void resetAquarium() {
    _aquariumId = 0;
    _visitCount = 0;
    _likeCount = 0;
    _likedByMe = false;
    _isFetched = false;
    notifyListeners();
  }
}
