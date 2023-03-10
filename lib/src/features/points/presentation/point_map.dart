/// Flutter package imports
import 'package:adminnut4health/src/features/points/presentation/points_screen_controller.dart';
import 'package:adminnut4health/src/features/users/data/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///Map import
// ignore: import_of_legacy_library_into_null_safe
import 'package:syncfusion_flutter_maps/maps.dart';

import '../../../sample/model/sample_view.dart';


/// Renders the map widget with OSM map.
class MapPointPage extends LocalizationSampleView {
  /// Creates the map widget with OSM map.
  const MapPointPage(Key key) : super(key: key);

  @override
  _TileLayerSampleState createState() => _TileLayerSampleState();
}

class _TileLayerSampleState extends LocalizationSampleViewState {
  late PageController _pageViewController;
  late MapTileLayerController _mapController;

  late MapZoomPanBehavior _zoomPanBehavior;

  late List<_PointDetails> _points;

  late int _currentSelectedIndex;
  late int _previousSelectedIndex;
  late int _tappedMarkerIndex;

  late double _cardHeight;

  late bool _canUpdateFocalLatLng;
  late bool _canUpdateZoomLevel;
  late bool _isDesktop;

  bool init = true;

  @override
  void initState() {
    super.initState();
    _currentSelectedIndex = 5;
    _canUpdateFocalLatLng = true;
    _canUpdateZoomLevel = true;
    _mapController = MapTileLayerController();
    _points = <_PointDetails>[];
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    _mapController.dispose();
    _points.clear();
    super.dispose();
  }

  void _initPoints(AsyncValue pointsAsyncValue) {
    pointsAsyncValue.value?.forEach((element) {
      if (element.active) {
        _points.add(
            _PointDetails(
                place: element.fullName,
                latitude: element.latitude,
                longitude: element.longitude,
                cases: element.cases.toString(),
                casesnormopeso: element.casesnormopeso.toString(),
                casesmoderada: element.casesmoderada.toString(),
                casessevera: element.casessevera.toString(),
            ));
      }
    });
  }

  @override
  Widget buildSample(BuildContext context) {
    return Consumer(

        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            pointsScreenControllerProvider,
                (_, state) =>
            {
            },
          );
          final pointsAsyncValue = ref.watch(pointsStreamProvider);
          if (pointsAsyncValue.value != null) {
            _initPoints(pointsAsyncValue);
            if (init) {
              init = false;
              _zoomPanBehavior = MapZoomPanBehavior(
                minZoomLevel: 3,
                maxZoomLevel: 10,
                focalLatLng: MapLatLng(_points[_currentSelectedIndex].latitude,
                    _points[_currentSelectedIndex].longitude),
                enableDoubleTapZooming: true,
              );
              final ThemeData themeData = Theme.of(context);
              _isDesktop = model.isWebFullView ||
                  themeData.platform == TargetPlatform.macOS ||
                  themeData.platform == TargetPlatform.windows ||
                  themeData.platform == TargetPlatform.linux;
              if (_canUpdateZoomLevel) {
                _zoomPanBehavior.zoomLevel = _isDesktop ? 5 : 4;
                _canUpdateZoomLevel = false;
              }
              _cardHeight = (MediaQuery.of(context).orientation == Orientation.landscape)
                  ? (_isDesktop ? 120 : 90)
                  : 110;
              _pageViewController = PageController(
                  initialPage: _currentSelectedIndex,
                  viewportFraction:
                  (MediaQuery.of(context).orientation == Orientation.landscape)
                      ? (_isDesktop ? 0.5 : 0.7)
                      : 0.8);
            }
              return Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Image.asset(
                      'images/maps_grid.png',
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                  SfMaps(
                    layers: <MapLayer>[
                      MapTileLayer(
                        /// URL to request the tiles from the providers.
                        ///
                        /// The [urlTemplate] accepts the URL in WMTS format i.e. {z} —
                        /// zoom level, {x} and {y} — tile coordinates.
                        ///
                        /// We will replace the {z}, {x}, {y} internally based on the
                        /// current center point and the zoom level.
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        zoomPanBehavior: _zoomPanBehavior,
                        controller: _mapController,
                        initialMarkersCount: _points.length,
                        tooltipSettings: const MapTooltipSettings(
                          color: Colors.transparent,
                        ),
                        markerTooltipBuilder: (BuildContext context, int index) {
                          if (_isDesktop) {
                            return ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, top: 5.0, bottom: 5.0),
                                      width: 150,
                                      color: Colors.white,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Directionality(
                                              textDirection: TextDirection.ltr,
                                              child: Text(
                                                _points[index].place,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ]),
                            );
                          }

                          return const SizedBox();
                        },
                        markerBuilder: (BuildContext context, int index) {
                          final double markerSize =
                          _currentSelectedIndex == index ? 40 : 25;
                          return MapMarker(
                            latitude: _points[index].latitude,
                            longitude: _points[index].longitude,
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              onTap: () {
                                if (_currentSelectedIndex != index) {
                                  _canUpdateFocalLatLng = false;
                                  _tappedMarkerIndex = index;
                                  _pageViewController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: markerSize,
                                width: markerSize,
                                child: FittedBox(
                                  child: Icon(Icons.location_on,
                                      color: _currentSelectedIndex == index
                                          ? Colors.blue
                                          : Colors.red,
                                      size: markerSize),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: _cardHeight,
                      padding: const EdgeInsets.only(bottom: 10),

                      child: PageView.builder(
                        itemCount: _points.length,
                        onPageChanged: _handlePageChange,
                        controller: _pageViewController,
                        itemBuilder: (BuildContext context, int index) {
                          final _PointDetails item = _points[index];
                          return Transform.scale(
                            scale: index == _currentSelectedIndex ? 1 : 0.85,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color:
                                    Theme.of(context).brightness == Brightness.light
                                        ? const Color.fromRGBO(255, 255, 255, 1)
                                        : const Color.fromRGBO(66, 66, 66, 1),
                                    border: Border.all(
                                      color: const Color.fromRGBO(153, 153, 153, 1),
                                      width: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(children: <Widget>[
                                    // Adding title and description for card.
                                    Expanded(
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.only(top: 5.0, right: 5.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Directionality(
                                                textDirection: TextDirection.ltr,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.place),
                                                    Text(item.place,
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16),
                                                        textAlign: TextAlign.center),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Directionality(
                                                textDirection: TextDirection.ltr,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: <Widget>[
                                                    Directionality(
                                                        textDirection: TextDirection.ltr,
                                                        child: Row(
                                                          children: [
                                                            Image.asset('images/maps_cases.png', width: 40, height: 40),
                                                            const SizedBox(width: 5), // Separación entre el icono y el texto
                                                            Text(
                                                              item.cases,
                                                              style:
                                                              TextStyle(
                                                                  fontSize: _isDesktop ? 14 : 11, color: Colors.blueAccent),
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: (index == 2 || index == 6) ? 2 : 4,
                                                            ),
                                                          ],
                                                        )),
                                                    const SizedBox(height: 20),
                                                    Directionality(
                                                      textDirection: TextDirection.ltr,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Image.asset('images/maps_normopeso.png', width: 40, height: 40),
                                                          const SizedBox(width: 5), // Separación entre el icono y el texto
                                                          Text(
                                                            item.casesnormopeso,
                                                            style:
                                                            TextStyle(
                                                                fontSize: _isDesktop ? 14 : 11, color: Colors.green),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: (index == 2 || index == 6) ? 2 : 4,
                                                          ),
                                                        ],
                                                      ),

                                                    ),
                                                    const SizedBox(height: 20),
                                                    Directionality(
                                                      textDirection: TextDirection.ltr,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Image.asset('images/maps_moderada.png', width: 40, height: 40),
                                                          const SizedBox(width: 5), // Separación entre el icono y el texto
                                                          Text(
                                                            item.casesmoderada,
                                                            style:
                                                            TextStyle(
                                                                fontSize: _isDesktop ? 14 : 11, color: Colors.orange),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: (index == 2 || index == 6) ? 2 : 4,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Directionality(
                                                      textDirection: TextDirection.ltr,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Image.asset('images/maps_severa.png', width: 40, height: 40),
                                                          const SizedBox(width: 5), // Separación entre el icono y el texto
                                                          Text(
                                                            item.casessevera,
                                                            style:
                                                            TextStyle(
                                                                fontSize: _isDesktop ? 14 : 11, color: Colors.red),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: (index == 2 || index == 6) ? 2 : 4,
                                                          ),
                                                        ],
                                                      ),

                                                    ),
                                                  ],
                                                ),

                                              ),
                                            ],
                                          ),
                                        )),
                                  ]),
                                ),
                                // Adding splash to card while tapping.
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius:
                                    const BorderRadius.all(Radius.elliptical(10, 10)),
                                    onTap: () {
                                      if (_currentSelectedIndex != index) {
                                        _pageViewController.animateToPage(
                                          index,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );

          } else  {
            return const Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(),
                )
            );
          }

        });
  }

  void _handlePageChange(int index) {
    /// While updating the page viewer through interaction, selected position's
    /// marker should be moved to the center of the maps. However, when the
    /// marker is directly clicked, only the respective card should be moved to
    /// center and the marker itself should not move to the center of the maps.
    if (!_canUpdateFocalLatLng) {
      if (_tappedMarkerIndex == index) {
        _updateSelectedCard(index);
      }
    } else if (_canUpdateFocalLatLng) {
      _updateSelectedCard(index);
    }
  }

  void _updateSelectedCard(int index) {
    setState(() {
      _previousSelectedIndex = _currentSelectedIndex;
      _currentSelectedIndex = index;
    });

    /// While updating the page viewer through interaction, selected position's
    /// marker should be moved to the center of the maps. However, when the
    /// marker is directly clicked, only the respective card should be moved to
    /// center and the marker itself should not move to the center of the maps.
    if (_canUpdateFocalLatLng) {
      _zoomPanBehavior.focalLatLng = MapLatLng(
          _points[_currentSelectedIndex].latitude,
          _points[_currentSelectedIndex].longitude);
    }

    /// Updating the design of the selected marker. Please check the
    /// `markerBuilder` section in the build method to know how this is done.
    _mapController
        .updateMarkers(<int>[_currentSelectedIndex, _previousSelectedIndex]);
    _canUpdateFocalLatLng = true;
  }
}

class _PointDetails {
  const _PointDetails(
      {required this.place,
        required this.latitude,
        required this.longitude,
        required this.cases,
        required this.casesnormopeso,
        required this.casesmoderada,
        required this.casessevera});

  final String place;
  final double latitude;
  final double longitude;
  final String cases;
  final String casesnormopeso;
  final String casesmoderada;
  final String casessevera;
}
