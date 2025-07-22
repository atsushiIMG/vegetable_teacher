enum PlantType {
  seed('種'),
  seedling('苗');

  const PlantType(this.displayName);
  final String displayName;
}

enum LocationType {
  pot('鉢'),
  field('畑');

  const LocationType(this.displayName);
  final String displayName;
}

enum VegetableStatus {
  growing('growing'),
  harvested('harvested'),
  archived('archived');

  const VegetableStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case VegetableStatus.growing:
        return '栽培中';
      case VegetableStatus.harvested:
        return '収穫済み';
      case VegetableStatus.archived:
        return 'アーカイブ';
    }
  }
}

class UserVegetable {
  final String id;
  final String userId;
  final String vegetableId;
  final DateTime plantedDate;
  final PlantType plantType;
  final LocationType location;
  final bool isPhotoMode;
  final String? photoId;
  final VegetableStatus status;
  final Map<String, dynamic> scheduleAdjustments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserVegetable({
    required this.id,
    required this.userId,
    required this.vegetableId,
    required this.plantedDate,
    required this.plantType,
    required this.location,
    this.isPhotoMode = false,
    this.photoId,
    this.status = VegetableStatus.growing,
    this.scheduleAdjustments = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserVegetable.fromSupabase(Map<String, dynamic> data) {
    return UserVegetable(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      vegetableId: data['vegetable_id'] as String,
      plantedDate: DateTime.parse(data['planted_date'] as String),
      plantType: data['plant_type'] == '種' ? PlantType.seed : PlantType.seedling,
      location: data['location'] == '鉢' ? LocationType.pot : LocationType.field,
      isPhotoMode: data['is_photo_mode'] as bool? ?? false,
      photoId: data['photo_id'] as String?,
      status: VegetableStatus.values.firstWhere(
        (status) => status.value == data['status'],
        orElse: () => VegetableStatus.growing,
      ),
      scheduleAdjustments: data['schedule_adjustments'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'vegetable_id': vegetableId,
      'planted_date': plantedDate.toIso8601String().split('T')[0], // Date only
      'plant_type': plantType.displayName,
      'location': location.displayName,
      'is_photo_mode': isPhotoMode,
      'photo_id': photoId,
      'status': status.value,
      'schedule_adjustments': scheduleAdjustments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserVegetable copyWith({
    String? id,
    String? userId,
    String? vegetableId,
    DateTime? plantedDate,
    PlantType? plantType,
    LocationType? location,
    bool? isPhotoMode,
    String? photoId,
    VegetableStatus? status,
    Map<String, dynamic>? scheduleAdjustments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserVegetable(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vegetableId: vegetableId ?? this.vegetableId,
      plantedDate: plantedDate ?? this.plantedDate,
      plantType: plantType ?? this.plantType,
      location: location ?? this.location,
      isPhotoMode: isPhotoMode ?? this.isPhotoMode,
      photoId: photoId ?? this.photoId,
      status: status ?? this.status,
      scheduleAdjustments: scheduleAdjustments ?? this.scheduleAdjustments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get daysSincePlanted {
    return DateTime.now().difference(plantedDate).inDays;
  }
}