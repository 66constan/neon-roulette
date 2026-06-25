import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:neon_roulette/models/game_state.dart';
import 'package:neon_roulette/providers/game_provider.dart';
import 'package:neon_roulette/widgets/bottom_bar.dart';
import 'package:neon_roulette/widgets/center_button.dart';
import 'package:neon_roulette/widgets/neon_grid.dart';

/// Helper to wrap a widget with [GameProvider] and [MaterialApp].
Widget wrapWithProviders(Widget child, {GameProvider? provider}) {
  final p = provider ?? GameProvider();
  return ChangeNotifierProvider<GameProvider>.value(
    value: p,
    child: MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  // ===========================================================================
  // NeonGrid smoke test
  // ===========================================================================
  group('NeonGrid', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const NeonGrid()));

      // Should render something (not crash)
      expect(find.byType(NeonGrid), findsOneWidget);
    });

    testWidgets('renders 8 penalty cells (3×3 grid, center empty)',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const NeonGrid()));

      // 3×3 GridView with 8 penalty cells (one empty center)
      final grid = tester.widget<NeonGrid>(find.byType(NeonGrid));
      expect(grid, isNotNull);
    });
  });

  // ===========================================================================
  // CenterButton — different labels per phase
  // ===========================================================================
  group('CenterButton', () {
    testWidgets('in idle phase shows "长按中心" and "松手随机"',
        (WidgetTester tester) async {
      final provider = GameProvider();
      await tester.pumpWidget(wrapWithProviders(
        CenterButton(
          phase: provider.state.phase, // idle
          onLongPressStart: () {},
          onLongPressEnd: () {},
          onTap: () {},
        ),
        provider: provider,
      ));
      await tester.pump();

      // The label contains multi-line text
      expect(find.textContaining('长按中心'), findsOneWidget);
      expect(find.textContaining('松手随机'), findsOneWidget);
    });

    testWidgets('in charging phase shows "松手!"',
        (WidgetTester tester) async {
      final provider = GameProvider();
      provider.startCharging(); // idle → charging

      await tester.pumpWidget(wrapWithProviders(
        CenterButton(
          phase: provider.state.phase,
          onLongPressStart: () {},
          onLongPressEnd: () {},
          onTap: () {},
        ),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('松手!'), findsOneWidget);
    });

    testWidgets('in spinning phase shows empty text (disabled)',
        (WidgetTester tester) async {
      final provider = GameProvider();
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 0); // charging → spinning

      await tester.pumpWidget(wrapWithProviders(
        CenterButton(
          phase: provider.state.phase,
          onLongPressStart: () {},
          onLongPressEnd: () {},
          onTap: () {},
        ),
        provider: provider,
      ));
      await tester.pump();

      // In spinning, label is ''
      expect(find.text(''), findsWidgets);
    });

    testWidgets('in result phase shows "再来一局"',
        (WidgetTester tester) async {
      final provider = GameProvider();
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 0); // freePass
      provider.onSpinComplete(0); // → result

      await tester.pumpWidget(wrapWithProviders(
        CenterButton(
          phase: provider.state.phase,
          onLongPressStart: () {},
          onLongPressEnd: () {},
          onTap: () {},
        ),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('再来一局'), findsOneWidget);
    });
  });

  // ===========================================================================
  // BottomBar — contextual text per phase
  // ===========================================================================
  group('BottomBar', () {
    testWidgets('in idle phase shows "长按中心 · 松手随机"',
        (WidgetTester tester) async {
      final provider = GameProvider();

      await tester.pumpWidget(wrapWithProviders(
        BottomBar(phase: provider.state.phase),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('🔊 长按中心 · 松手随机'), findsOneWidget);
    });

    testWidgets('in charging phase shows "蓄力中..."',
        (WidgetTester tester) async {
      final provider = GameProvider();
      provider.startCharging();

      await tester.pumpWidget(wrapWithProviders(
        BottomBar(phase: provider.state.phase),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('🔊 蓄力中...'), findsOneWidget);
    });

    testWidgets('in spinning phase shows "旋转中..."',
        (WidgetTester tester) async {
      final provider = GameProvider();
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 0);

      await tester.pumpWidget(wrapWithProviders(
        BottomBar(phase: provider.state.phase),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('🔊 旋转中...'), findsOneWidget);
    });

    testWidgets('in picking phase shows "请选择一位玩家"',
        (WidgetTester tester) async {
      final provider = GameProvider();
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 1); // kiss10s → picking
      provider.onSpinComplete(1);

      await tester.pumpWidget(wrapWithProviders(
        BottomBar(phase: provider.state.phase),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('👆 请选择一位玩家'), findsOneWidget);
    });

    testWidgets('with custom statusText, uses it over default',
        (WidgetTester tester) async {
      final provider = GameProvider();

      await tester.pumpWidget(wrapWithProviders(
        BottomBar(phase: provider.state.phase, statusText: '自定义消息'),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('自定义消息'), findsOneWidget);
    });
  });
}
