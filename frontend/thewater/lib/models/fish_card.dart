class FishCard {
  final int cardId;
  final int userId;
  final int pointId;
  final int fishId;
  final int? aquariumId;
  final String fishName;
  final int fishSize;
  final String collectDate;
  final int sky;
  final int tw;
  final int tide;
  final String comment;
  final bool isDeleted;
  final String imgUrl;

  FishCard({
    required this.cardId,
    required this.userId,
    required this.pointId,
    required this.fishId,
    this.aquariumId,
    required this.fishName,
    required this.fishSize,
    required this.collectDate,
    required this.sky,
    required this.tw,
    required this.tide,
    required this.comment,
    required this.isDeleted,
    required this.imgUrl,
  });

  factory FishCard.fromJson(Map<String, dynamic> json) {
    return FishCard(
      cardId: json['card_id'],
      userId: json['uer_id'],
      pointId: json['point_id'],
      fishId: json['fish_id'],
      aquariumId: json['aquarium_id'],
      fishName: json['fish_name'],
      fishSize: json['fish_size'],
      collectDate: json['collect_date'],
      sky: json['sky'],
      tw: json['tw'],
      tide: json['tide'],
      comment: json['comment'],
      isDeleted: json['is_deleted'],
      imgUrl: json['img_url'],
    );
  }
}
