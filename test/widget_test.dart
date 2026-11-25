import 'package:flutter_test/flutter_test.dart';
import 'package:robot_tec_explorer/main.dart';

void main() {
  testWidgets('Robot Tec Explorer smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RobotTecExplorerApp());
    expect(find.text('ROBOT TEC EXPLORER'), findsWidgets);
  });
}
