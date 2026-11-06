import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

  Produto? editando;
  bool _carregado = false;
  bool _selecionandoFoto = false;
  bool _salvando = false;
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

  Uint8List? _fotoBytes;
  String? _fotoDataUri;
  String? _nomeArquivo;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _corTexto => _isDark
      ? Theme.of(context).colorScheme.onSurface
      : DVanilleColors.darkTaupe;
  Color get _corSecundaria =>
      _isDark ? const Color(0xFFCEBFB1) : DVanilleColors.taupe;
  Color get _corBorda =>
      _isDark ? const Color(0xFF5A4D44) : DVanilleColors.line;

  // Converte identificadores antigos que têm um equivalente conhecido.
  // Outros identificadores antigos são exibidos temporariamente no menu.
  String _normalizarCategoria(String categoriaSalva) {
    final original = categoriaSalva.trim();
    final existe = categorias.any((c) => c.id == original);
    if (existe) return original;

    if (original.toLowerCase() == 'bolos' &&
        categorias.any((c) => c.id == 'bolo')) {
      return 'bolo';
    }
    return original;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_carregado) return;
    _carregado = true;

    final argumento = ModalRoute.of(context)?.settings.arguments;
    final produto =
        argumento is Produto ? argumento : state.produtoPorId(argumento);
    if (produto == null) return;

    editando = produto;
    nome.text = produto.nome;
    descricao.text = produto.descricao;
    ingredientes.text = produto.ingredientes.join(', ');
    preco.text = produto.preco.toStringAsFixed(2);
    // Fotos enviadas ao navegador ficam em data URI. Não exibimos a string
    // enorme no campo de URL: ela continua disponível para pré-visualização.
    if (produto.imagem.startsWith('data:image/') &&
        produto.imagem.contains(';base64,')) {
      try {
        _fotoDataUri = produto.imagem;
        _fotoBytes = base64Decode(
          produto.imagem.substring(produto.imagem.indexOf(',') + 1),
        );
      } catch (_) {
        _fotoDataUri = null;
        _fotoBytes = null;
      }
    } else {
      imagem.text = produto.imagem.startsWith('blob:') ? '' : produto.imagem;
    }
    alergenicos.text = produto.alergenicos.join(', ');
    categoria = _normalizarCategoria(produto.categoria);
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
    for (final controller in [
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
      acucares,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selecionarFoto() async {
    if (!kIsWeb) {
      setState(() {
        erro =
            'O envio de fotos deste formulário está disponível na versão Web.';
      });
      return;
    }

    setState(() {
      _selecionandoFoto = true;
      erro = null;
    });

    try {
      final arquivo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 960,
        maxHeight: 960,
        imageQuality: 72,
      );
      if (arquivo == null) return;

      final extensao = arquivo.name.split('.').last.toLowerCase();
      if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extensao)) {
        if (!mounted) return;
        setState(() => erro = 'Selecione uma imagem JPG, PNG ou WebP.');
        return;
      }

      final bytes = await arquivo.readAsBytes();
      // SharedPreferences no Web usa armazenamento local com quota limitada.
      // Limite por foto reduz a chance de exceder o espaço do navegador.
      if (bytes.lengthInBytes > 450 * 1024) {
        if (!mounted) return;
        setState(() => erro =
            'Após a seleção, a foto precisa ter até 450 KB. Tente um JPG menor.');
        return;
      }
      if (!mounted) return;

      final tipoMime = extensao == 'jpg' || extensao == 'jpeg'
          ? 'image/jpeg'
          : 'image/$extensao';
      final dataUri = 'data:$tipoMime;base64,${base64Encode(bytes)}';

      setState(() {
        _fotoBytes = bytes;
        _fotoDataUri = dataUri;
        _nomeArquivo = arquivo.name;
        imagem.clear();
        erro = null;
      });
    } catch (e) {
      debugPrint('Erro ao selecionar foto: $e');
      if (!mounted) return;
      setState(() {
        erro = 'Não foi possível selecionar a imagem. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() => _selecionandoFoto = false);
      }
    }
  }

  void _removerFoto() {
    setState(() {
      _fotoBytes = null;
      _fotoDataUri = null;
      _nomeArquivo = null;
      imagem.clear();
    });
  }

  Widget _imagemVazia(String mensagem) {
    return SizedBox(
      height: 210,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            size: 50,
            color: DVanilleColors.rose,
          ),
          const SizedBox(height: 12),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: TextStyle(color: _corSecundaria, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _visualizacaoImagem() {
    if (_fotoBytes != null) {
      return Image.memory(
        _fotoBytes!,
        width: double.infinity,
        height: 210,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }

    final url = imagem.text.trim();
    if (url.isNotEmpty) {
      return Image.network(
        url,
        width: double.infinity,
        height: 210,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _imagemVazia('Não foi possível carregar a imagem.'),
      );
    }
    return _imagemVazia('Nenhuma foto selecionada');
  }

  Widget _campoFoto() {
    final temImagem = _fotoDataUri != null || imagem.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto do produto',
          style: AppTheme.display(size: 21, color: _corTexto),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecione uma foto ou informe uma URL para o cardápio.',
          style: TextStyle(fontSize: 13, color: _corSecundaria),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _isDark ? DVanilleColors.darkCream2 : DVanilleColors.cream,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _corBorda),
          ),
          child: _visualizacaoImagem(),
        ),
        if (_nomeArquivo != null) ...[
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 17,
                color: DVanilleColors.rose,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _nomeArquivo!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _corSecundaria, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: _selecionandoFoto ? null : _selecionarFoto,
              icon: _selecionandoFoto
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_rounded, size: 19),
              label: Text(_fotoBytes == null ? 'Escolher foto' : 'Trocar foto'),
              style: FilledButton.styleFrom(
                backgroundColor: DVanilleColors.taupe,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
            if (temImagem)
              OutlinedButton.icon(
                onPressed: _removerFoto,
                icon: const Icon(Icons.delete_outline_rounded, size: 19),
                label: const Text('Remover foto'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB5473F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'JPG, PNG ou WebP. Até 450 KB após a seleção; JPG é recomendado.',
          style: TextStyle(color: _corSecundaria, fontSize: 12),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: imagem,
          onChanged: (_) {
            setState(() {
              _fotoBytes = null;
              _fotoDataUri = null;
              _nomeArquivo = null;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Ou informe a URL da imagem',
            hintText: 'https://...',
            prefixIcon: Icon(Icons.link_rounded),
          ),
        ),
      ],
    );
  }

  double _num(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  List<String> _lista(TextEditingController controller) => controller.text
      .split(',')
      .map((texto) => texto.trim())
      .where((texto) => texto.isNotEmpty)
      .toList();

  Widget _numero(TextEditingController controller, String label) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  Future<void> _salvar() async {
    if (_salvando) return;
    final valorPreco = double.tryParse(preco.text.replaceAll(',', '.'));
    if (nome.text.trim().isEmpty || valorPreco == null) {
      setState(() {
        erro = 'Preencha nome, categoria e preço corretamente.';
      });
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

    // Quando o admin remove a foto, salva String vazia: sem fallback de café.
    // Dados da imagem local são persistíveis, ao contrário de URLs blob:.
    final caminhoImagem = _fotoDataUri ?? imagem.text.trim();

    final dados = Produto(
      id: editando?.id ?? 0,
      nome: nome.text.trim(),
      categoria: categoria,
      preco: valorPreco,
      descricao: descricao.text.trim(),
      imagem: caminhoImagem,
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

    setState(() => _salvando = true);
    state.salvarProduto(dados, editando: editando);
    // Confirma se o navegador conseguiu guardar o produto para o reload.
    final persistido = await state.salvarProdutos();
    if (!mounted) return;
    setState(() => _salvando = false);

    if (!persistido) {
      setState(() {
        erro = 'A alteração aparece agora no site, mas não pôde ser '
            'salva no navegador. O armazenamento pode estar cheio. '
            'Tente uma imagem menor.';
      });
      return;
    }

    showToast(
      editando == null
          ? 'Produto cadastrado com sucesso!'
          : 'Produto atualizado!',
      '✓',
    );
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.adminProdutos,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Caso apareça uma categoria antiga sem equivalente, adicionamos apenas
    // uma opção temporária com aquele id: assim nunca há zero correspondências.
    final categoriaNaLista = categorias.any((c) => c.id == categoria);
    final itensCategorias = <DropdownMenuItem<String>>[
      if (!categoriaNaLista)
        DropdownMenuItem<String>(
          value: categoria,
          child: Text('Categoria antiga: $categoria'),
        ),
      ...categorias.map(
        (item) => DropdownMenuItem<String>(
          value: item.id,
          child: Text(item.label),
        ),
      ),
    ];

    return AdminShell(
      titulo: editando == null ? 'Cadastrar produto' : 'Editar produto',
      rotaAtual: Routes.adminProdutos,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final estreito = constraints.maxWidth < 700;
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: InfoBox(
              padding: EdgeInsets.all(estreito ? 16 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (erro != null) ...[
                    CaixaAlerta(erro!),
                    const SizedBox(height: 16),
                  ],
                  _par(estreito, [
                    TextField(
                      controller: nome,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: categoria,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: itensCategorias,
                      onChanged: (valor) {
                        if (valor == null) return;
                        setState(() => categoria = valor);
                      },
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
                      labelText: 'Ingredientes (separados por vírgula)',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: preco,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                  ),
                  const SizedBox(height: 26),
                  _campoFoto(),
                  const SizedBox(height: 28),
                  Text(
                    'Informações nutricionais (por porção)',
                    style: AppTheme.display(size: 20, color: _corTexto),
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 22),
                  Text(
                    'Restrições atendidas',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _corTexto,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: restricoesLabels.entries.map((entrada) {
                      return FilterChip(
                        label: Text(entrada.value),
                        selected: restricoes.contains(entrada.key),
                        selectedColor: DVanilleColors.blush,
                        checkmarkColor: DVanilleColors.darkTaupe,
                        onSelected: (selecionado) {
                          setState(() {
                            if (selecionado) {
                              restricoes.add(entrada.key);
                            } else {
                              restricoes.remove(entrada.key);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: alergenicos,
                    decoration: const InputDecoration(
                      labelText: 'Alergênicos (separados por vírgula)',
                    ),
                  ),
                  const SizedBox(height: 26),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: _salvando ? null : _salvar,
                        icon: const Icon(Icons.check_rounded, size: 19),
                        label: Text(
                          editando == null
                              ? 'Cadastrar produto'
                              : 'Salvar alterações',
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.adminProdutos,
                          (route) => false,
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
