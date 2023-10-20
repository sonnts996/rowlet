/*
 Created by Thanh Son on 26/09/2023.
 Copyright (c) 2023 . All rights reserved.
*/
import 'package:flutter/cupertino.dart';

import '../../interfaces/history_base.dart';

/// Implement [HistoryBase]. Logging the router history via using [RouteObserver] to watch when the router changes.
class ROwletHistory extends RouteObserver with HistoryBase, ChangeNotifier {
  /// [ROwletHistory]'s constructor
  ROwletHistory();

  final List<Route> _history = [];

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _history.removeLast();
    notifyListeners();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _history.remove(route);
    notifyListeners();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _history.add(route);
    notifyListeners();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null && oldRoute != null) {
      var index = _history.indexOf(oldRoute);
      _history.replaceRange(index, index + 1, [newRoute]);
      notifyListeners();
    }
  }

  @override
  List<Route> get routes => _history;
}
