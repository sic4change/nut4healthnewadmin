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
class StatisticContractsByPointAndStatusPage extends SampleView {
  /// Renders the range selector with line chart zooming option
  const StatisticContractsByPointAndStatusPage(Key key) : super(key: key);

  @override
  _StatisticContractsByPointAndStatusPageState createState() =>
      _StatisticContractsByPointAndStatusPageState();
}

class _StatisticContractsByPointAndStatusPageState extends SampleViewState
    with SingleTickerProviderStateMixin {
  _StatisticContractsByPointAndStatusPageState();

  List<Point> points = <Point>[];
  Point pointSelected = const Point(pointId: '', name: '', pointName: "", pointCode: "",
      fullName: '', type: '', country: '', regionId: '', province: '', phoneCode: '',
      phoneLength: 0, active: false, latitude: 0.0, longitude: 0.0, language: "",
      cases: 0, casesnormopeso: 0, casesmoderada: 0, casessevera: 0, transactionHash: "");

  int normopesoValues = 0;
  int moderadaValues = 0;
  int severaValues = 0;

  int normopesoPercentage = 0;
  int moderadaPercentage = 0;
  int severaPercentage = 0;

  bool enableDeferredUpdate = true;

  var currentUserRole = "";

  /// Selected locale
  late String selectedLocale;

  /// Translate names
  late String _title;
  late String _points;

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
    if (contracts.value!.isNotEmpty){
      normopesoValues = contracts.value!.where((element) => element!.percentage! < 50).length;
      moderadaValues = contracts.value!.where((element) => element!.percentage! == 50).length;
      severaValues = contracts.value!.where((element) => element!.percentage! > 50).length;

      normopesoPercentage = (normopesoValues * 100) ~/ contracts.value!.length;
      moderadaPercentage = (moderadaValues * 100) ~/ contracts.value!.length;
      severaPercentage = (severaValues * 100) ~/ contracts.value!.length;
    } else {
      normopesoValues = 0;
      moderadaValues = 0;
      severaValues = 0;

      normopesoPercentage = 0;
      moderadaPercentage = 0;
      severaPercentage = 0;
    }
  }


  @override
  void initState() {
    super.initState();
    selectedLocale = model.locale.toString();
    _title = 'Diagnósticos';
    _points = 'Puestos de Salud';

  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Returns the circular charts with pie series.
  SfCircularChart _buildRadiusPieChart() {
    return SfCircularChart(
      title: ChartTitle(text: ''),
      legend: Legend(
          isVisible: !isCardView, overflowMode: LegendItemOverflowMode.wrap),
      series: _getRadiusPieSeries(),
      onTooltipRender: (TooltipArgs args) {
        final NumberFormat format = NumberFormat.decimalPattern();
        args.text = args.dataPoints![args.pointIndex!.toInt()].x.toString() +
            ' : ' +
            format.format(args.dataPoints![args.pointIndex!.toInt()].y);
      },
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  List<PieSeries<ChartSampleData, String>> _getRadiusPieSeries() {
    return <PieSeries<ChartSampleData, String>>[
      PieSeries<ChartSampleData, String>(
          dataSource: <ChartSampleData>[
            ChartSampleData(x: 'Normopeso (NW)', y: normopesoValues, text: '$normopesoPercentage%', pointColor: Colors.green),
            ChartSampleData(x: 'Desnutrición Aguda Moderada (MAM)', y: moderadaValues, text: '$moderadaPercentage%'),
            ChartSampleData(x: 'Desnutrición Aguda Severa (SAM)', y: severaValues, text: '$severaPercentage%')
          ],
          xValueMapper: (ChartSampleData data, _) => data.x as String,
          yValueMapper: (ChartSampleData data, _) => data.y,
          dataLabelMapper: (ChartSampleData data, _) => data.x,
          startAngle: 100,
          endAngle: 100,
          pointRadiusMapper: (ChartSampleData data, _) => data.text,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, labelPosition: ChartDataLabelPosition.outside))
    ];
  }

  Widget _buildView(AsyncValue<List<Contract>> contracts) {
    if (contracts.value != null) {
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
        _points = 'Health Points';
        break;
      case 'es_ES':
        _title = 'Diagnósticos';
        _points = 'Puestos de Salud';
        break;
      case 'fr_FR':
        _title = 'Diagnostics';
        _points = 'Points de santé';
        break;
    }

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
                  _buildRadiusPieChart(),
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
                      value: pointSelected.name,
                      items: points.map((Point value) {
                        return DropdownMenuItem<String>(
                            value: value.name,
                            child: Text(value.name,
                                style: TextStyle(color: model.textColor)));
                      }).toList(),
                      onChanged: (dynamic value) {
                        setState(() {
                          pointSelected = points.firstWhere(
                                  (element) => element.name == value);
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
