import 'package:just_audio/just_audio.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';

import '../Nucleo/emisora.dart';
import '../constantes.dart';

class Reproductor{

  static final AudioPlayer _reproductor = AudioPlayer(userAgent: USER_AGENT,
                                                        useProxyForRequestHeaders: true, // default
                                                      );
  Reproductor() : super();

  static bool pasarEmisora() {
    // TODO: implement pasarEmisora
    throw UnimplementedError();
  }

  static void playPause() {
    if (_reproductor.playing) {
      _reproductor.pause();
    } else {
      _reproductor.play();
    }
  }

  static void reproducirEmisora(Emisora emisora) async {
    await _reproductor.setUrl(emisora.url);
    _reproductor.play();
  }

  static bool reproducirLista(ListaReproduccion lista) {
    // TODO: implement reproducirLista
    throw UnimplementedError();
  }

  static void pararReproduccion() {
    _reproductor.stop();
    _reproductor.dispose();
  }
}