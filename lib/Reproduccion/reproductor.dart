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
  Reproductor() : super();

  void pasarEmisora() async{
    await _reproductor.seekToNext();
    if (_reproductor.currentIndex != null) {
      _emisoraSeleccionada = _emisorasEscuchando[_reproductor.currentIndex!];
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
    //await _reproductor.setUrl(emisora.url);
    _reproductor.play();
    notifyListeners();
  }

  void pararReproduccion() {
    _emisoraSeleccionada = Emisora("0", "", "", [], []);
    _reproductor.stop();
    notifyListeners();
  }

  Emisora get emisoraSeleccionada => _emisoraSeleccionada;
  void set emisoraSeleccionada(Emisora emisora) => _emisoraSeleccionada = emisora;

  bool get reproduciendo => _reproductor.playing;
  bool get parado => _emisoraSeleccionada.id == "0";

}