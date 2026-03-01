/*
 * La clase en este fichero gestiona los textos de la aplicación como singleton
 */

import 'dart:convert';

import 'package:flutter/services.dart';

class TextosApp{

  static Map<String, String> _textos = {};
  static final String _origenTextos = "assets/l10n/idiomas/";


  TextosApp._singletonConst();
  static final TextosApp _instancia = TextosApp._singletonConst();
  static get instancia => _instancia;

  static Future<void> cargarTextos(String idioma) async {
    var jsonDecodificado = jsonDecode(await rootBundle.loadString("$_origenTextos/$idioma.json"));
    _textos = Map<String,String>.from(jsonDecodificado);
  }

  static String getTexto(String clave){
    return _textos.keys.contains(clave) ? _textos[clave]! : "[$clave no encontrada]";
  }

}