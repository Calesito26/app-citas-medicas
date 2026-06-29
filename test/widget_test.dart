import 'package:citas_medicas/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra el menu principal de citas medicas', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Centro de Salud'), findsOneWidget);
    expect(find.text('Disponibilidad'), findsOneWidget);
    expect(find.text('Registrar cita'), findsOneWidget);
    expect(find.text('Atender cita'), findsOneWidget);
    expect(find.text('Reportes'), findsOneWidget);
  });
}
