import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/store_service.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _obscureToken = true;

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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.storefront_rounded, size: 72, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'فروشگاه‌یار',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اتصال امن با توکن',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'آدرس سایت',
                      hintText: 'https://example.com',
                      prefixIcon: Icon(Icons.language),
                    ),
                    keyboardType: TextInputType.url,
                    textDirection: TextDirection.ltr,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'آدرس سایت را وارد کنید';
                      if (!v.startsWith('http')) return 'آدرس باید با http شروع شود';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _tokenController,
                    obscureText: _obscureToken,
                    decoration: InputDecoration(
                      labelText: 'توکن اتصال',
                      hintText: 'توکن را از پیشخوان سایت کپی کنید',
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureToken ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureToken = !_obscureToken),
                      ),
                    ),
                    textDirection: TextDirection.ltr,
                    validator: (v) => v == null || v.trim().isEmpty ? 'توکن الزامی است' : null,
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'از پیشخوان وردپرس ← منوی فروشگاه‌یار ← «ساخت توکن» بگیرید و اینجا وارد کنید.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (auth.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        auth.error!,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _connect,
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('اتصال به فروشگاه'),
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
