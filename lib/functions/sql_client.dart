
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

String server = 'http://192.168.1.19:8080';

// Server Lokal
// String server = 'http://192.168.1.106:8080';

class SQL {

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
    var res = await request.send();
    print("insertMultiPart:"+res.statusCode.toString());
  }

  static Future<Map> insert({required Map<String, dynamic> item, required String api}) async {
    item['id_$api'] = null;

    print('sql_client(insert): ${jsonEncode(item)}');
    final response = await http.post(
      Uri.parse('$server/api/$api'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );

    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.MySQL.fromJson(
      print('return: ${response.body}');
      return jsonDecode(response.body);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create item.');
    }
  }

  static Future<List<Map<String, dynamic>>> retrieveAll(String api) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.parse('$server/api/$api');

    final response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200) {
      List<dynamic> data = (json.decode(response.body));

      List<Map<String, dynamic>> dataDecoded = [];

      for (var element in data) {
        dataDecoded.add(element);
      }

      return dataDecoded;
    } else {
      throw Exception('failed');
    }
  }

  static Future<Map> retrieve({required String query, required String value, required String api}) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    String queryParameters = '?$query=$value';

    var url = Uri.parse('$server/api/$api$queryParameters');
    Map data = {};

    final response = await http.get(url, headers: requestHeaders).timeout(
      const Duration(seconds: 1), 
      onTimeout: () {
        return http.Response('Error', 408);
      }, 
    );

    if (response.statusCode == 200) {
      List<dynamic> data = (json.decode(response.body)) as List;
      return data.last; 
    }

    return data;
  }
}
