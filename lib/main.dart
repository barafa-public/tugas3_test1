import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tugas3_test/pages/auth/login_page.dart';
import 'package:tugas3_test/pages/main_shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  print('BACKEND_URL: ${dotenv.env["BACKEND_URL"]}');

  await Supabase.initialize(
    url: dotenv.env["BACKEND_URL"] ?? '',
    publishableKey: dotenv.env["BACKEND_PUBLISHABLE_KEY"],
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Belanjaku',
      home: session != null ? MainShellPage() : const LoginPage(),
    );
  }
}
