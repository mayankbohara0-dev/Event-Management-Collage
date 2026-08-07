import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design_system.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  Map<String, dynamic>? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvent();
  }

  Future<void> _fetchEvent() async {
    try {
      final res = await Supabase.instance.client
          .from('events')
          .select('*, categories(name)')
          .eq('id', widget.eventId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _event = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.green)),
      );
    }

    if (_event == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Event not found')),
        body: const Center(child: Text('This event does not exist or was removed.')),
      );
    }

    final title = _event!['title'] ?? '';
    final shortDesc = _event!['short_description'] ?? '';
    final longDesc = _event!['long_description'] ?? '';
    final venue = _event!['venue'] ?? 'TBA';
    final coverImage = _event!['cover_image_url'];
    final category = _event!['categories']?['name'] ?? 'General';
    final startDateStr = _event!['start_date'];
    final endDateStr = _event!['end_date'];
    
    DateTime? startDate = startDateStr != null ? DateTime.tryParse(startDateStr)?.toLocal() : null;
    DateTime? endDate = endDateStr != null ? DateTime.tryParse(endDateStr)?.toLocal() : null;

    final dateString = startDate != null
        ? '${startDate.day}/${startDate.month}/${startDate.year}'
        : 'Date TBA';
    
    final timeString = startDate != null
        ? '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}'
        : 'Time TBA';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.green,
            flexibleSpace: FlexibleSpaceBar(
              background: coverImage != null && coverImage.isNotEmpty
                  ? Image.network(coverImage, fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                      child: const Center(
                        child: Icon(Icons.event_rounded, size: 80, color: Colors.white24),
                      ),
                    ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.black,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Key Details Cards
                    Row(
                      children: [
                        Expanded(child: _InfoTile(icon: Icons.calendar_today_rounded, label: 'Date', value: dateString)),
                        const SizedBox(width: 12),
                        Expanded(child: _InfoTile(icon: Icons.access_time_rounded, label: 'Time', value: timeString)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.location_on_rounded, label: 'Venue', value: venue),
                    
                    const SizedBox(height: 32),
                    
                    // Description
                    Text('About the Event',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black)),
                    const SizedBox(height: 12),
                    if (shortDesc.isNotEmpty) ...[
                      Text(shortDesc,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                              height: 1.5)),
                      const SizedBox(height: 12),
                    ],
                    Text(longDesc.isNotEmpty ? longDesc : 'No additional information provided.',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.grey600,
                            height: 1.6)),
                    const SizedBox(height: 100), // spacing for bottom nav
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button for Registration
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => context.push('/student/event/${widget.eventId}/register'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: Text(
            'Register Now',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 14, color: AppColors.black, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
