import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String theNumber;
  final String name;
  final String? foreignName;
  final String unitId;
  final String unitName;
  final String currencyId;
  final String currencyName;
  final double unitPrice;
  final String? imageUrl;
  final bool isActive;

  const ProductEntity({
    required this.id,
    required this.theNumber,
    required this.name,
    this.foreignName,
    required this.unitId,
    required this.unitName,
    required this.currencyId,
    required this.currencyName,
    required this.unitPrice,
    this.imageUrl,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        theNumber,
        name,
        foreignName,
        unitId,
        unitName,
        currencyId,
        currencyName,
        unitPrice,
        imageUrl,
        isActive,
      ];
}
