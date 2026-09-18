import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/ui_kit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final senha = TextEditingController();
  String? erro;

  @override
  void dispose() {
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  void _entrar() {
    final mensagem = AppState.instance.login(email.text, senha.text);
    if (mensagem != null) {
      setState(() => erro = mensagem);
      return;
    }
    showToast('Login realizado com sucesso!', '👋');

    final arg = ModalRoute.of(context)?.settings.arguments;
    final navigator = Navigator.of(context);
    if (arg is RedirecionamentoLogin) {
      navigator.pushNamedAndRemoveUntil(arg.rota, (r) => false,
          arguments: arg.argumentos);
      return;
    }
    navigator.pushNamedAndRemoveUntil(
        AppState.instance.isAdmin ? Routes.admin : Routes.home, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      child: Column(
        children: [
          const SizedBox(height: 56),
          ContentWidth(
            maxWidth: 480,
            child: InfoBox(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const SectionHead(
                      eyebrow: 'Bem-vindo(a) de volta', titulo: 'Entrar'),
                  const SizedBox(height: 24),
                  if (erro != null) CaixaAlerta(erro!),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: senha,
                    obscureText: true,
                    onSubmitted: (_) => _entrar(),
                    decoration: const InputDecoration(labelText: 'Senha'),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        onPressed: _entrar, child: const Text('Entrar')),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, Routes.recuperarSenha),
                    child: const Text('Esqueci minha senha'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Ainda não tem conta?'),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.cadastro),
                        child: const Text('Criar conta'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const DicaCampo(
                    'Demonstração — cliente: marina@email.com / Marina@123 · admin: admin@dvanille.com / Admin@123',
                    align: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
