import 'package:flutter/material.dart';
import 'package:flutter_weather_app/model/weather_model.dart';
import 'package:flutter_weather_app/service/weather_service.dart';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService("3b866f050353fbd206720e5d39fe165b");
  List<Weather> _weatherData = [];
  List<String> _selectedCities = [];

  final List<String> _cities = [
    'Lagos',
    'Abuja',
    'Ibadan',
    'Awka',
    'Kano',
    'Port Harcourt',
    'Onitsha',
    'Maiduguri',
    'Aba',
    'Benin City',
    'Shagamu',
    'Ikare',
    'Ogbomoso',
    'Mushin',
    'Ikeja',
  ];

  _fetchWeather(String cityName) async {
    cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weatherData.add(weather);
      });
    } catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case "mist":
      case "haze":
      case "smoke":
      case "dust":
      case "fog":
        return 'assets/cloud.json';
      case 'rain':
      case "drizzle":
      case 'shower':
        return 'assets/rain.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }
  
  _loadCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedCities = prefs.getStringList('selectedCities') ?? [];
    for (String city in _selectedCities) {
      _fetchWeather(city);
    }
  }

  _saveCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedCities', _selectedCities);
  }

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DropdownButton<String>(
              onChanged: (String? newValue) {
                if (newValue != null && !_selectedCities.contains(newValue)) {
                  setState(() {
                    _selectedCities.add(newValue);
                  });
                  _fetchWeather(newValue);
                  _saveCities();
                }
              },
              items: _cities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            CarouselSlider(
              options: CarouselOptions(height: 400.0),
              items: _weatherData.map((weather) {
                return Builder(
                  builder: (BuildContext context) {
                    return Column(
                      children: [
                        Text(
                          weather.cityName,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Lottie.asset(
                            getWeatherAnimation(weather.mainCondition)),
                        Column(
                          children: [
                            Text(
                              '${weather.temperature.roundToDouble()}°C',
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              weather.mainCondition,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
