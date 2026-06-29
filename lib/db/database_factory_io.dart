import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

sqflite.DatabaseFactory obtenerDatabaseFactory() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    ffi.sqfliteFfiInit();
    return ffi.databaseFactoryFfi;
  }

  return sqflite.databaseFactory;
}

Future<String> obtenerRutaBaseDatos(
  sqflite.DatabaseFactory factory,
  String nombre,
) async {
  final rutaBD = await factory.getDatabasesPath();
  return join(rutaBD, nombre);
}
