import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  final token = await _login(client, 'admin', '1q2w3E*');
  if (token == null) { client.close(); return; }

  final tenantId = 'd9581e3a-dc5f-4d61-57a0-c5ce5ac7a73f'; // ركن البيك

  print('\n======= items/get-all with specificFilters == TenantId =======');
  try {
    final uri = Uri.parse('https://erp.neosending.com/api/ECommerce/items/get-all');
    final req = await client.postUrl(uri);
    req.headers.set('Accept', 'application/json');
    req.headers.set('Content-Type', 'application/json');
    req.headers.set('Authorization', 'Bearer $token');
    
    final body = jsonEncode({
      'maxResultCount': 100,
      'skipCount': 0,
      'specificFilters': [
        {'key': 'TenantId', 'condition': '==', 'value': tenantId}
      ]
    });
    
    req.contentLength = utf8.encode(body).length;
    req.write(body);
    
    final res = await req.close();
    final resBody = await res.transform(utf8.decoder).join();
    
    if (res.statusCode == 200) {
      final data = jsonDecode(resBody);
      List items = data is List ? data : (data['items'] ?? []);
      print('Total items for TenantId: ${items.length}');
      if (items.isNotEmpty) {
         print('First item title: ${items.first['item']['name']}');
      }
    } else {
      print('Status: ${res.statusCode} - Body: $resBody');
    }
  } catch (e) { print('Error: $e'); }

  print('\n======= items/get-all with specificFilters == StoreId =======');
  try {
    final uri = Uri.parse('https://erp.neosending.com/api/ECommerce/items/get-all');
    final req = await client.postUrl(uri);
    req.headers.set('Accept', 'application/json');
    req.headers.set('Content-Type', 'application/json');
    req.headers.set('Authorization', 'Bearer $token');
    
    final body = jsonEncode({
      'maxResultCount': 100,
      'skipCount': 0,
      'specificFilters': [
        {'key': 'StoreId', 'condition': '==', 'value': 'f75f1e3a-66d3-6e82-a6b3-ab0df08aa493'}
      ]
    });
    
    req.contentLength = utf8.encode(body).length;
    req.write(body);
    
    final res = await req.close();
    final resBody = await res.transform(utf8.decoder).join();
    
    if (res.statusCode == 200) {
      final data = jsonDecode(resBody);
      List items = data is List ? data : (data['items'] ?? []);
      print('Total items for StoreId: ${items.length}');
      if (items.isNotEmpty) {
         print('First item title: ${items.first['item']['name']}');
      }
    } else {
      print('Status: ${res.statusCode}');
    }
  } catch (e) { print('Error: $e'); }

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
