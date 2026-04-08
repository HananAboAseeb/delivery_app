import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  final token = await _login(client, 'admin', '1q2w3E*');
  if (token == null) { client.close(); return; }

  // Get full details of first few items
  await _fullDetails(client, '/api/ECommerce/items', token, 'Items GET');
  await _fullDetails(client, '/api/ECommerce/items-cache', token, 'Items Cache');
  await _fullDetails(client, '/api/ECommerce/store-groups-cache', token, 'Store Groups Cache');

  client.close();
}

Future<String?> _login(HttpClient client, String user, String pass) async {
  final uri = Uri.parse('https://erp.neosending.com/connect/token');
  final req = await client.postUrl(uri);
  req.headers.set('Content-Type', 'application/x-www-form-urlencoded');
  final body = 'grant_type=password&client_id=ERP_APP&username=$user&password=${Uri.encodeComponent(pass)}';
  req.contentLength = utf8.encode(body).length;
  req.write(body);
  final res = await req.close();
  final resBody = await res.transform(utf8.decoder).join();
  if (res.statusCode != 200) { print('Login failed'); return null; }
  print('✅ Logged in');
  return (jsonDecode(resBody) as Map)['access_token'] as String;
}

Future<void> _fullDetails(HttpClient client, String path, String token, String label) async {
  print('\n======= $label ($path) =======');
  try {
    final uri = Uri.parse('https://erp.neosending.com$path');
    final req = await client.getUrl(uri);
    req.headers.set('Accept', 'application/json');
    req.headers.set('Authorization', 'Bearer $token');
    final res = await req.close();
    final resBody = await res.transform(utf8.decoder).join();
    
    if (res.statusCode == 200) {
      final data = jsonDecode(resBody);
      List items = data is List ? data : (data['items'] ?? []);
      print('Total items: ${items.length}');
      
      // Print first 3 items in full
      for (int i = 0; i < items.length && i < 3; i++) {
        print('\n  Item $i:');
        final item = items[i] as Map;
        item.forEach((k, v) {
          if (v != null && v.toString().isNotEmpty) {
            print('    $k: $v');
          }
        });
      }
    } else {
      print('Status: ${res.statusCode}');
    }
  } catch (e) { print('Error: $e'); }
}
