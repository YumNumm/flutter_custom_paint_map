import 'package:flutter/material.dart';
import 'package:flutter_custom_paint_map/model/map_polygon.dart';
import 'package:flutter_custom_paint_map/provider/map_area_forecast_local_e.dart';
import 'package:flutter_custom_paint_map/ui/basemap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<MapPolygon> mapAreaForecastLocalE =
      await loadMapAreaForecastLocalE();

  runApp(
    ProviderScope(
      overrides: [
        mapAreaForecastLocalEProvider.overrideWithValue(mapAreaForecastLocalE),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapTest',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MapTest'),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          //onScaleUpdate: (details) {
          //  ref.read(zoomLevelStateProvider.notifier).state = details.scale;
          //},
          onPanUpdate: (details) {
            ref.read(offsetStateProvider.notifier).state =
                ref.read(offsetStateProvider) + details.delta;
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: const BaseMapWidget(),
          ),
        ),
      ),
    );
  }
}
