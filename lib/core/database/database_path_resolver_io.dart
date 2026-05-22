import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

Future<String> resolvePath() async {
  final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS;

  if (kDebugMode && isDesktop) {
    final projectDb = p.join(
      Directory.current.path,
      'data',
      DatabaseConstants.dbName,
    );
    await Directory(p.dirname(projectDb)).create(recursive: true);
    return projectDb;
  }

  return p.join(await getDatabasesPath(), DatabaseConstants.dbName);
}
