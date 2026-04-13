import 'package:equatable/equatable.dart';

/// Single Responsibility: Holds the White-Label theme configuration
/// loaded from API or Local Storage.
class ThemeConfig extends Equatable {
  final String primaryColorHex;
  final String secondaryColorHex;
  final String? logoUrl;
  final String appName;
  final String? fontFamily;

  const ThemeConfig({
    required this.primaryColorHex,
    required this.secondaryColorHex,
    this.logoUrl,
    required this.appName,
    this.fontFamily,
  });

  factory ThemeConfig.defaultTheme() {
    return const ThemeConfig(
      // --- تغيير اللون الأساسي للتطبيق من هنا ---
      // غيّر الرمز '#E53935' للون الذي تريده.
      primaryColorHex: '#FF5722',
      secondaryColorHex: '#FF8A80',
      logoUrl: null,
      appName: 'خلك مرتاح',
      fontFamily: 'Inter',
    );
  }

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      primaryColorHex: json['primaryColorHex'] ?? '#E53935',
      secondaryColorHex: json['secondaryColorHex'] ?? '#FF8A80',
      logoUrl: json['logoUrl'],
      appName: json['appName'] ?? 'NeoDelivery',
      fontFamily: json['fontFamily'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColorHex': primaryColorHex,
      'secondaryColorHex': secondaryColorHex,
      'logoUrl': logoUrl,
      'appName': appName,
      'fontFamily': fontFamily,
    };
  }

  @override
  List<Object?> get props =>
      [primaryColorHex, secondaryColorHex, logoUrl, appName, fontFamily];
}
