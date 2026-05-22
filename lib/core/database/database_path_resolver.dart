import 'package:flutter/foundation.dart';

import 'database_constants.dart';
import 'database_path_resolver_stub.dart'
    if (dart.library.io) 'database_path_resolver_io.dart' as impl;

/// Resolves where [respondi.db] lives for the current platform.
class DatabasePathResolver {
  DatabasePathResolver._();

  static Future<String> resolve() async {
    if (kIsWeb) return DatabaseConstants.dbName;
    return impl.resolvePath();
  }
}
