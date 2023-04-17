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
import '../domain/ContractWithPoint.dart';
import '../domain/contract_stadistic.dart';
import 'contracts_screen_controller.dart';


/// Renders the range selector with line chart zooming option
class StatisticContractsByPointAndDatePage extends SampleView {
  /// Renders the range selector with line chart zooming option
  const StatisticContractsByPointAndDatePage(Key key) : super(key: key);

  @override
  _StatisticContractsByPointAndDatePageState createState() =>
      _StatisticContractsByPointAndDatePageState();
}

class _StatisticContractsByPointAndDatePageState extends SampleViewState
    with SingleTickerProviderStateMixin {
  _StatisticContractsByPointAndDatePageState();

  final DateTime min = DateTime(2021, 8, 1), max = DateTime.now();
  final List<ChartSampleData> chartData = <ChartSampleData>[];
  late RangeController rangeController;
  late SfCartesianChart columnChart, splineChart;
  late List<ChartSampleData>  splineSeriesData;
  bool enableDeferredUpdate = true;

  var currentUserRole = "";

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _title;
  late String _filter;
  late String _points;

  _saveContracts(AsyncValue<List<ContractStadistic>>? contracts) {
    splineSeriesData = <ChartSampleData>[];
    if (contracts == null) {
      splineSeriesData = List.empty();
    } else {
      contracts.value?.forEach((element) {
        splineSeriesData.add(ChartSampleData(
            x: element.creationDate,
            y: element.value)
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedLocale = model.locale.toString();
    _title = 'Diagnósticos';
    _filter = 'Filtrar';
    _points = 'Puestos de Salud';

  }

  @override
  void dispose() {
    chartData.clear();
    rangeController.dispose();
    splineSeriesData.clear();
    super.dispose();
  }

  Widget _buildView(AsyncValue<List<ContractStadistic>> contracts) {
    if (contracts.value != null && contracts.value!.isNotEmpty) {
      selectedLocale = model.locale.toString();
      return _buildLayoutBuilder();
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

  Widget _buildLayoutBuilder() {
    final ThemeData themeData = Theme.of(context);
    final bool isLightTheme =
        themeData.colorScheme.brightness == Brightness.light;
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    switch (selectedLocale) {
      case 'en_US':
        _title = 'Diagnosis';
        _filter = 'Filter';
        _points = 'Health Points';
        break;
      case 'es_ES':
        _title = 'Diagnósticos';
        _filter = 'Filtrar';
        _points = 'Puestos de Salud';
        break;
      case 'fr_FR':
        _title = 'Diagnostics';
        _filter = 'Filtrer';
        _points = 'Points de santé';
        break;
    }
    rangeController = RangeController(
      start: splineSeriesData[0].x as DateTime,
      end: splineSeriesData[splineSeriesData.length - 1].x as DateTime,
    );
    columnChart = SfCartesianChart(
      margin: EdgeInsets.zero,
      primaryXAxis: DateTimeAxis(isVisible: false, maximum: splineSeriesData[splineSeriesData.length - 1].x),
      primaryYAxis: NumericAxis(isVisible: false),
      plotAreaBorderWidth: 0,
      series: <SplineAreaSeries<ChartSampleData, DateTime>>[
        SplineAreaSeries<ChartSampleData, DateTime>(
          dataSource: splineSeriesData,
          borderColor: const Color.fromRGBO(0, 193, 187, 1),
          color: const Color.fromRGBO(163, 226, 224, 1),
          borderDrawMode: BorderDrawMode.excludeBottom,
          borderWidth: 1,
          xValueMapper: (ChartSampleData sales, _) => sales.x as DateTime,
          yValueMapper: (ChartSampleData sales, _) => sales.y,
        )
      ],
    );
    splineChart = SfCartesianChart(
      title: ChartTitle(text: _title),
      plotAreaBorderWidth: 0,
      tooltipBehavior: TooltipBehavior(
          animationDuration: 0, shadowColor: Colors.transparent, enable: true),
      primaryXAxis: DateTimeAxis(
          labelStyle: const TextStyle(),
          isVisible: false,
          minimum: splineSeriesData[0].x as DateTime,
          maximum: splineSeriesData[splineSeriesData.length - 1].x as DateTime,
          visibleMinimum: rangeController.start,
          visibleMaximum: rangeController.end,
          rangeController: rangeController),
      primaryYAxis: NumericAxis(
        labelPosition: ChartDataLabelPosition.inside,
        labelAlignment: LabelAlignment.end,
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(color: Colors.transparent),
        anchorRangeToVisiblePoints: false,
      ),
      series: <SplineSeries<ChartSampleData, DateTime>>[
        SplineSeries<ChartSampleData, DateTime>(
          name: '$_title',
          dataSource: splineSeriesData,
          color: const Color.fromRGBO(0, 193, 187, 1),
          animationDuration: 0,
          xValueMapper: (ChartSampleData sales, _) =>
            (sales.x as DateTime),
          yValueMapper: (ChartSampleData sales, _) => sales.y,
        )
      ],
    );
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
                  //_buildPoints(),
                  Container(
                      width: mediaQueryData.orientation == Orientation.landscape
                          ? model.isWebFullView
                          ? mediaQueryData.size.width * 0.7
                          : mediaQueryData.size.width
                          : mediaQueryData.size.width,
                      padding: const EdgeInsets.fromLTRB(5, 20, 15, 25),
                      child: splineChart),
                  SfRangeSelectorTheme(
                      data: SfRangeSelectorThemeData(
                          activeLabelStyle: TextStyle(
                              fontSize: 10,
                              color: isLightTheme ? Colors.black : Colors.white),
                          inactiveLabelStyle: TextStyle(
                              fontSize: 10,
                              color: isLightTheme
                                  ? Colors.black
                                  : const Color.fromRGBO(170, 170, 170, 1)),
                          activeTrackColor: const Color.fromRGBO(255, 125, 30, 1),
                          inactiveRegionColor: isLightTheme
                              ? Colors.white.withOpacity(0.75)
                              : const Color.fromRGBO(33, 33, 33, 0.75),
                          thumbColor: Colors.white,
                          thumbStrokeColor: const Color.fromRGBO(255, 125, 30, 1),
                          thumbStrokeWidth: 2.0,
                          overlayRadius: 1,
                          overlayColor: Colors.transparent),
                      child: Container(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        width: mediaQueryData.orientation == Orientation.landscape
                            ? model.isWebFullView
                            ? mediaQueryData.size.width * 0.7
                            : mediaQueryData.size.width
                            : mediaQueryData.size.width,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 15, 15),
                            child: SfRangeSelector(
                              min: min,
                              max: max,
                              interval: 1,
                              enableDeferredUpdate: enableDeferredUpdate,
                              deferredUpdateDelay: 1000,
                              labelPlacement: LabelPlacement.betweenTicks,
                              dateIntervalType: DateIntervalType.months,
                              controller: rangeController,
                              showTicks: true,
                              showLabels: true,
                              dragMode: SliderDragMode.both,
                              labelFormatterCallback:
                                  (dynamic actualLabel, String formattedText) {
                                String label = DateFormat.MMM().format(actualLabel);
                                label = (model.isWebFullView &&
                                    mediaQueryData.size.width <= 1000)
                                    ? label[0]
                                    : label;
                                return label;
                              },
                              onChanged: (SfRangeValues values) {},
                              child: Container(
                                height: 75,
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                child: columnChart,
                              ),
                            ),
                          ),
                        ),
                      )),
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
              height: 327,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 5, left: 8),
                    child: Text(
                      '$_points:',
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                  ),
                 CheckboxListTile(
                    contentPadding: const EdgeInsets.only(left: 8),
                    title: const Text(
                      'Basic',
                      style: TextStyle(fontSize: 16),
                    ),
                    value: true,
                    activeColor: Colors.grey,
                    onChanged: (bool? value) {},
                  ),
                  /*
                  CheckboxListTile(
                      contentPadding: const EdgeInsets.only(left: 8),
                      title: const Text(
                        'Banquet hall',
                        style: TextStyle(fontSize: 16),
                      ),
                      value: _needBanquetHall,
                      onChanged: (bool? value) {
                        setState(() {
                          _needBanquetHall = value!;
                        });
                      }),
                  CheckboxListTile(
                      contentPadding: const EdgeInsets.only(left: 8),
                      title: const Text(
                        'Health spa',
                        style: TextStyle(fontSize: 16),
                      ),
                      value: _needHealthSpa,
                      onChanged: (bool? value) {
                        setState(() {
                          _needHealthSpa = value!;
                        });
                      }),
                  CheckboxListTile(
                      contentPadding: const EdgeInsets.only(left: 8),
                      title: const Text(
                        'Pets allowed',
                        style: TextStyle(fontSize: 16),
                      ),
                      value: _needPets,
                      onChanged: (bool? value) {
                        setState(() {
                          _needPets = value!;
                        });
                      }),
                  CheckboxListTile(
                      contentPadding: const EdgeInsets.only(left: 8),
                      title: const Text(
                        'Indoor entertainment',
                        style: TextStyle(fontSize: 16),
                      ),
                      value: _needIndoorEntertainment,
                      onChanged: (bool? value) {
                        setState(() {
                          _needIndoorEntertainment = value!;
                        });
                      }),*/
                ],
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
        child: _buildFilterButton(),
      )
    ]);
  }

  Widget _buildFilterButton() {
    return SizedBox(
      width: 350,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              const Color.fromRGBO(255, 102, 102, 1.0)),
        ),

        /// On clicking the button, chart inside the range selector will be
        /// updated with the filtered data.
        onPressed: () {
          setState(() {
            /*_updateChartData(
              _values,
              hasBanquetHall: _needBanquetHall,
              hasHealthSpa: _needHealthSpa,
              arePetsAllowed: _needPets,
              hasIndoorEntertainment: _needIndoorEntertainment,
            );*/
          });
        },
        child: Text(
            _filter,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
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
          final contractsAsyncValue = ref.watch(contractsStadisticsStreamProvider);
          if (contractsAsyncValue.value != null) {
            _saveContracts(contractsAsyncValue);
          }
          return _buildView(contractsAsyncValue);
        });
  }

  @override
  Widget buildSettings(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter stateSetter) {
        return CheckboxListTile(
          value: enableDeferredUpdate,
          title: const Text(
            'Enable deferred update',
            softWrap: false,
          ),
          activeColor: model.backgroundColor,
          contentPadding: EdgeInsets.zero,
          onChanged: (bool? value) {
            setState(
              () {
                enableDeferredUpdate = value!;
                stateSetter(() {});
              },
            );
          },
        );
      },
    );
  }
}
