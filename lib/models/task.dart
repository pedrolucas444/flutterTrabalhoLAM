import 'dart:convert';

class Task {
  // Identificação básica e metadados
  final int id; // Mantido não-nulo para compatibilidade com armazenamento atual
  final String title;
  final String description;
  final String priority;
  final bool completed;
  final DateTime createdAt;

  // Campo legado ainda usado na UI atual (será removido/migrado depois)
  final DateTime? dueDate;

  // MULTIPLAS FOTOS: lista com paths locais
  final List<String>? photoPaths;

  // SENSORES
  final DateTime? completedAt;
  final String? completedBy; // 'manual', 'shake'

  // GPS
  final double? latitude;
  final double? longitude;
  final String? locationName;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = 'medium',
    this.completed = false,
    DateTime? createdAt,
    this.dueDate,
    this.photoPaths,
    this.completedAt,
    this.completedBy,
    this.latitude,
    this.longitude,
    this.locationName,
  }) : createdAt = createdAt ?? DateTime.now();

  // Compatibilidade: retorna o primeiro photoPath quando necessário
  String? get photoPath => (photoPaths != null && photoPaths!.isNotEmpty) ? photoPaths!.first : null;

  // Getters auxiliares
  bool get hasPhoto => (photoPaths != null && photoPaths!.isNotEmpty) || (photoPath != null && photoPath!.isNotEmpty);
  bool get hasLocation => latitude != null && longitude != null;
  bool get wasCompletedByShake => completedBy == 'shake';

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? priority,
    bool? completed,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String>? photoPaths,
    DateTime? completedAt,
    String? completedBy,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      photoPaths: photoPaths ?? this.photoPaths,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  // JSON (compatível com armazenamento atual via SharedPreferences)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority,
        'completed': completed,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
    // Para compatibilidade com o banco atual guardamos o JSON da lista dentro de 'photoPath'
    'photoPath': jsonEncode(photoPaths ?? []),
        'completedAt': completedAt?.toIso8601String(),
        'completedBy': completedBy,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    // photoPaths may be stored as JSON string or missing
    List<String>? parsedPhotoPaths;
    try {
      final raw = json['photoPath'];
      if (raw is String && raw.isNotEmpty) {
        // try parse as JSON array first (we store JSON array in photoPath for compatibility)
        if (raw.trimLeft().startsWith('[')) {
          final decoded = jsonDecode(raw);
          if (decoded is List) parsedPhotoPaths = decoded.map((e) => e.toString()).toList();
        } else {
          // fallback: single path string
          parsedPhotoPaths = [raw];
        }
      }
    } catch (_) {}

    return Task(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
      completed: json['completed'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
      photoPaths: parsedPhotoPaths,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
      completedBy: json['completedBy'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
    );
  }

  // Map para uso futuro com SQLite (sqflite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'completed': completed ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      // Persist as JSON in the existing 'photoPath' column (keeps DB schema)
        'photoPath': jsonEncode(photoPaths ?? []),
      'completedAt': completedAt?.toIso8601String(),
      'completedBy': completedBy,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    List<String>? parsedPhotoPaths;
    try {
      final raw = map['photoPath'];
      if (raw is String && raw.isNotEmpty) {
        if (raw.trimLeft().startsWith('[')) {
          final decoded = jsonDecode(raw);
          if (decoded is List) parsedPhotoPaths = decoded.map((e) => e.toString()).toList();
        } else {
          parsedPhotoPaths = [raw];
        }
      }
    } catch (_) {}

    return Task(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      priority: map['priority'] as String? ?? 'medium',
      completed: (map['completed'] is int)
          ? ((map['completed'] as int) == 1)
          : (map['completed'] as bool? ?? false),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['dueDate'] as String? ?? ''),
      photoPaths: parsedPhotoPaths,
      completedAt: DateTime.tryParse(map['completedAt'] as String? ?? ''),
      completedBy: map['completedBy'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      locationName: map['locationName'] as String?,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, completed: $completed, priority: $priority, dueDate: $dueDate, photos: ${photoPaths?.length ?? 0})';
  }
}
