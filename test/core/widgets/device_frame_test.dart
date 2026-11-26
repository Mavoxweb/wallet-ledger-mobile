import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/widgets/device_frame.dart';

void main() {
  Future<Size> contentSize(WidgetTester tester, Size screen) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DeviceFrame(child: SizedBox.expand(key: Key('app'))),
      ),
    );
    return tester.getSize(find.byKey(const Key('app')));
  }

  testWidgets('no computador, o app fica numa moldura de celular', (
    tester,
  ) async {
    final size = await contentSize(tester, const Size(1280, 900));

    expect(size.width, DeviceFrame.width);
  });

  testWidgets('no celular, o app ocupa a tela toda', (tester) async {
    final size = await contentSize(tester, const Size(390, 844));

    expect(size, const Size(390, 844));
  });
}
