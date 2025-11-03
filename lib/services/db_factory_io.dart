import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Initialize sqflite factory for desktop (macOS/Windows/Linux).
Future<void> initDatabaseFactory() async {
  if (Platform.isAndroid || Platform.isIOS) {
    // Mobile platforms use the default sqflite implementation.
    return;
  }
  // Desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
