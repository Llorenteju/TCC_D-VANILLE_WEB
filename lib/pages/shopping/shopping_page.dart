import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../models/item_carrinho.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  double valor = 50;
  final nome = TextEditingController();
  final mensagem = TextEditingController();
  String? erro;

  static const valores = [30.0, 50.0, 100.0, 150.0];

  @override
  void dispose() {
    nome.dispose();
    mensagem.dispose();
    super.dispose();
  }

  void _adicionar() {
    if (nome.text.trim().isEmpty) {
      setState(() => erro = 'Informe o nome do presenteado.');
      return;
    }
    final state = AppState.instance;
    state.adicionarItem(ItemCarrinho(
      id: 'gift-${DateTime.now().millisecondsSinceEpoch}',
      nome:
          "Vale-presente D'Vanille (${money(valor)}) — para ${nome.text.trim()}",
      preco: valor,
      icon: '🎁',
    ));
    state.emitirValePresente(
      valor: valor,
      destinatario: nome.text.trim(),
      mensagem: mensagem.text.trim(),
    );
    showToast('Produto adicionado ao carrinho!', '🎁');
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Routes.carrinho, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      activeRoute: Routes.shopping,
      child: Column(
        children: [
          const SizedBox(height: 56),
          const ContentWidth(
            child: SectionHead(
              eyebrow: 'Presenteie com carinho',
              titulo: 'Shopping — Vale-presente',
            ),
          ),
          const SizedBox(height: 34),
          ContentWidth(
            maxWidth: 820,
            child: Column(
              children: [
                Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  alignment: WrapAlignment.center,
                  children: valores.map(_cartao).toList(),
                ),
                const SizedBox(height: 36),
                InfoBox(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personalize seu presente',
                          style: AppTheme.display(
                              size: 24, color: DVanilleColors.darkTaupe)),
                      const SizedBox(height: 18),
                      if (erro != null) CaixaAlerta(erro!),
                      InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Valor selecionado'),
                        child: Text(money(valor),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: DVanilleColors.darkTaupe)),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: nome,
                        decoration: const InputDecoration(
                            labelText: 'Nome do presenteado'),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: mensagem,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Mensagem',
                          hintText: 'Escreva uma mensagem especial...',
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _adicionar,
                          child: const Text('Adicionar ao carrinho'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartao(double v) {
    final selecionado = v == valor;
    return InkWell(
      onTap: () => setState(() => valor = v),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DVanilleColors.taupe, DVanilleColors.rose],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selecionado
                ? DVanilleColors.darkTaupe
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("VALE-PRESENTE D'VANILLE",
                style: TextStyle(
                    color: Color(0xD9FFFFFF),
                    fontSize: 11,
                    letterSpacing: .6)),
            const SizedBox(height: 10),
            Text(money(v),
                style: AppTheme.display(
                    size: 30, weight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
