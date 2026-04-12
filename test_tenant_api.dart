import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://erp.neosending.com',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      '__tenant': 'd9581e3a-dc5f-4d61-57a0-c5ce5ac7a73f'
    }
  ));
  
  try {
    final cacheRes = await dio.get('/api/ECommerce/items-cache');
    print('items-cache list length: ${(cacheRes.data as List).length}');
    if ((cacheRes.data as List).isNotEmpty) {
      print('First item: ${(cacheRes.data as List).first['name']}');
    }
  } catch(e) {
    if (e is DioException) {
      print('items-cache error: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      print('items-cache error: $e');
    }
  }

  try {
    final listRes = await dio.post('/api/ECommerce/items/get-all', data: {'maxResultCount': 100, 'skipCount': 0});
    print('items/get-all response type: ${listRes.data.runtimeType}');
    if (listRes.data is Map) {
      print('items/get-all data keys: ${(listRes.data as Map).keys}');
      if (listRes.data['items'] != null) {
        print('items/get-all items length: ${(listRes.data['items'] as List).length}');
        if ((listRes.data['items'] as List).isNotEmpty) {
          print('First item from get-all: ${(listRes.data['items'] as List).first['item']['name']}');
        }
      }
    } else if (listRes.data is List) {
       print('items/get-all items length: ${(listRes.data as List).length}');
    }
  } catch(e) {
    if (e is DioException) {
      print('get-all error: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      print('get-all error: $e');
    }
  }
}
