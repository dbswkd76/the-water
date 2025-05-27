class Aquarium {
  final int aquariumId; // 어항 관리 번호
  final int userId; // 멤버 관리 번호
  final int fishCount; // 물고기 수 (ERD 에는 bool 이라고 되어있음. 수정 필요)
  final int totalPrice; // 어항 시세 총합
  final int likes; // 좋아요 수
  final int visitors; // 방문자 수

  Aquarium({
    required this.aquariumId,
    required this.userId,
    required this.fishCount,
    required this.totalPrice,
    required this.likes,
    required this.visitors,
  });

  // JSON 변환용 factory 생성
  factory Aquarium.fromJson(Map<String, dynamic> json) {
    return Aquarium(
      aquariumId: json['aquarium_id'],
      userId: json['user_id'],
      fishCount: json['fish_count'], // BOOLEAN 타입 대응
      totalPrice: json['total_price'],
      likes: json['likes'],
      visitors: json['visitors'],
    );
  }

  // JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'aquarium_id': aquariumId,
      'user_id': userId,
      'fish_count': fishCount, // BOOLEAN 값을 1/0으로 변환
      'total_price': totalPrice,
      'likes': likes,
      'visitors': visitors,
    };
  }
}
