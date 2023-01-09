import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorSpeed extends StatefulWidget {
  const GeolocatorSpeed({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<GeolocatorSpeed> createState() => _GeolocatorSpeedState();
}

class _GeolocatorSpeedState extends State<GeolocatorSpeed> {
  Position? _position;
  var options =
      LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);

  void _testCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
  }

  void _getCurrentSpeed() async {
    var options = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    StreamSubscription<Position> positionSpeed =
        Geolocator.getPositionStream(locationSettings: options)
            .listen((position) {
      var speedInMps = position.speed.toStringAsPrecision(2);
      //var bumpProximity = position.
      print('your speed is: $speedInMps MpS');
      print('your speed is: ${double.parse(speedInMps) * 3.6} KpH');
    });
  }

  void _getProximity() async {}

  void _getCurrentLocation() async {
    Position position = await _determinePosition();
    setState(() {
      _position = position;
    });
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Geolocation App"),
      ),
      body: Center(
        child: _position != null
            ? Text('Current Location: ' + _position.toString())
            : Text('No Location Data'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentSpeed,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
