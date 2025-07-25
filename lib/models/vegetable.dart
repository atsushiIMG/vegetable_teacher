import 'user_vegetable.dart';

class VegetableTask {
  final int day;
  final String type;
  final String description;

  const VegetableTask({
    required this.day,
    required this.type,
    required this.description,
  });

  factory VegetableTask.fromJson(Map<String, dynamic> json) {
    return VegetableTask(
      day: json['day'] as int,
      type: json['type'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'type': type,
      'description': description,
    };
  }

}

class VegetableSchedule {
  final List<VegetableTask> tasks;
  final int wateringBaseInterval;
  final int fertilizerInterval;

  const VegetableSchedule({
    required this.tasks,
    required this.wateringBaseInterval,
    required this.fertilizerInterval,
  });

  factory VegetableSchedule.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['tasks'] as List<dynamic>;
    final tasks = tasksJson
        .map((task) => VegetableTask.fromJson(task as Map<String, dynamic>))
        .toList();

    return VegetableSchedule(
      tasks: tasks,
      wateringBaseInterval: json['watering_base_interval'] as int,
      fertilizerInterval: json['fertilizer_interval'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'watering_base_interval': wateringBaseInterval,
      'fertilizer_interval': fertilizerInterval,
    };
  }
}

class Vegetable {
  final String id;
  final String name;
  final VegetableSchedule seedSchedule;
  final VegetableSchedule seedlingSchedule;
  final String? growingTips;
  final String? commonProblems;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vegetable({
    required this.id,
    required this.name,
    required this.seedSchedule,
    required this.seedlingSchedule,
    this.growingTips,
    this.commonProblems,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vegetable.fromSupabase(Map<String, dynamic> data) {
    final scheduleData = data['schedule'] as Map<String, dynamic>;
    
    return Vegetable(
      id: data['id'] as String,
      name: data['name'] as String,
      seedSchedule: VegetableSchedule.fromJson(scheduleData['seed_schedule'] as Map<String, dynamic>),
      seedlingSchedule: VegetableSchedule.fromJson(scheduleData['seedling_schedule'] as Map<String, dynamic>),
      growingTips: data['growing_tips'] as String?,
      commonProblems: data['common_problems'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'schedule': {
        'seed_schedule': seedSchedule.toJson(),
        'seedling_schedule': seedlingSchedule.toJson(),
      },
      'growing_tips': growingTips,
      'common_problems': commonProblems,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 植えタイプに応じた適切なスケジュールを取得
  VegetableSchedule getScheduleForPlantType(PlantType plantType) {
    switch (plantType) {
      case PlantType.seed:
        return seedSchedule;
      case PlantType.seedling:
        return seedlingSchedule;
    }
  }
}