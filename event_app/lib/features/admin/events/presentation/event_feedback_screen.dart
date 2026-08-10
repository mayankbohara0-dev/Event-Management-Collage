import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../admin_colors.dart';

class EventFeedbackScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventFeedbackScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventFeedbackScreen> createState() => _EventFeedbackScreenState();
}

class _EventFeedbackScreenState extends ConsumerState<EventFeedbackScreen> {
  bool _isLoading = true;
  String _eventTitle = '';
  List<Map<String, dynamic>> _feedbacks = [];
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    setState(() => _isLoading = true);
    try {
      final event = await Supabase.instance.client
          .from('events')
          .select('title')
          .eq('id', widget.eventId)
          .single();
      _eventTitle = event['title'];

      final feedbacksRes = await Supabase.instance.client
          .from('event_feedback')
          .select('id, rating, review, created_at, student_profiles(name, roll_number)')
          .eq('event_id', widget.eventId)
          .order('created_at', ascending: false);

      final feedbacks = List<Map<String, dynamic>>.from(feedbacksRes);
      
      double sum = 0;
      for (final f in feedbacks) {
        sum += (f['rating'] as num).toDouble();
      }
      final avg = feedbacks.isNotEmpty ? sum / feedbacks.length : 0.0;

      if (mounted) {
        setState(() {
          _feedbacks = feedbacks;
          _averageRating = avg;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading feedback: $e'), backgroundColor: AdminColors.error),
        );
      }
    }
  }

  Future<void> _requestFeedback() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.surface,
        title: Text('Request Feedback', style: GoogleFonts.inter(color: AdminColors.textPrimary)),
        content: Text('Send a notification to all attended students asking them to rate this event?',
            style: GoogleFonts.inter(color: AdminColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AdminColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.accent),
            child: const Text('Send Requests'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client.rpc('request_event_feedback', params: {'p_event_id': widget.eventId});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback requests sent!'), backgroundColor: AdminColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send requests: $e'), backgroundColor: AdminColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      appBar: AppBar(
        backgroundColor: AdminColors.sidebar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AdminColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Feedback: $_eventTitle',
          style: GoogleFonts.inter(color: AdminColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _requestFeedback,
              icon: const Icon(Icons.notifications_active_rounded, size: 16),
              label: const Text('Request Feedback'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AdminColors.accent))
          : Column(
              children: [
                // Average Rating Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: AdminColors.surface,
                    border: Border(bottom: BorderSide(color: AdminColors.border)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < _averageRating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 32,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on ${_feedbacks.length} reviews',
                        style: GoogleFonts.inter(color: AdminColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Reviews List
                Expanded(
                  child: _feedbacks.isEmpty
                      ? Center(
                          child: Text(
                            'No feedback received yet.',
                            style: GoogleFonts.inter(color: AdminColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: _feedbacks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final f = _feedbacks[index];
                            final profile = f['student_profiles'];
                            final studentName = profile != null ? profile['name'] : 'Unknown';
                            final roll = profile != null ? profile['roll_number'] : '';
                            
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AdminColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AdminColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AdminColors.accent.withValues(alpha: 0.1),
                                        child: Text(
                                          studentName[0],
                                          style: const TextStyle(color: AdminColors.accent, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              studentName,
                                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                                            ),
                                            if (roll != null)
                                              Text(roll, style: GoogleFonts.inter(fontSize: 12, color: AdminColors.textSecondary)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(5, (i) {
                                          return Icon(
                                            i < f['rating'] ? Icons.star_rounded : Icons.star_border_rounded,
                                            color: Colors.amber,
                                            size: 16,
                                          );
                                        }),
                                      )
                                    ],
                                  ),
                                  if (f['review'] != null && f['review'].toString().trim().isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      f['review'],
                                      style: GoogleFonts.inter(color: AdminColors.textSecondary, height: 1.5),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
