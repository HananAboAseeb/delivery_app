import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  final token = await _login(client, 'admin', '1q2w3E*');
  if (token == null) { client.close(); return; }

  final uri = Uri.parse('https://erp.neosending.com/api/ECommerce/item-activity-cache');
  final req = await client.getUrl(uri);
  req.headers.set('Accept', 'application/json');
  req.headers.set('Authorization', 'Bearer $token');
  
  final res = await req.close();
  final resBody = await res.transform(utf8.decoder).join();
  
  if (res.statusCode == 200) {
    List items = jsonDecode(resBody);
    for (var item in items) {
       print('\n--- Activity: ${item['name']} ---');
       item.forEach((k, v) => print('$k: $v'));
    }
  } else {
     print('Status: ${res.statusCode} - $resBody');
  }

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
