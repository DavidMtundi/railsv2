import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../services/.env.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final FlutterTts flutterTts = FlutterTts();
  GoogleMapController? mapController; //controller for Google map
  Position? position;

  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = googleAPIKey;

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  LatLng startLocation = LatLng(0.06285124305144678, 37.62949646822997);
  LatLng endLocation = LatLng(0.07119359834536633, 37.64828136161653);
  //List<LatLng> startLocationLists = [LatLng(0.06285124305144678, 37.62949646822997),LatLng(0.06197758729014899, 37.63012944809486)];
  //List<LatLng> endLocationLists = [LatLng(0.059752824753039294, 37.63486201344238), LatLng(0.057333899156838716, 37.64206151726037)];
/*  List<LatLng> startendLocationLists = const [
    LatLng(0.06300916306897089, 37.62939552635421),
    LatLng(0.061947008951223646, 37.630141180399306),
    LatLng(0.05735581501134411, 37.64205902165467),
    LatLng(0.05949518791639107, 37.64400873487676),
    LatLng(0.06105358435453296, 37.64486353645474),
    LatLng(0.06501267432357581, 37.64667975825815),
    LatLng(0.06771782803204465, 37.647767956632954),
    LatLng(0.07119359834536633, 37.64828136161653)
  ];*/
  List<LatLng> startendLocationLists = [];
  //getting the list from firebase
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  ///GETTING THE BUMPS ON A ROUTE
  ///
  Future<void> bumpsOnRoad() async {
    firestore
        .collection('roads')
        .doc('B6')
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('document exists on the database');
        final data = documentSnapshot.data() as Map<String, dynamic>;
        List<dynamic> bumpList = data['bumps'];
        print(bumpList.length);
        print(bumpList[0]);
        //print(bumpList.latitude);
        bumpList.forEach((e) async {
          print('lat: ${e.latitude} + long: ${e.longitude}');
          GeoPoint geoPoint = e;
          double lat = e.latitude;
          double lng = e.longitude;
          LatLng latLng = LatLng(lat, lng);

          startendLocationLists.add(latLng);
          print(startendLocationLists);
        });
        print(bumpList);
      } else {
        print('document is null');
      }
    });
  }

  ///GETTING THE POSITION OF A BUMP
  ///
  CollectionReference bumpsCollection =
      FirebaseFirestore.instance.collection('roads');
  Future addBumps() async {
    print('active');
    // firebase command of adding cordinates to a database array
    bumpsCollection
        .doc('C91')
        .set({'bumps': FieldValue.arrayUnion(getGeoPoint())}, SetOptions(merge: true))
        .then((_) => print('Bump Added'))
        .catchError((error) => print('Add failed: $error'));
  }

  double distance = 0.0;
  int timeCalc = 0;

  @override
  void initState() {
    bumpsOnRoad();
    markers.add(Marker(
      //add start location marker
      markerId: MarkerId(startLocation.toString()),
      position: startLocation, //position of marker
      infoWindow: InfoWindow(
        //popup info
        title: 'Starting Point ',
        snippet: 'Start Marker',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    markers.add(Marker(
      //add distination location marker
      markerId: MarkerId(endLocation.toString()),
      position: endLocation, //position of marker
      infoWindow: InfoWindow(
        //popup info
        title: 'Destination Point ',
        snippet: 'Destination Marker',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    //getDirections(); //fetch direction polylines from Google API
    //paceNoteSequence();

    super.initState();
  }

  /// make a list of polyline points, compare both lists and check each for proximity
  /// determine route name or street name

  ///PACE NOTE ALGORITHMS
  Future<void> paceNoteSequence() async {
    for (int start = 0; start <= startendLocationLists.length - 2; start++) {
      setState(() {
        startLocation = startendLocationLists[start];
        endLocation = startendLocationLists[start + 1];
        getDirections();
      });
      print('start' + startLocation.toString());
      print('end' + endLocation.toString());
      await timeToNext();
      await speak('bump in $timeCalc seconds');

      await Future.delayed(Duration(seconds: timeCalc));
    }
  }

  Future<int> timeToNext() async {
    //time is given by distance/speed
    //using actual distance
    //simulating speed
    //double time;
    final double time =
        await getDirections() / 14.75; //direction(m) / speed(ms) = time(sec)
    print('Time is: ${time.toStringAsFixed(0)} secs');
    setState(() {
      timeCalc = int.parse(time.toStringAsFixed(0));
    });
    return timeCalc;
  }

  ///PACE NOTE ALGORITHMS
  Future<double> getDirections() async {
    //returning distance for the time to keep function

    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        print('poly ${point.latitude} poly ${point.longitude}');
      });
    } else {
      print(result.errorMessage);
    }

    //polylineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }
    print(totalDistance);

    setState(() {
      distance = totalDistance * 1000;
    });
    //await speak("bump in ${distance.toStringAsFixed(0)} meters");
    //add to the list of poly line coordinates
    addPolyLine(polylineCoordinates);
    print(distance);

    return distance;
  }

//ASSISTANT PARAMETERS
  speak(String speach) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0); //0.5-1.5
    await flutterTts.speak(speach);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  ///CURRENT LOCATION AS BOTH LATLONG AND GEOPOINT
  getMyPosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('Positions is: $position');
    return position;
  }

  getGeoPoint() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var bumpGeo = GeoPoint(position!.latitude, position!.longitude);
    print(bumpGeo);
    return bumpGeo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Polyline Calculate Distance"),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: Stack(children: [
          GoogleMap(
            //Map widget from google_maps_flutter package
            zoomGesturesEnabled: true, //enable Zoom in, out on map
            initialCameraPosition: CameraPosition(
              //initial position in map
              target: startLocation, //initial position
              zoom: 14.0, //initial zoom level
            ),
            markers: markers, //markers to show on map
            polylines: Set<Polyline>.of(polylines.values), //polylines
            mapType: MapType.normal, //map type
            onMapCreated: (controller) {
              //method called when map is created
              setState(() {
                mapController = controller;
              });
            },
          ),
          Positioned(
              bottom: 200,
              left: 50,
              child: Container(
                  child: GestureDetector(
                onTap: () async {
                  //await bumpsOnRoad();
                  //await paceNoteSequence();
                  await addBumps();
                  print('object');
                },
                child: Card(
                  child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                              "Distance is: " +
                                  distance.toStringAsFixed(2) +
                                  " m",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("Time is: " + timeCalc.toString() + " secs",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      )),
                ),
              ))),
          FloatingActionButton(onPressed: () async{
            print('pressed');
             addBumps;
          }),
        ]));
  }
}
