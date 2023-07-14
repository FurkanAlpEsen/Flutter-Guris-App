import 'package:flutter/material.dart';
import 'package:guris/pages/google_maps.dart';

class CustomSearchDelegate extends SearchDelegate {

  var result; 

  List<String> searchTerms = [
    'Tesis Ankara',
    'Tesis Istanbul',
    'Tesis Antalya',
    'Tesis Mersin',
    'Tesis Izmir',
    'Tesis Adiyaman',
    'Tesis Gaziantep',
    'Tesis Kayseri',
    'Tesis Erzurum'
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          onTap: () {
                        Navigator.pop(context);
            result;
          },
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MapView(selection: result)),
            );
          },
          title: Text(result),
        );
      },
    );
  }
}
