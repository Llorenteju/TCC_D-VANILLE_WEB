import 'package:flutter/material.dart';

import 'app/app.dart';
import 'services/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppState.instance.carregarDados();

  runApp(const DVanilleApp());
}
