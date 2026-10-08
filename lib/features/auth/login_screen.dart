import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/store_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final urlCtrl = TextEditingController(text: 'https://apadanasleep.ir');
  final tokenCtrl = TextEditingController();
  bool hide = true;

  @override
  void dispose() {
    urlCtrl.dispose();
    tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> connect() async {
    final url = urlCtrl.text.trim();
    final token = tokenCtrl.text.trim();
    if (url.isEmpty || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('آدرس و توکن را پر کنید')),
      );
      return;
    }
    final auth = context.read<AuthService>();
    final stores = context.read<StoreService>();
    final ok = await auth.connectWithToken(siteUrl: url, token: token);
    if (ok && mounted) {
      await stores.addStore(Store(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: auth.site?['name'] ?? 'فروشگاه',
        url: url,
        token: token,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.store, size: 64, color: Color(0xFF7C6CFF)),
            const SizedBox(height: 12),
            const Text(
              'فروشگاه‌یار',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'مدیریت فروشگاه ووکامرس',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 40),

            const Text('آدرس سایت', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            TextField(
              controller: urlCtrl,
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'https://apadanasleep.ir',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 20),

            const Text('توکن', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            TextField(
              controller: tokenCtrl,
              obscureText: hide,
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'توکن را اینجا بچسبان',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => hide = !hide),
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              'توکن را از پیشخوان وردپرس → فروشگاه‌یار کپی کنید',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),

            if (auth.error != null) ...[
              const SizedBox(height: 16),
              Text(
                auth.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],

            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : connect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C6CFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: auth.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ورود به فروشگاه', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
