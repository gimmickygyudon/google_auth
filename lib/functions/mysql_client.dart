import 'package:mysql1/mysql1.dart';

class Mysql1 {
  static Future<MySqlConnection> intializeDatabase() async {
    var settings = ConnectionSettings(
      host: '192.168.1.16',
      port: 3306,
      user: 'mysql_user',
      password: '1BM123',
      db: 'indostar',
      useSSL: false
    );
    MySqlConnection conn = await MySqlConnection.connect(settings);
    return conn;
  }

  static Future<void> insert(Map<String, dynamic> item) async {
    intializeDatabase().then((conn) async {
      await conn.query(
        'insert into olog (id_olog, date_time, form_sender, remarks, source) values (?, ?, ?, ? , ?)', 
        [null, item['date_time'], item['form_sender'], item['remarks'], item['source']]
      );
    });
  }

  static Future<void> update(Map<String, dynamic> item) async {
    intializeDatabase().then((conn) async {
      await conn.query(
        'update olog set date_time=?, form_sender=?, remarks=?, source=? where id_olog=?',
        [item['date_time'], item['form_sender'], item['remarks'], item['source'], item['id_olog']]
      );
    });
    print(item['id_olog']);
  }

  static Future<void> retrieve(String? source) async {
    intializeDatabase().then((conn) async {
      await conn.query('select * from olog where source = ?', [source]);
    });
  }
}