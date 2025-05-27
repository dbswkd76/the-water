import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://j12c201.p.ssafy.io/api';

class SearchedUser {
  final int id;
  final String loginId;
  final String email;
  final String nickname;
  final DateTime birthday;
  final String loginType;
  final String? comment;

  SearchedUser({
    required this.id,
    required this.loginId,
    required this.email,
    required this.nickname,
    required this.birthday,
    required this.loginType,
    this.comment,
  });

  factory SearchedUser.fromJson(Map<String, dynamic> json) {
    return SearchedUser(
      id: json['id'],
      loginId: json['loginId'],
      email: json['email'],
      nickname: json['nickname'],
      birthday: DateTime.parse(json['birthday']),
      loginType: json['loginType'],
      comment: json['comment'],
    );
  }
}

class SearchProvider extends ChangeNotifier {
  List<String> _allNicknames = [];
  List<SearchedUser> _searchResults = [];

  List<String> get allNicknames => _allNicknames;
  List<SearchedUser> get searchResults => _searchResults;

  // 전체 닉네임 불러오기
  Future<void> fetchAllNicknames() async {
    final url = Uri.parse('$baseUrl/users/search/all-nickname');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        _allNicknames = List<String>.from(data);
        notifyListeners();
      } else {
        debugPrint("❌ 닉네임 전체 불러오기 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ 닉네임 전체 예외 발생: $e");
    }
  }

  // 검색어 기반 유저 검색
  Future<void> searchUsersByNickname(String keyword) async {
    final encodedKeyword = Uri.encodeComponent(keyword);

    final url = Uri.parse('$baseUrl/users/search?nickname=$encodedKeyword');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody)['data'];
        _searchResults =
            data.map((json) => SearchedUser.fromJson(json)).toList();
        notifyListeners();
      } else {
        debugPrint("❌ 유저 검색 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ 유저 검색 예외 발생: $e");
    }
  }
}
