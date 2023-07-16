import 'package:flutter/material.dart';

class SavedLocationPage extends StatelessWidget {
  const SavedLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Center(child: Text('Saved Location')),
      ),
      body: Container(
        child: ListView(
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.arrow_drop_down_circle),
                    title: const Text('Dummy Location 1'),
                    subtitle: Text(
                      '',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  Image.asset('assets/images/guris.png'),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Dummy Text Greyhound divisively hello coldly wonderfully marginally far upon excluding.',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Perform some action
                        },
                        child: const Text('UNSAVE'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Perform some action
                        },
                        child: const Text('DELETE'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.arrow_drop_down_circle),
                    title: const Text('Dummy Location 2'),
                    subtitle: Text(
                      '',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  Image.asset('assets/images/guris.png'),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Dummy Text Greyhound divisively hello coldly wonderfully marginally far upon excluding.',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Perform some action
                        },
                        child: const Text('UNSAVE'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Perform some action
                        },
                        child: const Text('DELETE'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
