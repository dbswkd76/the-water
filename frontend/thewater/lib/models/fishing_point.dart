class FishingPoint {
  final int pointId; //포인트 관리번호
  final int satelliteDataId; //해양정보 관리 번호
  final int environmentDataId; //환경정보 관리번호
  final bool isPublic; //공개여부
  final String pointName; //지명
  final double latitude; // 위도
  final double longitude; //경도
  final String province; //광역시/도
  final String city; //시/군/구
  final String town; //읍/면동
  final bool isOfficial; //모두의낚시포인트 여부

  FishingPoint({
    required this.pointId,
    required this.satelliteDataId,
    required this.environmentDataId,
    required this.isPublic,
    required this.pointName,
    required this.latitude,
    required this.longitude,
    required this.province,
    required this.city,
    required this.town,
    required this.isOfficial,
  });

  factory FishingPoint.fromJson(Map<String, dynamic> json) {
    return FishingPoint(
      pointId: json['point_id'],
      satelliteDataId: json['satellite_data_id'],
      environmentDataId: json['environment_data_id'],
      isPublic: json['public'],
      pointName: json['point_name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      province: json['province'],
      city: json['city'],
      town: json['town'],
      isOfficial: json['official'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'point_id': pointId,
      'satellite_data_id': satelliteDataId,
      'environment_data_id': environmentDataId,
      'public': isPublic,
      'point_name': pointName,
      'latitude': latitude,
      'longitude': longitude,
      'province': province,
      'city': city,
      'town': town,
      'official': isOfficial,
    };
  }
}
