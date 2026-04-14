import '../../domain/entities/store_entity.dart';

class StoreItemGroupModel extends StoreItemGroupEntity {
  const StoreItemGroupModel({
    required super.groupId,
    required super.groupName,
  });

  factory StoreItemGroupModel.fromJson(Map<String, dynamic> json) {
    return StoreItemGroupModel(
      groupId: json['groupId']?.toString() ?? '',
      groupName: json['groupName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
    };
  }
}

class StoreGroupModel extends StoreGroupEntity {
  const StoreGroupModel({
    required super.id,
    super.theNumber,
    super.name,
    super.foreignName,
    required super.isActive,
  });

  factory StoreGroupModel.fromJson(Map<String, dynamic> json) {
    return StoreGroupModel(
      id: json['id']?.toString() ?? '',
      theNumber: json['theNumber']?.toString(),
      name: json['name'],
      foreignName: json['foreignName'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'theNumber': theNumber,
      'name': name,
      'foreignName': foreignName,
      'isActive': isActive,
    };
  }
}

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
    super.tenantId,
    super.groupId,
    super.storesItemGroups = const [],
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    var itemsGroupsJson = json['storesItemGroups'] as List?;
    List<StoreItemGroupModel> itemsGroups = [];
    if (itemsGroupsJson != null) {
      itemsGroups =
          itemsGroupsJson.map((e) => StoreItemGroupModel.fromJson(e)).toList();
    }

    return StoreModel(
      id: json['id']?.toString() ?? '',
      theNumber: json['theNumber']?.toString() ?? '',
      name: json['name'] ?? json['storeName'] ?? '',
      foreignName: json['foreignName'],
      isActive: json['isActive'] ?? true,
      // Try multiple possible image field names
      imageUrl: json['imageUrl'] ??
          json['imagUrl'] ??
          json['image'] ??
          json['logoUrl'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      tenantId: json['tenantId']?.toString(),
      groupId: json['groupId']?.toString(),
      storesItemGroups: itemsGroups,
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
      'tenantId': tenantId,
      'groupId': groupId,
      'storesItemGroups': storesItemGroups
          .map((e) => (e as StoreItemGroupModel).toJson())
          .toList(),
    };
  }
}
