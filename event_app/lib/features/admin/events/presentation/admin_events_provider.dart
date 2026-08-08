// lib/features/admin/events/presentation/admin_events_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides a list of events for the admin dashboard.
/// Auth is enforced at the router level — no silent profile creation here.
final adminEventsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('events')
      .select('id, title, start_date, max_seats, visibility, venue, created_at')
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
});
