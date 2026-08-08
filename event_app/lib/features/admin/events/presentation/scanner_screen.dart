import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:event_app/core/design_system.dart';

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
      // Find the registration by qr_code_data OR id (for manual fallback)
      final regRes = await Supabase.instance.client
          .from('registrations')
          .select('id, student_id, student_profiles(name, roll_number)')
          .or('qr_code_data.eq.$rawValue,id.eq.$rawValue')
          .eq('event_id', widget.eventId)
          .maybeSingle();
          
      if (regRes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Invalid Ticket or Wrong Event!'), backgroundColor: AppColors.error),
          );
        }
      } else {
        final registrationId = regRes['id'];
        final studentId = regRes['student_id'];
        final studentName = regRes['student_profiles']['name'] ?? 'Student';
        
        // Mark Attendance
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
            
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Success! Marked $studentName as attended.'),
              backgroundColor: AppColors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
    
    // Wait a bit before allowing next scan to avoid duplicates
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: Text('Scan Tickets', style: TextStyle(color: AppColors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
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
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? AppColors.yellow : AppColors.green,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          if (_isProcessing)
            Center(
              child: CircularProgressIndicator(color: AppColors.white),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Point camera at Student Ticket',
                  style: TextStyle(color: AppColors.white, fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.green,
        onPressed: () {
          final tec = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.black,
              title: const Text('Manual Entry', style: TextStyle(color: AppColors.white)),
              content: TextField(
                controller: tec,
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Enter Registration ID or QR data',
                  hintStyle: const TextStyle(color: AppColors.grey400),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.grey800)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.green)),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.grey400)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (tec.text.trim().isNotEmpty) {
                      _processQR(tec.text.trim());
                    }
                  },
                  child: const Text('Submit', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.keyboard, color: AppColors.black),
        label: const Text('Manual Entry', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
