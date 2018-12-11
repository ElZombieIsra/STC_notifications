import 'dart:math'; 
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Google Maps demo')),
      body: MapsDemo(),
    ),
  ));
}

class MapsDemo extends StatefulWidget {
  @override
  State createState() => MapsDemoState();
}

class MapsDemoState extends State<MapsDemo> {
  Map loc1 = {'lat': 19.415871, 'lon':-99.072874}; // Ubicación aproximada de metro pantitlán
  Map loc2 = {'lat': 19.423813, 'lon':-99.063910};
  num distance = 0;

  Map<String, double> _startLocation;
  Map<String, double> _currentLocation;

  StreamSubscription<Map<String, double>> _locationSubscription;

  Location _location = new Location();
  bool _permission = false;
  String error;
  
  GoogleMapController mapController;

  @override
  void initState() {
    super.initState();

    initPlatformState();

    _locationSubscription = _location.onLocationChanged().listen((Map<String,double> result){
      setState(() {
        _currentLocation = result;
        print(result);
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    Map<String, double> location;
    // Platform messages may fail, so we use a try/catch PlatformException.

    try {
      _permission = await _location.hasPermission();
      location = await _location.getLocation();


      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied - please ask the user to enable it from the app settings';
      }

      location = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;

    setState(() {
        _startLocation = location;
    });

  }

  @override
  Widget build(BuildContext context) {
    distance = getDistanceBetween(loc1, {'lat': _currentLocation['latitude'], 'lon': _currentLocation['longitude']});
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          /*Center(
            child: SizedBox(
              width: 300.0,
              height: 200.0,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
              ),
            ),
          ),*/
          Text('${_currentLocation["latitude"]}, ${_currentLocation["longitude"]}. Distancia de aquí a pantitlan = $distance'),
          RaisedButton(
            child: const Text('Go to London'),
            onPressed: mapController == null ? null : () {
              mapController.animateCamera(CameraUpdate.newCameraPosition(
                const CameraPosition(
                  bearing: 270.0,
                  target: LatLng(51.5160895, -0.1294527),
                  tilt: 30.0,
                  zoom: 17.0,
                ),
              ));
            },
          ),
        ],
      ),
    );
  }
  

  void _onMapCreated(GoogleMapController controller) {
    setState(() { mapController = controller; });
  }
}

num getDistanceBetween(Map loc1, Map loc2){
  num R = 6371e3;
  num lat1 = radians(loc1['lat']);
  num lat2 = radians(loc2['lat']); 
  num diff1 = radians(loc2['lat'] - loc1['lat']);
  num diff2 = radians(loc2['lon'] - loc1['lon']);
  num a = pow(sin(diff1/2), 2) + cos(lat1) * cos(lat2) * pow(sin(diff2/2), 2);
  num c = 2 * atan2(sqrt(a), sqrt(1 - a));
  num distance = (R * c).round();
  return distance;
}