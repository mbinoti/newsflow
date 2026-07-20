import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newsflow/core/adaptive/adaptive_widgets.dart';
import 'package:newsflow/core/adaptive/platform.dart';

void main() {
  testWidgets('campo de pesquisa usa CupertinoSearchTextField no iOS', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      CupertinoApp(
        home: AdaptivePlatformScope(
          platform: TargetPlatform.iOS,
          child: CupertinoPageScaffold(
            child: AdaptiveSearchField(
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    expect(find.byType(SearchBar), findsNothing);
  });

  testWidgets('campo de pesquisa usa SearchBar no Android', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptivePlatformScope(
          platform: TargetPlatform.android,
          child: Scaffold(
            body: AdaptiveSearchField(
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(find.byType(SearchBar), findsOneWidget);
    expect(find.byType(CupertinoSearchTextField), findsNothing);
  });
}
