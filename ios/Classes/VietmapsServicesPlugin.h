#import <Flutter/Flutter.h>
@import MapboxGeocoder;

@interface MBRectangularRegion : CLRegion
@property (nonatomic) CLLocationCoordinate2D southWest;
@property (nonatomic) CLLocationCoordinate2D northEast;

- (nonnull instancetype)initWithSouthWest:(CLLocationCoordinate2D)southWest northEast:(CLLocationCoordinate2D)northEast;
@end

@interface MBGeocodeOptions : NSObject
@property (nonatomic, strong) CLLocation * _Nullable focalLocation;
@property (nonatomic, strong) MBRectangularRegion * _Nullable allowedRegion;
@end

@interface MBReverseGeocodeOptions : MBGeocodeOptions
- (nonnull instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
@end

@interface MBForwardGeocodeOptions : MBGeocodeOptions
- (nonnull instancetype)initWithQuery:(NSString * _Nonnull)query;
@end


@interface MBGeocoder : NSObject
- (nonnull instancetype)initWithAccessToken:(NSString * _Nullable)accessToken;

- (NSURLSessionDataTask * _Nonnull)getInfoLocation:(MBReverseGeocodeOptions * _Nonnull)options completionHandler:(void (^ _Nonnull)(NSDictionary<NSString *, id> * _Nullable, NSError * _Nullable))completionHandler;

- (NSURLSessionDataTask * _Nonnull)geocodeWithOptions:(MBGeocodeOptions * _Nonnull)options jsonCompletionHandler:(void (^ _Nonnull)(NSDictionary<NSString *, id> * _Nullable, NSError * _Nullable))completionHandler;

@end

@interface VietmapsServicesPlugin : NSObject<FlutterPlugin>
@end
