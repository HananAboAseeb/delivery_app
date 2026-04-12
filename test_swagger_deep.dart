import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  // Fetch swagger spec
  final uri = Uri.parse('https://erp.neosending.com/swagger/v1/swagger.json');
  final req = await client.getUrl(uri);
  final res = await req.close();
  final resBody = await res.transform(utf8.decoder).join();
  final spec = jsonDecode(resBody) as Map;
  final paths = spec['paths'] as Map;
  
  // Find all item-related endpoints with their methods and parameters
  for (final entry in paths.entries) {
    final path = entry.key as String;
    if (path.toLowerCase().contains('item') || path.toLowerCase().contains('store')) {
      final methods = entry.value as Map;
      for (final methodEntry in methods.entries) {
        final method = methodEntry.key;
        final details = methodEntry.value as Map;
        final params = details['parameters'] as List? ?? [];
        final summary = details['summary'] ?? '';
        final requestBody = details['requestBody'];
        
        print('\n[$method] $path');
        if (summary.toString().isNotEmpty) print('  Summary: $summary');
        
        if (params.isNotEmpty) {
          print('  Parameters:');
          for (final p in params) {
            print('    - ${p['name']} (${p['in']}, ${p['required'] == true ? 'required' : 'optional'})');
          }
        }
        
        if (requestBody != null) {
          final content = requestBody['content'] as Map?;
          if (content != null) {
            for (final ct in content.entries) {
              final schema = ct.value['schema'] as Map?;
              if (schema != null) {
                final ref = schema['\$ref'];
                if (ref != null) {
                  print('  RequestBody: $ref');
                }
              }
            }
          }
        }
      }
    }
  }

  client.close();
}
