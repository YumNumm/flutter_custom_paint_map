import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;

@immutable
class MapPolygon {
  const MapPolygon({
    required this.code,
    required this.name,
    required this.path,
    required this.points,
    required this.latLngs,
  });

  final int code;
  final String name;
  final Path path;
  final List<Offset> points;
  final List<LatLng> latLngs;
}
