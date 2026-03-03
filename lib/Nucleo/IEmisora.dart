abstract class IEmisora{
  String get nombre;
  set nombre(String nombre);
  String get id;
  String get url;
  set url(String url);
  List<String> get metadatos;
  set metadatos(List<String> metadados);
  List<String> get etiquetas;
  set etiquetas(List<String> etiquetas);

  int compareTo(IEmisora emisora);
  bool operator ==(Object otra);
  Map<String, dynamic> toMap();
}