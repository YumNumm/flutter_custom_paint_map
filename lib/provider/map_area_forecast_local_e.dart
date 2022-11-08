import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_paint_map/model/map_polygon.dart';
import 'package:flutter_custom_paint_map/utils/map_global_offset.dart';
import 'package:geojson/geojson.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;

/// 地震情報／細分区域
final mapAreaForecastLocalEProvider = Provider<List<MapPolygon>>((ref) {
  throw UnimplementedError();
});

Future<List<MapPolygon>> loadMapAreaForecastLocalE() async {
  final stopwatch = Stopwatch()..start();
  final geo = GeoJson();

  final mapPaths = <MapPolygon>[];

  geo.processedFeatures.listen((feature) {
    if (feature.type == GeoJsonFeatureType.multipolygon) {
      final geometry = feature.geometry as GeoJsonMultiPolygon;
      for (final polygon in geometry.polygons) {
        for (final geoSeries in polygon.geoSeries) {
          if (feature.properties!['code'] == null) {
            continue;
          }
          final tmpPoints = <Offset>[];
          final tmpLatLngs = <LatLng>[];
          for (final geoPoint in geoSeries.geoPoints) {
            final offset = MapGlobalOffset.latLonToGlobalPoint(geoPoint.point)
                .toLocalOffset(const Size(476, 927.4));
            tmpPoints.add(offset);
            tmpLatLngs.add(geoPoint.point);
          }
          mapPaths.add(
            MapPolygon(
              code: int.parse(feature.properties!['code'].toString()),
              name: feature.properties!['name'].toString(),
              path: Path()..addPolygon(tmpPoints, true),
              points: tmpPoints,
              latLngs: tmpLatLngs,
            ),
          );
        }
      }
    } else if (feature.type == GeoJsonFeatureType.polygon) {
      final geometry = feature.geometry as GeoJsonPolygon;
      for (final geoSeries in geometry.geoSeries) {
        if (feature.properties!['code'] == null) {
          continue;
        }
        final tmpPoints = <Offset>[];
        final tmpLatLngs = <LatLng>[];
        for (final geoPoint in geoSeries.geoPoints) {
          final offset = MapGlobalOffset.latLonToGlobalPoint(geoPoint.point)
              .toLocalOffset(const Size(476, 927.4));
          tmpPoints.add(offset);
          tmpLatLngs.add(geoPoint.point);
        }
        mapPaths.add(
          MapPolygon(
            code: int.parse(feature.properties!['code'].toString()),
            name: feature.properties!['name'].toString(),
            path: Path()..addPolygon(tmpPoints, true),
            points: tmpPoints,
            latLngs: tmpLatLngs,
          ),
        );
      }
    }
  });
  geo.endSignal.listen((_) {
    stopwatch.stop();
    log(
      'mapAreaForecastLocalEを読み込みました: '
      '${stopwatch.elapsedMicroseconds / 1000}ms',
    );
  });
  await geo.parse(
    utf8.decode(
      (await rootBundle.load('assets/maps/AreaForecastLocalE.json'))
          .buffer
          .asUint8List(),
    ),
  );
  return mapPaths;
}
