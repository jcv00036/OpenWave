import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/emisora.dart';
import 'package:openwave/Nucleo/gestor_emisoras.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:sqflite/sqflite.dart';

import 'base_datos.dart';

class GestorListas extends ChangeNotifier{
  static List<ListaReproduccion> _listas = [];
  static late final Database _database;
  late GestorEmisoras _gestorEmisoras;
  
  GestorListas(this._gestorEmisoras);
  
  set gestorEmisoras(GestorEmisoras gestorEmisoras) => _gestorEmisoras = gestorEmisoras;
  
  List<ListaReproduccion> get listas {
    if (_listas.isEmpty) {
      init();
    }
    return List.of(_listas);
  }

  Future<void> init() async{
    // Carga la base de datos
    _database = await BaseDatos.db;
    // Comprueba si las tablas necesarias existen y si no las crea
    await _database.execute('CREATE TABLE IF NOT EXISTS lista ('
                              'id INTEGER,'
                              'nombre TEXT NOT NULL,'
                              'permanente INTEGER CONSTRAINT ck_permanente_lista CHECK (permanente == 0 OR permanente == 1),'
                              'CONSTRAINT pk_lista PRIMARY KEY (id AUTOINCREMENT))');
    await _database.execute('CREATE TABLE IF NOT EXISTS "emisora_lista" ('
                              '"id_emisora"	INTEGER,'
                              '"id_lista"	INTEGER,'
                              'CONSTRAINT "pk_emisora_lista" PRIMARY KEY("id_emisora","id_lista"),'
                              'FOREIGN KEY("id_emisora") REFERENCES "emisora"("id"),'
                              'FOREIGN KEY("id_lista") REFERENCES "lista"("id"))');
    await _cargarListas();
    notifyListeners();
  }
  
  Future<void> _cargarListas() async {
    var listaListasRaw = await _database.query("lista");
    if (listaListasRaw.isEmpty) {
      await _database.insert("lista", {"nombre": "lista_favoritos", "permanente": 1});
      _listas.add(ListaReproduccion("1", TextosApp.getTexto("lista_favoritos"), [], true));
    }
    listaListasRaw.forEach((Map<String, Object?> mapa) async {
      // Compongo la emisora
      bool permanente = mapa["permanente"] == 1;
      String nombre = permanente ? TextosApp.getTexto(mapa["nombre"].toString()) : mapa["nombre"].toString();
      String id = mapa["id"].toString();
      List<Emisora> emisoras = [];
      var listaEmisorasLista = <Emisora>[];
      var listaEmisorasListaRaw = await _database.query("emisora_lista", where: "id_lista = ?", whereArgs: [id]);
      listaEmisorasListaRaw.forEach((Map<String, Object?> mapa) {
        listaEmisorasLista.add(_gestorEmisoras.emisoras.firstWhere((Emisora emisora) => emisora.id == mapa["id_emisora"]));
      });
      
      // Construyo la lista de reproduccion
      _listas.add(ListaReproduccion(id, nombre, listaEmisorasLista, permanente));
    });
  }

  Future<bool> agregarLista(String nombre, List<Emisora> emisoras) async {
    try{
      // Añado la lista a la base de datos
      int id = await _database.insert("lista", {"nombre": nombre, "permanente": 0});

      // Añado todas las emisora_lista a la base de datos
      emisoras.map((emisora) async => {
        await _database.insert("emisora_lista", {"id_emisora": emisora.id, "id_lista": id})
      });

      // Creo la lista de reproduccion
      _listas.add(ListaReproduccion(id.toString(), nombre, emisoras, false));

      notifyListeners();
      return true;
    } catch (e) {
      print("Error al agregar lista: $e");
      return false;
    }
  }
  
  Future<bool> editarLista(ListaReproduccion lista, String nombre, List<Emisora> emisoras) async {
    try{
      // Borro todos los emisora_lista relacionados con esta lista y vuelvo a introducirlas con las nuevas emisoras
      await _database.delete("emisora_lista", where: "id_lista = ?", whereArgs: [lista.id]);
      emisoras.map((emisora) async => {
        await _database.insert("emisora_lista", {"id_emisora": emisora.id, "id_lista": lista.id})
      });
      
      // Edito la lista en la base de datos
      await _database.update("lista", {"nombre": nombre}, where: "id = ?", whereArgs: [lista.id]);
      
      // Actualizo la instancia de la lista
      int indice = _listas.indexOf(lista);
      _listas[indice].nombre = nombre;
      _listas[indice].emisoras = emisoras;
      
      notifyListeners();
      return true;
    }catch(e){
      print("Error al editar lista: $e");
      return false;
    }
  }
  
  Future<bool> eliminarLista(ListaReproduccion lista) async {
    try{
      // Borro todos los emisora_lista relacionados con esta lista
      await _database.delete("emisora_lista", where: "id_lista = ?", whereArgs: [lista.id]);

      // Elimino la lista en la base de datos
      await _database.delete("lista", where: "id = ?", whereArgs: [lista.id]);

      // Saco la instancia de la lista
      int indice = _listas.indexOf(lista);
      _listas.removeAt(indice);

      notifyListeners();
      return true;
    }catch(e){
      print("Error al eliminar lista: $e");
      return false;
    }
  }
}