import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

import '../services/secrets.dart';
import '../widgets/location_input.dart';

class MyMapViewPage extends StatefulWidget {
  const MyMapViewPage({super.key});

  @override
  State<MyMapViewPage> createState() => _MyMapViewPageState();
}

class _MyMapViewPageState extends State<MyMapViewPage> {
  var _cameraPos;
  CameraPosition _initialLocation =
      CameraPosition(target: LatLng(40.734802, 34.467987), zoom: 5);
  late GoogleMapController mapController;

  Set<Marker> markers = {};
  Set<Marker> filteredmarkers = {};
  String searchValue = '';

  final List<String> _suggestions = [
    'Tesis Istanbul',
    'Tesis Ankara',
    'Tesis Izmir',
    'Tesis Erzurum',
    'Tesis Antalya',
    'Tesis Mersin',
    'Tesis Kayseri',
    'Tesis Adiyaman',
    'Tesis Gaziantep',
  ];

  TextEditingController startController = TextEditingController();
  TextEditingController destController = TextEditingController();
  String filterValue = 'All';
  var filterList = {
    'All',
    'Marmara',
    'Ege',
    'Akdeniz',
    'Dogu Anadolu',
    'Ic Anadolu',
    'Karadeniz',
    'Guneydogu Anadolu'
  };
  int filterkey = 0;

  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  double? distanceInMeters;
  String _markerAddress = '';
  LatLng _markerLoc = LatLng(1, 2);
  Position? mylocation;

  LatLng destPoint = LatLng(1, 2);
  LatLng startPoint = LatLng(1, 2);

  Future<List<String>> _fetchSuggestions(String searchValue) async {
    await Future.delayed(const Duration(milliseconds: 750));

    return _suggestions.where((element) {
      return element.toLowerCase().contains(searchValue.toLowerCase());
    }).toList();
  }

  void getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        mylocation = position;
        startController.text = mylocation.toString();
        startPoint = LatLng(mylocation!.latitude, mylocation!.longitude);
        print('_____________CURRENT POS: $mylocation');
      });
      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  void _getmyMarkerLocation(double lat, double long) async {
    _markerLoc = LatLng(lat, long);
    List<Placemark> p = await placemarkFromCoordinates(lat, long);

    Placemark place = p[0];

    _markerAddress =
        "${place.name}, ${place.locality},${place.administrativeArea}, ${place.postalCode}, ${place.country}";
    // destinationAddressController.text = _markerAddress;
    // _destinationAddress = _markerAddress;
    destPoint = LatLng(lat, long);
    destController.text = lat.toString() + ' ' + long.toString();
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
        _getmyMarkerLocation(39.90861, 41.27694);
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
      // visible: false,

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

    setState(() {
      filteredmarkers = markers;
    });

    filteredmarkers = markers;
  }

  void getPolyPoints(startLatitude, startLongitude, destinationLatitude,
      destinationLongitude) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      // travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    distanceInMeters = Geolocator.distanceBetween(startLatitude, startLongitude,
        destinationLatitude, destinationLongitude);
    setState(() {});
  }

  void updateFilter(String id) {
    // filteredmarkers.forEach((element) {
    //   filteredmarkers.remove(element);
    // });
    filteredmarkers.clear();

    _loadmyMarkers();
    markers.forEach((element) {
      if (element.markerId == id) {
        filteredmarkers.add(element);
      }
    });
    setState(() {});
  }

  var status;
  @override
  void initState() {
    super.initState();
    _loadmyMarkers();
    status = Permission.location.request();
    status = Permission.location.status;

    getCurrentLocation();

    // getPolyPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EasySearchBar(
          backgroundColor: Colors.amber,
          title: Center(child: const Text('Map')),
          onSearch: (value) {
            setState(() {
              searchValue = value;
              markers.forEach((element) {
                if (searchValue == element.markerId.value) {
                  // print('element ${element.markerId}');
                  // print('------ pos--------- ${element.position}');
                  _cameraPos = element.position;
                  setState(() {});
                  startController.text = searchValue;
                  startPoint = element.position;
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
          suggestions: _suggestions),
      body: Stack(
        children: [
          GoogleMap(
            polylines: {
              Polyline(
                  polylineId: PolylineId('route'),
                  color: Colors.purple,
                  points: polylineCoordinates,
                  width: 6)
            },
            // myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers: filteredmarkers,
            initialCameraPosition: _initialLocation,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                mapController = controller;
              });
              setState(() {});
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(9))),
                margin: EdgeInsets.only(top: 5, right: 5, left: 5),
                // color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.filter_list_alt),
                    DropdownButton<String>(
                      // Step 3.
                      value: filterValue,
                      // Step 4.
                      items: filterList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontSize: 15),
                          ),
                        );
                      }).toList(),
                      // Step 5.
                      onChanged: (String? newValue) {
                        setState(() {
                          filterValue = newValue!;
                          switch (filterValue) {
                            case 'All':
                              filterkey = 0;
                              // filteredmarkers = markers;
                              _loadmyMarkers();
                              print('-------filterdmarkers: $filteredmarkers');
                            case 'Marmara':
                              filterkey = 1;
                              updateFilter('Tesis Istanbul');
                              break;
                            case 'Ege':
                              filterkey = 2;
                              updateFilter('Tesis Izmir');

                              break;
                            case 'Akdeniz':
                              filterkey = 3;
                              updateFilter('Tesis Antalya');
                              updateFilter('Tesis Mersin');

                              break;
                            case 'Dogu Anadolu':
                              filterkey = 4;
                              updateFilter('Tesis Erzurum');

                              break;
                            case 'Ic Anadolu':
                              filterkey = 5;
                              updateFilter('Tesis Ankara');
                              updateFilter('Tesis Kayseri');

                              break;

                            case 'Karadeniz':
                              filterkey = 6;
                              // updateFilter('Tesis Istanbul');

                              break;
                            case 'Guneydogu Anadolu':
                              filterkey = 7;
                              updateFilter('Tesis Gaziantep');
                              updateFilter('Tesis Adiyaman');

                              break;

                            default:
                          }

                          // for (var marker in filteredmarkers) {
                          //   // print(marker);
                          //   if (filterkey == marker.zIndex) {
                          //     filteredmarkers.remove(marker);
                          //     print('------ visib: ${marker.visible}');
                          //   }

                          // markers.toSet();

                          //   // setState(() {
                          //   //   markers = markers.toSet();
                          //   //   print('-----guncell');
                          //   // });
                          // }

                          // markers.forEach((element) {
                          //   if (filterkey == element.zIndex) {
                          // print('element ${element.markerId}');
                          // print('------ pos--------- ${element.position}');
                          // _cameraPos = element.position;
                          // setState(() {});
                          // startController.text = searchValue;
                          // startPoint = element.position;
                          // mapController.animateCamera(
                          //   CameraUpdate.newCameraPosition(
                          //     CameraPosition(
                          //       target: LatLng(
                          //         _cameraPos.latitude,
                          //         _cameraPos.longitude,
                          //       ),
                          //       zoom: 8.0,
                          //     ),
                          //   ),
                          // );
                          //     print('---------filter key $filterkey ');
                          //     element =
                          //         element.copyWith(visibleParam: false);
                          //     print('---------element $element');

                          //     setState(() {});
                          //   }
                          // }
                          // );
                          // markers = markers.toSet();
                          // setState(() {
                          //   // print('---------element degisti');
                          // });
                        });
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
                  child: PointInput(
                    label: 'Start',
                    inputController: startController,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                child: PointInput(
                  label: 'Destination',
                  inputController: destController,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 190.0, left: 120),
            child: Column(
              children: [
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          getPolyPoints(
                              startPoint.latitude,
                              startPoint.longitude,
                              destPoint.latitude,
                              destPoint.longitude);
                          setState(() {});
                        },
                        child: Text('Calculate')),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // if (polylines.isNotEmpty) polylines.clear();
                          if (polylineCoordinates.isNotEmpty)
                            polylineCoordinates.clear();
                          distanceInMeters = null;
                          setState(() {});
                        },
                        child: Icon(Icons.delete),
                      ),
                    ),
                  ],
                ),
                distanceInMeters == null
                    ? Text('data')
                    : Padding(
                        padding: const EdgeInsets.only(right: 100.0, top: 10),
                        child: Container(
                          color: Colors.white,
                          child: Text(
                            'DISTANCE: ~${(distanceInMeters! ~/ 1000).toInt()} km',
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 20,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 70.0,
        width: 200.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 100,
              child: FloatingActionButton(
                  onPressed: () {
                    // startPoint =
                    //     LatLng(mylocation!.latitude, mylocation!.longitude);
                    startController.text = mylocation.toString();
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                              mylocation!.latitude, mylocation!.longitude),
                          zoom: 8.0,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  child: Icon(Icons.my_location)),
            ),
          ],
        ),
      ),
    );
  }
}
