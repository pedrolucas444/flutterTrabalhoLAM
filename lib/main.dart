import 'package:flutter/material.dart';
import 'services/camera_service.dart';
import 'services/db_factory_stub.dart'
  if (dart.library.html) 'services/db_factory_web.dart'
  if (dart.library.io) 'services/db_factory_io.dart';
import 'screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize sqflite for current platform (web/desktop/mobile)
  await initDatabaseFactory();
  
  // Inicializar câmera
  await CameraService.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const TaskListScreen(),
    );
  }
}