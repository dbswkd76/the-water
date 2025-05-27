class Fish {
  final int fishId;
  final String fishName;
  final String breedingSeason;
  final String prohibitionPeriod; // 금어기
  final int prohibitionLength; // 금지 체장
  final String characteristic; // 특이사항
  final String habitat; // 서식지
  final int sizeCm; // 평균 크기
  final int price; // 시세

  Fish({
    required this.fishId,
    required this.fishName,
    required this.breedingSeason,
    required this.prohibitionPeriod,
    required this.prohibitionLength,
    required this.characteristic,
    required this.habitat,
    required this.sizeCm,
    required this.price,
  });

  // JSON 변환용 factory 생성
  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      fishId: json['fish_id'],
      fishName: json['fish_name'],
      breedingSeason: json['breeding_season'],
      prohibitionPeriod: json['prohibition_period'],
      prohibitionLength: json['prohibition_length'],
      characteristic: json['characteristic'],
      habitat: json['habitat'],
      sizeCm: json['size_cm'],
      price: json['price'],
    );
  }

  // JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'fish_id': fishId,
      'fish_name': fishName,
      'breeding_season': breedingSeason,
      'prohibition_period': prohibitionPeriod,
      'prohibition_length': prohibitionLength,
      'characteristic': characteristic,
      'habitat': habitat,
      'size_cm': sizeCm,
      'price': price,
    };
  }
}
