import 'package:openwave/Nucleo/BaseDatos.dart';
import 'package:openwave/Nucleo/Emisora.dart';
import 'package:sqflite/sqflite.dart';
import 'package:openwave/Nucleo/IEmisora.dart';

class GestorEmisoras {

  static List<IEmisora> _emisoras = [];
  static late final Database _database;

  GestorEmisoras._singletonConst();
  static final GestorEmisoras _instancia = GestorEmisoras._singletonConst();
  static get instancia => _instancia;

  static Future<void> _cargarEmisoras() async{
    var listaEmisorasRaw = await _database.query("emisora");
    listaEmisorasRaw.forEach((Map<String, Object?> mapa) {
      _emisoras.add(Emisora(mapa["id"].toString(), mapa["nombre"].toString(), mapa["url"].toString(), [], []));
    });
  }

  static Future<void> init() async{
    // Carga la base de datos
    _database = await BaseDatos.db;
    await _cargarEmisoras();
  }

  static List<IEmisora> get emisoras => _emisoras;
}