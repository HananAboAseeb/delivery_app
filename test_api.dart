import 'dart:convert';
import 'dart:io';

// Run this with: dart test_api.dart
// To debug the API responses directly

void main() async {
  final client = HttpClient();
  
  // Read token from args if provided
  final token = Platform.environment['TOKEN'] ?? '';
  
  print('\n======= Testing ECommerce API Endpoints =======\n');
  
  await _testEndpoint(
    client: client,
    label: '1. GET /api/ECommerce/store-groups-cache',
    method: 'GET',
    url: 'https://erp.neosending.com/api/ECommerce/store-groups-cache',
    token: token,
  );

  await _testEndpoint(
    client: client,
    label: '2. POST /api/ECommerce/store-groups/get-all',
    method: 'POST',
    url: 'https://erp.neosending.com/api/ECommerce/store-groups/get-all',
    body: {'maxResultCount': 10, 'skipCount': 0},
    token: token,
  );

  await _testEndpoint(
    client: client,
    label: '3. POST /api/ECommerce/stores/get-all',
    method: 'POST',
    url: 'https://erp.neosending.com/api/ECommerce/stores/get-all',
    body: {'maxResultCount': 5, 'skipCount': 0},
    token: token,
  );

  await _testEndpoint(
    client: client,
    label: '4. POST /api/ECommerce/items/get-all (products)',
    method: 'POST',
    url: 'https://erp.neosending.com/api/ECommerce/items/get-all',
    body: {'maxResultCount': 5, 'skipCount': 0},
    token: token,
  );

  client.close();
}

Future<void> _testEndpoint({
  required HttpClient client,
  required String label,
  required String method,
  required String url,
  Map<String, dynamic>? body,
  required String token,
}) async {
  print('\n--- $label ---');
  try {
    final uri = Uri.parse(url);
    final request = method == 'POST'
        ? await client.postUrl(uri)
        : await client.getUrl(uri);
    
    request.headers.set('Accept', 'application/json');
    request.headers.set('Content-Type', 'application/json');
    if (token.isNotEmpty) {
      request.headers.set('Authorization', 'Bearer $token');
    }
    
    if (body != null) {
      final bodyStr = jsonEncode(body);
      request.headers.set('Content-Length', bodyStr.length.toString());
      request.write(bodyStr);
    }
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      if (data is List) {
        print('Response: Array with ${data.length} items');
        if (data.isNotEmpty) {
          print('First item keys: ${(data.first as Map).keys.toList()}');
        }
      } else if (data is Map) {
        print('Response: Object with keys: ${data.keys.toList()}');
        if (data.containsKey('items')) {
          final items = data['items'] as List;
          print('items count: ${items.length}');
          if (items.isNotEmpty) {
            print('First item keys: ${(items.first as Map).keys.toList()}');
            // Check for nested 'store' object
            if ((items.first as Map).containsKey('store')) {
              print('NESTED store keys: ${((items.first as Map)['store'] as Map).keys.toList()}');
            }
          }
        }
      }
    } else {
      // Print first 500 chars of error
      final truncated = responseBody.length > 500 ? responseBody.substring(0, 500) : responseBody;
      print('Error body: $truncated');
    }
  } catch (e) {
    print('EXCEPTION: $e');
  }
}
