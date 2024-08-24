import 'package:flutter/material.dart';
import 'package:weather/weather-api.dart';
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  final WeatherAPI weatherAPI = WeatherAPI();
  Map<String,dynamic> _weatherData = {};
  Position? _position;

  Future<void> _requestLocationService() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permanently denied, we cant request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

  }


  void _fetchLocationAndWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _position = position;
      });
      _fetchWeatherData();
    } catch (e) {
      print('Failed to get current location: $e');
    }
  }

  void _fetchWeatherData() async {
    try {
      if (_position == null) {
        print("Position is null");
        return;
      }
      Map<String, dynamic> weatherData = await weatherAPI.getData("/data/2.5/weather?lat=${_position?.latitude}&lon=${_position?.longitude}&units=metric&appid=e644f02624c5c7b167a31865bab6d400");
      setState(() {
        _weatherData = weatherData;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestLocationService();
    _fetchLocationAndWeather();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _fetchLocationAndWeather();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Weather"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_position == null)
              const Text("Getting location...")
            else if (_weatherData.isEmpty)
              const Text("Loading Weather...")
            else
              Column(
                children: <Widget> [
                  Image.network("https://openweathermap.org/img/wn/${_weatherData['weather'][0]['icon']}@2x.png"),
                  Text(
                    "${_weatherData['name']}, ${_weatherData['sys']['country']}"
                  ),
                  Text(
                    capitalize(_weatherData['weather'][0]['description'])
                  ),
                  Text(
                    "${_weatherData['main']['temp']}°C"
                  )
              ])
          ],
        ),
      ),

    );
  }
}
