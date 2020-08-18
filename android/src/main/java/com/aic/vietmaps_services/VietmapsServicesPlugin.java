package com.aic.vietmaps_services;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.JsonObject;
import com.mapbox.api.geocoding.v5.MapboxGeocoding;
import com.mapbox.geojson.BoundingBox;
import com.mapbox.geojson.Point;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import retrofit2.Response;

/**
 * VietmapsServicesPlugin
 */
public class VietmapsServicesPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private ExecutorService executorService = Executors.newSingleThreadExecutor();
  private Handler uiThreadHandler = new Handler(Looper.getMainLooper());

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "vietmaps_services");
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "vietmaps_services");
    channel.setMethodCallHandler(new VietmapsServicesPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "searchPlace":
        executorService.execute(() -> {
          String accessToken = call.argument("access_token");
          String query = call.argument("query");

          Point proximity = null;
          if (call.hasArgument("proximity")) {
            List<Double> latlng = call.argument("proximity");
            if (latlng != null && latlng.size() > 1) {
              proximity = Point.fromLngLat(latlng.get(1), latlng.get(0));
            }
          }

          BoundingBox boundingBox = null;
          if (call.hasArgument("bounding_box")) {
            List<List<Double>> params = call.argument("bounding_box");
            if (params != null && params.size() > 1) {
              List<Double> southWest = params.get(0);
              List<Double> northEast = params.get(1);
              if (southWest.size() > 1 && northEast.size() > 1) {
                Point p1 = Point.fromLngLat(southWest.get(1), southWest.get(0));
                Point p2 = Point.fromLngLat(northEast.get(1), northEast.get(0));
                boundingBox = BoundingBox.fromPoints(p1, p2);
              }
            }
          }

          String rs = searchPlace(accessToken, query, proximity, boundingBox);
          uiThreadHandler.post(() -> result.success(rs));
        });
        break;
      case "getLocationInfo":
        executorService.execute(() -> {
          String accessToken = call.argument("access_token");

          Point query = null;
          if (call.hasArgument("query")) {
            List<Double> latlng = call.argument("query");
            if (latlng != null && latlng.size() > 1) {
              query = Point.fromLngLat(latlng.get(1), latlng.get(0));
            }
          }

          String rs = getLocationInfo(accessToken, query);
          uiThreadHandler.post(() -> result.success(rs));
        });
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private String searchPlace(String accessToken,
                             String query,
                             @Nullable Point proximity,
                             @Nullable BoundingBox boundingBox) {

    MapboxGeocoding.Builder builder = MapboxGeocoding.builder()
            .accessToken(accessToken)
            .query(query);

    if (proximity != null) {
      builder.proximity(proximity);
    }

    if (boundingBox != null) {
      builder.bbox(boundingBox);
    }

    return requestAPI(builder.build());
  }

  private String getLocationInfo(String accessToken, Point query) {
    MapboxGeocoding.Builder builder = MapboxGeocoding.builder()
            .accessToken(accessToken)
            .query(query);
    return requestAPI(builder.build());
  }

  private String requestAPI(MapboxGeocoding geocoding) {
    try {
      Response<JsonObject> res = geocoding.executeCall();

      if (res.isSuccessful() && res.body() != null) {
        return res.body().toString();
      } else {
        return null;
      }

    } catch (IOException e) {
      e.printStackTrace();
      return null;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
