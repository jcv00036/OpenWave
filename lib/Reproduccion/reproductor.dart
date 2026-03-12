import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';

import '../Nucleo/emisora.dart';
import '../constantes.dart';

class Reproductor extends ChangeNotifier{

  Emisora _emisoraSeleccionada = Emisora("0", "", "", [], []);

  final AudioPlayer _reproductor = AudioPlayer(userAgent: USER_AGENT,
                                                        useProxyForRequestHeaders: true, // default
                                                      );
  Reproductor() : super();

  bool pasarEmisora() {
    // TODO: implement pasarEmisora
    throw UnimplementedError();
  }

  void playPause() {
    if (_reproductor.playing) {
      _reproductor.pause();
    } else {
      _reproductor.play();
    }
    notifyListeners();
  }

  void reproducirEmisora(Emisora emisora) async {
    _emisoraSeleccionada = emisora;
    await _reproductor.setUrl(emisora.url);
    _reproductor.play();
    notifyListeners();
  }

  bool reproducirLista(ListaReproduccion lista) {
    // TODO: implement reproducirLista
    throw UnimplementedError();
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