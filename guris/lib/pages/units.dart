import 'package:flutter/material.dart';

class UnitsPage extends StatelessWidget {
  const UnitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Units')),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              child: Icon(Icons.person, size: 24, color: Colors.blueAccent),
              padding: const EdgeInsets.all(12),
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12))),
              child: Text("Tester"),
              padding: const EdgeInsets.all(12),
            ),
             Container(
              child: Icon(Icons.person, size: 24, color: Colors.blueAccent),
              padding: const EdgeInsets.all(12),
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12))),
              child: Text("Worker"),
              padding: const EdgeInsets.all(12),
            ),
             Container(
              child: Icon(Icons.person, size: 24, color: Colors.blueAccent),
              padding: const EdgeInsets.all(12),
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12))),
              child: Text("Manager"),
              padding: const EdgeInsets.all(12),
            )
          ],
        ),
      ),
    );
  }
}
