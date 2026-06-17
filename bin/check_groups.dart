import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  final supabaseUrl = 'https://mjbpjtwlgwytiolvlkhn.supabase.co';
  final supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1qYnBqdHdsZ3d5dGlvbHZsa2huIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5Mjg3NzQsImV4cCI6MjA5NTUwNDc3NH0.LO2KtSX2pvrFuQXVw5BPwvsONc0yTmNy-P_EcVcsd90';

  final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);

  try {
    final data = await supabase.from('sports_groups').select('nama_grup');
    print('GRUP: $data');
  } catch (e) {
    print('ERROR: $e');
  }
  exit(0);
}
