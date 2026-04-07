import '../../domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.theNumber,
    required super.name,
    super.foreignName,
    required super.isActive,
    super.imageUrl,
    super.latitude,
    super.longitude,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id']?.toString() ?? '',
      theNumber: json['theNumber']?.toString() ?? '',
      name: json['name'] ?? '',
      foreignName: json['foreignName'],
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'] ?? json['imagUrl'],
      latitude: json['latitude'] != null ? (json['latitude']).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude']).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'theNumber': theNumber,
      'name': name,
      'foreignName': foreignName,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
