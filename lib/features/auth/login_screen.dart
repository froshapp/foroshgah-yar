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
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController(text: 'https://apadanasleep.ir');
  final _tokenController = TextEditingController();
  bool _obscureToken = true;

  static const _bg = Color(0xFF1A1B2E);
  static const _card = Color(0xFF252640);
  static const _primary = Color(0xFF6C63FF);
  static const _text = Color(0xFFF0F0F5);
  static const _muted = Color(0xFF9A9BB0);

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final storeService = context.read<StoreService>();

    final success = await auth.connectWithToken(
      siteUrl: _urlController.text.trim(),
      token: _tokenController.text.trim(),
    );

    if (success && mounted) {
      final site = auth.site;
      await storeService.addStore(Store(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: site?['name'] ?? 'فروشگاه',
        url: _urlController.text.trim(),
        token: _tokenController.text.trim(),
      ));
    }
  }

  InputDecoration _dec({required String label, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted, fontSize: 14),
      prefixIcon: Icon(icon, color: _muted, size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF2D2E48),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.storefront_rounded, size: 42, color: _primary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'فروشگاه‌یار',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _text, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'مدیریت فروشگاه ووکامرس',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  // کارت فرم
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _urlController,
                          style: const TextStyle(color: _text, fontSize: 15),
                          keyboardType: TextInputType.url,
                          textDirection: TextDirection.ltr,
                          decoration: _dec(label: 'آدرس سایت', icon: Icons.language),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'آدرس سایت را وارد کنید';
                            if (!v.startsWith('http')) return 'آدرس باید با https شروع شود';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _tokenController,
                          obscureText: _obscureToken,
                          style: const TextStyle(color: _text, fontSize: 15, letterSpacing: 1),
                          textDirection: TextDirection.ltr,
                          decoration: _dec(
                            label: 'توکن اتصال',
                            icon: Icons.vpn_key_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                _obscureToken ? Icons.visibility_off : Icons.visibility,
                                color: _muted,
                              ),
                              onPressed: () => setState(() => _obscureToken = !_obscureToken),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'توکن الزامی است' : null,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'توکن را از پیشخوان وردپرس ← فروشگاه‌یار بسازید',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                        if (auth.error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              auth.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _connect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
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
        ),
      ),
    );
  }
}
