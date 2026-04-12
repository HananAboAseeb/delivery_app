import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  final token = await _login(client, 'admin', '1q2w3E*');
  if (token == null) { client.close(); return; }

  final storeId = 'f75f1e3a-66d3-6e82-a6b3-ab0df08aa493'; // ركن البيك id
  final groupId = '32201e3a-0b35-2574-2aef-939b8702aeff'; // المطاعم group
  final tenantId = 'd9581e3a-dc5f-4d61-57a0-c5ce5ac7a73f';

  // Test 1: store-brows/get-group with sort and filters
  print('\n======= Test 1: store-brows/get-group (full params) =======');
  await _postTest(client, '/api/ECommerce/store-brows/get-group', token, tenantId, {
    'storeId': storeId,
    'groupId': groupId,
    'sort': 'name',
    'page': 1,
    'pageSize': 50,
    'filters': {},
  });

  // Test 2: without groupId but with sort/filters
  print('\n======= Test 2: store-brows/get-group (no groupId) =======');
  await _postTest(client, '/api/ECommerce/store-brows/get-group', token, tenantId, {
    'storeId': storeId,
    'sort': 'name',
    'page': 1,
    'pageSize': 50,
    'filters': {},
  });

  // Test 3: without storeId 
  print('\n======= Test 3: store-brows/get-group (no storeId) =======');
  await _postTest(client, '/api/ECommerce/store-brows/get-group', token, null, {
    'groupId': groupId,
    'sort': 'name',
    'page': 1,
    'pageSize': 50,
    'filters': {},
  });

  // Test 4: with under-sub-group ID (فطور)
  print('\n======= Test 4: store-brows/get-group (فطور underSubGroup) =======');
  await _postTest(client, '/api/ECommerce/store-brows/get-group', token, tenantId, {
    'storeId': storeId,
    'groupId': 'a65f1e3a-82d0-df6b-ef56-465ef80c8f19', // فطور
    'sort': 'name',
    'page': 1,
    'pageSize': 50,
    'filters': {},
  });

  // Test 5: with عشاء group 
  print('\n======= Test 5: store-brows/get-group (عشاء underSubGroup) =======');
  await _postTest(client, '/api/ECommerce/store-brows/get-group', token, tenantId, {
    'storeId': storeId,
    'groupId': 'd75f1e3a-1b61-de38-22eb-40f091b340da', // عشاء
    'sort': 'name',
    'page': 1,
    'pageSize': 50,
    'filters': {},
  });

  client.close();
}

Future<void> _postTest(HttpClient client, String path, String token, String? tenantId, Map data) async {
  try {
    final uri = Uri.parse('https://erp.neosending.com$path');
    final req = await client.postUrl(uri);
    req.headers.set('Accept', 'application/json');
    req.headers.set('Content-Type', 'application/json');
    req.headers.set('Authorization', 'Bearer $token');
    if (tenantId != null) req.headers.set('__tenant', tenantId);
    
    final body = jsonEncode(data);
    req.contentLength = utf8.encode(body).length;
    req.write(body);
    
    final res = await req.close();
    final resBody = await res.transform(utf8.decoder).join();
    
    if (res.statusCode == 200) {
      final decoded = jsonDecode(resBody);
      if (decoded is Map) {
        List items = decoded['items'] ?? [];
        print('Total items: ${items.length}, totalCount: ${decoded['totalCount']}');
        for (var item in items.take(10)) {
          print('  - ${item['name']} | price: ${item['price']} | store: ${item['storeName']} | img: ${item['thumbnailUrl']}');
        }
      } else if (decoded is List) {
        print('Total items: ${decoded.length}');
        for (var item in decoded.take(10)) {
          print('  - ${item['name']} | price: ${item['price']}');
        }
      }
    } else {
      print('Status: ${res.statusCode}');
      final body = resBody.length > 300 ? resBody.substring(0, 300) : resBody;
      print('Body: $body');
    }
  } catch (e) { print('Error: $e'); }
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
