// ignore_for_file: non_constant_identifier_names

// import 'package:mysql1/mysql1.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MySQL {

  static Future<Map> insert(Map<String, dynamic> item, String api) async {
    item['id_$api'] = null;

    print(jsonEncode(item));
    final response = await http.post(
      Uri.parse('http://192.168.1.19:8080/api/$api'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );

    print(response.statusCode);
    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.MySQL.fromJson(
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

    var url = Uri.http('192.168.1.19:8080', '/api/$api');

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

  static Future<Map> retrieve(String source, String api) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    final queryParameters = {
      'source': source,
    };

    var url = Uri.http('192.168.1.19:8080', '/api/$api', queryParameters);
    Map data = {};

    final response = await http.get(url, headers: requestHeaders);
    // if (response.statusCode == 404) {
    //   data = await UserLog.retrieve(source).then((value) {
    //     data = {
    //       'id_olog': value.last.id_olog,
    //       'date_time': value.last.date_time,
    //       'form_sender': value.last.form_sender,
    //       'remarks': value.last.remarks,
    //       'source': value.last.source
    //     };
        
    //     return data;
    //   });       
    // } else 
    if (response.statusCode == 200) {
      List<dynamic> data = (json.decode(response.body)) as List;
      
      return data.last; 
    }

    return data;
  }
}