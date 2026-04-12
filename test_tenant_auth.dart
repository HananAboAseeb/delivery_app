import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  final token = await _login(client, 'admin', '1q2w3E*');
  if (token == null) { client.close(); return; }

  final tenantId = 'd9581e3a-dc5f-4d61-57a0-c5ce5ac7a73f'; // ركن البيك

  await _fullDetails(client, '/api/ECommerce/items-cache', token, tenantId, 'Items Cache Tenant');
  await _fullDetails(client, '/api/ECommerce/items', token, tenantId, 'Items Tenant');
  await _fullDetails(client, '/api/ECommerce/items-groups-cache/groups-with-under-groups', token, tenantId, 'Groups Tenant');

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
  return (jsonDecode(resBody) as Map)['access_token'] as String;
}

Future<void> _fullDetails(HttpClient client, String path, String token, String tenantId, String label) async {
  print('\n======= $label ($path) =======');
  try {
    final uri = Uri.parse('https://erp.neosending.com$path');
    final req = await client.getUrl(uri);
    req.headers.set('Accept', 'application/json');
    req.headers.set('Authorization', 'Bearer $token');
    req.headers.set('__tenant', tenantId);
    
    final res = await req.close();
    final resBody = await res.transform(utf8.decoder).join();
    
    if (res.statusCode == 200) {
      final data = jsonDecode(resBody);
      List items = data is List ? data : (data['items'] ?? []);
      print('Total items: ${items.length}');
      if (items.isNotEmpty) {
         print('First item title: ${items.first['name']}');
      }
    } else {
      print('Status: ${res.statusCode} - Body: $resBody');
    }
  } catch (e) { print('Error: $e'); }
}
