import 'package:equatable/equatable.dart';

class StoreItemGroupEntity extends Equatable {
  final String groupId;
  final String groupName;

  const StoreItemGroupEntity({
    required this.groupId,
    required this.groupName,
  });

  @override
  List<Object?> get props => [groupId, groupName];
}

class StoreGroupEntity extends Equatable {
  final String id;
  final String? theNumber;
  final String? name;
  final String? foreignName;
  final bool isActive;

  const StoreGroupEntity({
    required this.id,
    this.theNumber,
    this.name,
    this.foreignName,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        theNumber,
        name,
        foreignName,
        isActive,
      ];
}

class StoreEntity extends Equatable {
  final String id;
  final String theNumber;
  final String name;
  final String? foreignName;
  final bool isActive;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final String? tenantId;
  final String? groupId;
  final List<StoreItemGroupEntity> storesItemGroups;

  const StoreEntity({
    required this.id,
    required this.theNumber,
    required this.name,
    this.foreignName,
    required this.isActive,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.tenantId,
    this.groupId,
    this.storesItemGroups = const [],
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
        tenantId,
        groupId,
        storesItemGroups,
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
