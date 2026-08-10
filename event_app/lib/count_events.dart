import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://fgdrvtonfgeuboggucoe.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZnZHJ2dG9uZmdldWJvZ2d1Y29lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwOTQyNzAsImV4cCI6MjEwMTY3MDI3MH0.A7Oghf0CjCjZKEmZ5PqhHKXLXP86MaPUWFMy_aoVaJM';

  final client = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    final response = await client.from('events').select('id');
    final list = response as List;
    print(list.length);
    exit(0);
  } catch (e) {
    print('Error: ' + e.toString());
    exit(1);
  }
}
