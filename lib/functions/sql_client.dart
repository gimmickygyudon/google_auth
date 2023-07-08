
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http/retry.dart';

// PUB
String server = 'http://192.168.1.19:8080';

// LOCAL
// String server = 'http://192.168.1.108:8080';

class SQL {
  static const int clientRetries = 5;
  static const int clienTimeout = 15;

  static final client = RetryClient(http.Client(), retries: clientRetries,
    whenError: ((error, stacktrace) async {
      return await Future.error('Periksa Koneksi Internet Anda');
    })
  );

  static Future<void> insertMultiPart({required String api, required Map<String, String> item, required String filePath}) async {
    Map<String, String> requestHeaders = {
      "Content-type": "multipart/form-data"
    };

    final request = http.MultipartRequest(
      'POST', Uri.parse('$server/api/$api'),
    );

    request.files.add(
      http.MultipartFile.fromBytes('file', File(filePath).readAsBytesSync(), filename: item['file_name'])
    );
    request.headers.addAll(requestHeaders);
    request.fields.addAll(item);

    await client.send(request);
  }


  static Future<Map> insert({required Map<String, dynamic> item, required String api}) async {
    item['id_$api'] = null;

    final response = await client.post(
      Uri.parse('$server/api/$api'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return Future.error(Exception('Error Code ${response.statusCode}'));
    }
  }


  static Future<List<Map<String, dynamic>>> retrieveAll({required String api}) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.parse('$server/api/$api');

    final response = await client.get(url, headers: requestHeaders);

    if (response.statusCode == 200) {
      List<dynamic> data = (json.decode(response.body));

      List<Map<String, dynamic>> dataDecoded = [];

      for (var element in data) {
        dataDecoded.add(element);
      }

      return dataDecoded;
    } else {
       return Future.error('Periksa Koneksi Internet Anda');
    }
  }


  static Future<dynamic> retrieve({
    required String api,
    required String query
  }) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    String queryParameters = '?$query';
    var url = Uri.parse('$server/api/$api$queryParameters');

    final response = await client.get(url, headers: requestHeaders)
      .timeout(const Duration(seconds: clienTimeout), onTimeout: () {
        return Future.error('Periksa Koneksi Internet Anda');
      })
      .onError(((error, stacktrace) {
        return Future.error(error.toString());
      })
    );

    if (response.statusCode == 200) {
      List<dynamic> data = (json.decode(response.body)) as List;

      if (data.length == 1) return data.last;

      return data;
    } else if (response.statusCode == 404) {
      return Future.error('error: ${response.statusCode}');
    } else {
      return Future.error('error: ${response.statusCode}');
    }
  }


  static FutureOr<List?> retrieveJoin({
    required String api,
    required String? param,
    required String query,
    int? limit,
    int? offset,
    Function? setCount
  }) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    String queryParameters = '?$query=$param';
    String pageParameters() {
      if (limit != null && offset != null) return '&limit=$limit&offset=$offset';
      return '';
    }

    var url = Uri.parse('$server/api/$api$queryParameters${pageParameters()}');

    final response = await client.get(url, headers: requestHeaders)
      .timeout(const Duration(seconds: clienTimeout), onTimeout: () {
        return Future.error('Periksa Koneksi Internet Anda');
      });

    if (response.statusCode == 200 && pageParameters().isNotEmpty) {
      List<dynamic> data = (json.decode(response.body))['rows'];
      if(setCount != null) setCount((json.decode(response.body))['count']);

      return data;
    } else if (response.statusCode == 200) {
      List<dynamic> data = (json.decode(response.body));

      return data;
    } else {
      return Future.error('Periksa Koneksi Internet Anda');
    }

  }

  static Future<String> delete({required String api, required String query}) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    String queryParameters = '?$query';
    var url = Uri.parse('$server/api/$api$queryParameters');

    print(url);

    final response = await client.delete(url, headers: requestHeaders)
      .timeout(const Duration(seconds: clienTimeout), onTimeout: () {
        return Future.error('Periksa Koneksi Internet Anda');
      })
      .onError(((error, stacktrace) {
        return Future.error(error.toString());
      })
    );

    if (response.statusCode == 200) {
      return json.decode(response.body).toString();

    } else if (response.statusCode == 404) {
      return Future.error('error: ${response.body}');

    } else {
      return Future.error('error: ${response.body}');
    }
  }
}
