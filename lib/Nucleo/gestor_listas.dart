import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/emisora.dart';
import 'package:openwave/Nucleo/gestor_emisoras.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:sqflite/sqflite.dart';

import 'base_datos.dart';

class GestorListas extends ChangeNotifier {
  static List<ListaReproduccion> _listas = [];
  static Database? _database;
  bool _inicializada = false;
  late GestorEmisoras _gestorEmisoras;

  GestorListas(this._gestorEmisoras);

  set gestorEmisoras(GestorEmisoras gestorEmisoras) => _gestorEmisoras = gestorEmisoras;

  List<ListaReproduccion> get listas {
    if (!_inicializada) {
      init();
    }
    return List.of(_listas);
  }

  Future<void> init() async {
    if (_inicializada) return;
    // Carga la base de datos
    _database ??= await BaseDatos.db;
    // Comprueba si las tablas necesarias existen y si no las crea
    await _database!.execute('CREATE TABLE IF NOT EXISTS lista ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'nombre TEXT NOT NULL,'
        'permanente INTEGER CONSTRAINT ck_permanente_lista CHECK (permanente == 0 OR permanente == 1))');
    
    await _database!.execute('CREATE TABLE IF NOT EXISTS "emisora_lista" ('
        '"id_emisora" INTEGER,'
        '"id_lista" INTEGER,'
        'CONSTRAINT "pk_emisora_lista" PRIMARY KEY("id_emisora","id_lista"),'
        'FOREIGN KEY("id_emisora") REFERENCES "emisora"("id"),'
        'FOREIGN KEY("id_lista") REFERENCES "lista"("id"))');

    await _cargarListas();
    _inicializada = true;
    notifyListeners();
  }

  Future<void> _cargarListas() async {
    _listas.clear();
    var listaListasRaw = await _database!.query("lista");
    
    if (listaListasRaw.isEmpty) {
      int id = await _database!.insert("lista", {"nombre": "lista_favoritos", "permanente": 1});
      _listas.add(ListaReproduccion(id.toString(), TextosApp.getTexto("lista_favoritos"), [], true));
      return;
    }

    // IMPORTANTE: Usar for...in para esperar tareas asíncronas
    for (var mapa in listaListasRaw) {
      bool permanente = mapa["permanente"] == 1;
      String nombre = permanente ? TextosApp.getTexto(mapa["nombre"].toString()) : mapa["nombre"].toString();
      String id = mapa["id"].toString();
      
      List<Emisora> listaEmisorasLista = [];
      var listaEmisorasListaRaw = await _database!.query("emisora_lista", where: "id_lista = ?", whereArgs: [id]);
      
      for (var eMapa in listaEmisorasListaRaw) {
        try {
          // Buscamos la emisora asegurándonos de comparar IDs como Strings
          var emisora = _gestorEmisoras.emisoras.firstWhere(
            (e) => e.id.toString() == eMapa["id_emisora"].toString()
          );
          listaEmisorasLista.add(emisora);
        } catch (e) {
          print("Emisora ${eMapa["id_emisora"]} no encontrada en GestorEmisoras");
        }
      }

      _listas.add(ListaReproduccion(id, nombre, listaEmisorasLista, permanente));
    }
  }

  Future<bool> agregarLista(String nombre, List<Emisora> emisoras) async {
    try {
      int id = await _database!.insert("lista", {"nombre": nombre, "permanente": 0});

      for (var emisora in emisoras) {
        await _database!.insert("emisora_lista", {"id_emisora": emisora.id, "id_lista": id});
      }

      _listas.add(ListaReproduccion(id.toString(), nombre, List.from(emisoras), false));
      notifyListeners();
      return true;
    } catch (e) {
      print("Error al agregar lista: $e");
      return false;
    }
  }

  Future<bool> editarLista(ListaReproduccion lista, String nombre, List<Emisora> emisoras) async {
    try {
      await _database!.delete("emisora_lista", where: "id_lista = ?", whereArgs: [lista.id]);
      
      for (var emisora in emisoras) {
        await _database!.insert("emisora_lista", {"id_emisora": emisora.id, "id_lista": lista.id});
      }

      if(!lista.permanente) {
        await _database!.update("lista", {"nombre": nombre}, where: "id = ?",
            whereArgs: [lista.id]);
      }

      int indice = _listas.indexWhere((l) => l.id == lista.id);
      if (indice != -1) {
        if(!lista.permanente) {
          _listas[indice].nombre = nombre;
        }
        _listas[indice].emisoras = List.from(emisoras);
      }

      notifyListeners();
      return true;
    } catch (e) {
      print("Error al editar lista: $e");
      return false;
    }
  }

  Future<bool> eliminarLista(ListaReproduccion lista) async {
    if(lista.permanente) return false;
    try {
      await _database!.delete("emisora_lista", where: "id_lista = ?", whereArgs: [lista.id]);
      await _database!.delete("lista", where: "id = ?", whereArgs: [lista.id]);

      _listas.removeWhere((l) => l.id == lista.id);
      notifyListeners();
      return true;
    } catch (e) {
      print("Error al eliminar lista: $e");
      return false;
    }
  }
}
