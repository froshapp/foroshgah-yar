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
  final _urlController = TextEditingController(text: 'https://apadanasleep.ir');
  final _tokenController = TextEditingController();
  bool _hideToken = true;

  static const bg = Color(0xFF16162A);
  static const card = Color(0xFF22223A);
  static const field = Color(0xFF2E2E4A);
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(text, style: const TextStyle(color: grey, fontSize: 13)),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? trailing,
    TextInputType? type,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: field,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(icon, color: grey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: type,
              style: const TextStyle(color: white, fontSize: 15),
              cursorColor: accent,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF6A6A85), fontSize: 14),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (trailing != null) trailing,
          const SizedBox(width: 6),
        ],
      ),
    );
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
              // لوگو
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
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

              // کارت فرم
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
                    _label('آدرس سایت'),
                    _field(
                      controller: _urlController,
                      hint: 'https://example.com',
                      icon: Icons.language,
                      type: TextInputType.url,
                    ),
                    const SizedBox(height: 18),
                    _label('توکن اتصال'),
                    _field(
                      controller: _tokenController,
                      hint: 'توکن را اینجا بچسبانید',
                      icon: Icons.vpn_key_rounded,
                      obscure: _hideToken,
                      trailing: IconButton(
                        icon: Icon(
                          _hideToken ? Icons.visibility_off : Icons.visibility,
                          color: grey,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _hideToken = !_hideToken),
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
                          disabledBackgroundColor: accent.withOpacity(0.5),
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
    );
  }
}
