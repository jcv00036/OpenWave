import 'package:flutter/cupertino.dart';
import 'package:openwave/Nucleo/base_datos.dart';
import 'package:openwave/Nucleo/emisora.dart';
import 'package:sqflite/sqflite.dart';

class GestorEmisoras extends ChangeNotifier{

  static List<Emisora> _emisoras = [];
  static late final Database _database;

  Future<void> _cargarEmisoras() async{
    var listaEmisorasRaw = await _database.query("emisora");
    listaEmisorasRaw.forEach((Map<String, Object?> mapa) {
      _emisoras.add(Emisora(mapa["id"].toString(), mapa["nombre"].toString(), mapa["url"].toString(), [], []));
    });
  }

  Future<void> init() async{
    // Carga la base de datos
    _database = await BaseDatos.db;
    await _cargarEmisoras();
    notifyListeners();
  }

  List<Emisora> get emisoras {
    if (_emisoras.isEmpty) {
      init();
    }
    return List.of(_emisoras);
  }

  Future<bool> agregarEmisora(String nombre, String url) async{
    try {
      int id = await _database.insert("emisora", {"nombre": nombre, "url": url});
      _emisoras.add(Emisora(id.toString(), nombre, url, [], []));
      notifyListeners();
      return true;
    } catch (e) {
      print("Error al agregar emisora: $e");
      return false;
    }
  }

}