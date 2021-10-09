import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class NewsDatabase {
  static Future<Database> createorGetDatabase() async {
    // File path to a file in the current directory
    // get the application documents directory
    var dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await dir.create(recursive: true);
    // build the database path
    var dbPath = join(dir.path, 'news.db');
    DatabaseFactory dbFactory = databaseFactoryIo;

    // We use the database factory to open the database
    return dbFactory.openDatabase(dbPath);
  }
}
