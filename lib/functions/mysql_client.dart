// ignore_for_file: non_constant_identifier_names

// import 'package:mysql1/mysql1.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MySQL {
  final int? id_olog;
  final String date_time;
  final String form_sender;
  final String remarks;
  final String source;

  const MySQL({required this.id_olog, required this.date_time, required this.form_sender, required this.remarks, required this.source});

  factory MySQL.fromJson(Map<String, dynamic> json) {
    return MySQL(
      id_olog: json['id_olog'],
      date_time: json['date_time'],
      form_sender: json['form_sender'],
      remarks: json['remarks'],
      source: json['source'],
    );
  }
  // static Future<MySqlConnection> intializeDatabase() async {
  //   var settings = ConnectionSettings(
  //     host: '192.168.1.16',
  //     port: 3306,
  //     user: 'mysql_user',
  //     password: '1BM123',
  //     db: 'indostar',
  //     useSSL: false
  //   );
  //   MySqlConnection conn = await MySqlConnection.connect(settings);
  //   return conn;
  // }

  // static Future<void> insert(Map<String, dynamic> item) async {
  //   intializeDatabase().then((conn) async {
  //     await conn.query(
  //       'insert into olog (id_olog, date_time, form_sender, remarks, source) values (?, ?, ?, ? , ?)', 
  //       [null, item['date_time'], item['form_sender'], item['remarks'], item['source']]
  //     );
  //   });
  // }

  // static Future<void> update(Map<String, dynamic> item) async {
  //   intializeDatabase().then((conn) async {
  //     await conn.query(
  //       'update olog set date_time=?, form_sender=?, remarks=?, source=? where id_olog=?',
  //       [item['date_time'], item['form_sender'], item['remarks'], item['source'], item['id_olog']]
  //     );
  //   });
  //   print(item['id_olog']);
  // }

  // static Future<void> retrieve(String? source) async {
  //   intializeDatabase().then((conn) async {
  //     await conn.query('select * from olog where source = ?', [source]);
  //   });
  // }

  static Future<MySQL> insert(Map<String, dynamic> item) async {
    item['id_olog'] = null;

    print(jsonEncode(item));
    final response = await http.post(
      Uri.parse('http://192.168.1.19:8080/api/olog'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(item),
    );

    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return MySQL.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create item.');
    }
  }

  static Future<List<Map<String, dynamic>>> retrieveAll() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http('192.168.1.19:8080', '/api/olog');

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

  static Future<Map> retrieve(String source) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    final queryParameters = {
      'source': source,
    };

    var url = Uri.http('192.168.1.19:8080', '/api/olog', queryParameters);
    Map data = {};

    final response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 404) {
      data = await UserLog.retrieve(source).then((value) {
        data = {
          'id_olog': value.last.id_olog,
          'date_time': value.last.date_time,
          'form_sender': value.last.form_sender,
          'remarks': value.last.remarks,
          'source': value.last.source
        };
        
        return data;
      });       
    } else if (response.statusCode == 200) {
      List<dynamic> data = (json.decode(response.body)) as List;
      
      return data.last; 
    }

    return data;
  }
}