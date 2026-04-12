import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  final token = await _login(client, 'admin', '1q2w3E*');
  if (token == null) { client.close(); return; }

  final tenantAldiar = 'd1581e3a-65d4-aaf7-c7f5-02cde535584e'; // الديار 2

  final uri = Uri.parse('https://erp.neosending.com/api/ECommerce/items-cache');
  final req = await client.getUrl(uri);
  req.headers.set('Accept', 'application/json');
  req.headers.set('Authorization', 'Bearer $token');
  req.headers.set('__tenant', tenantAldiar);
  
  final res = await req.close();
  final resBody = await res.transform(utf8.decoder).join();
  
  if (res.statusCode == 200) {
    List items = jsonDecode(resBody);
    print('Total items: ${items.length}');
    for (var item in items) {
       print('- ${item['name']}');
    }
  } else {
      print('Status: ${res.statusCode}');
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
