import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';

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
    _cargando = true;
    // Informo de que se está cargando la emisora
    if (_reproductor.currentIndex !+ 1 < _emisorasEscuchando.length) _emisoraSeleccionada = _emisorasEscuchando[_reproductor.currentIndex !+ 1];
    notifyListeners();
    await _reproductor.seekToNext();
    if (_reproductor.currentIndex != null) {
      _emisoraSeleccionada = _emisorasEscuchando[_reproductor.currentIndex!];
      _cargando = false;
      notifyListeners();
    }else{
      _cargando = false;
      _reproductor.stop();
      notifyListeners();
    }
  }

  void retrocederEmisora() async {
    _cargando = true;
    // Informo de que se está cargando la emisora
    if (hayAnterior) _emisoraSeleccionada = _emisorasEscuchando[_reproductor.currentIndex! - 1];
    notifyListeners();
    await _reproductor.seekToPrevious();
    if (_reproductor.currentIndex != null) {
      _emisoraSeleccionada = _emisorasEscuchando[_reproductor.currentIndex!];
      _cargando = false;
      notifyListeners();
    }else{
      _cargando = false;
      _reproductor.stop();
      notifyListeners();
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
    _cargando = true;
    notifyListeners();

    var indiceEmisora = emisoras.indexOf(emisora);
    if (indiceEmisora == -1) {
      return;
    }
    await _reproductor.setAudioSources(
      emisoras.map((emisora) => AudioSource.uri(Uri.parse(emisora.url))).toList(),
      initialIndex: indiceEmisora,
    );
    _emisorasEscuchando = emisoras;
    _emisoraSeleccionada = emisora;
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
}