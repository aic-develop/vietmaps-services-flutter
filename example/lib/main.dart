import 'package:flutter/material.dart';
import 'package:vietmaps_services_example/src/info_place.dart';
import 'package:vietmaps_services_example/src/page.dart';
import 'package:vietmaps_services_example/src/search_place.dart';

final List<ExamplePage> _allPages = <ExamplePage>[
  SearchPlacePage(),
  InfoPlacePage(),
];

class MapsDemo extends StatelessWidget {
  //FIXME: Add your Mapbox access token here
  static const String ACCESS_TOKEN = "";

  void _pushPage(BuildContext context, ExamplePage page) async {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              appBar: AppBar(title: Text(page.title)),
              body: page,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vietmaps services examples')),
      body: ListView.builder(
        itemCount: _allPages.length,
        itemBuilder: (_, int index) => ListTile(
          leading: _allPages[index].leading,
          title: Text(_allPages[index].title),
          onTap: () => _pushPage(context, _allPages[index]),
        ),
      ),
    );
  }
}

class Util {
  static showMessage(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}

void main() {
  runApp(MaterialApp(home: MapsDemo()));
}
