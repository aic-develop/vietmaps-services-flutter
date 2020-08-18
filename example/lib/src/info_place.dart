import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:vietmaps_services/vietmaps_services.dart';
import 'package:vietmaps_services_example/src/page.dart';

import '../main.dart';

class InfoPlacePage extends ExamplePage {
  InfoPlacePage() : super(const Icon(Icons.place), 'Info place');

  @override
  Widget build(BuildContext context) {
    return InfoPlaceBody();
  }
}

class InfoPlaceBody extends StatefulWidget {
  InfoPlaceBody();

  @override
  State<StatefulWidget> createState() {
    return _InfoPlaceBodyState();
  }
}

class _InfoPlaceBodyState extends State<InfoPlaceBody> {
  final lngController = TextEditingController(text: '105.803067');
  final latController = TextEditingController(text: '21.023784');

  Map<String, dynamic> _result = {"message": "empty result"};

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    lngController.dispose();
    latController.dispose();
    super.dispose();
  }

  Future<void> _getLocationInfo(BuildContext context) async {
    double lng = double.tryParse(lngController.text);
    double lat = double.tryParse(latController.text);

    if (lng == null || lat == null) {
      Util.showMessage(context, "Invalid query");
      return;
    }

    try {
      setState(() {
        _result = {"message": "searching..."};
      });
      String rs = await VietmapsServices.getLocationInfo(<String, dynamic>{
        'access_token': MapsDemo.ACCESS_TOKEN,
        'query': new LatLng(lat, lng).toJson(),
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
                          SizedBox(
                            height: 12,
                          ),
                          RaisedButton(
                            child: Text('Get Info',
                                style: TextStyle(fontSize: 20)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.5, horizontal: 36.0),
                            onPressed: () => _getLocationInfo(context),
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
