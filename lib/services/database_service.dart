import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class DatabaseService {
  DatabaseService._privateConstructor();

  static final DatabaseService instance = DatabaseService._privateConstructor();

  static const _key = 'tasks_storage_v1';

  Future<List<Task>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return <Task>[];
    try {
      final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
      final tasks = data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (_) {
      return <Task>[];
    }
  }

  Future<Task> create(Task task) async {
    final tasks = await readAll();
    // ensure unique id - if zero treat as new
    final id = task.id == 0 ? DateTime.now().millisecondsSinceEpoch : task.id;
    final newTask = task.copyWith(id: id);
    tasks.insert(0, newTask);
    await _saveAll(tasks);
    return newTask;
  }

  Future<void> update(Task task) async {
    final tasks = await readAll();
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      tasks[idx] = task;
      await _saveAll(tasks);
    }
  }

  Future<void> delete(int id) async {
    final tasks = await readAll();
    tasks.removeWhere((t) => t.id == id);
    await _saveAll(tasks);
  }

  Future<void> _saveAll(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}
