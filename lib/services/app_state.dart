import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/item_carrinho.dart';
import '../models/pedido.dart';
import '../models/produto.dart';
import '../models/reserva.dart';
import '../models/usuario.dart';
import '../models/vale_presente.dart';

/// Estado único da aplicação.
class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();

  AppState._();

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

  /// Desconto calculado a partir do cupom aplicado.
  double get desconto {
    final cupom = cupomAplicado;

    if (cupom == null) return 0;

    return subtotal * (cupons[cupom] ?? 0);
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
    } else {
      var maiorId = 0;

      for (final item in produtos) {
        if (item.id > maiorId) {
          maiorId = item.id;
        }
      }

      produto.id = maiorId + 1;
      produtos.add(produto);
    }

    notifyListeners();
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
    notifyListeners();
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
    final usuario = Usuario(
      id: usuarios.length + 1,
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

    return null;
  }

  // ================= gerenciamento do carrinho =================

  void adicionarProduto(
    Produto produto, {
    int qtd = 1,
  }) {
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

    notifyListeners();
  }

  void removerItem(String id) {
    carrinho.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void limparCarrinho() {
    carrinho.clear();
    cupomAplicado = null;
    notifyListeners();
  }

  /// Aplica um cupom existente.
  bool aplicarCupom(String codigo) {
    final cupom = codigo.trim().toUpperCase();

    if (!cupons.containsKey(cupom)) {
      return false;
    }

    cupomAplicado = cupom;
    notifyListeners();

    return true;
  }

  // ================= pedidos de alimentos =================

  /// Cria um pedido somente com os produtos alimentícios.
  ///
  /// Os vale-presentes permanecem no carrinho e não são
  /// convertidos em itens de pedido.
  Pedido criarPedido(String modo) {
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
