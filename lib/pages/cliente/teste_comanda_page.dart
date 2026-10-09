import 'package:flutter/material.dart';

import '../../app/app.dart';

class TesteComandaPage extends StatelessWidget {
  const TesteComandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teste da comanda D'Vanille"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.qr_code_2,
                  size: 72,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Acesso de demonstração',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Abra a comanda de uma mesa para testar '
                  'a inclusão de produtos e o cálculo do total.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.comandaMesa,
                      arguments: {'mesa': '04'},
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Abrir mesa 04'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
