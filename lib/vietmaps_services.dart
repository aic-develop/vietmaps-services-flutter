import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class VietmapsServices {
  static const MethodChannel _channel =
      const MethodChannel('vietmaps_services');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> searchPlace(Map<String, dynamic> queries) async {
    final String rs = await _channel.invokeMethod('searchPlace', queries);
    return rs;
  }

  static Future<String> getLocationInfo(Map<String, dynamic> queries) async {
    final String rs = await _channel.invokeMethod('getLocationInfo', queries);
    return rs;
  }
}
