import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tugas3_test/pages/auth/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

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
      home: session != null
          ? const _PlaceholderHome() // TODO: ganti dengan MainShellPage setelah dibuat
          : const LoginPage(),
    );
  }
}

/// Placeholder sementara sampai main_shell_page.dart selesai dibuat.
/// Dipakai supaya main.dart tetap bisa jalan dan dites tanpa error,
/// meskipun MainShellPage belum jadi.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '-';
    return Scaffold(
      appBar: AppBar(title: const Text('Sudah Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Login berhasil sebagai:\n$email',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              },
              child: const Text('Logout (sementara)'),
            ),
          ],
        ),
      ),
    );
  }
}
