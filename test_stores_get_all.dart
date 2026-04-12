import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  final token = await _login(client, 'admin', '1q2w3E*');
  if (token == null) { client.close(); return; }

  try {
    final uri = Uri.parse('https://erp.neosending.com/api/ECommerce/stores/get-all');
    final req = await client.postUrl(uri);
    req.headers.set('Accept', 'application/json');
    req.headers.set('Content-Type', 'application/json');
    req.headers.set('Authorization', 'Bearer $token');
    
    final body = jsonEncode({
      'maxResultCount': 100,
      'skipCount': 0,
    });
    
    req.contentLength = utf8.encode(body).length;
    req.write(body);
    
    final res = await req.close();
    final resBody = await res.transform(utf8.decoder).join();
    
    if (res.statusCode == 200) {
      final data = jsonDecode(resBody);
      List items = data is List ? data : (data['items'] ?? []);
      print('Total stores: ${items.length}');
      for (var obj in items.take(5)) {
         final store = obj['store'] ?? obj;
         final List groups = store['storesItemGroups'] ?? [];
         print('- ${store['name']}, groups: ${groups.length}');
         for (var g in groups) {
            print('   -> ${g['groupName']}');
         }
      }
    } else {
      print('Status: ${res.statusCode} - $resBody');
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
  if (res.statusCode != 200) return null;
  return (jsonDecode(resBody) as Map)['access_token'] as String;
}
