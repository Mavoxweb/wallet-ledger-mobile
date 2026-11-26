import 'dart:ui' show PointerDeviceKind;

import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/app/scroll_behavior.dart';

void main() {
  test('mouse e trackpad também arrastam (demo web no computador)', () {
    const behavior = AppScrollBehavior();

    expect(behavior.dragDevices, contains(PointerDeviceKind.mouse));
    expect(behavior.dragDevices, contains(PointerDeviceKind.trackpad));
    expect(behavior.dragDevices, contains(PointerDeviceKind.touch));
  });
}
