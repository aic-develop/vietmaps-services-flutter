import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietmaps_services/vietmaps_services.dart';

void main() {
  const MethodChannel channel = MethodChannel('vietmaps_services');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await VietmapsServices.platformVersion, '42');
  });
}
