/// dart imports
import 'dart:io' show Platform;

import 'package:adminnut4health/src/features/countries/data/firestore_repository.dart';
import 'package:adminnut4health/src/features/users/data/firestore_repository.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';
/// package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/authentication/data/firebase_auth_repository.dart';
import '../routing/app_router.dart';
/// local imports
import 'model/helper.dart';
import 'model/model.dart';
import 'model/web_view.dart';
import 'widgets/animate_opacity_widget.dart';


/// Root widget of the sample browser
/// Contains the Homepage wrapped with a MaterialApp widget
class SampleBrowser extends ConsumerStatefulWidget {
  /// Creates sample browser widget
  const SampleBrowser();

  @override
  _SampleBrowserState createState() => _SampleBrowserState();
}

class _SampleBrowserState extends ConsumerState<SampleBrowser> {
  late SampleModel _sampleListModel;
  @override
  void initState() {
    _sampleListModel = SampleModel.instance;
    _initializeProperties();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final user = ref.watch(authRepositoryProvider).currentUser;
    final countries = ref.watch(countriesStreamProvider).value;
    final regions = ref.watch(regionsStreamProvider).value;

    if (user != null && user.metadata.lastSignInTime != null) {
      final claims = user.getIdTokenResult();
      claims.then((value) => {
        if (value.claims != null && value.claims!['donante'] == true && User.currentRole != "donante") {
          User.currentRole = 'donante'
        } else if (value.claims != null && value.claims!['super-admin'] == true && User.currentRole != "super-admin") {
          User.currentRole = 'super-admin'
        } else if (value.claims != null && value.claims!['medico-jefe'] == true && User.currentRole != "medico-jefe") {
          User.currentRole = 'medico-jefe'
        } else if (value.claims != null && value.claims!['direccion-regional-salud'] == true && User.currentRole != "direccion-regional-salud") {
          User.currentRole = 'direccion-regional-salud'
        }
      });

      final localUser = ref.watch(userStreamProvider(user.uid));

      if (localUser.value != null) {
        User.currentRegionId = localUser.value!.regionId ?? "";
        User.currentProvinceId = localUser.value!.provinceId ?? "";
        if ((User.currentRole == 'direccion-regional-salud' || User.currentRole == 'medico-jefe') && countries != null && regions != null) {
          final currentRegion = regions.firstWhere((r) => r.regionId == User.currentRegionId);
          final country = countries.firstWhere((c) => c.countryId == currentRegion.countryId);
          User.needValidation = country.needValidation;
        }
      }
    }

    final Map<String, WidgetBuilder> navigationRoutes = <String, WidgetBuilder>{
      _sampleListModel.isWebFullView ? '/' : '/demos': (BuildContext context) =>
          const HomePage()
    };
    for (int i = 0; i < _sampleListModel.routes!.length; i++) {
      final SampleRoute sampleRoute = _sampleListModel.routes![i];
      WidgetCategory? category;
      for (int j = 0; j < _sampleListModel.categoryList.length; j++) {
        if (sampleRoute.subItem!.categoryName ==
            _sampleListModel.categoryList[j].categoryName) {
          category = _sampleListModel.categoryList[j];
          break;
        }
      }

      navigationRoutes[sampleRoute.routeName!] = (BuildContext context) =>
          WebLayoutPage(
              key: GlobalKey<State>(),
              routeName: sampleRoute.routeName,
              sampleModel: _sampleListModel,
              category: category,
              subItem: sampleRoute.subItem);
    }

    if (_sampleListModel.isWebFullView) {
      _sampleListModel.currentThemeData = ThemeData.from(
          colorScheme: const ColorScheme.light().copyWith(
              primary: _sampleListModel.currentPaletteColor,
              secondary: _sampleListModel.currentPaletteColor));
      _sampleListModel.paletteBorderColors = <Color>[];
      _sampleListModel.changeTheme(_sampleListModel.currentThemeData!);
    }

    ///Avoiding page popping on escape key press
    final Map<ShortcutActivator, Intent> shortcuts =
        Map<ShortcutActivator, Intent>.of(WidgetsApp.defaultShortcuts)
          ..remove(LogicalKeySet(LogicalKeyboardKey.escape));
    return _sampleListModel.isWebFullView
        ? MaterialApp(
            shortcuts: shortcuts,
            initialRoute: '/',
            routes: navigationRoutes,
            //ignore: always_specify_types
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              SfGlobalLocalizations.delegate
            ],
            //ignore: always_specify_types
            supportedLocales: const [
              Locale('en'),
              Locale('es'),
              Locale('fr')
            ],
            locale:  const Locale('es'),
            debugShowCheckedModeBanner: false,
            title: 'Dashboard NUT4Health',
            theme: ThemeData.from(
                    colorScheme: const ColorScheme.light().copyWith(
                        primary: _sampleListModel.currentPaletteColor,
                        secondary: _sampleListModel.currentPaletteColor))
                .copyWith(
                    scrollbarTheme: const ScrollbarThemeData().copyWith(
                        thumbColor: MaterialStateProperty.all(
                            const Color.fromRGBO(128, 128, 128, 0.3)))),
            darkTheme: ThemeData.from(
                    colorScheme: const ColorScheme.dark().copyWith(
                        primary: _sampleListModel.currentPaletteColor,
                        secondary: _sampleListModel.currentPaletteColor,
                        onPrimary: Colors.white))
                .copyWith(
                    scrollbarTheme: const ScrollbarThemeData().copyWith(
                        thumbColor: MaterialStateProperty.all(
                            const Color.fromRGBO(255, 255, 255, 0.3)))),
          )
        : MaterialApp(
            initialRoute: '/demos',
            routes: navigationRoutes,
            debugShowCheckedModeBanner: false,
            title: 'Dashboard NUT4Health',
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              SfGlobalLocalizations.delegate
            ],
            //ignore: always_specify_types
            supportedLocales: const [
              Locale('es'),
              Locale('fr'),
              Locale('en'),
            ],
            locale: const Locale('es'),
            theme: ThemeData.from(
                colorScheme: const ColorScheme.light().copyWith(
                    primary: _sampleListModel.currentPaletteColor,
                    secondary: _sampleListModel.currentPaletteColor)),
            darkTheme: ThemeData.from(
                colorScheme: const ColorScheme.dark().copyWith(
                    primary: _sampleListModel.currentPaletteColor,
                    secondary: _sampleListModel.currentPaletteColor,
                    onPrimary: Colors.white)),
            home: Builder(builder: (BuildContext context) {
              _sampleListModel.systemTheme = Theme.of(context);
              _sampleListModel.currentThemeData ??=
                  _sampleListModel.systemTheme.brightness != Brightness.dark
                      ? ThemeData.from(
                          colorScheme: const ColorScheme.light().copyWith(
                              primary: _sampleListModel.currentPaletteColor,
                              secondary: _sampleListModel.currentPaletteColor))
                      : ThemeData.from(
                          colorScheme: const ColorScheme.dark().copyWith(
                              primary: _sampleListModel.currentPaletteColor,
                              secondary: _sampleListModel.currentPaletteColor,
                              onPrimary: Colors.white));
              _sampleListModel.changeTheme(_sampleListModel.currentThemeData!);
              return const HomePage();
            }));
  }

  void _initializeProperties() {
    final SampleModel model = SampleModel.instance;
    model.isWebFullView =
        kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    if (kIsWeb) {
      model.isWeb = true;
    } else {
      model.isAndroid = Platform.isAndroid;
      model.isIOS = Platform.isIOS;
      model.isLinux = Platform.isLinux;
      model.isWindows = Platform.isWindows;
      model.isMacOS = Platform.isMacOS;
      model.isDesktop =
          Platform.isLinux || Platform.isMacOS || Platform.isWindows;
      model.isMobile = Platform.isAndroid || Platform.isIOS;
    }
  }
}

/// Home page of the sample browser for both mobile and web
class HomePage extends StatefulWidget {
  /// creates the home page layout
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SampleModel sampleListModel;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    sampleListModel = SampleModel.instance;
    _addColors();
    sampleListModel.addListener(_handleChange);
    super.initState();
  }

  ///Notify the framework by calling this method
  void _handleChange() {
    if (mounted) {
      setState(() {
        // The listenable's state was changed already.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ///Checking the download button is currently hovered
    bool isHoveringDownloadButton = false;

    ///Checking the get packages is currently hovered
    bool isHoveringPubDevButton = false;
    final bool isMaxxSize = MediaQuery.of(context).size.width >= 1000;
    final SampleModel model = sampleListModel;
    model.isMobileResolution = (MediaQuery.of(context).size.width) < 768;
    return SafeArea(
        child: model.isMobileResolution
            ? Scaffold(
                resizeToAvoidBottomInset: false,
                key: scaffoldKey,
                backgroundColor: model.webBackgroundColor,
                endDrawerEnableOpenDragGesture: false,
                endDrawer:
                    model.isWebFullView ? showWebThemeSettings(model) : null,
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(46.0),
                    child: AppBar(
                      leading: (!model.isWebFullView && Platform.isIOS)
                          ? Container()
                          : null,
                      elevation: 0.0,
                      backgroundColor: model.paletteColor,
                      title: AnimateOpacityWidget(
                          controller: controller,
                          opacity: 0,
                          child: const Text('NUT4Health',
                              style: TextStyle(
                                  fontSize: 18, fontFamily: 'HeeboMedium'))),
                      actions: <Widget>[
                        Row(
                          children: [IconButton(
                            icon: const Icon(Icons.person,
                                color: Colors.white),
                            onPressed: () {
                              context.goNamed(AppRoute.account.name);
                            },
                          ),
                            IconButton(
                              icon: const Icon(Icons.settings,
                                  color: Colors.white),
                              onPressed: () {
                                scaffoldKey.currentState!.openEndDrawer();
                              },
                            )
                          ],
                        ),
                      ],
                    )),
                body: Container(
                    transform: Matrix4.translationValues(0, -1, 0),
                    child: _getScrollableWidget(model)))
            : Scaffold(
                bottomNavigationBar: getFooter(context, model),
                key: scaffoldKey,
                backgroundColor: model.webBackgroundColor,
                endDrawerEnableOpenDragGesture: false,
                endDrawer: showWebThemeSettings(model),
                resizeToAvoidBottomInset: false,
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(90.0),
                    child: AppBar(
                      leading: Container(),
                      elevation: 0.0,
                      backgroundColor: model.paletteColor,
                      flexibleSpace: Container(
                          transform: Matrix4.translationValues(0, 4, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.fromLTRB(24, 10, 0, 0),
                                child: Text('NUT4Health ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        letterSpacing: 0.53,
                                        fontFamily: 'Roboto-Bold')),
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(24, 0, 0, 0),
                                  child: Text('Administración . Visor mapas . Informes',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Roboto-Regular',
                                          letterSpacing: 0.26,
                                          fontWeight: FontWeight.normal))),
                              const Padding(
                                padding: EdgeInsets.only(top: 15),
                              ),
                              Container(
                                  alignment: Alignment.bottomCenter,
                                  width: double.infinity,
                                  height: kIsWeb ? 16 : 14,
                                  decoration: BoxDecoration(
                                      color: model.webBackgroundColor,
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12.0),
                                          topRight: Radius.circular(12.0)),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: model.webBackgroundColor,
                                          offset: const Offset(0, 2.0),
                                          blurRadius: 0.25,
                                        )
                                      ]))
                            ],
                          )),
                      actions: <Widget>[

                        if (model.isMobileResolution)
                          Container()
                        else
                          Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  top: 10, left: isMaxxSize ? 20 : 0),
                              child: Container(
                                  width: 115,
                                  height: 32,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white)),
                                  child: StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setState) {
                                    return MouseRegion(
                                      onHover: (PointerHoverEvent event) {
                                        isHoveringDownloadButton = true;
                                        setState(() {});
                                      },
                                      onExit: (PointerExitEvent event) {
                                        isHoveringDownloadButton = false;
                                        setState(() {});
                                      },
                                      child: InkWell(
                                        hoverColor: Colors.white,
                                        onTap: () {
                                          launchUrl(Uri.parse(
                                              'https://nut4health.org/'));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 9, 8, 9),
                                          child: Row(children: <Widget>[
                                            Image.asset('images/nut_logo.png',
                                                fit: BoxFit.contain,
                                                height: 33,
                                                width: 33),
                                            Text('Web Info',
                                                style: TextStyle(
                                                    color:
                                                    isHoveringPubDevButton
                                                        ? model.paletteColor
                                                        : Colors.white,
                                                    fontSize: 12,
                                                    fontFamily:
                                                    'Roboto-Medium'))
                                          ]),
                                        ),
                                      ),
                                    );
                                  }))),

                        if (model.isMobileResolution)
                          Container()
                        else
                          Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  top: 10, left: isMaxxSize ? 25 : 12),
                              child: Container(
                                  width: 118,
                                  height: 32,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white)),
                                  child: StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setState) {
                                    return MouseRegion(
                                      onHover: (PointerHoverEvent event) {
                                        isHoveringPubDevButton = true;
                                        setState(() {});
                                      },
                                      onExit: (PointerExitEvent event) {
                                        isHoveringPubDevButton = false;
                                        setState(() {});
                                      },
                                      child: InkWell(
                                        hoverColor: Colors.white,
                                        onTap: () {
                                          launchUrl(Uri.parse(
                                              'https://play.google.com/store/apps/details?id=org.sic4change.nut4health&gl=ES'));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 7, 8, 7),
                                          child: Row(children: <Widget>[
                                            Image.asset('images/google_play_logo.png',
                                                fit: BoxFit.contain,
                                                height: 33,
                                                width: 33),
                                            Text('Google Play',
                                                style: TextStyle(
                                                    color:
                                                        isHoveringPubDevButton
                                                            ? model.paletteColor
                                                            : Colors.white,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        'Roboto-Medium'))
                                          ]),
                                        ),
                                      ),
                                    );
                                  }))),
                        Padding(
                            padding: EdgeInsets.only(left: isMaxxSize ? 30 : 0),
                            child: Container(
                              padding: MediaQuery.of(context).size.width < 500
                                  ? const EdgeInsets.only(top: 20, left: 10)
                                  : const EdgeInsets.only(top: 10, right: 30),
                              height: 120,
                              width: 120,
                              child: Row(
                                children: [IconButton(
                                  icon: const Icon(Icons.person,
                                      color: Colors.white),
                                  onPressed: () {
                                    context.goNamed(AppRoute.account.name);
                                  },
                                ),
                                  IconButton(
                                    icon: const Icon(Icons.settings,
                                        color: Colors.white),
                                    onPressed: () {
                                      scaffoldKey.currentState!.openEndDrawer();
                                    },
                                  )
                                ],
                              ),
                            )),
                      ],
                    )),
                body: _CategorizedCards()));
  }

  /// Get scrollable widget to getting stickable view with scrollbar depends on platform
  Widget _getScrollableWidget(SampleModel model) {
    return model.isWeb
        ? Scrollbar(
            controller: controller,
            thumbVisibility: true,
            child: _getCustomScrollWidget(model))
        : _getCustomScrollWidget(model);
  }

  /// Get scrollable widget to getting stickable view
  Widget _getCustomScrollWidget(SampleModel model) {
    final List<Widget> searchResults = _getSearchedItems(model);
    return Container(
        color: model.paletteColor,
        child: GlowingOverscrollIndicator(
            color: model.paletteColor,
            axisDirection: AxisDirection.down,
            child: CustomScrollView(
              controller: controller,
              physics: const ClampingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Text('NUT4Health',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              letterSpacing: 0.53,
                              fontFamily: 'HeeboBold',
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 0, 0),
                      child: Text('Administración . Visor mapas . Informes',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 0.26,
                              fontFamily: 'HeeboBold',
                              fontWeight: FontWeight.normal)),
                    )
                  ],
                )),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PersistentHeaderDelegate(model),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    Container(
                        color: model.webBackgroundColor,
                        child: searchResults.isNotEmpty
                            ? SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: ListView(children: searchResults))
                            : _CategorizedCards()),
                  ]),
                )
              ],
            )));
  }

  /// Add the palette colors
  void _addColors() {
    sampleListModel.paletteColors = <Color>[
      const Color.fromRGBO(0, 116, 227, 1),
      const Color.fromRGBO(230, 74, 25, 1),
      const Color.fromRGBO(216, 27, 96, 1),
      const Color.fromRGBO(103, 58, 184, 1),
      const Color.fromRGBO(2, 137, 123, 1)
    ];
    sampleListModel.darkPaletteColors = <Color>[
      const Color.fromRGBO(68, 138, 255, 1),
      const Color.fromRGBO(255, 110, 64, 1),
      const Color.fromRGBO(238, 79, 132, 1),
      const Color.fromRGBO(180, 137, 255, 1),
      const Color.fromRGBO(29, 233, 182, 1)
    ];
    sampleListModel.paletteBorderColors = <Color>[
      const Color.fromRGBO(0, 116, 227, 1),
      Colors.transparent,
      Colors.transparent,
      Colors.transparent,
      Colors.transparent
    ];
  }

  /// returns searched result
  List<Widget> _getSearchedItems(SampleModel model) {
    final List<Widget> items = <Widget>[];
    for (int i = 0; i < model.sampleList.length; i++) {
      items.add(Material(
          color: model.webBackgroundColor,
          child: InkWell(
              splashColor: Colors.grey.withOpacity(0.4),
              onTap: () {
                Feedback.forLongPress(context);
                onTapExpandSample(context, model.sampleList[i], model);
              },
              child: Container(
                alignment: Alignment.centerLeft,
                height: 40,
                padding: const EdgeInsets.fromLTRB(20, 10, 5, 10),
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                          text: model.sampleList[i].control!.title,
                          style: TextStyle(
                              fontFamily: 'Roboto-Bold',
                              fontWeight: FontWeight.normal,
                              color: model.textColor,
                              letterSpacing: 0.3)),
                      TextSpan(
                          text: ' - ' + model.sampleList[i].title!,
                          style: TextStyle(
                              fontFamily: 'HeeboMedium',
                              fontWeight: FontWeight.normal,
                              color: model.textColor,
                              letterSpacing: 0.3)),
                    ],
                  ),
                ),
              ))));
      items.add(Divider(
        color: model.dividerColor,
        thickness: 1,
      ));
    }

    if (model.sampleList.isEmpty &&
        model.controlList.isEmpty &&
        model.editingController.text.trim() != '') {
      items.add(
        Container(
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
            color: model.webBackgroundColor,
            child: Center(
                child: Text('No results found',
                    style: TextStyle(color: model.textColor, fontSize: 15)))),
      );
    }
    return items;
  }
}

/// Search bar, rounded corner
class _PersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PersistentHeaderDelegate(SampleModel sampleModel) {
    _sampleListModel = sampleModel;
  }
  SampleModel? _sampleListModel;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 90,
      child: Container(
          color: _sampleListModel!.paletteColor,
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                height: 70,
                child: _sampleListModel!.searchBar,
              ),
              Container(
                  height: 20,
                  decoration: BoxDecoration(
                      color: _sampleListModel!.webBackgroundColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: _sampleListModel!.webBackgroundColor,
                          offset: const Offset(0, 2.0),
                          blurRadius: 0.25,
                        )
                      ])),
            ],
          )),
    );
  }

  @override
  double get maxExtent => 90;

  @override
  double get minExtent => 90;

  @override
  bool shouldRebuild(_PersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

/// Positioning/aligning the categories as  cards
/// based on the screen width
class _CategorizedCards extends StatefulWidget {
  @override
  _CategorizedCardsState createState() => _CategorizedCardsState();
}

class _CategorizedCardsState extends State<_CategorizedCards> {
  SampleModel model = SampleModel.instance;
  late double _cardWidth;

  @override
  Widget build(BuildContext context) {
    return model.isWeb
        ? Scrollbar(thumbVisibility: model.isWeb, child: _getCategorizedCards())
        : _getCategorizedCards();
  }

  Widget _getCategorizedCards() {
    final double deviceWidth = MediaQuery.of(context).size.width;
    double padding;
    double sidePadding = deviceWidth > 1060
        ? deviceWidth * 0.038
        : deviceWidth >= 768
            ? deviceWidth * 0.041
            : deviceWidth * 0.05;

    Widget? organizedCardWidget;

    if (deviceWidth > 1060) {
      padding = deviceWidth * 0.011;
      _cardWidth = (deviceWidth * 0.9) / 3;

      ///setting max cardwidth, spacing between cards in higher resolutions
      if (deviceWidth > 3000) {
        _cardWidth = deviceWidth / 3.5;
        sidePadding = (_cardWidth / 2) * 0.125;
        padding = 30;
      }
      final List<Widget> firstColumnWidgets = <Widget>[];
      final List<Widget> secondColumnWidgets = <Widget>[];
      final List<Widget> thirdColumnWidgets = <Widget>[];
      int firstColumnControlCount = 0;
      int secondColumnControlCount = 0;
      for (int i = 0; i < model.categoryList.length; i++) {
        if (firstColumnControlCount < model.controlList.length / 3) {
          firstColumnWidgets.add(_getCategoryWidget(model.categoryList[i]));
          firstColumnWidgets
              .add(Padding(padding: EdgeInsets.only(top: padding)));
          firstColumnControlCount += model.categoryList[i].controlList!.length;
        } else if (secondColumnControlCount < model.controlList.length / 3 &&
            (secondColumnControlCount +
                    model.categoryList[i].controlList!.length <
                model.controlList.length / 3)) {
          secondColumnWidgets.add(_getCategoryWidget(model.categoryList[i]));
          secondColumnWidgets
              .add(Padding(padding: EdgeInsets.only(top: padding)));
          secondColumnControlCount += model.categoryList[i].controlList!.length;
        } else {
          thirdColumnWidgets.add(_getCategoryWidget(model.categoryList[i]));
          thirdColumnWidgets
              .add(Padding(padding: EdgeInsets.only(top: padding)));
        }
        organizedCardWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: sidePadding)),
            Column(children: firstColumnWidgets),
            Padding(padding: EdgeInsets.only(left: padding)),
            Column(children: secondColumnWidgets),
            Padding(padding: EdgeInsets.only(left: padding)),
            Column(children: thirdColumnWidgets),
            Padding(
              padding: EdgeInsets.only(left: sidePadding),
            )
          ],
        );
      }
    } else if (deviceWidth >= 768) {
      padding = deviceWidth * 0.018;
      _cardWidth = (deviceWidth * 0.9) / 2;
      final List<Widget> firstColumnWidgets = <Widget>[];
      final List<Widget> secondColumnWidgets = <Widget>[];
      int firstColumnControlCount = 0;
      for (int i = 0; i < model.categoryList.length; i++) {
        if (firstColumnControlCount < model.controlList.length / 2) {
          firstColumnWidgets.add(_getCategoryWidget(model.categoryList[i]));
          firstColumnWidgets
              .add(Padding(padding: EdgeInsets.only(top: padding)));
          firstColumnControlCount += model.categoryList[i].controlList!.length;
        } else {
          secondColumnWidgets.add(_getCategoryWidget(model.categoryList[i]));
          secondColumnWidgets
              .add(Padding(padding: EdgeInsets.only(top: padding)));
        }
        organizedCardWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: sidePadding)),
            Column(children: firstColumnWidgets),
            Padding(padding: EdgeInsets.only(left: padding)),
            Column(children: secondColumnWidgets),
            Padding(
              padding: EdgeInsets.only(left: sidePadding),
            )
          ],
        );
      }
    } else {
      _cardWidth = deviceWidth * 0.9;
      padding = deviceWidth * 0.035;
      sidePadding = (deviceWidth * 0.1) / 2;
      final List<Widget> verticalOrderedWidgets = <Widget>[];
      for (int i = 0; i < model.categoryList.length; i++) {
        verticalOrderedWidgets.add(_getCategoryWidget(model.categoryList[i]));
        verticalOrderedWidgets
            .add(Padding(padding: EdgeInsets.only(top: padding)));
      }
      organizedCardWidget = Row(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: sidePadding)),
          Column(children: verticalOrderedWidgets),
          Padding(
            padding: EdgeInsets.only(left: sidePadding),
          )
        ],
      );
    }
    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.only(top: deviceWidth > 1060 ? 15 : 10),
            child: organizedCardWidget));
  }

  /// get the rounded corner layout for given category
  Widget _getCategoryWidget(WidgetCategory category) {
    return Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: model.cardColor,
            border: Border.all(
                color: const Color.fromRGBO(0, 0, 0, 0.12), width: 1.1),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        width: _cardWidth,
        child: Column(children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 15, bottom: 2),
            child: Text(
              category.categoryName!.toUpperCase(),
              style: TextStyle(
                  color: model.backgroundColor,
                  fontSize: 16,
                  fontFamily: 'Roboto-Bold'),
            ),
          ),
          Divider(
            color: model.themeData.colorScheme.brightness == Brightness.dark
                ? const Color.fromRGBO(61, 61, 61, 1)
                : const Color.fromRGBO(238, 238, 238, 1),
            thickness: 1,
          ),
          Column(children: _getControlListView(category))
        ]));
  }

  /// get the list view of the controls in the specified category.
  List<Widget> _getControlListView(WidgetCategory category) {
    final List<Widget> items = <Widget>[];
    for (int i = 0; i < category.controlList!.length; i++) {
      final Control control = category.controlList![i] as Control;
      final String? status = control.status;

      items.add(
        Container(
            color: model.cardColor,
            child: Material(
              color: model.cardColor,
              child: InkWell(
                splashFactory: InkRipple.splashFactory,
                hoverColor: Colors.grey.withOpacity(0.2),
                onTap: () {
                  !model.isWebFullView
                      ? onTapControlInMobile(context, model, category, i)
                      : onTapControlInWeb(context, model, category, i);
                  model.searchResults.clear();
                },
                child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(
                        12, 2, 0, category.controlList!.length > 3 ? 6 : 0),
                    leading: Image.asset(control.image!, fit: BoxFit.cover),
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(children: <Widget>[
                            Text(
                              control.title!,
                              textAlign: TextAlign.left,
                              softWrap: true,
                              textScaleFactor: 1,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                  color: model.textColor,
                                  fontFamily: 'Roboto-Bold'),
                            ),
                            if (!model.isWebFullView && Platform.isIOS)
                              Container()
                            else
                              (control.isBeta ?? false)
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Container(
                                          alignment: Alignment.center,
                                          padding: model.isWeb &&
                                                  model.isMobileResolution
                                              ? const EdgeInsets.fromLTRB(
                                                  3, 1.5, 3, 5.5)
                                              : const EdgeInsets.fromLTRB(
                                                  3, 3, 3, 2),
                                          decoration: const BoxDecoration(
                                              color: Color.fromRGBO(
                                                  245, 188, 14, 1)),
                                          child: const Text(
                                            'BETA',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.12,
                                                fontFamily: 'Roboto-Medium',
                                                color: Colors.black),
                                          )))
                                  : Container()
                          ]),
                          if (status != null)
                            Container(
                                decoration: BoxDecoration(
                                    color: status.toLowerCase() == 'new'
                                        ? const Color.fromRGBO(55, 153, 30, 1)
                                        : status.toLowerCase() == 'updated'
                                            ? const Color.fromRGBO(
                                                246, 117, 0, 1)
                                            : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10))),
                                padding: model.isWeb && model.isMobileResolution
                                    ? const EdgeInsets.fromLTRB(6, 1.5, 4, 5.5)
                                    : const EdgeInsets.fromLTRB(6, 2.7, 4, 2.7),
                                child: Text(status,
                                    style: const TextStyle(
                                        fontFamily: 'Roboto-Medium',
                                        color: Colors.white,
                                        fontSize: 10.5)))
                          else
                            Container()
                        ]),
                    subtitle: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 7.0, 12.0, 0.0),
                      child: Text(
                        control.description!,
                        textAlign: TextAlign.left,
                        softWrap: true,
                        textScaleFactor: 1,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: Color.fromRGBO(128, 128, 128, 1),
                        ),
                      ),
                    )),
              ),
            )),
      );
    }
    return items;
  }
}
