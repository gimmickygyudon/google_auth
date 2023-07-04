import 'package:async/async.dart';
import 'package:google_auth/functions/sql_client.dart';

class Video {

  static AsyncMemoizer<List<Map>> ytVideosMemoizer = AsyncMemoizer();

  static Future<List<Map>> getYTVideos() async {
    return ytVideosMemoizer.runOnce(() async {
      return await SQL.retrieveAll(api: 'yvid')
      .onError((error, stackTrace) {
        return Future.error(error.toString());
      });
    }).onError((error, stackTrace) {
      return Future.error(error.toString());
    }).then((value) async {
      if (value.isEmpty) return await SQL.retrieveAll(api: 'yvid');

      return value;
    });
  }

}