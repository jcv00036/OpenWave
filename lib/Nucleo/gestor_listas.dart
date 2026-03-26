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
    await _cargarListas();
    notifyListeners();
  }
  
  Future<void> _cargarListas() async {
    var listaListasRaw = await _database.query("lista");
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
    
}