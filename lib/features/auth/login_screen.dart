import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/store_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _urlController = TextEditingController(text: 'https://apadanasleep.ir');
  final _tokenController = TextEditingController();
  bool _hideToken = true;

  static const bg = Color(0xFF16162A);
  static const card = Color(0xFF22223A);
  static const accent = Color(0xFF7C6CFF);
  static const white = Color(0xFFF5F5FA);
  static const grey = Color(0xFF9B9BB5);

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final url = _urlController.text.trim();
    final token = _tokenController.text.trim();

    if (url.isEmpty || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('آدرس سایت و توکن را وارد کنید')),
      );
      return;
    }

    final auth = context.read<AuthService>();
    final storeService = context.read<StoreService>();

    final ok = await auth.connectWithToken(siteUrl: url, token: token);

    if (ok && mounted) {
      final site = auth.site;
      await storeService.addStore(Store(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: site?['name'] ?? 'فروشگاه',
        url: url,
        token: token,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.storefront_rounded, size: 36, color: accent),
              ),
              const SizedBox(height: 18),
              const Text(
                'فروشگاه‌یار',
                style: TextStyle(color: white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'مدیریت فروشگاه ووکامرس',
                style: TextStyle(color: grey, fontSize: 14),
              ),
              const SizedBox(height: 36),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('آدرس سایت', style: TextStyle(color: grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      cursorColor: accent,
                      textDirection: TextDirection.ltr,
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2E2E4A),
                        hintText: 'https://example.com',
                        hintStyle: const TextStyle(color: Color(0xFF6A6A85)),
                        prefixIcon: const Icon(Icons.language, color: grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('توکن اتصال', style: TextStyle(color: grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tokenController,
                      obscureText: _hideToken,
                      style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 0.5),
                      cursorColor: accent,
                      textDirection: TextDirection.ltr,
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2E2E4A),
                        hintText: 'توکن را اینجا بچسبانید',
                        hintStyle: const TextStyle(color: Color(0xFF6A6A85)),
                        prefixIcon: const Icon(Icons.vpn_key_rounded, color: grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hideToken ? Icons.visibility_off : Icons.visibility,
                            color: grey,
                          ),
                          onPressed: () => setState(() => _hideToken = !_hideToken),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'توکن را از پیشخوان وردپرس ← فروشگاه‌یار بسازید\n(بدون تاریخ انقضا تا وقتی خودتان حذف کنید)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: grey, fontSize: 11, height: 1.5),
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          auth.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _connect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Text(
                                'ورود به فروشگاه',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
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
