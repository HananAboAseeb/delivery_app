import '../../domain/entities/store_entity.dart';

class RegionModel extends RegionEntity {
  const RegionModel({
    required super.id,
    required super.name,
    required super.cityId,
    required super.cityName,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      cityId: json['cityId']?.toString() ?? '',
      cityName: json['cityName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cityId': cityId,
      'cityName': cityName,
    };
  }
}
