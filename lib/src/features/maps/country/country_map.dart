///Flutter package imports
import 'package:flutter/material.dart';

///Core theme import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';

///Map import
import 'package:syncfusion_flutter_maps/maps.dart';

import '../../../sample/model/sample_view.dart';


/// Renders the map widget with bubbles
class MapCountryPage extends SampleView {
  /// Creates the map widget for a statistics
  const MapCountryPage(Key key) : super(key: key);

  @override
  _MapCountryPageState createState() => _MapCountryPageState();
}

class _MapCountryPageState extends SampleViewState
    with TickerProviderStateMixin {
  _MapCountryPageState();

  late MapShapeSource _mapSource;
  late MapShapeSource _casesMapSource;
  late MapShapeSource _casesnormopesoMapSource;
  late MapShapeSource _casesseveraMapSource;
  late MapShapeSource _casesmoderadaMapSource;

  late bool _isLightTheme;

  late Color _shapeColor;
  late Color _shapeStrokeColor;
  late Color _bubbleColor;
  late Color _bubbleStrokeColor;
  late Color _tooltipColor;
  late Color _tooltipStrokeColor;
  late Color _tooltipTextColor;

  late String _currentDelegate;

  BoxDecoration? _casesBoxDecoration;
  BoxDecoration? _casesnormopesoBoxDecoration;
  BoxDecoration? _casesseveraBoxDecoration;
  BoxDecoration? _casesmoderadaBoxDecoration;

  late List<_UserDetails> _casesUsers;
  late List<_UserDetails> _casesnormopesoUsers;
  late List<_UserDetails> _casesmoderadaUsers;
  late List<_UserDetails> _casesseveraUsers;

  late AnimationController _casesController;
  late AnimationController _casesnormopesoController;
  late AnimationController _casesseveraController;
  late AnimationController _casesmoderadaController;

  late Animation<double> _casesAnimation;
  late Animation<double> _casesnormopesoAnimation;
  late Animation<double> _casesseveraAnimation;
  late Animation<double> _casesmoderadaAnimation;

  @override
  void initState() {
    super.initState();

    _isLightTheme = model.themeData.colorScheme.brightness == Brightness.light;

    _casesController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
        lowerBound: 0.6);
    _casesAnimation =
        CurvedAnimation(parent: _casesController, curve: Curves.easeInOut);

    _casesnormopesoController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
        lowerBound: 0.6);
    _casesnormopesoAnimation =
        CurvedAnimation(parent: _casesnormopesoController, curve: Curves.easeInOut);

    _casesseveraController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
        lowerBound: 0.6);
    _casesseveraAnimation =
        CurvedAnimation(parent: _casesseveraController, curve: Curves.easeInOut);

    _casesmoderadaController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
        lowerBound: 0.6);
    _casesmoderadaAnimation =
        CurvedAnimation(parent: _casesmoderadaController, curve: Curves.easeInOut);

    _casesController.forward();

    // Data source to the map.
    //
    // [country]: Field name in the .json file to identify the shape.
    // This is the name to be mapped with shapes in .json file.
    // This should be exactly same as the value of the [shapeDataField]
    // in the .json file
    //
    // [usersCount]: On the basis of this value, color mapping color has been
    // applied to the shape.
    _casesUsers = <_UserDetails>[
      _UserDetails('Guatemala', 280),
      _UserDetails('Mauritania', 280),
    ];

    _casesnormopesoUsers = <_UserDetails>[
      _UserDetails('Guatemala', 260),
      _UserDetails('Mauritania', 260),
    ];


    _casesseveraUsers = <_UserDetails>[
      _UserDetails('Guatemala', 12),
      _UserDetails('Mauritania', 12),
    ];

    _casesmoderadaUsers = <_UserDetails>[
      _UserDetails('Guatemala', 8),
      _UserDetails('Mauritania', 8),
    ];

    _casesMapSource = MapShapeSource.asset(
      // Path of the GeoJSON file.
      'assets/worldmap.json',
      // Field or group name in the .json file to identify the shapes.
      //
      // Which is used to map the respective shape to data source.
      shapeDataField: 'name',
      // The number of data in your data source collection.
      //
      // The callback for the [primaryValueMapper] will be called
      // the number of times equal to the [dataCount].
      // The value returned in the [primaryValueMapper] should be
      // exactly matched with the value of the [shapeDataField]
      // in the .json file. This is how the mapping between the
      // data source and the shapes in the .json file is done.
      dataCount: _casesUsers.length,
      primaryValueMapper: (int index) => _casesUsers[index].country,
      // The value returned from this callback will be used as a factor to
      // calculate the radius of the bubble between the
      // [MapBubbleSettings.minRadius] and [MapBubbleSettings.maxRadius].
      bubbleSizeMapper: (int index) => _casesUsers[index].usersCount,
    );

    _casesnormopesoMapSource = MapShapeSource.asset(
      'assets/worldmap.json',
      shapeDataField: 'name',
      dataCount: _casesnormopesoUsers.length,
      primaryValueMapper: (int index) => _casesnormopesoUsers[index].country,
      bubbleSizeMapper: (int index) => _casesnormopesoUsers[index].usersCount,
    );
    _casesseveraMapSource = MapShapeSource.asset(
      'assets/worldmap.json',
      shapeDataField: 'name',
      dataCount: _casesseveraUsers.length,
      primaryValueMapper: (int index) => _casesseveraUsers[index].country,
      bubbleSizeMapper: (int index) => _casesseveraUsers[index].usersCount,
    );

    _casesmoderadaMapSource = MapShapeSource.asset(
      'assets/worldmap.json',
      shapeDataField: 'name',
      dataCount: _casesmoderadaUsers.length,
      primaryValueMapper: (int index) => _casesmoderadaUsers[index].country,
      bubbleSizeMapper: (int index) => _casesmoderadaUsers[index].usersCount,
    );

    _mapSource = _casesMapSource;
    _currentDelegate = 'Casos';
    _shapeColor = _isLightTheme
        ? const Color.fromRGBO(57, 110, 218, 0.35)
        : const Color.fromRGBO(72, 132, 255, 0.35);
    _shapeStrokeColor = const Color.fromARGB(255, 52, 85, 176).withOpacity(0);
    _bubbleColor = _isLightTheme
        ? const Color.fromRGBO(15, 59, 177, 0.5)
        : const Color.fromRGBO(135, 167, 255, 0.6);
    _bubbleStrokeColor = Colors.white;
    _tooltipColor = _isLightTheme
        ? const Color.fromRGBO(35, 65, 148, 1)
        : const Color.fromRGBO(52, 85, 176, 1);
    _tooltipStrokeColor = Colors.white;
    _tooltipTextColor = Colors.white;
    _casesBoxDecoration = _getBoxDecoration(
        const Color.fromARGB(255, 52, 85, 176)
            .withOpacity(_isLightTheme ? 0.1 : 0.3));
  }

  @override
  void dispose() {
    _casesUsers.clear();
    _casesnormopesoUsers.clear();
    _casesseveraUsers.clear();

    _casesController.dispose();
    _casesnormopesoController.dispose();
    _casesseveraController.dispose();
    _casesmoderadaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool scrollEnabled = constraints.maxHeight > 400;
          double height = scrollEnabled ? constraints.maxHeight : 400;
          if (model.isWebFullView ||
              (model.isMobile &&
                  MediaQuery.of(context).orientation == Orientation.landscape)) {
            final double refHeight = height * 0.6;
            height = height > 500 ? (refHeight < 500 ? 500 : refHeight) : height;
          }
          return Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: constraints.maxWidth,
                height: height,
                child: _buildMapsWidget(scrollEnabled),
              ),
            ),
          );
        });
  }

  Widget _buildMapsWidget(bool scrollEnabled) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: scrollEnabled
              ? EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.05,
              bottom: MediaQuery.of(context).size.height * 0.15,
              right: 10)
              : const EdgeInsets.only(bottom: 75.0, right: 10),
          child: SfMapsTheme(
              data: SfMapsThemeData(
                shapeHoverColor: Colors.transparent,
                shapeHoverStrokeColor: Colors.transparent,
                bubbleHoverColor: _shapeColor,
                bubbleHoverStrokeColor: _bubbleColor,
                bubbleHoverStrokeWidth: 1.5,
              ),
              child: Column(children: <Widget>[
                /*Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 30),
                    child: Align(
                        child: Text('Estadísticas por Países',
                            style: Theme.of(context).textTheme.subtitle1))),*/
                Expanded(
                  child: SfMaps(
                    layers: <MapLayer>[
                      MapShapeLayer(
                        loadingBuilder: (BuildContext context) {
                          return const SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          );
                        },
                        source: _mapSource,
                        color: _shapeColor,
                        strokeWidth: 1,
                        strokeColor: _shapeStrokeColor,
                        // Returns the custom tooltip for each bubble.
                        bubbleTooltipBuilder:
                            (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(_getCustomizedString(index),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(color: _tooltipTextColor)),
                          );
                        },
                        bubbleSettings: MapBubbleSettings(
                            strokeColor: _bubbleStrokeColor,
                            strokeWidth: 0.5,
                            color: _bubbleColor,
                            maxRadius: 40),
                        tooltipSettings: MapTooltipSettings(
                            color: _tooltipColor,
                            strokeColor: _tooltipStrokeColor),
                      ),
                    ],
                  ),
                )
              ])),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: _casesBoxDecoration,
                  child: ScaleTransition(
                    scale: _casesAnimation,
                    child: IconButton(
                      icon: Image.asset('images/maps_cases.png'),
                      iconSize: 50,
                      onPressed: () {
                        setState(() {
                          _mapSource = _casesMapSource;
                          _currentDelegate = 'Casos';
                          _shapeColor = _isLightTheme
                              ? const Color.fromRGBO(57, 110, 218, 0.35)
                              : const Color.fromRGBO(72, 132, 255, 0.35);
                          _shapeStrokeColor =
                              const Color.fromARGB(255, 52, 85, 176)
                                  .withOpacity(0);
                          _bubbleColor = _isLightTheme
                              ? const Color.fromRGBO(15, 59, 177, 0.5)
                              : const Color.fromRGBO(135, 167, 255, 0.6);
                          _tooltipColor = _isLightTheme
                              ? const Color.fromRGBO(35, 65, 148, 1)
                              : const Color.fromRGBO(52, 85, 176, 1);
                          _bubbleStrokeColor = Colors.white;
                          _tooltipStrokeColor = Colors.white;
                          _tooltipTextColor = Colors.white;

                          _casesController.forward();

                          _casesnormopesoController.reverse();
                          _casesmoderadaController.reverse();
                          _casesseveraController.reverse();

                          _casesnormopesoBoxDecoration = null;
                          _casesseveraBoxDecoration = null;
                          _casesmoderadaBoxDecoration = null;

                          _casesBoxDecoration = _getBoxDecoration(
                              const Color.fromARGB(255, 52, 85, 176)
                                  .withOpacity(_isLightTheme ? 0.1 : 0.3));
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: _casesnormopesoBoxDecoration,
                  child: ScaleTransition(
                    scale: _casesnormopesoAnimation,
                    child: IconButton(
                      icon: Image.asset('images/maps_normopeso.png'),
                      iconSize: 50,
                      onPressed: () {
                        setState(() {
                          _mapSource = _casesnormopesoMapSource;
                          _currentDelegate = 'Normopeso';
                          _shapeColor = _isLightTheme
                              ? const Color.fromRGBO(86, 170, 235, 0.35)
                              : const Color.fromRGBO(32, 154, 255, 0.35);
                          _shapeStrokeColor =
                              const Color.fromARGB(255, 0, 122, 202)
                                  .withOpacity(0);
                          _bubbleColor = _isLightTheme
                              ? const Color.fromRGBO(17, 124, 179, 0.5)
                              : const Color.fromRGBO(56, 184, 251, 0.5);
                          _tooltipColor = _isLightTheme
                              ? const Color.fromRGBO(27, 129, 188, 1)
                              : const Color.fromRGBO(65, 154, 207, 1);
                          _bubbleStrokeColor = Colors.white;
                          _tooltipStrokeColor = Colors.white;
                          _tooltipTextColor = Colors.white;

                          _casesnormopesoController.forward();

                          _casesController.reverse();
                          _casesmoderadaController.reverse();
                          _casesseveraController.reverse();

                          _casesBoxDecoration = null;
                          _casesseveraBoxDecoration = null;
                          _casesmoderadaBoxDecoration = null;

                          _casesnormopesoBoxDecoration = _getBoxDecoration(
                              const Color.fromARGB(255, 0, 122, 202)
                                  .withOpacity(_isLightTheme ? 0.1 : 0.3));
                        });
                      },
                    ),
                  ),
                ),

                Container(
                  decoration: _casesmoderadaBoxDecoration,
                  child: ScaleTransition(
                    scale: _casesmoderadaAnimation,
                    child: IconButton(
                      icon: Image.asset('images/maps_moderada.png'),
                      iconSize: 50,
                      onPressed: () {
                        setState(() {
                          _mapSource = _casesmoderadaMapSource;
                          _currentDelegate = 'Moderada';
                          _shapeColor = _isLightTheme
                              ? const Color.fromRGBO(212, 185, 48, 0.35)
                              : const Color.fromRGBO(227, 226, 73, 0.35);
                          _shapeStrokeColor =
                              const Color.fromARGB(255, 255, 126, 0)
                                  .withOpacity(0);
                          _bubbleColor = _isLightTheme
                              ? const Color.fromRGBO(182, 150, 2, 0.5)
                              : const Color.fromRGBO(254, 253, 2, 0.458);
                          _tooltipColor = _isLightTheme
                              ? const Color.fromRGBO(173, 144, 12, 1)
                              : const Color.fromRGBO(225, 225, 30, 1);
                          _bubbleStrokeColor =
                          _isLightTheme ? Colors.black : Colors.white;
                          _tooltipStrokeColor =
                          _isLightTheme ? Colors.black : Colors.white;
                          _tooltipTextColor =
                          _isLightTheme ? Colors.white : Colors.black;

                          _casesmoderadaController.forward();

                          _casesController.reverse();
                          _casesnormopesoController.reverse();
                          _casesseveraController.reverse();

                          _casesBoxDecoration = null;
                          _casesnormopesoBoxDecoration = null;
                          _casesseveraBoxDecoration = null;

                          _casesmoderadaBoxDecoration = _getBoxDecoration(
                              const Color.fromARGB(255, 255, 221, 0)
                                  .withOpacity(_isLightTheme ? 0.2 : 0.3));
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: _casesseveraBoxDecoration,
                  child: ScaleTransition(
                    scale: _casesseveraAnimation,
                    child: IconButton(
                      icon: Image.asset('images/maps_severa.png'),
                      iconSize: 50,
                      onPressed: () {
                        setState(() {
                          _mapSource = _casesseveraMapSource;
                          _currentDelegate = 'Severa';
                          _shapeColor = _isLightTheme
                              ? const Color.fromRGBO(159, 119, 213, 0.35)
                              : const Color.fromRGBO(166, 104, 246, 0.35);
                          _shapeStrokeColor =
                              const Color.fromARGB(255, 238, 46, 73)
                                  .withOpacity(0);
                          _bubbleColor = _isLightTheme
                              ? const Color.fromRGBO(249, 99, 20, 0.5)
                              : const Color.fromRGBO(253, 173, 38, 0.5);
                          _tooltipColor = _isLightTheme
                              ? const Color.fromRGBO(175, 90, 66, 1)
                              : const Color.fromRGBO(202, 130, 8, 1);
                          _bubbleStrokeColor = Colors.white;
                          _tooltipStrokeColor = Colors.white;
                          _tooltipTextColor = Colors.white;

                          _casesseveraController.forward();

                          _casesController.reverse();
                          _casesnormopesoController.reverse();
                          _casesmoderadaController.reverse();

                          _casesBoxDecoration = null;
                          _casesnormopesoBoxDecoration = null;
                          _casesmoderadaBoxDecoration = null;

                          _casesseveraBoxDecoration = _getBoxDecoration(
                              const Color.fromARGB(255, 238, 46, 73)
                                  .withOpacity(_isLightTheme ? 0.1 : 0.3));
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getCustomizedString(int index) {
    switch (_currentDelegate) {
      case 'Casos':
        return _casesUsers[index].country +
            ' : ' +
            _casesUsers[index].usersCount.toStringAsFixed(0) +
            ' casos';
      case 'Normopeso':
        return _casesnormopesoUsers[index].country +
            ' : ' +
            _casesnormopesoUsers[index].usersCount.toStringAsFixed(0) +
            ' casos';
      case 'Severa':
        return _casesseveraUsers[index].country +
            ' : ' +
            _casesseveraUsers[index].usersCount.toStringAsFixed(0) +
            ' casos';
      case 'Moderada':
        return _casesmoderadaUsers[index].country +
            ' : ' +
            _casesmoderadaUsers[index].usersCount.toStringAsFixed(0) +
            ' casos';
      default:
        return '';
    }
  }

  BoxDecoration _getBoxDecoration(Color color) {
    return BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: color,
        )
      ],
    );
  }
}

class _UserDetails {
  _UserDetails(this.country, this.usersCount);

  final String country;
  final double usersCount;
}
