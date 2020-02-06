import 'package:flutter/material.dart';
import 'package:fluxmap/fluxmap.dart';
import 'package:latlong/latlong.dart';

import 'controller.dart';

class _LiveMapState extends State<LiveMap> {
  _LiveMapState({@required this.controller, this.center, this.zoom = 2.0})
      : assert(controller != null) {
    center ??= LatLng(0.0, 0.0);
  }

  LiveMapController controller;
  LatLng center;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    return FluxMap(
      state: controller.flux,
      devicesFlux: controller.devicesFlux.stream,
      networkStatusLoop: false,
      center: center,
      zoom: zoom,
    );
  }
}

/// The main livemap class
class LiveMap extends StatefulWidget {
  /// Provide a controller
  const LiveMap({@required this.controller, this.center, this.zoom = 2.0});

  /// The map controller
  final LiveMapController controller;

  /// The default center
  final LatLng center;

  /// The default zoom
  final double zoom;

  @override
  _LiveMapState createState() =>
      _LiveMapState(controller: controller, center: center, zoom: zoom);
}
