import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  // Fetch swagger spec to find StoreBrowsFilterDto schema
  final uri = Uri.parse('https://erp.neosending.com/swagger/v1/swagger.json');
  final req = await client.getUrl(uri);
  final res = await req.close();
  final resBody = await res.transform(utf8.decoder).join();
  final spec = jsonDecode(resBody) as Map;
  final schemas = spec['components']['schemas'] as Map;
  
  // Find StoreBrowsFilterDto
  for (final entry in schemas.entries) {
    final key = entry.key as String;
    if (key.contains('StoreBrows') || key.contains('Brows')) {
      print('\n=== Schema: $key ===');
      final schema = entry.value as Map;
      final props = schema['properties'] as Map? ?? {};
      for (final prop in props.entries) {
        print('  ${prop.key}: ${prop.value}');
      }
    }
  }
  
  // Also find item-sell-prices schema
  for (final entry in schemas.entries) {
    final key = entry.key as String;
    if (key.contains('ItemSellPrice') && key.contains('Dto')) {
      print('\n=== Schema: $key ===');
      final schema = entry.value as Map;
      final props = schema['properties'] as Map? ?? {};
      for (final prop in props.entries) {
        print('  ${prop.key}: ${prop.value}');
      }
    }
  }

  // Find GetAllStoresInput schema
  for (final entry in schemas.entries) {
    final key = entry.key as String;
    if (key.contains('GetAllStoresInput')) {
      print('\n=== Schema: $key ===');
      final schema = entry.value as Map;
      final props = schema['properties'] as Map? ?? {};
      for (final prop in props.entries) {
        print('  ${prop.key}: ${prop.value}');
      }
    }
  }

  // Find Items DTO 
  for (final entry in schemas.entries) {
    final key = entry.key as String;
    if (key.contains('ItemsDto') || key.contains('ItemsCacheDto')) {
      print('\n=== Schema: $key ===');
      final schema = entry.value as Map;
      final props = schema['properties'] as Map? ?? {};
      for (final prop in props.entries) {
        print('  ${prop.key}: ${prop.value}');
      }
    }
  }

  client.close();
}
