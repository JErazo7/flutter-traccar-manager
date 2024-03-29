import 'dart:async';

import 'package:device/device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluxmap/fluxmap.dart';
import 'package:geopoint/geopoint.dart';
import 'package:map_controller/map_controller.dart';
import 'package:pedantic/pedantic.dart';
import 'package:traccar_manager/src/traccar/client.dart';

import 'marker.dart';

/// The map controller
class LiveMapController extends StatefulMapController {
  /// Provide a [MapController]
  LiveMapController({
    @required this.mapController,
    this.positionStreamEnabled = true,
    this.updateTimeInterval = 3000,
    this.updateDistanceFilter,
    this.autoRotate = false,
    this.autoCenter = false,
    this.liveMarkerBuilder,
    this.verbose = false,
  })  : assert(mapController != null),
        super(mapController: mapController, verbose: verbose) {
    print("init map controller");
    initTraccar();
    // marker builder
    liveMarkerBuilder ??= defaultLiveMarkerBuilder;
    // state
    flux = FluxMapState(map: this, markerBuilder: _buildFluxMarker);
    devicesFlux = StreamController<Device>.broadcast();
    // subscribe to position stream
    if (positionStreamEnabled) {
      if (verbose) {
        print("Subscribe to position stream");
      }
      _subscribeToPositionStream();
    }
  }

  /// The Flutter Map [MapController]
  @override
  MapController mapController;

  /// Verbosity
  @override
  bool verbose;

  //tracar client
  var _trac;
  var _positions;

  /// Enable or not the position stream
  bool positionStreamEnabled;

  /// Autorotate the map from location brearing
  bool autoRotate;

  /// Autocenter state
  bool autoCenter;

  /// The time interval to update locations from.
  ///
  /// in milliseconds
  int updateTimeInterval;

  /// The distance filter to update locations from.
  ///
  /// in meters
  int updateDistanceFilter;

  /// The live marker builder
  FluxMarkerBuilder liveMarkerBuilder;

  GeoPoint _currentPosition;

  /// The map state
  FluxMapState flux;

  /// The positions updates flux
  StreamController<Device> devicesFlux;


  StreamSubscription<GeoPoint> _geoPointStreamSubscription;

  /// The stream of [GeoPoint] updates
  Stream<GeoPoint> get positionStream => _positions.geoPointStream;

  /// The current position
  GeoPoint get position => _currentPosition;

  /// Enable or disable autocenter
  Future<void> toggleAutoCenter() async {
    autoCenter = !autoCenter;
    if (autoCenter) {
      unawaited(centerOnLiveMarker());
    }
    //print("TOGGLE AUTOCENTER TO $autoCenter");
    notify("toggleAutoCenter", autoCenter, toggleAutoCenter,
        MapControllerChangeType.center);
  }

  /// Center the map on the live marker
  Future<void> centerOnLiveMarker() async {
    mapController.move(_currentPosition.toLatLng(), mapController.zoom);
  }

  /// Init traccar with url and token
  Future<void> initTraccar() async {
    _trac = Traccar(
        serverUrl: '167.172.155.28',
        userToken: 'Rh9wKOaPKV8toPWFeWRd4yd6sbyJkY8p');
    unawaited(_trac.init());
    await _trac.onReady;   
  }

  /// Toggle live position stream updates
  void togglePositionStreamSubscription() {
    positionStreamEnabled = !positionStreamEnabled;
    //print("TOGGLE POSITION STREAM TO $positionStreamEnabled");
    if (!positionStreamEnabled) {
      _geoPointStreamSubscription.cancel();
    } else {
      _subscribeToPositionStream();
    }
    notify(
        "positionStream",
        positionStreamEnabled,
        togglePositionStreamSubscription,
        MapControllerChangeType.positionStream);
  }

  /// Dispose the position stream subscription
  void dispose() {
    if (_geoPointStreamSubscription != null) {
      _geoPointStreamSubscription.cancel();
      devicesFlux.close();
    }
  }

  void _subscribeToPositionStream() async{
    _positions = await _trac.positions();
    _geoPointStreamSubscription = _positions.listen(_positionStreamCallbackAction);
  }

  void _positionStreamCallbackAction(GeoPoint geoPoint) {
    
    if (verbose) {
      print("Position update $geoPoint");
    }
    final device = Device(name: "0", id: 0, position: geoPoint);
    devicesFlux.add(device);
    // the marker might not be here yet if it is the first update
    if (namedMarkers.isNotEmpty) {
      if (autoCenter) {
        fitMarker("0");
      }
      if (autoRotate) {
        if (geoPoint.heading != 0) {
          mapController.rotate(geoPoint.heading);
        }
      }
    }
    _currentPosition = geoPoint;
    notify("currentPosition", geoPoint.toLatLng(),
        _positionStreamCallbackAction, MapControllerChangeType.markers);
  }

  Marker _buildFluxMarker(Device device) => liveMarkerBuilder(device);
}
