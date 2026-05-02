class WeatherModel {
  final String cityName;
  final String countryCode;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed; // km/h
  final double visibility; // km
  final int timezoneOffsetSeconds;

  WeatherModel({
    required this.cityName,
    required this.countryCode,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.timezoneOffsetSeconds,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];
    final sys = json['sys'];

    // Convert wind speed from m/s to km/h
    double windSpeedKmH = (wind['speed'] as num).toDouble() * 3.6;

    // Convert visibility from m to km
    double visibilityKm = (json['visibility'] as num).toDouble() / 1000.0;

    return WeatherModel(
      cityName: json['name'],
      countryCode: sys['country'],
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      condition: weather['description'],
      icon: weather['icon'],
      humidity: main['humidity'] as int,
      windSpeed: windSpeedKmH,
      visibility: visibilityKm,
      timezoneOffsetSeconds: json['timezone'] as int,
    );
  }
}
