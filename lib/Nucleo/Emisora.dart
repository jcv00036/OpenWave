import 'package:openwave/Nucleo/IEmisora.dart';

class Emisora implements IEmisora{
  String _nombre;
  String _url;
  String _id;
  List<String> _metadatos;
  List<String> _etiquetas;

  Emisora(this._id, this._nombre, this._url, this._metadatos, this._etiquetas);

  @override
  List<String> get etiquetas => List.of(_etiquetas);

  @override
  List<String> get metadatos => List.of(_metadatos);

  @override
  String get nombre => _nombre;

  @override
  String get id => _id;

  @override
  String get url => _url;

  @override
  set etiquetas(List<String> etiquetas) => _etiquetas = List.of(etiquetas);

  @override
  set metadatos(List<String> metadados) => _metadatos = List.of(metadados);

  @override
  set nombre(String nombre)  => _nombre = nombre;

  @override
  set url(String url) => _url = url;

  @override
  int compareTo(IEmisora emisora) => _nombre.compareTo(emisora.nombre);

  @override
  Map<String, dynamic> toMap(){
    //TODO: Ir poniendo los campos
    return {
      'id': id,
      'nombre': nombre,
      'url': url,
    };
  }
}