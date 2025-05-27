class User {
  final int userId; // 멤버 관리 번호
  final String loginId; // 멤버 아이디
  final String password; // 비밀번호 (단방향 암호화 필요)
  final String email; // 이메일
  final String loginType; // 로그인 타입 ('E' = 이메일, 'S' = 소셜)
  final String nickname; // 닉네임
  final DateTime birth; // 생년월일
  final bool isDeleted; // 탈퇴 여부

  User({
    required this.userId,
    required this.loginId,
    required this.password,
    required this.email,
    required this.loginType,
    required this.nickname,
    required this.birth,
    required this.isDeleted,
  });

  // JSON 변환용 factory 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      loginId: json['login_id'],
      password: json['password'],
      email: json['email'],
      loginType: json['login_type'],
      nickname: json['nickname'],
      birth: DateTime.parse(json['birth']), // 날짜 변환
      isDeleted: json['is_deleted'] == true, // BOOLEAN 변환
    );
  }

  // JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'login_id': loginId,
      'password': password,
      'email': email,
      'login_type': loginType,
      'nickname': nickname,
      'birth': birth.toIso8601String(), // 날짜 변환
      'is_deleted': isDeleted,
    };
  }
}
