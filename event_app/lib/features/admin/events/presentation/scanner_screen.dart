import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/zest_tokens.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class ScannerScreen extends StatefulWidget {

  final String eventId;
  const ScannerScreen({super.key, required this.eventId});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _processQR(String? rawValue) async {
    if (_isProcessing || rawValue == null) return;
    setState(() => _isProcessing = true);
    
    try {
      final regRes = await Supabase.instance.client
          .from('registrations')
          .select('id, student_id, student_profiles(name, roll_number)')
          .or('qr_code_data.eq.$rawValue,id.eq.$rawValue')
          .eq('event_id', widget.eventId)
          .maybeSingle();
          
      if (regRes == null) {
        if (mounted) {
          ZestSnack.show(
            context,
            message: 'Invalid pass or wrong event! 🍋',
            type: ZestSnackType.error,
          );
        }
      } else {
        final registrationId = regRes['id'];
        final studentId = regRes['student_id'];
        final studentName = regRes['student_profiles']?['name'] ?? 'Student';
        
        final admin = Supabase.instance.client.auth.currentUser;
        
        await Supabase.instance.client
            .from('attendance')
            .upsert({
              'registration_id': registrationId,
              'event_id': widget.eventId,
              'student_id': studentId,
              'check_in_time': DateTime.now().toIso8601String(),
              'marked_by': admin?.id,
              'method': 'qr_scan',
            }, onConflict: 'registration_id');

        // Award +80 XP to student profile
        if (studentId != null) {
          try {
            final pRes = await Supabase.instance.client
                .from('student_profiles')
                .select('points')
                .eq('id', studentId)
                .maybeSingle();
            final currentPts = (pRes?['points'] as num?)?.toInt() ?? 0;
            await Supabase.instance.client
                .from('student_profiles')
                .update({'points': currentPts + 80})
                .eq('id', studentId);
          } catch (_) {}
        }
            
        if (mounted) {
          ZestSnack.show(
            context,
            message: "You're in! Marked $studentName as attended (+80 XP) 🎟️",
            type: ZestSnackType.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ZestSnack.show(
          context,
          message: 'Error: $e',
          type: ZestSnackType.error,
        );
      }
    }
    
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Pass Scanner',
          style: ZestTokens.title.copyWith(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin/events');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                _processQR(barcodes.first.rawValue);
              }
            },
          ),
          // 250px Scanner Cutout with Blue Corner Brackets
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? ZestTokens.lemon : ZestTokens.core,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (_isProcessing ? ZestTokens.lemon : ZestTokens.core)
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: ZestTokens.borderPill,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.scanLine, color: ZestTokens.sky, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Point camera at Zest Event Pass',
                      style: ZestTokens.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ZestTokens.blue,
        onPressed: () {
          final tec = TextEditingController();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'Manual Entry',
                style: ZestTokens.title.copyWith(fontSize: 18),
              ),
              content: TextField(
                controller: tec,
                style: ZestTokens.body.copyWith(color: ZestTokens.ink),
                decoration: InputDecoration(
                  hintText: 'Enter Registration ID or QR data',
                  hintStyle: ZestTokens.body.copyWith(color: ZestTokens.ink3),
                  filled: true,
                  fillColor: ZestTokens.fill,
                  border: OutlineInputBorder(
                    borderRadius: ZestTokens.borderInput,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: ZestTokens.caption.copyWith(color: ZestTokens.ink3),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (tec.text.trim().isNotEmpty) {
                      _processQR(tec.text.trim());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZestTokens.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: ZestTokens.borderPill,
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(LucideIcons.keyboard, color: Colors.white, size: 18),
        label: const Text(
          'Manual Entry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
