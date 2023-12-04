/*
 Created by Thanh Son on 16/08/2023.
 Copyright (c) 2023 . All rights reserved.
*/

/// The owlet_router serves as a router manager, utilizing the route builder to create the router.
/// It allows you to build your router as a module tree, with each field of the object representing a branch,
/// making it easy to obtain the router path.
library owlet_router;

import 'package:flutter/widgets.dart';
import 'package:objectx/objectx.dart';

import 'src/route/route_base.dart';
import 'src/services/router_services.dart';

export 'src/route/builder/builder.dart';
export 'src/route/route_base.dart' hide RouteGuardFunctionIntl;
export 'src/services/router_services.dart' hide NavigationServiceImpl, RouteHistoryImpl;
export 'src/utilities.dart';

part 'navigation_service.dart';
part 'route_finder_delegate.dart';
part 'route_history.dart';
part 'route_mixin.dart';
