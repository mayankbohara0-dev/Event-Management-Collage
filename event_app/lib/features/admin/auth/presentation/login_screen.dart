import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design_system.dart';

// Admin palette — dark professional
class AdminColors {
  static const Color bg = Color(0xFFF7F7F7);
  static const Color sidebar = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color accent = Color(0xFF00843D);
  static const Color gold = Color(0xFFFFB700);
  static const Color success = Color(0xFF00843D);
  static const Color error = Color(0xFFE31837);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF616161);
  static const Color border = Color(0xFFE5E5E5);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF006630), Color(0xFF00843D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Check admin_profiles table (the correct table per schema)
        final adminProfile = await Supabase.instance.client
            .from('admin_profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        if (adminProfile != null) {
          // User exists in admin_profiles — allow access
          if (mounted) context.go('/admin/dashboard');
        } else {
          // Not in admin_profiles — check if they have an admin role in student profiles as fallback
          await Supabase.instance.client.auth.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Access denied. This account is not registered as an admin.'),
                backgroundColor: AdminColors.error,
              ),
            );
          }
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top green band adapted for admin (dark)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(gradient: AdminColors.heroGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AdminColors.gold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('ADMIN PORTAL',
                        style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 12),
                  Text('Welcome Back, Admin',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900)),
                  Text('Sign in to manage the portal.',
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Container(
                color: AdminColors.surface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Email address',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.inter(color: AdminColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'admin@college.edu',
                          hintStyle: GoogleFonts.inter(color: AdminColors.textSecondary),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: AdminColors.textSecondary, size: 20),
                          filled: true,
                          fillColor: AdminColors.surfaceLight,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AdminColors.accent, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Password',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.inter(color: AdminColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: GoogleFonts.inter(color: AdminColors.textSecondary),
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: AdminColors.textSecondary, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AdminColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: AdminColors.surfaceLight,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AdminColors.accent, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColors.accent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('Sign In to Admin Portal',
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Access restricted to authorised administrators only.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AdminColors.textSecondary,
                              height: 1.5),
                        ),
                      ),
                    ],
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
