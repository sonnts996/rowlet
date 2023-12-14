/*
 Created by Thanh Son on 25/09/2023.
 Copyright (c) 2023 . All rights reserved.
*/
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:objectx/objectx.dart';
import 'package:owlet_router/router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../main_routes.dart';
import '../../utilities/utilities.dart';
import '../../widgets/body_container.dart';
import '../../widgets/icon_widget.dart';
import '../../widgets/responsive_layout.dart';
import '../domain/interfaces/metadata_interface.dart';
import '../home_tab_route.dart';
import 'widgets/bread_crumb.dart';
import 'widgets/content_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.service,
    required this.metaData,
  });

  final NavigationService<HomeTabRoute> service;
  final MetaDataInterface metaData;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey(debugLabel: 'HomeScaffold');

  final HashMap<String, String> routeNamedMap = HashMap();

  NavigationService<HomeTabRoute> get tabService => widget.service;
  String? currentPath;
  String? currentFragment;

  @override
  void initState() {
    super.initState();
    routeNamedMap['/'] = 'Home';
    currentPath = '/';
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      tabService.route.tabPage.addListener(onUrlChanged);
      widget.service.history.addListener(onHistoryChanged);
    });
  }

  @override
  void dispose() {
    tabService.route.tabPage.removeListener(onUrlChanged);
    widget.service.history.addListener(onHistoryChanged);
    super.dispose();
  }

  void onUrlChanged() {
    final path = tabService.route.tabPage.settings?.path;
    final url = tabService.route.tabPage.settings?.name;
    url?.let((it) => updateUrlBar(routeNamedMap[path ?? ''] ?? widget.metaData.name, it));
    setState(() {
      currentPath = tabService.route.tabPage.settings?.path;
      currentFragment = '#${tabService.route.tabPage.settings?.fragment}';
    });
  }

  void onHistoryChanged() {
    setState(() {
      currentPath = widget.service.history.current.settings.path;
      currentFragment = '#${widget.service.history.current.settings.fragment}';
    });
  }

  Offset breadCrumbPosition() {
    var box = tabService.navigationKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  @override
  Widget build(BuildContext context) => ResponsiveLayout(
      child: Provider<PageInterface>.value(
        value: widget.metaData.homePage,
        updateShouldNotify: (previous, current) => false,
        builder: (context, child) => child!,
        child: OwletNavigator(tabService, reportsRouteUpdateToEngine: false),
      ),
      builder: (context, mode, child) => Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              centerTitle: false,
              automaticallyImplyLeading: false,
              elevation: 1,
              actions: [
                ...widget.metaData.repo
                    .map((e) => IconButton(
                        tooltip: e.label,
                        onPressed: () {
                          launchUrlString(e.url);
                        },
                        icon: IconWidget(iconUrl: e.icon, size: 24)))
                    .toList(),
                SizedBox(width: 16),
              ],
              titleSpacing: 0,
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (mode.isNormal)
                      SizedBox(
                        width: breadCrumbPosition().dx,
                        height: kToolbarHeight,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 8),
                              const SizedBox(width: 10),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF6C89EE), Color(0xFF012FC5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: IconWidget(iconUrl: widget.metaData.icon, size: 32),
                              ),
                              SizedBox(width: 8),
                              Text(widget.metaData.name, style: Theme.of(context).textTheme.titleMedium)
                            ]),
                      ),
                    SizedBox(width: 16),
                    SizedBox(
                        height: kToolbarHeight,
                        child: BreadCrumbWidget(
                          service: widget.service,
                          routeNamedMap: routeNamedMap,
                        )),
                  ]),
            ),
            drawer: mode.isNormal
                ? null
                : Drawer(
                    child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 16, top: 16, bottom: 16),
                      child: ContentList(
                        onTab: onSectionTab,
                        metaData: widget.metaData,
                        currentPath: currentPath,
                        currentFragment: currentFragment,
                      ),
                    ),
                  )),
            body: mode.isNormal
                ? BodyContainer(
                    child: Row(children: [
                    DesktopDrawer(
                      onDocumentTab: onSectionTab,
                      onNavigateTab: onNavigateTab,
                      metaData: widget.metaData,
                      currentPath: currentPath,
                      currentFragment: currentFragment,
                    ),
                    Expanded(child: child!),
                  ]))
                : child!,
            bottomNavigationBar: mode.isNormal
                ? null
                : BottomNavigationBar(
                    currentIndex: 1,
                    onTap: onNavigateTab,
                    type: BottomNavigationBarType.fixed,
                    items: const [
                        BottomNavigationBarItem(icon: Icon(CupertinoIcons.line_horizontal_3), label: 'Menu'),
                        BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
                        BottomNavigationBarItem(icon: Icon(CupertinoIcons.profile_circled), label: 'Author'),
                      ]),
          ));

  void onNavigateTab(int index) {
    switch (index) {
      case 0:
        scaffoldKey.currentState?.openDrawer();
        break;
      case 1:
        tabService.popUntil((route) => route.isFirst);
        break;
      case 2:
        RouteBase.of<MainRoute>(context).profile.pushNamed();
        break;
    }
  }

  void onSectionTab(String name, PageInterface page) {
    // tabService.pushNamed(path: name);
    scaffoldKey.currentState?.closeDrawer();
    Navigator.of(context, rootNavigator: true).pushNamed('/home/t$name', arguments: page);
    setState(() {
      routeNamedMap['/t${Uri.parse(name).path}'] = page.label.label;
    });
  }
}
