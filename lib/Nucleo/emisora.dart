import 'package:flutter/material.dart';

import '../constantes.dart';

class Emisora{
  String _nombre;
  String _url;
  String _id;
  List<String> _metadatos;
  List<String> _etiquetas;
  Image? _imagen;

  Emisora(this._id, this._nombre, this._url, this._metadatos, this._etiquetas);

  factory Emisora.fromJson(Map<String, dynamic> json){
    var instancia = Emisora("0", json["name"].toString(), json["url"].toString(), [], json["tags"].toString().split(","));
    var uriImagen = Uri.parse(json["favicon"].toString());
    if (!uriImagen.hasEmptyPath) {
      // Primero compruebo si la imagen es de un formato soportado por Image
      if (uriImagen.path.endsWith(".png") ||
          uriImagen.path.endsWith(".jpg") ||
          uriImagen.path.endsWith(".jpeg")) {
        instancia.imagen = Image.network(uriImagen.toString(), errorBuilder: (context, error, stackTrace) => Image.asset(IMAGEN_EMISORA_POR_DEFECTO),);
      }
    }
    return instancia;
  }


  List<String> get etiquetas => List.of(_etiquetas);

  List<String> get metadatos => List.of(_metadatos);

  String get nombre => _nombre;

  String get id => _id;

  String get url => _url;

  set etiquetas(List<String> etiquetas) => _etiquetas = List.of(etiquetas);

  set metadatos(List<String> metadados) => _metadatos = List.of(metadados);

  set nombre(String nombre)  => _nombre = nombre;

  set url(String url) => _url = url;

  set imagen(Image imagen) => _imagen = imagen;

  Image? get imagen => _imagen;

  int compareTo(Emisora emisora) => _nombre.compareTo(emisora.nombre);

  bool operator ==(Object other) {
    if (other is! Emisora) return false;
    return _id == other.id;
  }

  Map<String, dynamic> toMap(){
    //TODO: Ir poniendo los campos
    return {
      'id': id,
      'nombre': nombre,
      'url': url,
    };
  }
}