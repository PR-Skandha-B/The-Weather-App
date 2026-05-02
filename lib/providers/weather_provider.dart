import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

enum WeatherState { initial, loading, success, error }

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _weather;
  WeatherState _state = WeatherState.initial;
  String? _errorMessage;

  String? _lastSearchedCity;
  Position? _lastLocation;

  WeatherModel? get weather => _weather;
  WeatherState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == WeatherState.loading;

  Future<void> fetchWeather(String city) async {
    if (city.trim().isEmpty) return;

    _state = WeatherState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await _weatherService.fetchWeather(city.trim());
      _lastSearchedCity = city.trim();
      _lastLocation = null;
      _state = WeatherState.success;
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchWeatherByLocation(double lat, double lon) async {
    _state = WeatherState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await _weatherService.fetchWeatherByLocation(lat, lon);
      _state = WeatherState.success;
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchWeatherByCurrentLocation() async {
    _state = WeatherState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      _weather = await _weatherService.fetchWeatherByLocation(position.latitude, position.longitude);
      _lastSearchedCity = null;
      _lastLocation = position;
      _state = WeatherState.success;
    } catch (e) {
      _state = WeatherState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    if (_lastSearchedCity != null) {
      await fetchWeather(_lastSearchedCity!);
    } else if (_lastLocation != null) {
      await fetchWeatherByLocation(_lastLocation!.latitude, _lastLocation!.longitude);
    } else {
      await fetchWeatherByCurrentLocation();
    }
  }
}
