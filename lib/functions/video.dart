import 'package:google_auth/functions/sql_client.dart';

class Video {

  static Future<List<Map>> getYTVideos() async {
    return await SQL.retrieveAll(api: 'yvid');
  }

}