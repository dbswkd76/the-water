import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://j12c201.p.ssafy.io/api';

class RankingEntry {
  final int aquariumId;
  final int memberId;
  final String nickname;
  final int totalPrice;
  final String? memberComment;

  RankingEntry({
    required this.aquariumId,
    required this.memberId,
    required this.nickname,
    required this.totalPrice,
    this.memberComment,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      aquariumId: json['aquariumId'],
      memberId: json['memberId'],
      nickname: json['nickname'],
      totalPrice: json['totalPrice'],
      memberComment: json['memberComment'],
    );
  }
}

class RankingProvider extends ChangeNotifier {
  List<RankingEntry> _topRanking = [];
  List<RankingEntry> _randomRanking = [];

  List<RankingEntry> get topRanking => _topRanking;
  List<RankingEntry> get randomRanking => _randomRanking;

  Future<void> fetchTopRanking({int count = 30}) async {
    final url = Uri.parse('$baseUrl/aquarium/ranking/top/$count');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
        _topRanking = data.map((json) => RankingEntry.fromJson(json)).toList();
        notifyListeners();
      } else {
        debugPrint(" Top 랭킹 호출 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(" Top 랭킹 예외 발생: $e");
    }
  }

  Future<void> fetchRandomRanking({int count = 30}) async {
    final url = Uri.parse('$baseUrl/aquarium/ranking/random/$count');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
        _randomRanking =
            data.map((json) => RankingEntry.fromJson(json)).toList();
        notifyListeners();
      } else {
        debugPrint(" Random 랭킹 호출 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(" Random 랭킹 예외 발생: $e");
    }
  }
}
