#import "VietmapsServicesPlugin.h"

@interface VietmapsServicesPlugin()

@property(nonatomic, strong) MBGeocoder *geocoder;

@end

@implementation VietmapsServicesPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"vietmaps_services"
            binaryMessenger:[registrar messenger]];
  VietmapsServicesPlugin* instance = [[VietmapsServicesPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}
- (void) checkCreateServiceWithToken:(NSString *) token {
    if (_geocoder == nil) {
        _geocoder = [[MBGeocoder alloc] initWithAccessToken:token];
    }
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }
  else if ([@"getLocationInfo" isEqualToString:call.method]) {
      NSDictionary *params = call.arguments;
      if (params && params[@"access_token"] && params[@"query"]) {
          NSString *token = params[@"access_token"];
          [self checkCreateServiceWithToken:token];
          NSArray *latLong = params[@"query"];
          NSNumber *latNb = latLong[0];
          NSNumber *longNb = latLong[1];
          CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latNb.doubleValue, longNb.doubleValue);
          MBReverseGeocodeOptions *reverseOption = [[MBReverseGeocodeOptions alloc] initWithCoordinate:coordinate];
          [_geocoder getInfoLocation:reverseOption completionHandler:^(NSDictionary<NSString *,id> * _Nullable response, NSError * _Nullable error) {
              if (error) {
                  result(nil);
              }
              else {
                  result([self convertDicToString:response]);
              }
          }];
      }
      else {
          result(nil);
      }
  }
  else if ([@"searchPlace" isEqualToString:call.method]) {
      NSDictionary *params = call.arguments;
      if (params && params[@"access_token"]) {
          NSString *token = params[@"access_token"];
          [self checkCreateServiceWithToken:token];
          
          NSString *query = params[@"query"];
          MBForwardGeocodeOptions *forwardOption = [[MBForwardGeocodeOptions alloc] initWithQuery:query];
          
          NSArray *boundingBox = params[@"bounding_box"];
          if (boundingBox) {
              CLLocationCoordinate2D southWestCoor;
              CLLocationCoordinate2D northEastCoor;
              {
                  NSArray *southWest = boundingBox[0];
                  NSNumber *south = southWest[0];
                  NSNumber *west = southWest[1];
                  southWestCoor = CLLocationCoordinate2DMake(south.doubleValue, west.doubleValue);
              }
              {
                  NSArray *northEast = boundingBox[1];
                  NSNumber *north = northEast[0];
                  NSNumber *east = northEast[1];
                  northEastCoor = CLLocationCoordinate2DMake(north.doubleValue, east.doubleValue);
              }
              MBRectangularRegion *rectRegion = [[MBRectangularRegion alloc] initWithSouthWest:southWestCoor northEast:northEastCoor];
              forwardOption.allowedRegion = rectRegion;
          }
          NSArray *proximity = params[@"proximity"];
          if (proximity) {
              NSNumber *latNb = proximity[0];
              NSNumber *longNb = proximity[1];
              CLLocation *focalLocation = [[CLLocation alloc] initWithLatitude:latNb.doubleValue longitude:longNb.doubleValue];
              forwardOption.focalLocation = focalLocation;
          }
          [_geocoder geocodeWithOptions:forwardOption jsonCompletionHandler:^(NSDictionary<NSString *,id> * _Nullable response, NSError * _Nullable error) {
              if (error) {
                  result(nil);
              }
              else {
                  result([self convertDicToString:response]);
              }
          }];
      }
      else {
          result(nil);
      }
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}
- (NSString *) convertDicToString:(NSDictionary *) dic {
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    return myString;
}
@end
