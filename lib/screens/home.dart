import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:railsv2/data/items.dart';
import 'package:railsv2/map_detail/poly_points.dart';
import 'package:railsv2/map_detail/speed_points.dart';
import 'package:railsv2/screens/update.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

import '../register/auth_service.dart';
import '../services/directions.dart';
import '../services/directions_model.dart';
///TODO: after adjust marker location make sure that the map draws the route from the new location
///TODO; meanwhile google signout
///TODO: Now even the Google Sign Out is not working😂😂😂😂
///TODO: FIND ROUTE LOGIC PENDING
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

bool live = false;
bool about = true;
bool fatal = false;
class _HomeState extends State<Home> {
  int index = 0;
  bool _show = false;
  bool changedValue = false;
  SolidController _controller = SolidController();
  late AnimationController _animationController;
  //final PageController _pageController = PageController();

  Stream<QuerySnapshot> collectionStream = FirebaseFirestore.instance.collection('users').snapshots();
  Stream<DocumentSnapshot> documentStream = FirebaseFirestore.instance.collection('roads').doc('B6').collection('books').doc('Live').snapshots();


  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;
  LocationData? currentLocation;
  String _mode = 'driving';
  Location location = Location();
  var listeners;
  List<MapType> mapType = [
    MapType.hybrid,
    MapType.terrain,
    MapType.satellite,
    MapType.normal
  ];
  MapType _mapType = MapType.normal;
  late LatLng outPos;
  late LatLng newOutPos;
  void _addMarker(LatLng pos) async {
    outPos = pos;

    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
            markerId: const MarkerId('origin'),
            draggable: true,
            infoWindow:
                InfoWindow(title: 'origin'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos,
            onDragEnd: (newPos){
            //newOutPos = newPos;
            pos = newPos;
            changedValue = true;
            print('Origin NewPos to Latitude: ${newPos.latitude}');
            print('Origin NewPos to Longitude: ${newPos.longitude}');
            print('**********-----------***********');
            print('Origin Pos to Latitude: ${pos.latitude}');
            print('Origin Pos to Longitude: ${pos.longitude}');
          },
        );
        _destination = null;
        _info = null;
        print('Current Position $pos');
      });
    } else {
      setState(() {
        _destination = Marker(
            markerId: const MarkerId('destination'),
            draggable: true,

            infoWindow:
                InfoWindow(title:'destination'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
            position: pos,
          onDragEnd: (newPos){
            //newOutPos = newPos;
            pos = newPos;
            changedValue = true;
            print('Destination NewPos to Latitude: ${newPos.latitude}');
            print('Destination NewPos to Longitude: ${newPos.longitude}');
            print('**********-----------***********');
            print('Destination Pos to Latitude: ${pos.latitude}');
            print('Destination Pos to Longitude: ${pos.longitude}');
          },
        );
        print('Current Position $pos');
      });
      /// Get directions
     /* final directions = await DirectionsRep().getDirections(
          origin: _origin!.position, destination: pos, mode: _mode);
      setState(() {
        _info = directions;
      });*/
    }
  }

  listen() {
    listeners = location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            zoom: 15,
            tilt: 50.0,
          ),
        ),
      );
    });
  }

  getCurrentLoc() {
    location.onLocationChanged.listen((loc) {

        if(mounted){
          setState(() {
            currentLocation = loc;
          });
        }

      print(currentLocation);
    });
  }
///BOTTOM SHEET
  ///

  Widget? _showBottomSheet() {
    if (_show) {
      return BottomAppBar(
        //shape: CircularNotchedRectangle(),
        //notchMargin: 10,
        child: SolidBottomSheet(
          smoothness: Smoothness.high,
          draggableBody: true,
          headerBar: Container(
              color: Colors.transparent, height: 58, child: bottomBarRow()),
          body: Material(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child:Container(
                  child: StreamBuilder(
                      stream:  documentStream,
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text("Loading");
                        }
                        var res = snapshot.data!.data() as Map<String, dynamic>;

                        if(live){
                          return  Card(

                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(res['Title']??res['Author']??res['bus'],style: TextStyle(fontWeight: FontWeight.bold),),
                                  Divider(),
                                  ListTile(
                                    leading: CircleAvatar(child: Text(res['Author']??res['matatu']??res['risks'])),
                                    title: Text(res['Comment']??res['matatu']??res['risks']),
                                    //trailing: Text(res['Title']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if(about){
                          print(live );
                          print(about);
                        print(fatal);
                          return  Card(

                            child: Column(
                              children: [
                                Text(res['Route'],style: TextStyle(fontWeight: FontWeight.bold),),
                                Divider(),
                                ListTile(
                                  leading: CircleAvatar(child: Text(res['Author'])),
                                  title: Text(res['Risks']),
                                  //trailing: Text(res['Title']),
                                ),
                                ListTile(
                                  leading: CircleAvatar(child: Text(res['Author'])),
                                  title: Text(res['potholes']),
                                  //trailing: Text(res['Title']),
                                ),
                              ],
                            ),
                          );
                        }
                        if(fatal){

                        }
                        /*return  Card(

                          child: Column(
                            children: [
                              Text(res['Title'],style: TextStyle(fontWeight: FontWeight.bold),),
                              Divider(),
                              ListTile(
                                leading: CircleAvatar(child: Text(res['Author'])),
                                title: Text(res['Comment']),
                                //trailing: Text(res['Title']),
                              ),
                            ],
                          ),
                        );*/
                        return Container();
                      },
                  ),
                ),
              )),
        ),
      );
    } else {
      return null;
    }
  }

  ///WIDGET BOTTOMBAR
  ///
//access streams

  Widget bottomBarRow() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Items(
              size: size,
              icon: Icons.wifi_tethering,
              onTap: () {
               // _animationController.reset();
                /*_pageController.animateToPage(0,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInCubic);*/
                setState(() {
                  live == true;
                  about == false;
                  fatal == false;
                  documentStream = FirebaseFirestore.instance.collection('roads').doc('B6').collection('books').doc('Live').snapshots();
                });
              },
              label: 'Live',
              color: index == 0
                  ? Theme.of(context).brightness == Brightness.light
                  ? Colors.teal
                  : Colors.red
                  : Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white),
          Items(
              size: size,
              icon: Icons.lightbulb_sharp,
              onTap: () {
                setState(() {
                  live == false;
                  about == true;
                  fatal == false;
                  documentStream = FirebaseFirestore.instance.collection('roads').doc('B6').collection('books').doc('About').snapshots();
                });
              },
              label: 'About',
              color: index == 1
                  ? Theme.of(context).brightness == Brightness.light
                  ? Colors.teal
                  : Colors.red
                  : Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white),
          Items(
              size: size,
              icon: Icons.dangerous,
              onTap: () {
                setState(() {
                  live == false;
                  about == false;
                  fatal == true;
                  documentStream = FirebaseFirestore.instance.collection('roads').doc('B6').collection('books').doc('Fatal').snapshots();
                });
              },
              label: 'Fatal',
              color: index == 2
                  ? Theme.of(context).brightness == Brightness.light
                  ? Colors.teal
                  : Colors.red
                  : Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white),
        ],
      ),
    );
  }

  @override
  void initState() {
    getCurrentLoc();
    super.initState();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

 User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
             DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                //image: DecorationImage(image: NetworkImage(user!.photoURL.toString())),
              ),
              child: Row(
                children: [
                  Card(
                    elevation: 20,
                    color: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        height: 65,
                        width: 65,
                        decoration:
                        BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(32.5),
                            child: Image.asset('assets/rail_logo.png'),
                            //child: Image.network(user!.photoURL.toString())
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4,),
                  //Text(user!.displayName.toString(), style: TextStyle(fontSize: 15),),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.cable_rounded),
              title: const Text('PaceNotes'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LocationPage()));

              },
            ),
            ListTile(
              leading: Icon(Icons.location_history_outlined),
              title: const Text('Geolocator'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>GeolocatorSpeed(title: 'title')));

              },
            ),
            ListTile(
              leading: Icon(Icons.cloud_circle),
              title: const Text('Update'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdatePage()));

              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: const Text('FAQ'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>GeolocatorSpeed(title: 'title')));

              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>GeolocatorSpeed(title: 'title')));

              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('SignOut'),
              onTap: () {
                CupertinoAlertDialog(
                  title: Text('SignOut'),
                  content: Text('Confirm SignOut'),
                  actions: [
                    CupertinoDialogAction(child: Text('Stay'), onPressed: (){Navigator.of(context).pop();},),
                    CupertinoDialogAction(child: Text('Proceed'), onPressed: (){AuthService().signOut();},)
                  ],
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        //bottomOpacity: .5,
        //backgroundColor: Colors.black.withOpacity(.0),
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        title: const Text('Rails'),
        actions: [
          ButtonBar(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.bus_alert)),
              //IconButton(onPressed: () {}, icon: Icon(Icons.directions_walk)),
             // IconButton(onPressed: () {}, icon: Icon(Icons.pedal_bike)),
              IconButton(onPressed: () {}, icon: Icon(Icons.toys)),
            ],
          ),
          if (_origin != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origin!.position,
                    zoom: 35.5,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.greenAccent,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('from'),
            ),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _destination!.position,
                    zoom: 35.5,
                    // tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.redAccent,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('to'),
            )
        ],
      ),
      body: currentLocation != null
          ? Stack(
              alignment: Alignment.center,
              children: [
                // if (_info!=null)

                GoogleMap(
                  compassEnabled: false,
                 // onTap: ,
                  mapType: _mapType,
                  trafficEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onMapCreated: (controller) =>
                      _googleMapController = controller,
                  onLongPress: _addMarker,
                  markers: {
                    if (_origin != null) _origin!,
                    if (_destination != null) _destination!
                  },
                  polylines: {
                    if (_info != null)
                      Polyline(
                          polylineId: const PolylineId('overview_polyline'),
                          color: Colors.blue,
                          width: 6,
                          consumeTapEvents: true,
                          points: _info!.polylinePoints
                              .map((e) {
                                print(e);
                                print(_info);
                                return LatLng(e.latitude, e.longitude);
                              })
                              .toList())
                  },
                ),
                _info != null
                    ? Positioned(
                    top: 100,
                      left: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent.withOpacity(.4),
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,

                          children: [
                            Text(
                              '${_info!.totalDistance}, ${_info!.totalDuration}',
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                            Text('From: ${_info!.from}'),
                            Text('To: ${_info!.to}')
                          ],
                        ),
                      ),
                    )
                    : Container(),
                Positioned(
                  right: 10,
                  top: 10,
                  child: SafeArea(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white
                      ),

                      child: DropdownButton<MapType>(
                        elevation: 0,
                        dropdownColor: Colors.transparent,
                        hint: Text('layers'),
                        value: _mapType,
                        onChanged: (newMapType) {
                          _mapType = newMapType!;
                        },
                        items: mapType.map((maptype) {
                          return DropdownMenuItem(
                            value: maptype,
                            child: SizedBox(
                              height:55,

                              child: Card(
                                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(60)),
                                elevation: 0,
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                        Icon(maptype == MapType.satellite
                                    ? Icons.circle_rounded
                                    : maptype == MapType.normal
                                        ? Icons.book_rounded
                                        : maptype == MapType.hybrid
                                            ? Icons.wb_sunny_rounded
                                            : maptype == MapType.terrain
                                                ? Icons.add_road
                                                : Icons.ac_unit),
                                                 Text(maptype == MapType.satellite
                                    ? 'satellite'
                                    : maptype == MapType.normal
                                        ? 'normal'
                                        : maptype == MapType.hybrid
                                            ? 'hybrid'
                                            : maptype == MapType.terrain
                                                ? 'terrain'
                                                : '',overflow: TextOverflow.ellipsis,),
                                    ],
                                  ),

                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              ],
            )
          : Center(child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: LinearProgressIndicator(),
          )),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          (_info != null && changedValue == true)
              ? FloatingActionButton(
            heroTag: 'btn1',
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.clear_all),
                  onPressed: () {
                    _info = null;
                    _origin = null;
                    _destination = null;
                  })
              : FloatingActionButton(
            heroTag: 'btn2',
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              child: Icon(Icons.edit_location_alt_outlined),
              onPressed: () async{
                //_info = null;
                //_origin = null;
                //_destination = null;
                  final directions = await DirectionsRep().getDirections(
                      //origin: _origin!.position, destination: newOutPos, mode: _mode);
                  origin: _origin!.position, destination: outPos, mode: _mode);
                  setState(() {
                    _info = directions;
                  });
                  print('&{_origin!.position} &&&&&+ outPos');

              }),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: FloatingActionButton(
              heroTag: 'btn3',
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                tooltip: listeners == null
                    ? 'enable tracking'
                    : listeners.isPaused
                        ? 'enable tracking'
                        : 'disable tracking',
                onPressed: () {
                  listeners == null
                      ? listen()
                      : listeners.isPaused
                          ? listen()
                          : listeners.pause();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      listeners == null
                          ? 'live tracking enabled'
                          : listeners.isPaused
                              ? 'live tracking has been paused'
                              : 'live tracking enabled',
                    ),
                  ));
                },
                child: Icon(
                  listeners == null
                      ? Icons.track_changes_outlined
                      : listeners.isPaused
                          ? Icons.track_changes_outlined
                          : Icons.track_changes_sharp,
                  color: listeners == null
                      ? Colors.green
                      : listeners.isPaused
                          ? Colors.green
                          : Colors.red,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 0),
            child: FloatingActionButton(
              heroTag: 'btn4',
              tooltip: _info == null ? 'go to my location' : 'show route bounds',
              onPressed: () async {
                currentLocation = await location.getLocation();
                _googleMapController.animateCamera(_info != null
                    ? CameraUpdate.newLatLngBounds(_info!.bounds, 100)
                    : CameraUpdate.newCameraPosition(CameraPosition(
                        zoom: 14.5,
                        tilt: 50.0,
                        target: LatLng(currentLocation!.latitude!,
                            currentLocation!.longitude!))));
              },
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              child: Icon(_info == null
                  ? Icons.location_on_outlined
                  : Icons.center_focus_weak_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 0),
            child: FloatingActionButton(
              tooltip: _show == null ? 'go to my location' : 'show route bounds',
              onPressed: () async {
                if (_show) {
                  setState(() {
                    _show = false;
                  });
                } else {
                  setState(() {
                    _show = true;
                  });
                }
              },
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              child: _show ? Icon(Icons.arrow_downward) : Icon(Icons.book_outlined),

            ),
          ),
        ],
      ),
      /*bottomSheet: SolidBottomSheet(
        controller: _controller,
        draggableBody: true,
        headerBar: Container(
          color: Theme.of(context).primaryColor,
          //color: Colors.transparent,
          height: 50,
          child: Center(
            child: Text("Swipe me!"),
          ),
        ),
        body: Container(
          color: Colors.white,
          height: 30,
          child: Center(
            child: Text(
              "Hello! I'm a bottom sheet :D",
              //style: Theme.of(context).textTheme.display1,
            ),
          ),
        ),
      ),*/
      bottomSheet: _showBottomSheet(),
    );

  }
}
/*
void _settingModalBottomSheet(context){
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
        return Container(
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                  leading: new Icon(Icons.music_note),
                  title: new Text('Music'),
                  onTap: () => {}
              ),
              new ListTile(
                leading: new Icon(Icons.videocam),
                title: new Text('Video'),
                onTap: () => {},
              ),
            ],
          ),
        );
      }
  );
}*/
