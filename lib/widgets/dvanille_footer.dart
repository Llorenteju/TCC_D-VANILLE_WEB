import 'package:flutter/material.dart';

import '../app/app.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

class DVanilleFooter extends StatelessWidget {
  const DVanilleFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    const textoClaro = Color(0xC7FFFFFF);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.fromLTRB(0, 56, 0, 24),
      color: escuro ? const Color(0xFF1E1A17) : DVanilleColors.taupe,
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 36,
              runSpacing: 30,
              children: [
                SizedBox(
                  width: 320,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🌸', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text("D'Vanille",
                              style: AppTheme.display(
                                  size: 24,
                                  weight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sabor, acolhimento e inclusão em cada detalhe. Uma cafeteria pensada para todas as pessoas, com informação nutricional clara e opções para diferentes restrições alimentares.',
                        style: TextStyle(
                            color: textoClaro, fontSize: 14, height: 1.8),
                      ),
                    ],
                  ),
                ),
                _coluna(
                  'Navegue',
                  [
                    _link(context, "Conheça a D'Vanille", Routes.conheca),
                    _link(context, 'Cardápio', Routes.cardapio),
                    _link(context, 'Ofertas', Routes.ofertas),
                    _link(context, 'Reservas', Routes.reservas),
                    _link(context, 'Vale-presentes', Routes.shopping),
                  ],
                ),
                _coluna('Contato', const [
                  Text(
                      'Rua das Baunilhas, 245 — Jardim das Flores, São Paulo/SP',
                      style: TextStyle(
                          color: textoClaro, fontSize: 14, height: 1.9)),
                  Text('(11) 4002-8922',
                      style: TextStyle(
                          color: textoClaro, fontSize: 14, height: 1.9)),
                  Text('contato@dvanille.com.br',
                      style: TextStyle(
                          color: textoClaro, fontSize: 14, height: 1.9)),
                  Text('@dvanille.cafe',
                      style: TextStyle(
                          color: textoClaro, fontSize: 14, height: 1.9)),
                ]),
                _coluna('Funcionamento', const [
                  Text('Terça a Sexta — 09h às 20h',
                      style: TextStyle(
                          color: textoClaro, fontSize: 14, height: 1.9)),
                  Text('Sábado e Domingo — 10h às 21h',
                      style: TextStyle(
                          color: textoClaro, fontSize: 14, height: 1.9)),
                  Text('Segunda — Fechado',
                      style: TextStyle(
                          color: textoClaro, fontSize: 14, height: 1.9)),
                ]),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(color: Color(0x2EFFFFFF)),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                "D'Vanille © 2026 — Projeto de TCC desenvolvido por Ana Clara de Souza Torres, Julia Leite Llorente, Karina de Souza Honorato do Nascimento e Viviane Dias Nunes.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0x99FFFFFF), fontSize: 12.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coluna(String titulo, List<Widget> filhos) {
    return SizedBox(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: AppTheme.display(size: 18, color: Colors.white)),
          const SizedBox(height: 10),
          ...filhos,
        ],
      ),
    );
  }

  Widget _link(BuildContext context, String texto, String rota) {
    return InkWell(
      onTap: () =>
          Navigator.of(context).pushNamedAndRemoveUntil(rota, (r) => false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(texto,
            style: const TextStyle(color: Color(0xC7FFFFFF), fontSize: 14)),
      ),
    );
  }
}
