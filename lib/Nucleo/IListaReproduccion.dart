import 'package:openwave/Nucleo/IEmisora.dart';

abstract class IListaReproduccion {
  String get nombre;
  set nombre(String nombre);
  bool get esRutina;
  /// Devuelve un mapa vacío si no se ha inicializado todavía
  Map<int, IEmisora> get temporizacion;
  set temporizacion(Map<int, IEmisora> temporizacion);
  /// Devuelve una lista vacía si no se ha inicializado la lista de emisoras aún
  /// Devuelve las listas ya ordenadas
  List<IEmisora> get emisoras;
  set emisoras(List<IEmisora> emisoras);
}