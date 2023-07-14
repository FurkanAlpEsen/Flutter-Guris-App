import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:guris/pages/units.dart';
import 'package:guris/pages/saved_locations.dart';
import 'package:guris/pages/google_maps.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _tabItems = [
    SavedLocationPage(),
    MapView(selection: '',),
    UnitsPage()
  ];
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: 85,
        child: CurvedNavigationBar(
          // height: 100,
          color: Color.fromARGB(255, 255, 255, 255),
          backgroundColor: Color.fromARGB(255, 149, 183, 216),
          items: <Widget>[
            Icon(Icons.add_location),
            Icon(Icons.home),
            Icon(Icons.ad_units_outlined)
          ],
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
        ),
      ),
      body: _tabItems[_page],
    );
  }
}
