import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/common_widgets.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _newPasswordController = TextEditingController();

  bool _saving = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    final u = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(
      text: u?.displayName ?? 'Admin',
    );
    _emailController = TextEditingController(text: u?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'Kamu belum login.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });

    final messages = <String>[];

    try {
      // ========== 1) USERNAME (bisa langsung) ==========
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty && newName != (user.displayName ?? '')) {
        await user.updateDisplayName(newName);
        await user.reload();
        messages.add('Username diperbarui.');
      }

      // ========== 2) EMAIL (verifikasi via link) ==========
      final newEmail = _emailController.text.trim();
      if (newEmail.isNotEmpty && newEmail != (user.email ?? '')) {
        await user.verifyBeforeUpdateEmail(newEmail);
        messages.add(
          'Link verifikasi dikirim ke $newEmail. '
              'Klik link tersebut untuk menyelesaikan perubahan email.',
        );
      }

      // ========== 3) PASSWORD (reset via link) ==========
      final newPw = _newPasswordController.text;
      if (newPw.isNotEmpty) {
        final email = user.email;
        if (email == null || email.isEmpty) {
          throw StateError('Email admin tidak ditemukan.');
        }
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        messages.add(
          'Link reset password dikirim ke $email. '
              'Klik link tersebut untuk mengatur password baru.',
        );
        _newPasswordController.clear();
      }

      if (!mounted) return;
      setState(() {
        _saving = false;
        _success = messages.isEmpty
            ? 'Tidak ada perubahan.'
            : messages.join('\n\n');
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'requires-recent-login' =>
        'Sesi sudah lama. Silakan keluar lalu login ulang untuk '
            'mengubah email.',
        'email-already-in-use' => 'Email sudah dipakai akun lain.',
        'invalid-email' => 'Format email tidak valid.',
        'weak-password' => 'Password terlalu lemah (min. 6 karakter).',
        _ => e.message ?? 'Gagal memperbarui profil.',
      };
      setState(() {
        _saving = false;
        _error = message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final initial =
    (user?.displayName?.isNotEmpty ?? false) ? user!.displayName![0] : 'A';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text(
                  initial.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user?.displayName ?? 'Admin',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _nameController,
                hint: 'Username',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.notEmpty(v, 'Username'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _newPasswordController,
                hint: 'Password baru (opsional)',
                icon: Icons.lock_outline,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (v.length < 6) return 'Minimal 6 karakter.';
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
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
                ),
              ],
              if (_success != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F7A6B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 16, color: Color(0xFF1F7A6B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _success!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF1F7A6B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Simpan Perubahan',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ],
    );
  }
}