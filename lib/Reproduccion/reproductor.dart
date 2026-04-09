import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../Nucleo/emisora.dart';
import '../constantes.dart';

class Reproductor extends ChangeNotifier{

  Emisora _emisoraSeleccionada = Emisora("0", "", "", [], []);
  List<Emisora> _emisorasEscuchando = [];
  final AudioPlayer _reproductor = AudioPlayer(userAgent: USER_AGENT,
                                                        useProxyForRequestHeaders: true, // default
                                                      );
  bool _cargando = false;
  Reproductor() : super();

  void pasarEmisora() async{
    // Compruebo el siguiente índice
    int siguiente = _reproductor.currentIndex! + 1;
    if (siguiente < _emisorasEscuchando.length) {
      reproducirEmisora(_emisorasEscuchando[siguiente], _emisorasEscuchando);
    }else{
      reproducirEmisora(_emisorasEscuchando[0], _emisorasEscuchando);
    }
  }

  void retrocederEmisora() async {
    int anterior = _reproductor.currentIndex! - 1;
    if (anterior >= 0){
      reproducirEmisora(_emisorasEscuchando[anterior], _emisorasEscuchando);
    }else{
      reproducirEmisora(_emisorasEscuchando.last, _emisorasEscuchando);
    }
  }

  void playPause() {
    if (_reproductor.playing) {
      _reproductor.pause();
    } else {
      _reproductor.play();
    }
    notifyListeners();
  }

  void reproducirEmisora(Emisora emisora, List<Emisora> emisoras) async {

    var indiceEmisora = emisoras.indexOf(emisora);
    if (indiceEmisora == -1) {
      return;
    }

    _emisoraSeleccionada = emisora;
    _emisorasEscuchando = emisoras;

    _cargando = true;
    notifyListeners();
    try{
      await _reproductor.setAudioSources(
        emisoras.map((emisora) => AudioSource.uri(Uri.parse(emisora.url))).toList(),
        initialIndex: indiceEmisora,
      );
    }on PlayerException catch (e){
      print("Error al reproducir emisora: $e");
      pararReproduccion();
      notifyListeners();
      return;
    }

    _cargando = false;
    _reproductor.play();
    notifyListeners();
  }

  void pararReproduccion() {
    _emisoraSeleccionada = Emisora("0", "", "", [], []);
    _reproductor.stop();
    notifyListeners();
  }

  List<Emisora> get emisorasEscuchando => List.of(_emisorasEscuchando);
  Emisora get emisoraSeleccionada => _emisoraSeleccionada;
  void set emisoraSeleccionada(Emisora emisora) => _emisoraSeleccionada = emisora;

  bool get reproduciendo => _reproductor.playing;
  bool get parado => _emisoraSeleccionada.id == "0";

  bool get cargando => _cargando;
  bool get haySiguiente => _reproductor.currentIndex !+ 1 < _emisorasEscuchando.length;
  bool get hayAnterior => _reproductor.currentIndex != 0;

  Stream<IcyMetadata?> get metadataStream => _reproductor.icyMetadataStream;
}