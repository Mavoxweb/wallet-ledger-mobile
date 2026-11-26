import 'dart:ui' show PointerDeviceKind;

import 'package:material_ui/material_ui.dart';

/// Por padrão, o Flutter só deixa arrastar listas e carrosséis com o dedo.
/// Na demo web, aberta no computador, o carrossel de cartões ficaria preso:
/// aqui o mouse e o trackpad também arrastam.
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
