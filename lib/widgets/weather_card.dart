import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import 'detail_row.dart';

class WeatherCard extends StatefulWidget {
  final WeatherModel weather;

  const WeatherCard({super.key, required this.weather});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  late Timer _timer;
  late DateTime _localTime;
  late DateTime _cityTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }
  
  @override
  void didUpdateWidget(WeatherCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weather.cityName != widget.weather.cityName) {
      _updateTime();
    }
  }

  void _updateTime() {
    final utcNow = DateTime.now().toUtc();
    setState(() {
      _localTime = DateTime.now();
      _cityTime = utcNow.add(Duration(seconds: widget.weather.timezoneOffsetSeconds));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  Widget _getWeatherIcon(String iconCode) {
    IconData iconData;
    Color iconColor;

    switch (iconCode) {
      case '01d':
        iconData = Icons.wb_sunny_rounded;
        iconColor = Colors.yellow.shade600;
        break;
      case '01n':
        iconData = Icons.nightlight_round;
        iconColor = Colors.yellow.shade200;
        break;
      case '02d':
      case '02n':
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        iconData = Icons.cloud_rounded;
        iconColor = Colors.grey.shade300;
        break;
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        iconData = Icons.water_drop_rounded;
        iconColor = Colors.blue.shade300;
        break;
      case '11d':
      case '11n':
        iconData = Icons.bolt_rounded;
        iconColor = Colors.yellow.shade400;
        break;
      case '13d':
      case '13n':
        iconData = Icons.ac_unit_rounded;
        iconColor = Colors.cyan.shade200;
        break;
      case '50d':
      case '50n':
        iconData = Icons.waves_rounded; // Mist/fog
        iconColor = Colors.grey.shade400;
        break;
      default:
        iconData = Icons.cloud_rounded;
        iconColor = Colors.white;
    }

    return Icon(
      iconData,
      size: 100,
      color: iconColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM dd');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${widget.weather.cityName}, ${widget.weather.countryCode}',
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        
        // Dual Clock Display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildClockColumn('Local Time', _localTime, timeFormat, dateFormat),
            Container(
              height: 40,
              width: 1,
              color: Colors.white30,
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
            _buildClockColumn('${widget.weather.cityName} Time', _cityTime, timeFormat, dateFormat),
          ],
        ),
        
        const SizedBox(height: 20),
        _getWeatherIcon(widget.weather.icon),
        Text(
          '${widget.weather.temperature.round()}°C',
          style: textTheme.displayLarge,
        ),
        Text(
          _capitalize(widget.weather.condition),
          style: textTheme.bodyLarge?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 10),
        Text(
          'Feels like ${widget.weather.feelsLike.round()}°C',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              DetailRow(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: '${widget.weather.humidity}%',
              ),
              const Divider(color: Colors.white30, height: 30),
              DetailRow(
                icon: Icons.air,
                label: 'Wind',
                value: '${widget.weather.windSpeed.toStringAsFixed(1)} km/h',
              ),
              const Divider(color: Colors.white30, height: 30),
              DetailRow(
                icon: Icons.visibility,
                label: 'Visibility',
                value: '${widget.weather.visibility.toStringAsFixed(1)} km',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClockColumn(String title, DateTime time, DateFormat timeFormat, DateFormat dateFormat) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        Text(
          timeFormat.format(time),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          dateFormat.format(time),
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
