import 'dart:ui' show PointerDeviceKind;

import 'package:material_ui/material_ui.dart';

/// Na demo web, o mouse e o trackpad também arrastam (por padrão, só o dedo).
class AppScrollBehavior extends MaterialScrollBehavior {
  const new();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
