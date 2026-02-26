import 'package:openwave/Nucleo/IEmisora.dart';
import 'package:openwave/Nucleo/IListaReproduccion.dart';

class ListaReproduccion implements IListaReproduccion {
  String _nombre;
  bool? _esRutina;
  List<IEmisora>? _emisoras;
  Map<int, IEmisora>? _temporizacion;

  ListaReproduccion(this._nombre, [this._esRutina]);

  @override
  bool get esRutina => _esRutina ?? false;

  @override
  String get nombre => _nombre;

  @override
  set emisoras(List<IEmisora> emisoras) => _emisoras = List.of(emisoras);

  @override
  List<IEmisora> get emisoras {
    List<IEmisora> listaResultante = [];

    if (!esRutina) {
      listaResultante = List.of(_emisoras ?? []);
      listaResultante.sort((a, b) => a.compareTo(b));
    } else {
      if (_temporizacion != null) {
        // Ordenar las claves (tiempos) para asegurar el orden cronológico
        var tiempos = _temporizacion!.keys.toList()..sort();
        Set<IEmisora> buffer = {};
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

  @override
  Map<int, IEmisora> get temporizacion =>
      Map.of(_temporizacion ?? <int, IEmisora>{});

  @override
  set nombre(String nombre) => _nombre = nombre;

  @override
  set temporizacion(Map<int, IEmisora> temporizacion) {
    _temporizacion = Map.of(temporizacion);
    _esRutina = _temporizacion!.isNotEmpty;
  }
}
