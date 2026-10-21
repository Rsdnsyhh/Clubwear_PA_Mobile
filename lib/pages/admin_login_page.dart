import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/clubwear_provider.dart';
import '../widgets/common_widgets.dart';
import 'admin_dashboard_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if ((credential.user?.email ?? '') != ClubwearProvider.adminEmail) {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _loading = false;
          _error = 'Email ini bukan akun admin.';
        });
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AdminDashboardPage()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'user-not-found' ||
        'invalid-credential' ||
        'wrong-password' =>
        'Email atau password salah.',
        'network-request-failed' => 'Koneksi bermasalah.',
        _ => e.message ?? 'Login admin gagal.',
      };
      setState(() {
        _loading = false;
        _error = message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Terjadi kesalahan. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Admin Login',
      subtitle: 'Masuk dengan akun admin Clubwear.',
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _emailController,
              hint: 'Email Admin',
              icon: Icons.admin_panel_settings_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _passwordController,
              hint: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: Validators.password,
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Masuk sebagai Admin',
              isLoading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text(
                  '← Kembali ke login pengguna',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}