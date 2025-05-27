import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:thewater/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VisitApi {
  final String baseUrl;

  VisitApi({this.baseUrl = "http://j12c201.p.ssafy.io"});

  /// 아쿠아리움(=유저)의 방문(조회수)을 증가시키는 API 호출
  Future<bool> visitAquarium({
    required int aquariumId,
    required String token,
  }) async {
    // API 엔드포인트: /api/aquarium/visit/{aquarium_id}
    final url = Uri.parse('$baseUrl/api/aquarium/visit/$aquariumId');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        debugPrint('방문 카운트 증가 성공: ${response.body}');
        return true;
      } else {
        debugPrint('방문 카운트 증가 실패. 상태 코드: ${response.statusCode}');
        debugPrint('에러 내용: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('방문 카운트 요청 중 에러 발생: $e');
      return false;
    }
  }
}

/// UserModel에 저장된 토큰과 id를 이용하여 방문 API를 호출하는 함수
Future<void> triggerVisitAquarium(BuildContext context) async {
  final userModel = Provider.of<UserModel>(context, listen: false);
  final token = await userModel.token; // secure storage에서 토큰 읽기
  if (token == null) {
    debugPrint("토큰이 존재하지 않습니다.");
    return;
  }
  final visitApi = VisitApi();
  final success = await visitApi.visitAquarium(
    aquariumId: userModel.id, // 아쿠아리움 ID는 user_id와 동일
    token: token,
  );
  if (success) {
    debugPrint("방문 카운트 성공!");
  } else {
    debugPrint("방문 카운트 실패!");
  }
}

/// 동일 사용자가 자신의 아쿠아리움에 대해 중복 조회수 증가를 막기 위한 함수
/// (한 번 방문한 기록을 secure storage에 저장)
Future<void> countVisitIfNeeded(BuildContext context) async {
  final userModel = Provider.of<UserModel>(context, listen: false);
  final token = await userModel.token;
  if (token == null) {
    debugPrint("토큰이 존재하지 않습니다.");
    return;
  }
  final storage = const FlutterSecureStorage();
  final visitedKey = 'visited_aquarium_${userModel.id}';
  final visited = await storage.read(key: visitedKey);
  if (visited == null) {
    await triggerVisitAquarium(context);
    await storage.write(key: visitedKey, value: "true");
  } else {
    debugPrint("이미 방문 기록이 있습니다.");
  }
}
