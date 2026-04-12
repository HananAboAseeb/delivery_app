import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  final token = await _login(client, 'admin', '1q2w3E*');
  if (token == null) { client.close(); return; }

  final storeId = 'f75f1e3a-66d3-6e82-a6b3-ab0df08aa493'; // ركن البيك id
  final groupId = '32201e3a-0b35-2574-2aef-939b8702aeff'; // groupId

  await _testPath(client, '/api/ECommerce/items-cache?StoreId=$storeId', token);
  await _testPath(client, '/api/ECommerce/items-cache?tenantId=d9581e3a-dc5f-4d61-57a0-c5ce5ac7a73f', token);
  await _testPath(client, '/api/ECommerce/items-cache/store/$storeId', token);
  await _testPath(client, '/api/ECommerce/items/by-store/$storeId', token);
  await _testPath(client, '/api/ECommerce/items-groups-cache/restaurant-group?StoreId=$storeId', token);

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
  return (jsonDecode(resBody) as Map)['access_token'] as String;
}

Future<void> _testPath(HttpClient client, String path, String token) async {
  print('\n======= Testing $path =======');
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
      if (items.isNotEmpty && items.first is Map) {
         print('First item: ${items.first['name'] ?? items.first}');
      }
    } else {
      print('Status: ${res.statusCode}');
    }
  } catch (e) { print('Error: $e'); }
}
