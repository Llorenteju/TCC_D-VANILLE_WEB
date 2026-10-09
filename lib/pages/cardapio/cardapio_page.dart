import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../models/produto.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/product_card.dart';
import '../../widgets/ui_kit.dart';

class CardapioPage extends StatefulWidget {
  const CardapioPage({super.key});

  @override
  State<CardapioPage> createState() => _CardapioPageState();
}

class _CardapioPageState extends State<CardapioPage> {
  final state = AppState.instance;
  final buscaController = TextEditingController();

  String categoria = 'todas';
  String busca = '';
  String? mesa;

  final Set<String> filtros = {};

  bool _argumentoLido = false;

  bool get modoMesa => mesa != null && mesa!.trim().isNotEmpty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argumentoLido) return;
    _argumentoLido = true;

    final argumentos = ModalRoute.of(context)?.settings.arguments;

    if (argumentos is String && argumentos.isNotEmpty) {
      categoria = argumentos;
    } else if (argumentos is Map) {
      final modo = argumentos['modo']?.toString();
      final numeroMesa = argumentos['mesa']?.toString().trim();

      // Somente a navegação identificada como "mesa" libera pedidos.
      if (modo == 'mesa' && numeroMesa != null && numeroMesa.isNotEmpty) {
        mesa = numeroMesa;
      }

      final categoriaRecebida = argumentos['categoria']?.toString();

      if (categoriaRecebida != null && categoriaRecebida.isNotEmpty) {
        categoria = categoriaRecebida;
      }
    }
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 760;

    return PageShell(
      activeRoute: modoMesa ? null : Routes.cardapio,
      mostrarCabecalho: !modoMesa,
      mostrarRodape: !modoMesa,
      mostrarCarrinho: modoMesa,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final lista = state.filtrarProdutos(
            categoria: categoria,
            busca: busca,
            restricoes: filtros,
          );

          final recomendados = state.recomendados;

          return Column(
            children: [
              SizedBox(height: modoMesa ? 28 : 56),
              ContentWidth(
                child: Column(
                  children: [
                    Text(
                      'Nosso Cardápio',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'CreamCake',
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: DVanilleColors.rose,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      modoMesa
                          ? 'Faça seu pedido à mesa'
                          : 'Escolha com clareza e sabor',
                      textAlign: TextAlign.center,
                      style: AppTheme.display(
                        size: 24,
                        weight: FontWeight.w600,
                        color: DVanilleColors.darkTaupe,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      modoMesa
                          ? 'Mesa $mesa · Escolha os produtos que deseja pedir.'
                          : 'Pesquise, filtre por restrições alimentares e veja tudo sobre ingredientes e valores nutricionais.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: DVanilleColors.darkTaupe,
                      ),
                    ),
                    if (modoMesa) ...[
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            Routes.comandaMesa,
                            arguments: {'mesa': mesa},
                          );
                        },
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('Ver comanda da mesa'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 36),
              ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recomendados.isNotEmpty) ...[
                      Text(
                        'Recomendado para você',
                        style: const TextStyle(
                          fontFamily: 'CreamCake',
                          fontSize: 36,
                          fontWeight: FontWeight.w400,
                          color: DVanilleColors.darkTaupe,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const DicaCampo(
                        'Sugestões com base nas restrições alimentares do seu perfil. Isso não substitui orientação médica ou nutricional.',
                      ),
                      const SizedBox(height: 16),
                      GradeProdutos(
                        produtos: recomendados,
                        permitirAdicionar: modoMesa,
                        mesa: modoMesa ? mesa : null,
                      ),
                      const SizedBox(height: 44),
                    ],
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 23,
                        runSpacing: 8,
                        children: [
                          ChipSelecao(
                            label: 'Todas',
                            ativo: categoria == 'todas',
                            onTap: () {
                              setState(() => categoria = 'todas');
                            },
                          ),
                          for (final c in categorias)
                            ChipSelecao(
                              label: c.label,
                              ativo: categoria == c.id,
                              onTap: () {
                                setState(() => categoria = c.id);
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    if (estreito) ...[
                      _painelFiltros(),
                      const SizedBox(height: 20),
                      _campoBusca(),
                      const SizedBox(height: 24),
                      _resultado(lista),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 250,
                            child: _painelFiltros(),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            child: Column(
                              children: [
                                _campoBusca(),
                                const SizedBox(height: 24),
                                _resultado(lista),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (modoMesa) ...[
                const SizedBox(height: 36),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.comandaMesa,
                      arguments: {'mesa': mesa},
                    );
                  },
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Voltar para a comanda'),
                ),
                const SizedBox(height: 24),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _campoBusca() {
    return TextField(
      controller: buscaController,
      onChanged: (valor) {
        setState(() => busca = valor);
      },
      decoration: const InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: DVanilleColors.taupe,
        ),
        hintText: 'Pesquisar produtos, ex: café, cupcake, sem glúten...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          borderSide: BorderSide(
            color: DVanilleColors.line,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          borderSide: BorderSide(
            color: DVanilleColors.line,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          borderSide: BorderSide(
            color: DVanilleColors.rose,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _painelFiltros() {
    return InfoBox(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por restrição',
            style: AppTheme.display(
              size: 19,
              color: DVanilleColors.darkTaupe,
            ),
          ),
          const SizedBox(height: 6),
          for (final entrada in restricoesLabels.entries)
            InkWell(
              onTap: () {
                setState(() {
                  if (filtros.contains(entrada.key)) {
                    filtros.remove(entrada.key);
                  } else {
                    filtros.add(entrada.key);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Checkbox(
                      value: filtros.contains(entrada.key),
                      activeColor: DVanilleColors.taupe,
                      onChanged: (valor) {
                        setState(() {
                          if (valor == true) {
                            filtros.add(entrada.key);
                          } else {
                            filtros.remove(entrada.key);
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        entrada.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _resultado(List<Produto> lista) {
    if (lista.isEmpty) {
      return const EstadoVazio(
        emoji: '🔍',
        titulo: 'Nenhum produto encontrado',
        texto:
            'Não encontramos produtos para essa busca. Tente outro termo ou remova alguns filtros.',
      );
    }

    return GradeProdutos(
      produtos: lista,
      permitirAdicionar: modoMesa,
      mesa: modoMesa ? mesa : null,
    );
  }
}
