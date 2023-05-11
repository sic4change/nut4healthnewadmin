///Dart import
// ignore_for_file: depend_on_referenced_packages

import 'dart:math';

///Package imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

///Chart import
import 'package:syncfusion_flutter_charts/charts.dart' hide LabelPlacement;

///Core import
import 'package:syncfusion_flutter_core/core.dart';

///Core theme import
import 'package:syncfusion_flutter_core/theme.dart';

///Slider import
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../sample/model/sample_view.dart';
import '../data/firestore_repository.dart';
import '../../points/domain/point.dart';
import '../domain/contract.dart';
import '../domain/contract_point_stadistic.dart';
import 'contracts_screen_controller.dart';


/// Renders the range selector with line chart zooming option
class StatisticContractsByPointAndMuacPage extends SampleView {
  /// Renders the range selector with line chart zooming option
  const StatisticContractsByPointAndMuacPage(Key key) : super(key: key);

  @override
  _StatisticContractsByPointAndMuacPageState createState() =>
      _StatisticContractsByPointAndMuacPageState();
}

class _StatisticContractsByPointAndMuacPageState extends SampleViewState
    with SingleTickerProviderStateMixin {
  _StatisticContractsByPointAndMuacPageState();

  List<Point> points = <Point>[];
  Point pointSelected = const Point(pointId: '', name: '', fullName: '', country: '',
      province: '', phoneCode: '', phoneLength: 0, active: false, latitude: 0.0, longitude: 0.0,
      cases: 0, casesnormopeso: 0, casesmoderada: 0, casessevera: 0);


  bool enableDeferredUpdate = true;

  var currentUserRole = "";

  /// Selected locale
  late String selectedLocale;

  List<String>? _plotBandType;
  late bool isHorizontal;
  late bool isVertical;
  late bool isSegment;
  late bool isLine;
  TooltipBehavior? _tooltipBehavior;
  late String _selectedType;

  _savePoints(AsyncValue<List<Point>>? points) {
    if (points == null) {
      return;
    } else {
      this.points = points.value!;
      if (pointSelected.pointId.isEmpty) {
        pointSelected = this.points[0];
      }
    }
  }

  _saveContracts(AsyncValue<List<Contract?>> contracts) {

  }


  @override
  void initState() {
    super.initState();
    selectedLocale = model.locale.toString();
    _plotBandType =
        <String>['vertical', 'horizontal', 'segment', 'line'].toList();
    _selectedType = _plotBandType!.first;
    isHorizontal = true;
    isVertical = false;
    isSegment = false;
    isLine = false;
    _tooltipBehavior =
        TooltipBehavior(enable: true, canShowMarker: false, header: '');
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }


  /// Return the types of plotbands.
  SfCartesianChart _buildPlotBandChart(AsyncValue<List<Contract?>> contracts) {

    final Color plotbandYAxisTextColor = ((isSegment || isLine) &&
        model != null &&
        model.themeData.colorScheme.brightness == Brightness.light)
        ? Colors.black54
        : const Color.fromRGBO(255, 255, 255, 1);
    return SfCartesianChart(
      title: ChartTitle(text: ''),
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
          interval: 0.1,
          /// API for Y axis plot band.
          /// It returns the multiple plot band to chart.
          plotBands: <PlotBand>[
            PlotBand(
                isVisible: isCardView ? true : isHorizontal,
                start: 0.0,
                end: 114,
                text: 'SAM',
                textStyle: const TextStyle(color: Colors.black, fontSize: 13),
                color: const Color.fromRGBO(255, 0, 0, 1)),
            PlotBand(
                isVisible: isCardView ? true : isHorizontal,
                start: 114,
                end: 125,
                text: 'MAM',
                textStyle: const TextStyle(color: Colors.black, fontSize: 13),
                color: const Color.fromRGBO(254, 213, 2, 1)),
            PlotBand(
                isVisible: isCardView ? true : isHorizontal,
                start: 125,
                end: 280,
                text: 'NW',
                textStyle: const TextStyle(color: Colors.black, fontSize: 13),
                color: const Color.fromRGBO(140, 198, 62, 1)),
          ],
          majorGridLines: const MajorGridLines(width: 0)),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: getMaxValue(contracts),
        interval: 1,
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(width: 0),
        labelFormat: '{value}',
        rangePadding: ChartRangePadding.none,

        /// API for Y axis plot band.
        /// It returns the multiple plot band to chart.
        plotBands: <PlotBand>[],
      ),
      series: _getPlotBandSeries(contracts),
      tooltipBehavior: _tooltipBehavior,
      onMarkerRender: (MarkerRenderArgs markerargs) {
        markerargs.color = plotbandYAxisTextColor;
      },
    );
  }

  double getMaxValue(AsyncValue<List<Contract?>> contracts) {
    List<int> data = <int>[];
    for (double x = 0.0; x <= 28.0; x += 0.1) {
      data.add(contracts.value!.where((element) =>
          element!.armCircunference!.toDouble().toString() == x.toStringAsFixed(1)).length);
    }
    int? maxValue = data.reduce((value, element) => value> element ? value : element);
    return maxValue!.toDouble() + 10;
  }

  List<XyDataSeries<ChartSampleData, String>> _getPlotBandSeries(AsyncValue<List<Contract?>> contracts) {
    List<ChartSampleData> data = <ChartSampleData>[];
    for (double x = 0.0; x <= 28.0; x += 0.1) {
      data.add(ChartSampleData(xValue: x.toStringAsFixed(1),
          yValue: contracts.value!.where((element) =>
            element!.armCircunference!.toDouble().toString() == x.toStringAsFixed(1)).length));
    }

    const Color seriesColor = Colors.transparent;
    return <XyDataSeries<ChartSampleData, String>>[
      LineSeries<ChartSampleData, String>(
          dataSource: data,
          xValueMapper: (ChartSampleData sales, _) => sales.xValue as String,
          yValueMapper: (ChartSampleData sales, _) => sales.yValue,
          color: seriesColor,
          name: '',
          width: 2,
          markerSettings: const MarkerSettings(
              height: 5,
              width: 5,
              isVisible: true,
              color: Colors.white))
    ];
  }



  Widget _buildView(AsyncValue<List<Contract>> contracts) {
    if (contracts.value != null && contracts.value!.isNotEmpty) {
      selectedLocale = model.locale.toString();
      return _buildLayoutBuilder(contracts);
    } else {
      return const Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(),
          )
      );
    }
  }

  Widget _buildLayoutBuilder(AsyncValue<List<Contract>> contracts) {
    final ThemeData themeData = Theme.of(context);
    final bool isLightTheme =
        themeData.colorScheme.brightness == Brightness.light;
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    /*switch (selectedLocale) {
      case 'en_US':
        break;
      case 'es_ES':
        break;
      case 'fr_FR':
        break;
    }*/

    final Widget page = Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        color:
        model.isWebFullView ? model.cardThemeColor : model.cardThemeColor,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              color: isLightTheme ? const Color.fromRGBO(250, 250, 250, 1) : null,
              padding: model.isWebFullView
                  ? const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 20.0)
                  : const EdgeInsets.fromLTRB(10.0, 12.5, 10.0, 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildPoints(),
                  _buildPlotBandChart(contracts),
                ],
              ),
            ),
          ),
        ));
    return Scaffold(
      body: mediaQueryData.orientation == Orientation.landscape &&
          !model.isWebFullView
          ? Center(
        child: SingleChildScrollView(
          child: SizedBox(height: 400, child: page),
        ),
      )
          : page,
    );
  }

  Widget _buildPoints() {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: SizedBox(
              height: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  DropdownButton<String>(
                      focusColor: Colors.transparent,
                      underline:
                      Container(color: const Color(0xFFBDBDBD), height: 1),
                      value: pointSelected.fullName,
                      items: points.map((Point value) {
                        return DropdownMenuItem<String>(
                            value: value.fullName,
                            child: Text(value.fullName,
                                style: TextStyle(color: model.textColor)));
                      }).toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          pointSelected = points.firstWhere(
                                  (element) => element.fullName == value);
                        });
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue>(
            contractsScreenControllerProvider,
                (_, state) => {
            },
          );

          final pointsAsyncValue = ref.watch(pointsStreamProvider);
          if (pointsAsyncValue.value != null) {
            _savePoints(pointsAsyncValue);
          }
          final contractsAsyncValue = ref.watch(contractsPointStadisticsStreamProvider(pointSelected.pointId));
          if (contractsAsyncValue.value != null) {
            _saveContracts(contractsAsyncValue);
          }
          return _buildView(contractsAsyncValue);
        });
  }


}
