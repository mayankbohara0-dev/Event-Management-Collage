import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      ZestSnack.error(context, 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'http://localhost:8080/#/auth/reset-password',
      );
      if (mounted) {
        ZestSnack.success(context, 'Check your email for the reset link!');
        context.go('/student/login');
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
                      const TextSpan(text: 'Reset '),
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
                  "Enter your registered campus email and we'll send you a recovery link.",
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
                        controller: _emailController,
                        label: 'CAMPUS EMAIL',
                        hintText: 'student@college.edu',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.alternate_email_rounded, color: ZestTokens.ink3, size: 20),
                        errorText: _error,
                      ),
                      const SizedBox(height: 22),
                      ZestButton(
                        text: 'Send Recovery Link ⚡',
                        isLoading: _isLoading,
                        fullWidth: true,
                        onPressed: _resetPassword,
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
