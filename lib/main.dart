import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String city = "";
  String date = "";
  String weatherDescription = "";
  double temperature = 0, minTemp = 0, maxTemp = 0;
  final String apiKey = '53eea04bd6574dcd3fc99f74ad97504a';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi tidak aktif');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Permission lokasi ditolak permanen');
      }
    }
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _fetchWeather(pos.latitude, pos.longitude);
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
      '?lat=$lat&lon=$lon&units=metric&appid=$apiKey'
    );
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      setState(() {
        city = data['name'];
        date = DateTime.now().toLocal().toString().split(' ')[0];
        temperature = data['main']['temp'];
        minTemp = data['main']['temp_min'];
        maxTemp = data['main']['temp_max'];
        weatherDescription = data['weather'][0]['description'];
      });
    } else {
      throw Exception('Gagal memuat data cuaca');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/nikolas-noonan-fQM8cbGY6iQ-unsplash.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: city.isEmpty
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(city,
                        style: TextStyle(fontSize: 30, color: Colors.white)),
                    Text(date,
                        style: TextStyle(fontSize: 16, color: Colors.white70)),
                    SizedBox(height: 20),
                    Text("${temperature.toStringAsFixed(0)}°C",
                        style: TextStyle(fontSize: 80, color: Colors.white)),
                    SizedBox(height: 10),
                    Text(weatherDescription.toUpperCase(),
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    SizedBox(height: 10),
                    Text("${minTemp.toStringAsFixed(0)}°C / ${maxTemp.toStringAsFixed(0)}°C",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ],
                ),
        ),
      ),
    );
  }
}
