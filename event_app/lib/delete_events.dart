// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final supabaseUrl = 'https://fgdrvtonfgeuboggucoe.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZnZHJ2dG9uZmdldWJvZ2d1Y29lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwOTQyNzAsImV4cCI6MjEwMTY3MDI3MH0.A7Oghf0CjCjZKEmZ5PqhHKXLXP86MaPUWFMy_aoVaJM';

  final client = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    // Log in as an admin to get RLS permission to delete
    print('Logging in...');
    await client.auth.signInWithPassword(email: 'admin@eventcollage.com', password: 'password');
    
    print('Deleting all events...');
    final deleteRes = await client.from('events').delete().neq('id', '00000000-0000-0000-0000-000000000000').select();
    
    final list = deleteRes as List;
    print('Deleted:');
    print(list.length);
    exit(0);
  } catch (e) {
    print('Error: ' + e.toString());
    exit(1);
  }
}
