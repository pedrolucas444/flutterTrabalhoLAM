import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Initialize sqflite factory for Flutter Web (IndexedDB backend)
Future<void> initDatabaseFactory() async {
  databaseFactory = databaseFactoryFfiWeb;
}
