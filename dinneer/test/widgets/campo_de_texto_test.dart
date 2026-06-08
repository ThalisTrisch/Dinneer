import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dinneer/widgets/campo_de_texto.dart';

/// Envolve o widget em um MaterialApp/Scaffold mínimo para testes de UI.
Widget _envolver(Widget filho) => MaterialApp(home: Scaffold(body: filho));

void main() {
  testWidgets('exibe o texto de dica (hint)', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      _envolver(
        CampoDeTextoCustomizado(controller: controller, dica: 'E-mail'),
      ),
    );

    expect(find.text('E-mail'), findsOneWidget);
  });

  testWidgets('digitar atualiza o controller', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      _envolver(CampoDeTextoCustomizado(controller: controller, dica: 'Nome')),
    );

    await tester.enterText(find.byType(TextField), 'João');

    expect(controller.text, 'João');
  });

  testWidgets('textoObscuro oculta o conteúdo digitado', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      _envolver(
        CampoDeTextoCustomizado(
          controller: controller,
          dica: 'Senha',
          textoObscuro: true,
        ),
      ),
    );

    final campo = tester.widget<TextField>(find.byType(TextField));
    expect(campo.obscureText, isTrue);
  });
}
