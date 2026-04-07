import 'package:equatable/equatable.dart';

class StoreEntity extends Equatable {
  final String id;
  final String theNumber;
  final String name;
  final String? foreignName;
  final bool isActive;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  const StoreEntity({
    required this.id,
    required this.theNumber,
    required this.name,
    this.foreignName,
    required this.isActive,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        id,
        theNumber,
        name,
        foreignName,
        isActive,
        imageUrl,
        latitude,
        longitude,
      ];
}

class RegionEntity extends Equatable {
  final String id;
  final String name;
  final String cityId;
  final String cityName;

  const RegionEntity({
    required this.id,
    required this.name,
    required this.cityId,
    required this.cityName,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        cityId,
        cityName,
      ];
}
