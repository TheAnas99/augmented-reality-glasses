import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather/weather.dart';

import 'package:smart_glasses/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_glasses/guimap.dart';

var url = "http://www.mapquestapi.com/directions/v2/route";
var key = "ivvTktSW08yUuYd7TebZLeVB64ufAIZT"; // MapQuest API Key
List maneuvers = ['Start'];

Future<Map<String, dynamic>> getDirs(String from, String to) async {
  // Returns the Directions to the location "to" in JSON form
  var url =
      "http://www.mapquestapi.com/directions/v2/route?key=${key}&from=${from}&to=${to}";
  final response = await http.get(Uri.parse(url));
  final Map<String, dynamic> data = json.decode(response.body);
  return data;
}

ListView buildDirs(List<dynamic> dirs) {
  // Iterates through the Directions JSON to build a ListView widget for display
  List<Widget> tiles = new List<Widget>();
  for (var entry in dirs) {
    tiles.add(
      ListTile(
        title: Text(entry.toString()),
      ),
    );
  }
  return ListView(
    padding: const EdgeInsets.all(8),
    children: <Widget>[
      ...tiles,
    ],
  );
}

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Navigate"),
          centerTitle: true,
          backgroundColor: Colors.purple[900],
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.map_sharp,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GuiMap()),
                );
              },
            )
          ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Where do you want to go?',
                  ),
                  controller: controller,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: FloatingActionButton.extended(
                      onPressed: () async {
                        setState(() async {
                          Position currLoc = await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high);
                          String from =
                              currLoc.latitude.toString()+','+currLoc.longitude.toString() ;
                          print(from);
                          print(currLoc.latitude);
                          print(currLoc.longitude);

                          List<Placemark> placemarks = await placemarkFromCoordinates(currLoc.latitude, currLoc.longitude);
                          String to = controller.text;

                          Placemark pl =new Placemark();
                          Placemark ps =new Placemark();
                          pl=placemarks[0];
                          ps=placemarks[1];
                          print(pl.locality);
                          print(ps.name);
                          sendString(ps.name.toString());
                          String key = '34a42ada46a65fb1a01dd223cd1199ab';
                          WeatherFactory wf = WeatherFactory(key);
                          Weather w = await wf.currentWeatherByLocation(currLoc.latitude, currLoc.longitude);
                          print(w);
                          sendString(w.toString());
                          maneuvers = (await getDirs(from, to))['route']['legs']
                              [0]['maneuvers'];
                        });
                      },
                      label: Text('GO'),
                      icon: Icon(Icons.send)
                  ),
                ),
                //Container(height: 400, child: Directions())
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Directions extends StatefulWidget {
  @override
  DirectionState createState() => DirectionState();
}

class DirectionState extends State<Directions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      itemCount: maneuvers.length,
      itemBuilder: (context, index) {
        String narration = maneuvers[index]['narrative'].toString();
        print(narration);
        String dist = maneuvers[index]['distance'].toString() + " mi";
        return ListTile(
          title: Text(narration),
          subtitle: Text(dist),
        );
      },
    ));
  }
}
