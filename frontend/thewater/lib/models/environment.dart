class Environment {
  final int environmentDataId;
  final int sky;
  final int temperature;
  final int precipitation;
  final int windSpeed;
  final int windDirection;
  final int waveHeight;
  final int waterTemperature;
  final String sunrise;
  final String sunset;
  final DateTime updateDate;

  Environment({
    required this.environmentDataId,
    required this.sky,
    required this.temperature,
    required this.precipitation,
    required this.windSpeed,
    required this.windDirection,
    required this.waveHeight,
    required this.waterTemperature,
    required this.sunrise,
    required this.sunset,
    required this.updateDate,
  });

  factory Environment.fromJson(Map<String, dynamic> json) {
    return Environment(
      environmentDataId: json['environment_data_id'],
      sky: json['sky'],
      temperature: json['tmp'],
      precipitation: json['pcp'],
      windSpeed: json['wsd'],
      windDirection: json['vec'],
      waveHeight: json['wav'],
      waterTemperature: json['tw'],
      sunrise: json['sunrise'],
      sunset: json['sunset'],
      updateDate: DateTime.parse(json['update_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'environment_data_id': environmentDataId,
      'sky': sky,
      'tmp': temperature,
      'pcp': precipitation,
      'wsd': windSpeed,
      'vec': windDirection,
      'wav': waveHeight,
      'tw': waterTemperature,
      'sunrise': sunrise,
      'sunset': sunset,
      'update_date': updateDate.toIso8601String(),
    };
  }
}
