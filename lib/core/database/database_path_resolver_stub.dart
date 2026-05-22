import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

Future<String> resolvePath() async {
  return p.join(await getDatabasesPath(), DatabaseConstants.dbName);
}
