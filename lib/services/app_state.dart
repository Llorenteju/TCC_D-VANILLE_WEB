import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';
import '../models/item_carrinho.dart';
import '../models/pedido.dart';
import '../models/produto.dart';
import '../models/reserva.dart';
import '../models/usuario.dart';
import '../models/vale_presente.dart';

/// Configuração de uma promoção de um produto já cadastrado.
/// As datas são inclusivas: uma promoção com término em 10/11
/// continua válida durante todo esse dia.
class OfertaConfigurada {
  final int produtoId;
  final double precoOriginal;
  final double percentual;
  final DateTime? inicio;
  final DateTime? fim;

  const OfertaConfigurada({
    required this.produtoId,
    required this.precoOriginal,
    required this.percentual,
    this.inicio,
    this.fim,
  });

  double get precoPromocional =>
      (precoOriginal * (1 - percentual / 100) * 100).round() / 100;

  String get status {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final comeca = inicio == null
        ? null
        : DateTime(inicio!.year, inicio!.month, inicio!.day);
    final termina =
        fim == null ? null : DateTime(fim!.year, fim!.month, fim!.day);

    if (termina != null && hoje.isAfter(termina)) return 'encerrada';
    if (comeca != null && hoje.isBefore(comeca)) return 'agendada';
    return 'ativa';
  }

  bool get estaAtiva => status == 'ativa';

  Map<String, dynamic> toJson() => {
        'produtoId': produtoId,
        'precoOriginal': precoOriginal,
        'percentual': percentual,
        'inicio': inicio?.toIso8601String(),
        'fim': fim?.toIso8601String(),
      };

  factory OfertaConfigurada.fromJson(Map<String, dynamic> json) {
    return OfertaConfigurada(
      produtoId: (json['produtoId'] as num).toInt(),
      precoOriginal: (json['precoOriginal'] as num).toDouble(),
      percentual: (json['percentual'] as num).toDouble(),
      inicio: json['inicio'] == null
          ? null
          : DateTime.parse(json['inicio'] as String),
      fim: json['fim'] == null ? null : DateTime.parse(json['fim'] as String),
    );
  }
}

/// Estado único da aplicação.
class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();

  AppState._() {
    // Aproveita as ofertas de demonstração existentes no seedProdutos().
    for (final produto in produtos) {
      final precoBase = produto.oferta && produto.precoAntigo != null
          ? produto.precoAntigo!
          : produto.preco;
      _precosBase[produto.id] = precoBase;
      if (produto.oferta &&
          produto.precoAntigo != null &&
          produto.precoAntigo! > produto.preco) {
        _ofertasConfiguradas[produto.id] = OfertaConfigurada(
          produtoId: produto.id,
          precoOriginal: precoBase,
          percentual: (1 - produto.preco / precoBase) * 100,
        );
      }
    }
    _atualizarOfertasPorValidade();
    _timerOfertas = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_atualizarOfertasPorValidade()) notifyListeners();
    });
  }

  // ================= PERSISTÊNCIA DE USUÁRIOS =================

  static const String _chaveUsuarios = 'dvanille_usuarios';
  static const String _chaveOfertas = 'dvanille_ofertas_v1';
  static const String _chaveProdutos = 'dvanille_produtos_v1';

  final Map<int, OfertaConfigurada> _ofertasConfiguradas = {};
  final Map<int, double> _precosBase = {};
  Timer? _timerOfertas;

  /// Recupera os usuários salvos no navegador.
  ///
  /// Na primeira execução, mantém e salva os usuários de demonstração.
  Future<void> carregarDados() async {
    // Produtos primeiro, depois ofertas (que recalculam os preços exibidos).
    await carregarProdutos();
    await _carregarOfertas();
    try {
      final preferencias = await SharedPreferences.getInstance();
      final dadosSalvos = preferencias.getString(_chaveUsuarios);

      // Primeira execução: salva os usuários de demonstração.
      if (dadosSalvos == null) {
        await salvarUsuarios();
        return;
      }

      final List<dynamic> dados = jsonDecode(dadosSalvos);

      final usuariosCarregados = dados.map((item) {
        final usuario = Map<String, dynamic>.from(item);

        return Usuario(
          id: usuario['id'] as int,
          nome: usuario['nome'] as String,
          email: usuario['email'] as String,
          senha: usuario['senha'] as String,
          telefone: usuario['telefone'] as String? ?? '',
          endereco: usuario['endereco'] as String? ?? '',
          dataNascimento: usuario['dataNascimento'] == null
              ? null
              : DateTime.parse(
                  usuario['dataNascimento'] as String,
                ),
          tipo: usuario['tipo'] as String? ?? 'cliente',
          restricoes: List<String>.from(
            usuario['restricoes'] ?? <String>[],
          ),
          notificacoes: usuario['notificacoes'] as bool? ?? true,
        );
      }).toList();

      usuarios
        ..clear()
        ..addAll(usuariosCarregados);

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar usuários: $e');
    }
  }

  /// Salva todos os usuários no armazenamento local do navegador.
  Future<void> salvarUsuarios() async {
    try {
      final preferencias = await SharedPreferences.getInstance();

      final dados = usuarios.map((usuario) {
        return {
          'id': usuario.id,
          'nome': usuario.nome,
          'email': usuario.email,
          'senha': usuario.senha,
          'telefone': usuario.telefone,
          'endereco': usuario.endereco,
          'dataNascimento': usuario.dataNascimento?.toIso8601String(),
          'tipo': usuario.tipo,
          'restricoes': usuario.restricoes,
          'notificacoes': usuario.notificacoes,
        };
      }).toList();

      await preferencias.setString(
        _chaveUsuarios,
        jsonEncode(dados),
      );
    } catch (e) {
      debugPrint('Erro ao salvar usuários: $e');
    }
  }

  /// Agenda o salvamento sem alterar a assinatura dos métodos existentes.
  void _salvarUsuariosAutomaticamente() {
    unawaited(salvarUsuarios());
  }

  // ================= PERSISTÊNCIA DE PRODUTOS =================

  /// Restaura os produtos alterados no Admin, inclusive produtos novos
  /// e produtos cujas fotos foram removidas. Executado em carregarDados().
  Future<void> carregarProdutos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salvo = prefs.getString(_chaveProdutos);
      if (salvo == null) return; // Nenhuma edição persistida até agora.

      final registros = jsonDecode(salvo) as List<dynamic>;
      final restaurados = <Produto>[];

      for (final item in registros) {
        final dados = Map<String, dynamic>.from(item as Map);
        final nutri = dados['nutricional'] is Map
            ? Map<String, dynamic>.from(dados['nutricional'] as Map)
            : <String, dynamic>{};

        double numero(Map<String, dynamic> origem, String chave) =>
            (origem[chave] as num?)?.toDouble() ?? 0.0;

        List<String> lista(String chave) =>
            (dados[chave] as List<dynamic>? ?? <dynamic>[])
                .map((e) => e.toString())
                .toList();

        restaurados.add(
          Produto(
            id: (dados['id'] as num).toInt(),
            nome: dados['nome'] as String? ?? '',
            categoria: dados['categoria'] as String? ?? '',
            preco: numero(dados, 'preco'),
            precoAntigo: (dados['precoAntigo'] as num?)?.toDouble(),
            descricao: dados['descricao'] as String? ?? '',
            imagem: dados['imagem'] as String? ?? '',
            icon: dados['icon'] as String? ?? '🍽️',
            ingredientes: lista('ingredientes'),
            restricoes: lista('restricoes'),
            alergenicos: lista('alergenicos'),
            nutricional: Nutricional(
              calorias: numero(nutri, 'calorias'),
              carboidratos: numero(nutri, 'carboidratos'),
              proteinas: numero(nutri, 'proteinas'),
              gorduras: numero(nutri, 'gorduras'),
              fibras: numero(nutri, 'fibras'),
              acucares: numero(nutri, 'acucares'),
            ),
            oferta: dados['oferta'] as bool? ?? false,
          ),
        );
      }

      produtos
        ..clear()
        ..addAll(restaurados);

      // Reconstroi os precos-base; as ofertas serao carregadas depois.
      _precosBase.clear();
      for (final p in produtos) {
        _precosBase[p.id] =
            p.oferta && p.precoAntigo != null ? p.precoAntigo! : p.preco;
      }
      _ofertasConfiguradas.removeWhere(
        (id, config) => produtoPorId(id) == null,
      );
      notifyListeners();
    } catch (e) {
      // Se houver falha, mantem os produtos ja carregados da demonstracao.
      debugPrint('Erro ao carregar produtos: $e');
    }
  }

  /// Retorna true quando o navegador confirmou a escrita local.
  /// Imagens em data URI ocupam espaco; por isso o formulario limita o tamanho.
  Future<bool> salvarProdutos() async {
    try {
      final registros = produtos
          .map((p) => <String, dynamic>{
                'id': p.id,
                'nome': p.nome,
                'categoria': p.categoria,
                'preco': p.preco,
                'precoAntigo': p.precoAntigo,
                'descricao': p.descricao,
                'imagem': p.imagem,
                'icon': p.icon,
                'ingredientes': p.ingredientes,
                'restricoes': p.restricoes,
                'alergenicos': p.alergenicos,
                'oferta': p.oferta,
                'nutricional': <String, dynamic>{
                  'calorias': p.nutricional.calorias,
                  'carboidratos': p.nutricional.carboidratos,
                  'proteinas': p.nutricional.proteinas,
                  'gorduras': p.nutricional.gorduras,
                  'fibras': p.nutricional.fibras,
                  'acucares': p.nutricional.acucares,
                },
              })
          .toList();

      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_chaveProdutos, jsonEncode(registros));
    } catch (e) {
      debugPrint('Erro ao salvar produtos localmente: $e');
      return false;
    }
  }

  void _salvarProdutosAutomaticamente() {
    unawaited(salvarProdutos());
  }

  // ================= GERENCIAMENTO DE OFERTAS =================

  /// Todas as ofertas cadastradas, inclusive agendadas/encerradas.
  List<OfertaConfigurada> get ofertasGerenciadas {
    final lista = _ofertasConfiguradas.values.toList();
    lista.sort((a, b) => a.produtoId.compareTo(b.produtoId));
    return lista;
  }

  OfertaConfigurada? ofertaPorProduto(int id) => _ofertasConfiguradas[id];

  double precoOriginalProduto(int id) =>
      _ofertasConfiguradas[id]?.precoOriginal ??
      _precosBase[id] ??
      produtoPorId(id)?.preco ??
      0;

  /// Retorna null em caso de sucesso ou uma mensagem de validação.
  String? salvarOferta({
    required int produtoId,
    required double percentual,
    DateTime? inicio,
    DateTime? fim,
  }) {
    final produto = produtoPorId(produtoId);
    if (produto == null) return 'Produto não encontrado.';
    if (!percentual.isFinite || percentual <= 0 || percentual >= 100) {
      return 'Informe um desconto maior que 0% e menor que 100%.';
    }
    if (inicio != null && fim != null && fim.isBefore(inicio)) {
      return 'A data final não pode ser anterior à inicial.';
    }
    if (fim != null) {
      final agora = DateTime.now();
      final hoje = DateTime(agora.year, agora.month, agora.day);
      final dataFim = DateTime(fim.year, fim.month, fim.day);
      if (dataFim.isBefore(hoje)) {
        return 'A data final não pode estar no passado.';
      }
    }

    final original = precoOriginalProduto(produtoId);
    if (original <= 0) return 'O preço original precisa ser positivo.';

    _precosBase[produtoId] = original;
    _ofertasConfiguradas[produtoId] = OfertaConfigurada(
      produtoId: produtoId,
      precoOriginal: original,
      percentual: percentual,
      inicio: inicio,
      fim: fim,
    );
    _atualizarOfertasPorValidade();
    notifyListeners();
    _salvarOfertasAutomaticamente();
    return null;
  }

  /// Retira o produto da promoção e devolve seu preço original.
  void encerrarOferta(int produtoId) {
    if (_ofertasConfiguradas.remove(produtoId) == null) return;
    _atualizarOfertasPorValidade();
    notifyListeners();
    _salvarOfertasAutomaticamente();
  }

  Future<void> _carregarOfertas() async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      final jsonSalvo = preferencias.getString(_chaveOfertas);
      if (jsonSalvo != null) {
        // Mesmo uma lista vazia é importante: indica que o Admin
        // encerrou todas as ofertas de demonstração.
        final dados = jsonDecode(jsonSalvo) as List<dynamic>;
        _ofertasConfiguradas.clear();
        for (final item in dados) {
          final config = OfertaConfigurada.fromJson(
            Map<String, dynamic>.from(item as Map),
          );
          if (produtoPorId(config.produtoId) != null &&
              config.precoOriginal > 0 &&
              config.percentual > 0 &&
              config.percentual < 100) {
            _ofertasConfiguradas[config.produtoId] = config;
            _precosBase[config.produtoId] = config.precoOriginal;
          }
        }
      }
      if (_atualizarOfertasPorValidade()) notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar ofertas: $e');
    }
  }

  Future<void> _salvarOfertas() async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString(
        _chaveOfertas,
        jsonEncode(ofertasGerenciadas.map((c) => c.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Erro ao salvar ofertas: $e');
    }
  }

  void _salvarOfertasAutomaticamente() {
    unawaited(_salvarOfertas());
  }

  /// Sincroniza a promoção válida com Produto, que é utilizado nas
  /// páginas públicas, e corrige preços de itens já no carrinho.
  bool _atualizarOfertasPorValidade() {
    var mudou = false;
    for (final produto in produtos) {
      final config = _ofertasConfiguradas[produto.id];
      final precoBase = config?.precoOriginal ??
          _precosBase[produto.id] ??
          produto.precoAntigo ??
          produto.preco;
      final ativa = config?.estaAtiva ?? false;
      final precoAtual = ativa ? config!.precoPromocional : precoBase;
      final precoAntigo = ativa ? precoBase : null;

      if (produto.oferta != ativa ||
          produto.preco != precoAtual ||
          produto.precoAntigo != precoAntigo) {
        produto
          ..oferta = ativa
          ..preco = precoAtual
          ..precoAntigo = precoAntigo;
        mudou = true;
      }
    }
    if (mudou) _atualizarPrecosNoCarrinho();
    return mudou;
  }

  void _atualizarPrecosNoCarrinho() {
    for (var i = 0; i < carrinho.length; i++) {
      final item = carrinho[i];
      if (item.tipo != TipoItemCarrinho.produto) continue;
      final produto = produtoPorId(item.id);
      if (produto == null ||
          (item.preco == produto.preco &&
              item.imagem == produto.imagem &&
              item.nome == produto.nome &&
              item.icon == produto.icon)) {
        continue;
      }
      carrinho[i] = ItemCarrinho(
        id: item.id,
        nome: produto.nome,
        preco: produto.preco,
        imagem: produto.imagem,
        icon: produto.icon,
        tipo: TipoItemCarrinho.produto,
        qtd: item.qtd,
      );
    }
  }

  // ----------------- banco de dados em memória -----------------

  final List<Produto> produtos = seedProdutos();
  final List<Usuario> usuarios = seedUsuarios();
  final List<Pedido> pedidos = seedPedidos();
  final List<Reserva> reservas = seedReservas();
  final List<ValePresente> valePresentes = seedValePresentes();

  // ----------------- sessão -----------------

  Usuario? usuarioLogado;

  bool get logado => usuarioLogado != null;

  bool get isAdmin => usuarioLogado?.isAdmin ?? false;

  // ----------------- carrinho -----------------

  final List<ItemCarrinho> carrinho = [];

  String? cupomAplicado;

  /// Itens do carrinho destinados a pedidos de alimentos.
  List<ItemCarrinho> get itensProdutos =>
      carrinho.where((item) => item.tipo == TipoItemCarrinho.produto).toList();

  /// Vale-presentes aguardando confirmação da compra.
  List<ItemCarrinho> get itensValePresentes =>
      carrinho.where((item) => item.ehValePresente).toList();

  /// Quantidade total de itens no carrinho.
  int get totalItens => carrinho.fold(0, (soma, item) => soma + item.qtd);

  /// Subtotal de todos os itens do carrinho.
  double get subtotal =>
      carrinho.fold(0.0, (soma, item) => soma + item.subtotal);

  /// Desconto calculado exclusivamente sobre produtos alimentícios.
  double get desconto {
    final cupom = cupomAplicado;

    if (cupom == null || itensProdutos.isEmpty) {
      return 0;
    }

    return subtotalProdutos * (cupons[cupom] ?? 0);
  }

  /// Total do carrinho após o desconto.
  double get total {
    final valor = subtotal - desconto;
    return valor < 0 ? 0 : valor;
  }

  /// Subtotal exclusivo dos produtos alimentícios.
  double get subtotalProdutos =>
      itensProdutos.fold(0.0, (soma, item) => soma + item.subtotal);

  /// Subtotal exclusivo dos vale-presentes.
  double get subtotalValePresentes =>
      itensValePresentes.fold(0.0, (soma, item) => soma + item.subtotal);

  // ----------------- acessibilidade -----------------

  double fontScale = 1.0;

  bool dark = false;

  final Random _rand = Random();

  // ================= produtos =================

  Produto? produtoPorId(Object? id) {
    final numero = id is int ? id : int.tryParse('$id');

    if (numero == null) return null;

    for (final produto in produtos) {
      if (produto.id == numero) return produto;
    }

    return null;
  }

  List<Produto> get ofertas => produtos.where((p) => p.oferta).toList();

  /// Filtra o cardápio por categoria, busca e restrições.
  List<Produto> filtrarProdutos({
    required String categoria,
    required String busca,
    required Set<String> restricoes,
  }) {
    return produtos.where((produto) {
      final okCategoria = categoria == 'todas' ||
          (categoria == 'ofertas'
              ? produto.oferta
              : produto.categoria == categoria);

      final termo = busca.trim().toLowerCase();

      final okBusca =
          termo.isEmpty || produto.nome.toLowerCase().contains(termo);

      final okRestricoes = restricoes.every(
        (restricao) => produto.restricoes.contains(restricao),
      );

      return okCategoria && okBusca && okRestricoes;
    }).toList();
  }

  /// Produtos recomendados de acordo com as restrições do perfil.
  List<Produto> get recomendados {
    final usuario = usuarioLogado;

    if (usuario == null || usuario.restricoes.isEmpty) {
      return [];
    }

    return produtos
        .where(
          (produto) => usuario.restricoes.any(
            (restricao) => produto.restricoes.contains(restricao),
          ),
        )
        .take(4)
        .toList();
  }

  void salvarProduto(
    Produto produto, {
    Produto? editando,
  }) {
    if (editando != null) {
      final precoAntes = editando.preco;
      final config = _ofertasConfiguradas[editando.id];

      editando
        ..nome = produto.nome
        ..categoria = produto.categoria
        ..preco = produto.preco
        ..descricao = produto.descricao
        ..ingredientes = produto.ingredientes
        ..imagem = produto.imagem
        ..nutricional = produto.nutricional
        ..restricoes = produto.restricoes
        ..alergenicos = produto.alergenicos;

      // Ao editar o preço do produto, recalcula a oferta usando
      // o novo preço base. Se ele não mudou, preserva a promoção.
      if (produto.preco != precoAntes) {
        _precosBase[editando.id] = produto.preco;
        if (config != null) {
          _ofertasConfiguradas[editando.id] = OfertaConfigurada(
            produtoId: editando.id,
            precoOriginal: produto.preco,
            percentual: config.percentual,
            inicio: config.inicio,
            fim: config.fim,
          );
          _salvarOfertasAutomaticamente();
        }
      }
    } else {
      var maiorId = 0;
      for (final item in produtos) {
        if (item.id > maiorId) maiorId = item.id;
      }
      produto.id = maiorId + 1;
      produtos.add(produto);
      final base = produto.precoAntigo ?? produto.preco;
      _precosBase[produto.id] = base;
      if (produto.oferta &&
          produto.precoAntigo != null &&
          base > produto.preco) {
        _ofertasConfiguradas[produto.id] = OfertaConfigurada(
          produtoId: produto.id,
          precoOriginal: base,
          percentual: (1 - produto.preco / base) * 100,
        );
        _salvarOfertasAutomaticamente();
      }
    }

    _atualizarOfertasPorValidade();
    // Um produto no carrinho também precisa refletir nome/foto modificados.
    _atualizarPrecosNoCarrinho();
    notifyListeners();
    _salvarProdutosAutomaticamente();
  }

  bool nomeProdutoDuplicado(
    String nome, {
    Produto? ignorando,
  }) {
    final alvo = nome.trim().toLowerCase();

    return produtos.any(
      (produto) => produto != ignorando && produto.nome.toLowerCase() == alvo,
    );
  }

  void excluirProduto(int id) {
    produtos.removeWhere((produto) => produto.id == id);
    _precosBase.remove(id);
    if (_ofertasConfiguradas.remove(id) != null) {
      _salvarOfertasAutomaticamente();
    }
    notifyListeners();
    _salvarProdutosAutomaticamente();
  }

  // ================= autenticação =================

  /// Retorna null quando o login funciona ou uma mensagem de erro.
  String? login(
    String email,
    String senha,
  ) {
    for (final usuario in usuarios) {
      if (usuario.email.toLowerCase() == email.trim().toLowerCase() &&
          usuario.senha == senha) {
        usuarioLogado = usuario;
        notifyListeners();
        return null;
      }
    }

    return 'E-mail ou senha inválidos.';
  }

  void logout() {
    usuarioLogado = null;
    notifyListeners();
  }

  bool emailJaCadastrado(String email) => usuarios.any(
        (usuario) => usuario.email.toLowerCase() == email.trim().toLowerCase(),
      );

  /// Senha com no mínimo seis caracteres, uma maiúscula
  /// e um caractere especial.
  static bool senhaValida(String senha) {
    final temMaiuscula = RegExp(r'[A-Z]').hasMatch(senha);
    final temEspecial = RegExp(r'[^A-Za-z0-9]').hasMatch(senha);

    return senha.length >= 6 && temMaiuscula && temEspecial;
  }

  // ================= cadastro =================

  Usuario cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required DateTime dataNascimento,
    required List<String> restricoes,
    required bool notificacoes,
  }) {
    var maiorId = 0;

    for (final usuarioExistente in usuarios) {
      if (usuarioExistente.id > maiorId) {
        maiorId = usuarioExistente.id;
      }
    }

    final usuario = Usuario(
      id: maiorId + 1,
      nome: nome,
      email: email,
      senha: senha,
      telefone: telefone,
      dataNascimento: dataNascimento,
      tipo: 'cliente',
      restricoes: restricoes,
      notificacoes: notificacoes,
    );

    usuarios.add(usuario);
    usuarioLogado = usuario;

    notifyListeners();
    _salvarUsuariosAutomaticamente();

    return usuario;
  }

  // ================= atualização de perfil =================

  /// Atualiza o perfil e valida os dados antes de modificá-los.
  String? atualizarPerfil({
    required String nome,
    required String email,
    required String telefone,
    required String endereco,
    DateTime? dataNascimento,
    bool? notificacoes,
    String? senhaAtual,
    String? novaSenha,
    String? confirmarNovaSenha,
    required List<String> restricoes,
  }) {
    final usuario = usuarioLogado;

    if (usuario == null) {
      return 'Entre na sua conta para editar o perfil.';
    }

    final emailNormalizado = email.trim().toLowerCase();

    final emailDuplicado = usuarios.any(
      (outro) =>
          outro != usuario &&
          outro.email.trim().toLowerCase() == emailNormalizado,
    );

    if (emailDuplicado) {
      return 'Este e-mail já está cadastrado.';
    }

    final solicitouTrocaSenha = novaSenha != null && novaSenha.isNotEmpty;

    if (solicitouTrocaSenha) {
      if (senhaAtual == null || senhaAtual.isEmpty) {
        return 'Informe sua senha atual para realizar a troca.';
      }

      if (senhaAtual != usuario.senha) {
        return 'A senha atual está incorreta.';
      }

      if (confirmarNovaSenha == null || confirmarNovaSenha.isEmpty) {
        return 'Confirme a nova senha.';
      }

      if (novaSenha != confirmarNovaSenha) {
        return 'A confirmação não coincide com a nova senha.';
      }

      if (!senhaValida(novaSenha)) {
        return 'A nova senha deve ter no mínimo 6 caracteres, '
            '1 letra maiúscula e 1 caractere especial.';
      }

      if (novaSenha == usuario.senha) {
        return 'A nova senha deve ser diferente da senha atual.';
      }
    } else {
      if ((senhaAtual != null && senhaAtual.isNotEmpty) ||
          (confirmarNovaSenha != null && confirmarNovaSenha.isNotEmpty)) {
        return 'Preencha os três campos para trocar a senha.';
      }
    }

    usuario
      ..nome = nome.trim()
      ..email = email.trim()
      ..telefone = telefone.trim()
      ..endereco = endereco.trim()
      ..restricoes = List<String>.from(restricoes);

    if (dataNascimento != null) {
      usuario.dataNascimento = dataNascimento;
    }

    if (notificacoes != null) {
      usuario.notificacoes = notificacoes;
    }

    if (solicitouTrocaSenha) {
      usuario.senha = novaSenha;
    }

    notifyListeners();
    _salvarUsuariosAutomaticamente();

    return null;
  }

  // ================= gerenciamento do carrinho =================

  void adicionarProduto(
    Produto produto, {
    int qtd = 1,
  }) {
    // Confere a validade da promoção antes de colocar o item no carrinho.
    _atualizarOfertasPorValidade();
    final id = '${produto.id}';

    for (final item in carrinho) {
      if (item.id == id && item.tipo == TipoItemCarrinho.produto) {
        item.qtd += qtd;
        notifyListeners();
        return;
      }
    }

    carrinho.add(
      ItemCarrinho(
        id: id,
        nome: produto.nome,
        preco: produto.preco,
        imagem: produto.imagem,
        icon: produto.icon,
        tipo: TipoItemCarrinho.produto,
        qtd: qtd,
      ),
    );

    notifyListeners();
  }

  void adicionarItem(ItemCarrinho item) {
    carrinho.add(item);
    notifyListeners();
  }

  void alterarQuantidade(
    String id,
    int delta,
  ) {
    for (final item in List<ItemCarrinho>.from(carrinho)) {
      if (item.id == id) {
        item.qtd += delta;

        if (item.qtd <= 0) {
          carrinho.remove(item);
        }

        break;
      }
    }

    _limparCupomSeNaoHouverProdutos();

    notifyListeners();
  }

  void removerItem(String id) {
    carrinho.removeWhere((item) => item.id == id);

    _limparCupomSeNaoHouverProdutos();

    notifyListeners();
  }

  /// Remove o cupom quando não existem mais produtos alimentícios.
  void _limparCupomSeNaoHouverProdutos() {
    if (itensProdutos.isEmpty && cupomAplicado != null) {
      cupomAplicado = null;
    }
  }

  void limparCarrinho() {
    carrinho.clear();
    cupomAplicado = null;
    notifyListeners();
  }

  /// Aplica um cupom existente.
  ///
  /// PRIMEIRACOMPRA exige cliente logado, sem pedidos anteriores
  /// e produtos alimentícios no carrinho.
  bool aplicarCupom(String codigo) {
    final codigoNormalizado = codigo.trim().toUpperCase();

    if (!cupons.containsKey(codigoNormalizado)) {
      return false;
    }

    // Não permite aplicar cupons quando há somente vale-presentes.
    if (itensProdutos.isEmpty) {
      return false;
    }

    if (codigoNormalizado == 'PRIMEIRACOMPRA') {
      final usuario = usuarioLogado;

      if (usuario == null) {
        return false;
      }

      final jaRealizouCompra = pedidos.any(
        (pedido) =>
            pedido.clienteEmail.trim().toLowerCase() ==
            usuario.email.trim().toLowerCase(),
      );

      if (jaRealizouCompra) {
        return false;
      }
    }

    cupomAplicado = codigoNormalizado;
    notifyListeners();

    return true;
  }

  // ================= pedidos de alimentos =================

  /// Cria um pedido somente com os produtos alimentícios.
  ///
  /// Os vale-presentes permanecem no carrinho e não são
  /// convertidos em itens de pedido.
  Pedido criarPedido(String modo) {
    // Garante os valores vigentes mesmo na mudança de dia.
    _atualizarOfertasPorValidade();
    final itens = itensProdutos;

    if (itens.isEmpty) {
      throw StateError(
        'Não existem produtos de alimentação para criar um pedido.',
      );
    }

    final agora = DateTime.now();

    final subtotalDosProdutos = subtotalProdutos;

    // O desconto é calculado apenas sobre os produtos alimentícios.
    final taxaDesconto = cupons[cupomAplicado] ?? 0.0;
    final descontoDosProdutos = subtotalDosProdutos * taxaDesconto;

    final totalDosProdutos = (subtotalDosProdutos - descontoDosProdutos)
        .clamp(0.0, double.infinity)
        .toDouble();

    final pedido = Pedido(
      id: _gerarId('PD'),
      clienteEmail: usuarioLogado?.email ?? '',
      itens: itens
          .map(
            (item) => ItemPedido(
              produtoId: item.id,
              nome: item.nome,
              preco: item.preco,
              qtd: item.qtd,
            ),
          )
          .toList(),
      total: totalDosProdutos,
      data: _formatarDataHora(agora),
      status: 'recebido',
      modo: modo,
    );

    pedidos.add(pedido);

    final idsProdutos = itens.map((item) => item.id).toSet();

    carrinho.removeWhere((item) => idsProdutos.contains(item.id));

    cupomAplicado = null;

    notifyListeners();

    return pedido;
  }

  Pedido? pedidoPorId(String? id) {
    for (final pedido in pedidos) {
      if (pedido.id == id) return pedido;
    }

    return null;
  }

  List<Pedido> get meusPedidos {
    final email = usuarioLogado?.email;

    final lista =
        pedidos.where((pedido) => pedido.clienteEmail == email).toList();

    lista.sort((a, b) => b.id.compareTo(a.id));

    return lista;
  }

  void atualizarStatusPedido(
    String id,
    String status,
  ) {
    final pedido = pedidoPorId(id);

    if (pedido != null) {
      pedido.status = status;
      notifyListeners();
    }
  }

  // ================= reservas =================

  Reserva criarReserva({
    required String nome,
    required String email,
    required String telefone,
    required String data,
    required String horario,
    required int pessoas,
    required String preferencias,
    required String observacoes,
  }) {
    final reserva = Reserva(
      id: _gerarId('RS'),
      nome: nome,
      email: email,
      telefone: telefone,
      data: data,
      horario: horario,
      pessoas: pessoas,
      preferencias: preferencias,
      observacoes: observacoes,
      status: 'solicitada',
    );

    reservas.add(reserva);
    notifyListeners();

    return reserva;
  }

  Reserva? reservaPorId(String? id) {
    for (final reserva in reservas) {
      if (reserva.id == id) return reserva;
    }

    return null;
  }

  /// Retorna as reservas do usuário conectado.
  List<Reserva> get minhasReservas {
    final email = usuarioLogado?.email;

    if (email == null || email.trim().isEmpty) {
      return [];
    }

    final lista = reservas
        .where(
          (reserva) =>
              reserva.email.trim().toLowerCase() == email.trim().toLowerCase(),
        )
        .toList();

    lista.sort((a, b) => b.id.compareTo(a.id));

    return lista;
  }

  void atualizarStatusReserva(
    String id,
    String status,
  ) {
    final reserva = reservaPorId(id);

    if (reserva != null) {
      reserva.status = status;
      notifyListeners();
    }
  }

  // ================= vale-presentes =================

  /// Emite um vale-presente ativo.
  ///
  /// No fluxo de compra, chame este método somente após a
  /// confirmação simulada da compra.
  ValePresente emitirValePresente({
    required double valor,
    required String destinatario,
    required String mensagem,
  }) {
    final vale = ValePresente(
      id: _gerarId('VP'),
      valor: valor,
      codigo: 'DVAN-${1000 + _rand.nextInt(9000)}-GIFT',
      status: 'ativo',
      criadoEm: _formatarData(DateTime.now()),
      destinatario: destinatario,
      mensagem: mensagem,
      compradorEmail: usuarioLogado?.email ?? '',
    );

    valePresentes.add(vale);
    notifyListeners();

    return vale;
  }

  /// Confirma a compra dos vale-presentes atualmente no carrinho.
  ///
  /// Deve ser chamado somente depois da confirmação simulada
  /// da compra. Produtos alimentícios não são removidos.
  List<ValePresente> confirmarCompraValePresentes() {
    final itens = itensValePresentes;

    if (itens.isEmpty) {
      return [];
    }

    final valesEmitidos = <ValePresente>[];

    for (final item in itens) {
      for (var i = 0; i < item.qtd; i++) {
        final vale = emitirValePresente(
          valor: item.preco,
          destinatario: item.destinatario,
          mensagem: item.mensagem,
        );

        valesEmitidos.add(vale);
      }
    }

    final idsVales = itens.map((item) => item.id).toSet();

    carrinho.removeWhere((item) => idsVales.contains(item.id));

    cupomAplicado = null;

    notifyListeners();

    return valesEmitidos;
  }

  void excluirValePresente(String id) {
    valePresentes.removeWhere((vale) => vale.id == id);
    notifyListeners();
  }

  // ================= acessibilidade =================

  void aumentarFonte() {
    fontScale = (fontScale + 0.1).clamp(0.85, 1.3);
    notifyListeners();
  }

  void diminuirFonte() {
    fontScale = (fontScale - 0.1).clamp(0.85, 1.3);
    notifyListeners();
  }

  void alternarDark() {
    dark = !dark;
    notifyListeners();
  }

  @override
  void dispose() {
    _timerOfertas?.cancel();
    super.dispose();
  }

  // ================= utilitários =================

  String _gerarId(String prefixo) => '$prefixo${1000 + _rand.nextInt(9000)}';

  static String _dois(int valor) => valor.toString().padLeft(2, '0');

  static String _formatarData(DateTime data) =>
      '${data.year}-${_dois(data.month)}-${_dois(data.day)}';

  static String _formatarDataHora(DateTime data) =>
      '${_dois(data.day)}/${_dois(data.month)}/${data.year} '
      '${_dois(data.hour)}:${_dois(data.minute)}';
}

/// Formata valores monetários como R$ 12,90.
String money(double valor) =>
    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
