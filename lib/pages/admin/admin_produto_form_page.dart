import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../data/mock_data.dart';
import '../../models/produto.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_kit.dart';
import 'admin_shell.dart';

class AdminProdutoFormPage extends StatefulWidget {
  const AdminProdutoFormPage({super.key});

  @override
  State<AdminProdutoFormPage> createState() => _AdminProdutoFormPageState();
}

class _AdminProdutoFormPageState extends State<AdminProdutoFormPage> {
  final state = AppState.instance;

  Produto? editando;
  bool _carregado = false;
  String? erro;

  final nome = TextEditingController();
  final descricao = TextEditingController();
  final ingredientes = TextEditingController();
  final preco = TextEditingController();
  final imagem = TextEditingController();
  final alergenicos = TextEditingController();
  final calorias = TextEditingController(text: '0');
  final carboidratos = TextEditingController(text: '0');
  final proteinas = TextEditingController(text: '0');
  final gorduras = TextEditingController(text: '0');
  final fibras = TextEditingController(text: '0');
  final acucares = TextEditingController(text: '0');

  String categoria = categorias.first.id;
  final Set<String> restricoes = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_carregado) return;
    _carregado = true;

    final arg = ModalRoute.of(context)?.settings.arguments;
    final produto = arg is Produto ? arg : state.produtoPorId(arg);
    if (produto == null) return;

    editando = produto;
    nome.text = produto.nome;
    descricao.text = produto.descricao;
    ingredientes.text = produto.ingredientes.join(', ');
    preco.text = produto.preco.toStringAsFixed(2);
    imagem.text = produto.imagem;
    alergenicos.text = produto.alergenicos.join(', ');
    categoria = produto.categoria;
    restricoes.addAll(produto.restricoes);
    calorias.text = '${produto.nutricional.calorias}';
    carboidratos.text = '${produto.nutricional.carboidratos}';
    proteinas.text = '${produto.nutricional.proteinas}';
    gorduras.text = '${produto.nutricional.gorduras}';
    fibras.text = '${produto.nutricional.fibras}';
    acucares.text = '${produto.nutricional.acucares}';
  }

  @override
  void dispose() {
    for (final c in [
      nome,
      descricao,
      ingredientes,
      preco,
      imagem,
      alergenicos,
      calorias,
      carboidratos,
      proteinas,
      gorduras,
      fibras,
      acucares
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  List<String> _lista(TextEditingController c) => c.text
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  void _salvar() {
    final valorPreco = double.tryParse(preco.text.replaceAll(',', '.'));

    if (nome.text.trim().isEmpty || valorPreco == null) {
      setState(() =>
          erro = 'Preencha nome, categoria e preço corretamente.');
      return;
    }
    if (valorPreco < 0) {
      setState(() => erro = 'O preço não pode ser negativo.');
      return;
    }
    if (state.nomeProdutoDuplicado(nome.text, ignorando: editando)) {
      setState(() => erro = 'Já existe um produto com esse nome.');
      return;
    }

    final dados = Produto(
      id: editando?.id ?? 0,
      nome: nome.text.trim(),
      categoria: categoria,
      preco: valorPreco,
      descricao: descricao.text.trim(),
      imagem: imagem.text.trim().isEmpty ? Img.espresso : imagem.text.trim(),
      icon: editando?.icon ?? '🍽️',
      ingredientes: _lista(ingredientes),
      restricoes: restricoes.toList(),
      alergenicos: _lista(alergenicos),
      nutricional: Nutricional(
        calorias: _num(calorias),
        carboidratos: _num(carboidratos),
        proteinas: _num(proteinas),
        gorduras: _num(gorduras),
        fibras: _num(fibras),
        acucares: _num(acucares),
      ),
    );

    state.salvarProduto(dados, editando: editando);
    showToast(
      editando != null
          ? 'Produto atualizado!'
          : 'Produto cadastrado com sucesso!',
      '✓',
    );
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Routes.adminProdutos, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 760;

    return AdminShell(
      titulo: editando == null ? 'Cadastrar produto' : 'Editar produto',
      rotaAtual: Routes.adminProdutos,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: InfoBox(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (erro != null) CaixaAlerta(erro!),
              _par(estreito, [
                TextField(
                    controller: nome,
                    decoration: const InputDecoration(labelText: 'Nome')),
                DropdownButtonFormField<String>(
                  initialValue: categoria,
                  decoration:
                      const InputDecoration(labelText: 'Categoria'),
                  items: categorias
                      .map((c) => DropdownMenuItem(
                          value: c.id, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => categoria = v ?? categoria),
                ),
              ]),
              const SizedBox(height: 14),
              TextField(
                controller: descricao,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ingredientes,
                decoration: const InputDecoration(
                    labelText: 'Ingredientes (separados por vírgula)'),
              ),
              const SizedBox(height: 14),
              _par(estreito, [
                TextField(
                  controller: preco,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Preço (R\$)'),
                ),
                TextField(
                  controller: imagem,
                  decoration: const InputDecoration(
                      labelText: 'URL da imagem', hintText: 'https://...'),
                ),
              ]),
              const SizedBox(height: 22),
              Text('Informações nutricionais (por porção)',
                  style: AppTheme.display(
                      size: 20, color: DVanilleColors.darkTaupe)),
              const SizedBox(height: 12),
              _par(estreito, [
                _numero(calorias, 'Calorias (kcal)'),
                _numero(carboidratos, 'Carboidratos (g)'),
              ]),
              const SizedBox(height: 14),
              _par(estreito, [
                _numero(proteinas, 'Proteínas (g)'),
                _numero(gorduras, 'Gorduras (g)'),
              ]),
              const SizedBox(height: 14),
              _par(estreito, [
                _numero(fibras, 'Fibras (g)'),
                _numero(acucares, 'Açúcares (g)'),
              ]),
              const SizedBox(height: 20),
              const Text('Restrições atendidas',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: DVanilleColors.darkTaupe)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: restricoesLabels.entries.map((e) {
                  return FilterChip(
                    label: Text(e.value),
                    selected: restricoes.contains(e.key),
                    selectedColor: DVanilleColors.blush,
                    checkmarkColor: DVanilleColors.darkTaupe,
                    onSelected: (v) => setState(() {
                      if (v) {
                        restricoes.add(e.key);
                      } else {
                        restricoes.remove(e.key);
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: alergenicos,
                decoration: const InputDecoration(
                    labelText: 'Alergênicos (separados por vírgula)'),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  FilledButton(
                    onPressed: _salvar,
                    child: Text(editando != null
                        ? 'Salvar alterações'
                        : 'Cadastrar produto'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                            Routes.adminProdutos, (r) => false),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numero(TextEditingController c, String label) => TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      );

  Widget _par(bool estreito, List<Widget> filhos) {
    if (estreito) {
      return Column(
        children: [filhos[0], const SizedBox(height: 14), filhos[1]],
      );
    }
    return Row(
      children: [
        Expanded(child: filhos[0]),
        const SizedBox(width: 14),
        Expanded(child: filhos[1]),
      ],
    );
  }
}
