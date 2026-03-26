import 'emisora.dart';

class ListaReproduccion {
  String _id;
  String _nombre;
  List<Emisora>? _emisoras;
  bool _permanente;

  ListaReproduccion(this._id, this._nombre, this._emisoras, [this._permanente = false]);

  
  String get nombre => _nombre;
  set nombre(String nombre) => _nombre = nombre;

  List<Emisora> get emisoras {
    List<Emisora> listaResultante = List.of(_emisoras ?? []);
    listaResultante.sort((a, b) => a.compareTo(b));

    return listaResultante;
  }
  set emisoras(List<Emisora> emisoras) => _emisoras = List.of(emisoras);

  bool get permanente => _permanente;

  String get id => id;

  bool agregarEmisora(Emisora emisora) {
    _emisoras?.add(emisora);
    return true;
  }

  bool eliminarEmisora(Emisora emisora) {
    _emisoras?.remove(emisora);
    return true;
  }

  Map<String, dynamic> toMap(){
    //TODO: Ir poniendo los campos
    return {
      'id': id,
      'nombre': nombre,
      'permanente': permanente,
    };
  }
}
