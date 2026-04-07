import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.theNumber,
    required super.name,
    super.foreignName,
    required super.unitId,
    required super.unitName,
    required super.currencyId,
    required super.currencyName,
    required super.unitPrice,
    super.imageUrl,
    required super.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      theNumber: json['theNumber'] ?? '',
      name: json['name'] ?? '',
      foreignName: json['foreignName'],
      unitId: json['unitId'] ?? '',
      unitName: json['unitName'] ?? '',
      currencyId: json['currencyId'] ?? '',
      currencyName: json['currencyName'] ?? '',
      unitPrice: (json['unitPrice'] ?? json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? json['thumbnailUrl'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'theNumber': theNumber,
      'name': name,
      'foreignName': foreignName,
      'unitId': unitId,
      'unitName': unitName,
      'currencyId': currencyId,
      'currencyName': currencyName,
      'unitPrice': unitPrice,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
