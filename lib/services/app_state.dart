import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/item_carrinho.dart';
import '../models/pedido.dart';
import '../models/produto.dart';
import '../models/reserva.dart';
import '../models/usuario.dart';
import '../models/vale_presente.dart';

/// Estado único da aplicação — equivale aos objetos DB / session / ui do HTML.
class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  // ----------------- "banco de dados" -----------------
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

  // ----------------- acessibilidade -----------------
  double fontScale = 1.0;
  bool dark = false;

  final _rand = Random();

  // ================= produtos =================
  Produto? produtoPorId(Object? id) {
    final n = id is int ? id : int.tryParse('$id');
    if (n == null) return null;
    for (final p in produtos) {
      if (p.id == n) return p;
    }
    return null;
  }

  List<Produto> get ofertas => produtos.where((p) => p.oferta).toList();

  /// Filtro do cardápio: categoria + busca + restrições (todas precisam bater).
  List<Produto> filtrarProdutos({
    required String categoria,
    required String busca,
    required Set<String> restricoes,
  }) {
    return produtos.where((p) {
      final okCategoria = categoria == 'todas' ||
          (categoria == 'ofertas' ? p.oferta : p.categoria == categoria);
      final okBusca = busca.trim().isEmpty ||
          p.nome.toLowerCase().contains(busca.trim().toLowerCase());
      final okRestricoes = restricoes.every((r) => p.restricoes.contains(r));
      return okCategoria && okBusca && okRestricoes;
    }).toList();
  }

  /// "Recomendado para você" — produtos que atendem alguma restrição do perfil.
  List<Produto> get recomendados {
    final u = usuarioLogado;
    if (u == null || u.restricoes.isEmpty) return [];
    return produtos
        .where((p) => u.restricoes.any((r) => p.restricoes.contains(r)))
        .take(4)
        .toList();
  }

  void salvarProduto(Produto produto, {Produto? editando}) {
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
      var maior = 0;
      for (final p in produtos) {
        if (p.id > maior) maior = p.id;
      }
      produto.id = maior + 1;
      produtos.add(produto);
    }
    notifyListeners();
  }

  bool nomeProdutoDuplicado(String nome, {Produto? ignorando}) {
    final alvo = nome.trim().toLowerCase();
    return produtos
        .any((p) => p != ignorando && p.nome.toLowerCase() == alvo);
  }

  void excluirProduto(int id) {
    produtos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ================= autenticação =================
  /// Retorna null em caso de sucesso, ou a mensagem de erro.
  String? login(String email, String senha) {
    for (final u in usuarios) {
      if (u.email.toLowerCase() == email.trim().toLowerCase() &&
          u.senha == senha) {
        usuarioLogado = u;
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

  bool emailJaCadastrado(String email) => usuarios
      .any((u) => u.email.toLowerCase() == email.trim().toLowerCase());

  /// Regra do HTML: mínimo 6 caracteres, 1 maiúscula e 1 caractere especial.
  static bool senhaValida(String senha) {
    final temMaiuscula = RegExp(r'[A-Z]').hasMatch(senha);
    final temEspecial = RegExp(r'[^A-Za-z0-9]').hasMatch(senha);
    return senha.length >= 6 && temMaiuscula && temEspecial;
  }

  Usuario cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required List<String> restricoes,
    required bool notificacoes,
  }) {
    final u = Usuario(
      id: usuarios.length + 1,
      nome: nome,
      email: email,
      senha: senha,
      telefone: telefone,
      tipo: 'cliente',
      restricoes: restricoes,
      notificacoes: notificacoes,
    );
    usuarios.add(u);
    usuarioLogado = u;
    notifyListeners();
    return u;
  }

  void atualizarPerfil({
    required String nome,
    required String email,
    required String telefone,
    required String endereco,
    String? novaSenha,
    required List<String> restricoes,
  }) {
    final u = usuarioLogado;
    if (u == null) return;
    u
      ..nome = nome
      ..email = email
      ..telefone = telefone
      ..endereco = endereco
      ..restricoes = restricoes;
    if (novaSenha != null && novaSenha.isNotEmpty) u.senha = novaSenha;
    notifyListeners();
  }

  // ================= carrinho =================
  int get totalItens => carrinho.fold(0, (a, i) => a + i.qtd);

  double get subtotal => carrinho.fold(0.0, (a, i) => a + i.subtotal);

  double get desconto {
    final c = cupomAplicado;
    if (c == null) return 0;
    return subtotal * (cupons[c] ?? 0);
  }

  double get total {
    final t = subtotal - desconto;
    return t < 0 ? 0 : t;
  }

  void adicionarProduto(Produto p, {int qtd = 1}) {
    final id = '${p.id}';
    for (final i in carrinho) {
      if (i.id == id) {
        i.qtd += qtd;
        notifyListeners();
        return;
      }
    }
    carrinho.add(ItemCarrinho(
      id: id,
      nome: p.nome,
      preco: p.preco,
      imagem: p.imagem,
      icon: p.icon,
      qtd: qtd,
    ));
    notifyListeners();
  }

  void adicionarItem(ItemCarrinho item) {
    carrinho.add(item);
    notifyListeners();
  }

  void alterarQuantidade(String id, int delta) {
    for (final i in List<ItemCarrinho>.from(carrinho)) {
      if (i.id == id) {
        i.qtd += delta;
        if (i.qtd <= 0) carrinho.remove(i);
        break;
      }
    }
    notifyListeners();
  }

  void removerItem(String id) {
    carrinho.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void limparCarrinho() {
    carrinho.clear();
    cupomAplicado = null;
    notifyListeners();
  }

  /// true se o cupom existe e foi aplicado.
  bool aplicarCupom(String codigo) {
    final c = codigo.trim().toUpperCase();
    if (!cupons.containsKey(c)) return false;
    cupomAplicado = c;
    notifyListeners();
    return true;
  }

  // ================= pedidos =================
  Pedido criarPedido(String modo) {
    final agora = DateTime.now();
    final pedido = Pedido(
      id: _gerarId('PD'),
      clienteEmail: usuarioLogado?.email ?? '',
      itens: carrinho
          .map((i) => ItemPedido(
              produtoId: i.id, nome: i.nome, preco: i.preco, qtd: i.qtd))
          .toList(),
      total: total,
      data: _formatarDataHora(agora),
      status: 'recebido',
      modo: modo,
    );
    pedidos.add(pedido);
    limparCarrinho();
    return pedido;
  }

  Pedido? pedidoPorId(String? id) {
    for (final p in pedidos) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Pedido> get meusPedidos {
    final email = usuarioLogado?.email;
    final lista =
        pedidos.where((p) => p.clienteEmail == email).toList();
    lista.sort((a, b) => b.id.compareTo(a.id));
    return lista;
  }

  void atualizarStatusPedido(String id, String status) {
    final p = pedidoPorId(id);
    if (p != null) {
      p.status = status;
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
    final r = Reserva(
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
    reservas.add(r);
    notifyListeners();
    return r;
  }

  Reserva? reservaPorId(String? id) {
    for (final r in reservas) {
      if (r.id == id) return r;
    }
    return null;
  }

  void atualizarStatusReserva(String id, String status) {
    final r = reservaPorId(id);
    if (r != null) {
      r.status = status;
      notifyListeners();
    }
  }

  // ================= vale-presentes =================
  ValePresente emitirValePresente({
    required double valor,
    required String destinatario,
    required String mensagem,
  }) {
    final vp = ValePresente(
      id: _gerarId('VP'),
      valor: valor,
      codigo: 'DVAN-${1000 + _rand.nextInt(9000)}-GIFT',
      status: 'ativo',
      criadoEm: _formatarData(DateTime.now()),
      destinatario: destinatario,
      mensagem: mensagem,
    );
    valePresentes.add(vp);
    notifyListeners();
    return vp;
  }

  void excluirValePresente(String id) {
    valePresentes.removeWhere((g) => g.id == id);
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

  static String _dois(int v) => v.toString().padLeft(2, '0');

  static String _formatarData(DateTime d) =>
      '${d.year}-${_dois(d.month)}-${_dois(d.day)}';

  static String _formatarDataHora(DateTime d) =>
      '${_dois(d.day)}/${_dois(d.month)}/${d.year} ${_dois(d.hour)}:${_dois(d.minute)}';
}

/// Formata valores como no protótipo (R$ 12,90).
String money(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
