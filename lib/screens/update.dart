import 'package:flutter/material.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Updates'),),
      body: Column(
        children: [
          Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.grey,
                elevation: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.album, size: 60),
                      title: Text(
                          'Live Data',
                          style: TextStyle(fontSize: 30.0)
                      ),
                      subtitle: Text(
                          'Whats happening today on your route',
                          style: TextStyle(fontSize: 18.0)
                      ),
                    ),
                    ButtonBar(
                      children: [
                       ElevatedButton(
                          child: const Text('Provide Update'),
                          onPressed: () {/* ... */},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.grey,
                elevation: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.album, size: 60),
                      title: Text(
                          'Route History',
                          style: TextStyle(fontSize: 30.0)
                      ),
                      subtitle: Text(
                          'What do you know about this route',
                          style: TextStyle(fontSize: 18.0)
                      ),
                    ),
                    ButtonBar(
                      children: [
                        ElevatedButton(
                          child: const Text('Provide History'),
                          onPressed: () {/* ... */},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.grey,
                elevation: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.album, size: 60),
                      title: Text(
                          'Report Fatalities',
                          style: TextStyle(fontSize: 30.0)
                      ),
                      subtitle: Text(
                          'Has there been any fatalities on the route',
                          style: TextStyle(fontSize: 18.0)
                      ),
                    ),
                    ButtonBar(
                      children: [
                        ElevatedButton(
                          child: const Text('Report Fatality'),
                          onPressed: () {/* ... */},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
