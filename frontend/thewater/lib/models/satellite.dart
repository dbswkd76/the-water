class Satellite {
  final int satelliteDataId;
  final String obsPostId;
  final String obsPostName;
  final double obsLat;
  final double obsLon;
  final String hiCode;
  final DateTime tphTime;
  final int tphLevel;
  final DateTime updateDate;

  Satellite({
    required this.satelliteDataId,
    required this.obsPostId,
    required this.obsPostName,
    required this.obsLat,
    required this.obsLon,
    required this.hiCode,
    required this.tphTime,
    required this.tphLevel,
    required this.updateDate,
  });

  factory Satellite.fromJson(Map<String, dynamic> json) {
    return Satellite(
      satelliteDataId: json['satellite_data_id'],
      obsPostId: json['obs_post_id'],
      obsPostName: json['obs_post_name'],
      obsLat: json['obs_lat'].toDouble(),
      obsLon: json['obs_lon'].toDouble(),
      hiCode: json['hi_code'],
      tphTime: DateTime.parse(json['tph_time']),
      tphLevel: json['tph_level'],
      updateDate: DateTime.parse(json['update_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'satellite_data_id': satelliteDataId,
      'obs_post_id': obsPostId,
      'obs_post_name': obsPostName,
      'obs_lat': obsLat,
      'obs_lon': obsLon,
      'hi_code': hiCode,
      'tph_time': tphTime.toIso8601String(),
      'tph_level': tphLevel,
      'update_date': updateDate.toIso8601String(),
    };
  }
}
