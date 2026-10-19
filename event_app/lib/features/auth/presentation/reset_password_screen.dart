import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      ZestSnack.error(context, 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      if (mounted) {
        ZestSnack.success(context, 'Password updated successfully! 🎉');
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        final msg = 'Failed: $e';
        setState(() => _error = msg);
        ZestSnack.error(context, msg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestTokens.page,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: ZestBlobLogo(size: 56, animateOnLoad: true)),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: ZestTokens.display.copyWith(fontSize: 30),
                    children: [
                      const TextSpan(text: 'Set new '),
                      TextSpan(
                        text: 'password',
                        style: ZestTokens.accentItalic.copyWith(fontSize: 36),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a strong password with at least 6 characters.',
                  textAlign: TextAlign.center,
                  style: ZestTokens.body.copyWith(color: ZestTokens.ink2),
                ),
                const SizedBox(height: 28),
                ZestCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ZestTextField(
                        controller: _passwordController,
                        label: 'NEW PASSWORD',
                        hintText: '••••••••',
                        isPassword: true,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: ZestTokens.ink3, size: 20),
                        errorText: _error,
                        onSubmitted: (_) => _updatePassword(),
                      ),
                      const SizedBox(height: 22),
                      ZestButton(
                        text: 'Update Password ⚡',
                        isLoading: _isLoading,
                        fullWidth: true,
                        onPressed: _updatePassword,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
