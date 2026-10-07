import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../pages/admin/admin_dashboard_page.dart';
import '../pages/admin/admin_pedidos_page.dart';
import '../pages/admin/admin_produto_form_page.dart';
import '../pages/admin/admin_produtos_page.dart';
import '../pages/admin/admin_reservas_page.dart';
import '../pages/admin/admin_usuarios_page.dart';
import '../pages/admin/admin_vale_presentes_page.dart';
import '../pages/auth/cadastro_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/recuperar_senha_page.dart';
import '../pages/cardapio/cardapio_page.dart';
import '../pages/cardapio/produto_page.dart';
import '../pages/cliente/acompanhar_pedido_page.dart';
import '../pages/cliente/carrinho_page.dart';
import '../pages/cliente/checkout_page.dart';
import '../pages/cliente/meus_pedidos_page.dart';
import '../pages/cliente/minhas_reservas_page.dart';
import '../pages/cliente/pedido_confirmado_page.dart';
import '../pages/cliente/perfil_page.dart';
import '../pages/cliente/reserva_confirmada_page.dart';
import '../pages/cliente/reservas_page.dart';
import '../pages/conheca/conheca_page.dart';
import '../pages/contato/contato_page.dart';
import '../pages/home/home_page.dart';
import '../pages/ofertas/ofertas_page.dart';
import '../pages/shopping/shopping_page.dart';
import '../services/app_state.dart';
import '../services/navigation.dart';
import '../theme/app_theme.dart';

class Routes {
  static const home = '/';
  static const conheca = '/conheca';
  static const cardapio = '/cardapio';
  static const produto = '/produto';
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const recuperarSenha = '/recuperar-senha';
  static const perfil = '/perfil';
  static const carrinho = '/carrinho';
  static const checkout = '/checkout';
  static const pedidoConfirmado = '/pedido-confirmado';
  static const meusPedidos = '/meus-pedidos';
  static const minhasReservas = '/minhas-reservas';
  static const acompanharPedido = '/pedido';
  static const reservas = '/reservas';
  static const reservaConfirmada = '/reserva-confirmada';
  static const ofertas = '/ofertas';
  static const shopping = '/shopping';
  static const contato = '/contato';

  static const admin = '/admin';
  static const adminProdutos = '/admin-produtos';
  static const adminProdutoForm = '/admin-produto-form';
  static const adminPedidos = '/admin-pedidos';
  static const adminReservas = '/admin-reservas';
  static const adminValePresentes = '/admin-vale-presentes';
  static const adminUsuarios = '/admin-usuarios';

  /// Rotas que exigem login.
  static const privadas = <String>[
    perfil,
    carrinho,
    checkout,
    pedidoConfirmado,
    meusPedidos,
    minhasReservas,
    acompanharPedido,
    reservas,
    reservaConfirmada,
    shopping,
  ];

  /// Rotas exclusivas do administrador.
  static const administrativas = <String>[
    admin,
    adminProdutos,
    adminProdutoForm,
    adminPedidos,
    adminReservas,
    adminValePresentes,
    adminUsuarios,
  ];
}

/// Argumento usado quando o login precisa devolver
/// o usuário à rota pedida.
class RedirecionamentoLogin {
  final String rota;
  final Object? argumentos;

  const RedirecionamentoLogin(
    this.rota,
    this.argumentos,
  );
}

class DVanilleApp extends StatelessWidget {
  const DVanilleApp({super.key});

  static final Map<String, WidgetBuilder> _paginas = {
    Routes.home: (_) => const HomePage(),
    Routes.conheca: (_) => const ConhecaPage(),
    Routes.cardapio: (_) => const CardapioPage(),
    Routes.produto: (_) => const ProdutoPage(),

    Routes.login: (_) => const LoginPage(),
    Routes.cadastro: (_) => const CadastroPage(),
    Routes.recuperarSenha: (_) => const RecuperarSenhaPage(),

    Routes.perfil: (_) => const PerfilPage(),

    Routes.carrinho: (_) => const CarrinhoPage(),
    Routes.checkout: (_) => const CheckoutPage(),

    Routes.pedidoConfirmado: (_) => const PedidoConfirmadoPage(),

    Routes.meusPedidos: (_) => const MeusPedidosPage(),

    Routes.minhasReservas: (_) => const MinhasReservasPage(),

    Routes.acompanharPedido: (_) => const AcompanharPedidoPage(),

    Routes.reservas: (_) => const ReservasPage(),

    Routes.reservaConfirmada: (_) => const ReservaConfirmadaPage(),

    Routes.ofertas: (_) => const OfertasPage(),

    Routes.shopping: (_) => const ShoppingPage(),

    Routes.contato: (_) => const ContatoPage(),

    // ================= ADMIN =================

    Routes.admin: (_) => const AdminDashboardPage(),

    Routes.adminProdutos: (_) => const AdminProdutosPage(),

    Routes.adminProdutoForm: (_) => const AdminProdutoFormPage(),

    Routes.adminPedidos: (_) => const AdminPedidosPage(),

    Routes.adminReservas: (_) => const AdminReservasPage(),

    Routes.adminValePresentes: (_) => const AdminValePresentesPage(),

    Routes.adminUsuarios: (_) => const AdminUsuariosPage(),
  };

  /// Guarda de rota — reproduz a função navigate()
  /// do protótipo HTML.
  Route<dynamic>? _gerarRota(
    RouteSettings settings,
  ) {
    final state = AppState.instance;

    var nome = settings.name ?? Routes.home;

    var argumentos = settings.arguments;

    if (Routes.administrativas.contains(nome) && !state.isAdmin) {
      showToast(
        'Acesso restrito ao administrador.',
        '⚠️',
      );

      nome = state.logado ? Routes.home : Routes.login;

      argumentos = null;
    } else if (Routes.privadas.contains(nome) && !state.logado) {
      showToast(
        'Faça login para continuar.',
        '🔒',
      );

      argumentos = RedirecionamentoLogin(
        nome,
        settings.arguments,
      );

      nome = Routes.login;
    }

    final builder = _paginas[nome] ?? _paginas[Routes.home]!;

    return MaterialPageRoute<dynamic>(
      builder: builder,
      settings: RouteSettings(
        name: nome,
        arguments: argumentos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return MaterialApp(
          title: "D'Vanille",

          debugShowCheckedModeBanner: false,

          navigatorKey: navigatorKey,

          scaffoldMessengerKey: messengerKey,

          theme: AppTheme.light,

          darkTheme: AppTheme.dark,

          themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,

          // ============================================================
          // LOCALIZAÇÃO
          // ============================================================

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: const [
            Locale('pt', 'BR'),
          ],

          locale: const Locale('pt', 'BR'),

          // ============================================================
          // ROTAS
          // ============================================================

          initialRoute: Routes.home,

          onGenerateRoute: _gerarRota,

          // ============================================================
          // ESCALA DE FONTE
          // ============================================================

          builder: (context, child) {
            final mq = MediaQuery.of(context);

            return MediaQuery(
              data: mq.copyWith(
                textScaler: TextScaler.linear(
                  state.fontScale,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
