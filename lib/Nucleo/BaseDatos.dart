import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BaseDatos {
  static final BaseDatos _instancia = BaseDatos._constructorSingleton();
  BaseDatos._constructorSingleton();

  static Database? _database;

  static Future<Database> get db async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String directorioBaseDatos = join(await getDatabasesPath(), 'openwave.db');

    var baseDatosExiste = await databaseExists(directorioBaseDatos);

    if (!baseDatosExiste){
      // Si no existe, la buscamos en los assets de la aplicación
      try {
        await Directory(dirname(directorioBaseDatos)).create(recursive: true);
      } catch (_) {
        throw Exception("No se ha podido crear la base de datos de emisoras");
      }

      ByteData data = await rootBundle.load(join("assets", "openwave.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(directorioBaseDatos).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(directorioBaseDatos);
  }
}