import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

sqflite.DatabaseFactory obtenerDatabaseFactory() {
  return databaseFactoryFfiWeb;
}

Future<String> obtenerRutaBaseDatos(
  sqflite.DatabaseFactory factory,
  String nombre,
) async {
  return nombre;
}
