import 'package:flutter/material.dart'; // Stores the Google Maps API Key
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'dart:math' show cos, sqrt, asin;

import '../services/secrets.dart';
import '../widgets/searchbar_filter.dart';

class MapView extends StatefulWidget {
  final String selection;

  const MapView({Key? key, required this.selection}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(40.734802, 34.467987), zoom: 5);
  late GoogleMapController mapController;

  late Position _currentPosition;
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  var _cameraPos;

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  Set<Marker> markers = {};

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  _getCurrentLocation() async {
     await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
      setState(() {
        
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality},${place.administrativeArea}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _calculateDistance() async {
    try {
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(_destinationAddress);

      double startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;

      // double startLatitude = startPlacemark[0].latitude;
      // double startLongitude = startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      // setState(() {
      //   startLocation = LatLng(startLatitude, startLongitude);
      //   endLocation = LatLng(destinationLatitude, destinationLongitude);
      // });

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      Marker startMarker = Marker(
        markerId: MarkerId('Start'),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId('Destination'),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      markers.add(startMarker);
      markers.add(destinationMarker);

      print(
        'START COORDINATES: ($startLatitude, $startLongitude)',
      );
      print(
        'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
      );

      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );
      print('test------------$test');
      await _createPolylines(startLatitude as double, startLongitude as double,
          destinationLatitude as double, destinationLongitude as double);

      // print(
      //     '---values: $startLatitude, $startLongitude, $destinationLatitude, $destinationLongitude----');

      //await _createPolylines(41.015983, 28.977655, 39.929079, 32.869710);

      double totalDistance = 0.0;

      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        print('buraya girdi');
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(startLatitude, startLongitude, destinationLatitude,
      destinationLongitude) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color.fromARGB(255, 83, 160, 247),
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  LatLng test = LatLng(1, 2);

  void _getmyMarkerLocation(double lat, double long) async {
    test = LatLng(lat, long);
    List<Placemark> p = await placemarkFromCoordinates(lat, long);

    Placemark place = p[0];

    _currentAddress =
        "${place.name}, ${place.locality},${place.administrativeArea}, ${place.postalCode}, ${place.country}";
    destinationAddressController.text = _currentAddress;
    _destinationAddress = _currentAddress;
  }

  void _loadmyMarkers() async {
    final Uint8List markIcons = await getImages('assets/images/guris.png', 100);
    Marker sample1 = Marker(
      markerId: MarkerId('Tesis Istanbul'),
      position: LatLng(41.015983, 28.977655),
      infoWindow: InfoWindow(
        title: 'Tesis Istanbul',
      ),
      icon: BitmapDescriptor.fromBytes(markIcons),
      onTap: () {
        _getmyMarkerLocation(41.015983, 28.977655);
        setState(() {});
        // setState(() async {
        //   _getmyMarkerLocation(41.015983, 28.977655);
        // });
      },
    );

    Marker sample2 = Marker(
      markerId: MarkerId('Tesis Ankara'),
      position: LatLng(39.929079, 32.869710),
      infoWindow: InfoWindow(
        title: 'Tesis Ankara',
      ),
      icon: BitmapDescriptor.fromBytes(markIcons),
      onTap: () {
        _getmyMarkerLocation(39.929079, 32.869710);
        setState(() {});
      },
    );
    Marker sample3 = Marker(
      markerId: MarkerId('Tesis Izmir'),
      position: LatLng(38.420000, 27.149997),
      infoWindow: InfoWindow(
        title: 'Tesis Izmir',
      ),
      icon: BitmapDescriptor.fromBytes(markIcons),
      onTap: () {
        _getmyMarkerLocation(38.420000, 27.149997);
        setState(() {});
      },
    );
    Marker sample4 = Marker(
      markerId: MarkerId('Tesis Erzurum'),
      position: LatLng(39.90861, 41.27694),
      infoWindow: InfoWindow(
        title: 'Tesis Erzurum',
      ),
      icon: BitmapDescriptor.fromBytes(markIcons),
      onTap: () {
        _getmyMarkerLocation(39.90861 ,41.27694);
        setState(() {});
      },
    );
    Marker sample5 = Marker(
      markerId: MarkerId('Tesis Antalya'),
      position: LatLng(36.90812, 30.69556),
      infoWindow: InfoWindow(
        title: 'Tesis Antalya',
      ),
      icon: BitmapDescriptor.fromBytes(markIcons),
      onTap: () {
        _getmyMarkerLocation(36.90812, 30.69556);
        setState(() {});
      },
    );
    Marker sample6 = Marker(
      markerId: MarkerId('Tesis Mersin'),
      position: LatLng(36.812103, 34.641479),
      infoWindow: InfoWindow(
        title: 'Tesis Mersin',
      ),
      icon: BitmapDescriptor.fromBytes(markIcons),
      onTap: () {
        _getmyMarkerLocation(36.812103, 34.641479);
        setState(() {});
      },
    );
    Marker sample7 = Marker(
      markerId: MarkerId('Tesis Kayseri'),
      position: LatLng(38.734802, 35.467987),
      infoWindow: InfoWindow(
        title: 'Tesis Kayseri',
      ),
      icon: BitmapDescriptor.fromBytes(markIcons),
      onTap: () {
        _getmyMarkerLocation(38.734802, 35.467987);
        setState(() {});
      },
    );
    Marker sample8 = Marker(
      markerId: MarkerId('Tesis Adiyaman'),
      position: LatLng(37.783745, 37.641323),
      infoWindow: InfoWindow(
        title: 'Tesis Adiyaman',
      ),
      icon: BitmapDescriptor.fromBytes(markIcons),
      onTap: () {
        _getmyMarkerLocation(37.783745, 37.641323);
        setState(() {});
      },
    );
    Marker sample9 = Marker(
      markerId: MarkerId('Tesis Gaziantep'),
      position: LatLng(37.066666, 37.383331),
      infoWindow: InfoWindow(
        title: 'Tesis Gaziantep',
      ),
      icon: BitmapDescriptor.fromBytes(markIcons),
      onTap: () {
        _getmyMarkerLocation(37.066666, 37.383331);
        setState(() {});
      },
    );
    markers.add(sample1);
    markers.add(sample2);
    markers.add(sample3);
    markers.add(sample4);
    markers.add(sample5);
    markers.add(sample6);
    markers.add(sample7);
    markers.add(sample8);
    markers.add(sample9);

    // setState(() {
    //   markers.forEach((element) {
    //     if (widget.selection == element.markerId.value) {
    //       print('element ${element.markerId}');
    //       print('pos ${element.position}');
    //       _cameraPos = element.position;

    //       mapController.animateCamera(
    //         CameraUpdate.newCameraPosition(
    //           CameraPosition(
    //             target: LatLng(
    //               _cameraPos.latitude,
    //               _cameraPos.longitude,
    //             ),
    //             zoom: 8.0,
    //           ),
    //         ),
    //       );
    //     }
    //   });
    // });
  }

  var status;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadmyMarkers();
    status = Permission.location.request();
    status = Permission.location.status;
    // getPolyPoints();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      width: width,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Harita')),
          actions: [
            IconButton(
              onPressed: () {
                // method to show the search bar
                showSearch(
                    context: context,
                    // delegate to customize the search bar
                    delegate: CustomSearchDelegate());
              },
              icon: const Icon(Icons.search),
            )
          ],
        ),
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            GoogleMap(
              markers: Set<Marker>.of(markers),
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              trafficEnabled: true,
              // polylines: Set<Polyline>.of(polylines.values),
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  mapController = controller;
                });
                setState(() {
                  
                });
                setState(() {
                  markers.forEach((element) {
                    if (widget.selection == element.markerId.value) {
                      print('element ${element.markerId}');
                      print('pos ${element.position}');
                      _cameraPos = element.position;

                      mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              _cameraPos.latitude,
                              _cameraPos.longitude,
                            ),
                            zoom: 8.0,
                          ),
                        ),
                      );
                    }
                  });
                });
              },
            ),
            // Show zoom buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 300),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color:
                            Color.fromARGB(255, 64, 138, 203), // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color:
                            Color.fromARGB(255, 64, 138, 203), // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Show the place input fields & button for
            // showing the route
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Konumlar',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Baslangic',
                              hint: 'Baslangic noktasi secin',
                              prefixIcon: Icon(Icons.looks_one),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.my_location),
                                onPressed: () {
                                  setState(() {
                                    _getAddress();
                                    print(
                                        '-----current adres: $_currentAddress');
                                    startAddressController.text =
                                        _currentAddress;
                                    _startAddress = _currentAddress;
                                  });
                                  setState(() {});
                                },
                              ),
                              controller: startAddressController,
                              focusNode: startAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _startAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Varis',
                              hint: 'Hedef konum secin',
                              prefixIcon: Icon(Icons.looks_two),
                              controller: destinationAddressController,
                              focusNode: desrinationAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _destinationAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(
                              'DISTANCE: $_placeDistance km',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: (_startAddress != '' ||
                                        _destinationAddress != '')
                                    ? () async {
                                        startAddressFocusNode.unfocus();
                                        desrinationAddressFocusNode.unfocus();
                                        setState(() {
                                          // if (markers.isNotEmpty)
                                          //   markers.clear();
                                          if (polylines.isNotEmpty)
                                            polylines.clear();
                                          if (polylineCoordinates.isNotEmpty)
                                            polylineCoordinates.clear();
                                          _placeDistance = null;
                                        });
                                        //_createPolylines(test.latitude, test.longitude, _currentPosition.latitude, _currentPosition.longitude);
                                        _calculateDistance()
                                            .then((isCalculated) {
                                          if (isCalculated) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Distance Calculated Sucessfully'),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error Calculating Distance'),
                                              ),
                                            );
                                          }
                                        });
                                        setState(() {});
                                      }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Rota goster'.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 64, 138, 203),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  startAddressFocusNode.unfocus();
                                  desrinationAddressFocusNode.unfocus();
                                  Marker start = markers.firstWhere((marker) =>
                                      marker.markerId.value == "Start");
                                  Marker dest = markers.firstWhere(
                                    (marker) =>
                                        marker.markerId.value == "Destination",
                                  );
                                   markers.remove(start);
                                  markers.remove(dest);

                                  polylines.clear();
                                  polylineCoordinates.clear();
                                  _placeDistance = null;
                                  startAddressController.clear();
                                  destinationAddressController.clear();
                                  setState(() {

                                  });
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Show current location button
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Color.fromARGB(255, 86, 165, 218), // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(
                            Icons.my_location,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    _currentPosition.latitude,
                                    _currentPosition.longitude,
                                  ),
                                  zoom: 18.0,
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
