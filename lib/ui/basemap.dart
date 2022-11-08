import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_paint_map/model/map_polygon.dart';
import 'package:flutter_custom_paint_map/provider/map_area_forecast_local_e.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// zoomLevelStateProvider double
final zoomLevelStateProvider = StateProvider<double>((ref) => 1.0);

// offsetStateProvider Offset
final offsetStateProvider = StateProvider<Offset>((ref) => Offset.zero);

/// 日本地図
class BaseMapWidget extends ConsumerWidget {
  const BaseMapWidget({this.isFilled = true, super.key});
  final bool isFilled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapSource = ref.watch(mapAreaForecastLocalEProvider);
    final zoomLevel = ref.watch(zoomLevelStateProvider);
    final offset = ref.watch(offsetStateProvider);

    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        painter: MapBasePainter(
          mapPolygons: mapSource,
          zoomLevel: zoomLevel,
          offset: offset,
        ),
        size: const Size(476, 927.4),
      ),
    );
  }
}

// Debug
int drawCount = 0;
double totalMs = 0.0;

/// 日本地図の描画
class MapBasePainter extends CustomPainter {
  MapBasePainter({
    required this.mapPolygons,
    required this.zoomLevel,
    required this.offset,
    this.isFilled = true,
  });
  final List<MapPolygon> mapPolygons;
  final bool isFilled;
  final double zoomLevel;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    final stopWatch = Stopwatch()..start();
    final paintBuilding = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final paintOutline = Paint()
      ..color = const Color.fromARGB(255, 50, 50, 50)
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.2;

    for (final polygon in mapPolygons) {
      if (isFilled) {
        canvas.drawPath(
          Path()..addPath(polygon.path, offset),
          paintBuilding,
        );
      }
      canvas.drawPath(
        Path()..addPath(polygon.path, offset),
        paintOutline,
      );
    }

    log('BaseMap Paint took ${stopWatch.elapsedMicroseconds / 1000} ms');
    drawCount++;
    totalMs += stopWatch.elapsedMicroseconds / 1000;
    TextPainter(
      text: TextSpan(
        text: '${kDebugMode ? 'Debug' : 'Release'} Mode\n'
            'BaseMap(Layer1) Paint ${(totalMs / drawCount).toStringAsFixed(2)} ms (count $drawCount)',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, const Offset(0, 0));
  }

  @override
  bool shouldRepaint(MapBasePainter oldDelegate) {
    return oldDelegate.mapPolygons != mapPolygons ||
        oldDelegate.isFilled != isFilled ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.offset != offset;
  }
}
