import 'emisora.dart';

class ListaReproduccion {
  String _nombre;
  bool? _esRutina;
  List<Emisora>? _emisoras;
  Map<int, Emisora>? _temporizacion;

  ListaReproduccion(this._nombre, [this._esRutina]);
  
  bool get esRutina => _esRutina ?? false;
  
  String get nombre => _nombre;
  
  set emisoras(List<Emisora> emisoras) => _emisoras = List.of(emisoras);
  
  List<Emisora> get emisoras {
    List<Emisora> listaResultante = [];

    if (!esRutina) {
      listaResultante = List.of(_emisoras ?? []);
      listaResultante.sort((a, b) => a.compareTo(b));
    } else {
      if (_temporizacion != null) {
        // Ordenar las claves (tiempos) para asegurar el orden cronológico
        var tiempos = _temporizacion!.keys.toList()..sort();
        Set<Emisora> buffer = {};
        for (var tiempo in tiempos) {
          var emisora = _temporizacion![tiempo];
          if (emisora != null && !buffer.contains(emisora)) {
            buffer.add(emisora);
            listaResultante.add(emisora);
          }
        }
      }
    }

    return listaResultante;
  }
  
  Map<int, Emisora> get temporizacion =>
      Map.of(_temporizacion ?? <int, Emisora>{});
  
  set nombre(String nombre) => _nombre = nombre;
  
  set temporizacion(Map<int, Emisora> temporizacion) {
    _temporizacion = Map.of(temporizacion);
    _esRutina = _temporizacion!.isNotEmpty;
  }
}
