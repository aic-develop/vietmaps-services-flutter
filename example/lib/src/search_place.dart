import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:vietmaps_services/vietmaps_services.dart';
import 'package:vietmaps_services_example/src/page.dart';

import '../main.dart';

class SearchPlacePage extends ExamplePage {
  SearchPlacePage() : super(const Icon(Icons.search), 'Search place');

  @override
  Widget build(BuildContext context) {
    return SearchPlaceBody();
  }
}

class SearchPlaceBody extends StatefulWidget {
  SearchPlaceBody();

  @override
  State<StatefulWidget> createState() {
    return _SearchPlaceBodyState();
  }
}

class _SearchPlaceBodyState extends State<SearchPlaceBody> {
  final textEditingController =
      TextEditingController(text: 'đường ngô quyền');

  final lngController = TextEditingController(text: '106.342640');
  final latController = TextEditingController(text: '20.938797');

  final westController = TextEditingController(text: '106.564077');
  final southController = TextEditingController(text: '20.661891');
  final eastController = TextEditingController(text: '106.130391');
  final northController = TextEditingController(text: '21.247567');

  Map<String, dynamic> _result = {"message": "empty result"};

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    textEditingController.dispose();
    lngController.dispose();
    latController.dispose();
    westController.dispose();
    southController.dispose();
    eastController.dispose();
    northController.dispose();
    super.dispose();
  }

  Future<void> _searchPlace(BuildContext context) async {
    String input = textEditingController.text;
    double lng = double.tryParse(lngController.text);
    double lat = double.tryParse(latController.text);

    double west = double.tryParse(westController.text);
    double south = double.tryParse(southController.text);
    double east = double.tryParse(eastController.text);
    double north = double.tryParse(northController.text);

    if (input.isEmpty) {
      Util.showMessage(context, "Empty input");
      return;
    }

    if (lng == null || lat == null) {
      Util.showMessage(context, "Invalid proximity");
      return;
    }

    if (west == null || south == null || east == null || north == null) {
      Util.showMessage(context, "Invalid bounding box");
      return;
    }

    try {
      setState(() {
        _result = {"message": "searching..."};
      });
      String rs = await VietmapsServices.searchPlace(<String, dynamic>{
        'access_token': MapsDemo.ACCESS_TOKEN,
        'query': input,
        'proximity': new LatLng(lat, lng).toJson(),
        'bounding_box': new LatLngBounds(
                southwest: new LatLng(south, west),
                northeast: new LatLng(north, east))
            .toList()
      });
      if (rs != null) {
        setState(() {
          _result = jsonDecode(rs);
        });
      } else {
        setState(() {
          _result = {"message": "request failed"};
        });
      }
    } on PlatformException {
      Util.showMessage(context, "Platform not found");
    } on MissingPluginException {
      Util.showMessage(context, "Missing plugin");
    } on Exception {
      Util.showMessage(context, "Request error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
            builder: (context) => new GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 12,
                          ),
                          TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Address',
                                isDense: true,
                                contentPadding: EdgeInsets.all(12)),
                            controller: textEditingController,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text('Proximity'),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Lng",
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(12)),
                                  controller: lngController,
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Lat",
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(12)),
                                  controller: latController,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text('Bounding box'),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "West",
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(12)),
                                  controller: westController,
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "South",
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(12)),
                                  controller: southController,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "East",
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(12)),
                                  controller: eastController,
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "North",
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(12)),
                                  controller: northController,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          RaisedButton(
                            child: Text('Search place',
                                style: TextStyle(fontSize: 20)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.5, horizontal: 36.0),
                            onPressed: () => _searchPlace(context),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          JsonViewerWidget(_result),
                        ],
                      ),
                    ),
                  ),
                )),
      ),
    );
  }
}
