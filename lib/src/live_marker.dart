import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:device/device.dart';
import 'package:latlong/latlong.dart';

import 'controller.dart';
import 'livemap.dart';


class _LivemapMarkerPageState extends State<LivemapMarkerPage> {

  LiveMapController liveMapController;
  IconData markerIcon = Icons.airport_shuttle;
  Icon get _liveMapStatusIcon => _getliveMapStatusIcon();
  StreamSubscription _stateChangeSubscription;

  Marker liveMarkerBuilder(Device device) {
    assert(device != null);
    assert(device.position != null);
    return Marker(
        point: device.position.point,
        builder: (BuildContext c) => Container(
            child: Icon(markerIcon, size: 45.0, color: Colors.orange)));
  }

  @override
  void initState() {
    liveMapController = LiveMapController(
        liveMarkerBuilder: liveMarkerBuilder,
        mapController: MapController(),
        autoCenter: true);
    _stateChangeSubscription =
        liveMapController.changeFeed.listen((stateChange) {
      if (stateChange.name == "positionStream") {
        setState(() {});
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: LiveMap(
            controller: liveMapController,
            center: LatLng(-0.2501894, -79.1638053),
            zoom: 16.0),
        floatingActionButton: FloatingActionButton(
            child: _liveMapStatusIcon,
            onPressed:liveMapController.togglePositionStreamSubscription));
  }

  @override
  void dispose() {
    liveMapController.dispose();
    _stateChangeSubscription.cancel();
    super.dispose();
  }

  Icon _getliveMapStatusIcon() {
    Icon ic;
    liveMapController.positionStreamEnabled
        ? ic = const Icon(Icons.gps_not_fixed)
        : ic = const Icon(Icons.gps_off);
    return ic;
  }
}

class LivemapMarkerPage extends StatefulWidget {
  LivemapMarkerPage();

  @override
  _LivemapMarkerPageState createState() => _LivemapMarkerPageState();
}
