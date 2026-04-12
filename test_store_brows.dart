import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  final token = await _login(client, 'admin', '1q2w3E*');
  if (token == null) { client.close(); return; }

  final storeId = 'f75f1e3a-66d3-6e82-a6b3-ab0df08aa493'; // ركن البيك id
  final groupId = '32201e3a-0b35-2574-2aef-939b8702aeff'; // المطاعم group
  final tenantId = 'd9581e3a-dc5f-4d61-57a0-c5ce5ac7a73f'; // ركن البيك tenant

  // Test 1: store-brows/get-group WITH storeId
  print('\n======= Test 1: store-brows/get-group (storeId=$storeId) =======');
  await _postTest(client, '/api/ECommerce/store-brows/get-group', token, null, {
    'storeId': storeId,
    'groupId': groupId,
    'page': 1,
    'pageSize': 50,
  });

  // Test 2: store-brows/get-group with __tenant header
  print('\n======= Test 2: store-brows/get-group (__tenant=$tenantId) =======');
  await _postTest(client, '/api/ECommerce/store-brows/get-group', token, tenantId, {
    'storeId': storeId,
    'groupId': groupId,
    'page': 1,
    'pageSize': 50,
  });

  // Test 3: without groupId
  print('\n======= Test 3: store-brows/get-group (no groupId) =======');
  await _postTest(client, '/api/ECommerce/store-brows/get-group', token, tenantId, {
    'storeId': storeId,
    'page': 1,
    'pageSize': 50,
  });

  // Test 4: stores-cache/market/{StoreId}
  print('\n======= Test 4: stores-cache/market/$storeId =======');
  await _getTest(client, '/api/ECommerce/stores-cache/market/$storeId', token, null);

  // Test 5: stores-cache/market/{StoreId} with tenant
  print('\n======= Test 5: stores-cache/market/$storeId (__tenant) =======');
  await _getTest(client, '/api/ECommerce/stores-cache/market/$storeId', token, tenantId);

  // Test 6: item-sell-prices-cache
  print('\n======= Test 6: item-sell-prices-cache =======');
  await _getTest(client, '/api/ECommerce/item-sell-prices-cache', token, tenantId);

  // Test 7: stores-cache/inervals/{storeId}
  print('\n======= Test 7: stores-cache/inervals/$storeId =======');
  await _getTest(client, '/api/ECommerce/stores-cache/inervals/$storeId', token, null);

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
        for (var item in items.take(5)) {
          print('  - ${item['name']} | price: ${item['price']} | store: ${item['storeName']} | img: ${item['thumbnailUrl']}');
        }
      } else if (decoded is List) {
        print('Total items: ${decoded.length}');
        for (var item in decoded.take(5)) {
          print('  - ${item['name']} | price: ${item['price']}');
        }
      }
    } else {
      print('Status: ${res.statusCode} - ${resBody.length > 200 ? resBody.substring(0, 200) : resBody}');
    }
  } catch (e) { print('Error: $e'); }
}

Future<void> _getTest(HttpClient client, String path, String token, String? tenantId) async {
  try {
    final uri = Uri.parse('https://erp.neosending.com$path');
    final req = await client.getUrl(uri);
    req.headers.set('Accept', 'application/json');
    req.headers.set('Authorization', 'Bearer $token');
    if (tenantId != null) req.headers.set('__tenant', tenantId);
    
    final res = await req.close();
    final resBody = await res.transform(utf8.decoder).join();
    
    if (res.statusCode == 200) {
      final decoded = jsonDecode(resBody);
      if (decoded is List) {
        print('Total items: ${decoded.length}');
        for (var item in decoded.take(5)) {
          if (item is Map) print('  - ${item}');
        }
      } else if (decoded is Map) {
        print('Response keys: ${decoded.keys}');
        if (decoded['items'] != null) {
          print('Total items: ${(decoded['items'] as List).length}');
        }
      }
    } else {
      print('Status: ${res.statusCode}');
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
  if (res.statusCode != 200) { print('Login failed: ${res.statusCode}'); return null; }
  return (jsonDecode(resBody) as Map)['access_token'] as String;
}
