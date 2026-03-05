class Emisora{
  String _nombre;
  String _url;
  String _id;
  List<String> _metadatos;
  List<String> _etiquetas;

  Emisora(this._id, this._nombre, this._url, this._metadatos, this._etiquetas);

  List<String> get etiquetas => List.of(_etiquetas);

  List<String> get metadatos => List.of(_metadatos);

  String get nombre => _nombre;

  String get id => _id;

  String get url => _url;

  set etiquetas(List<String> etiquetas) => _etiquetas = List.of(etiquetas);

  set metadatos(List<String> metadados) => _metadatos = List.of(metadados);

  set nombre(String nombre)  => _nombre = nombre;

  set url(String url) => _url = url;

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