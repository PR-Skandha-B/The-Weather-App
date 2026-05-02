import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../utils/constants.dart';

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}

class WeatherService {
  Future<WeatherModel> fetchWeather(String city) async {
    final url = Uri.parse('${Constants.baseUrl}?q=$city&appid=${Constants.apiKey}&units=metric');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw WeatherException('City not found. Try again.');
      } else if (response.statusCode == 401) {
        throw WeatherException('Invalid API key. Please check your configuration.');
      } else {
        throw WeatherException('Failed to fetch weather data. Please try again later.');
      }
    } on SocketException {
      throw WeatherException('No internet connection.');
    } on TimeoutException {
      throw WeatherException('Request timed out. Try again.');
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('An unexpected error occurred.');
    }
  }

  Future<WeatherModel> fetchWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse('${Constants.baseUrl}?lat=$lat&lon=$lon&appid=${Constants.apiKey}&units=metric');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw WeatherException('Location not found. Try again.');
      } else if (response.statusCode == 401) {
        throw WeatherException('Invalid API key. Please check your configuration.');
      } else {
        throw WeatherException('Failed to fetch weather data. Please try again later.');
      }
    } on SocketException {
      throw WeatherException('No internet connection.');
    } on TimeoutException {
      throw WeatherException('Request timed out. Try again.');
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('An unexpected error occurred.');
    }
  }
}
