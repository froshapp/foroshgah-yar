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
  final _url = TextEditingController(text: 'https://apadanasleep.ir');
  final _token = TextEditingController();
  bool _hide = true;

  @override
  void dispose() {
    _url.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final u = _url.text.trim();
    final t = _token.text.trim();
    if (u.isEmpty || t.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('آدرس و توکن را پر کنید')),
      );
      return;
    }
    final auth = context.read<AuthService>();
    final stores = context.read<StoreService>();
    final ok = await auth.connectWithToken(siteUrl: u, token: t);
    if (ok && mounted) {
      await stores.addStore(Store(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: auth.site?['name'] ?? 'فروشگاه',
        url: u,
        token: t,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1B2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.storefront, size: 34, color: Color(0xFF6C63FF)),
              ),
              const SizedBox(height: 16),
              const Text(
                'فروشگاه‌یار',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'مدیریت فروشگاه ووکامرس',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF252640),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('آدرس سایت', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _url,
                      keyboardType: TextInputType.url,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                      cursorColor: Colors.black,
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFECECF3),
                        hintText: 'https://apadanasleep.ir',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.language, color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('توکن اتصال', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _token,
                      obscureText: _hide,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                      cursorColor: Colors.black,
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFECECF3),
                        hintText: 'توکن را اینجا بچسبانید',
                        hintStyle: const TextStyle(color: Colors.black38),
                        prefixIcon: const Icon(Icons.vpn_key, color: Colors.black54),
                        suffixIcon: IconButton(
                          icon: Icon(_hide ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'توکن را از پیشخوان وردپرس ← فروشگاه‌یار بسازید',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 12),
                      Text(auth.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _go,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('ورود به فروشگاه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
