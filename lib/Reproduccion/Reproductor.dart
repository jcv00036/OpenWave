import 'package:openwave/Nucleo/IEmisora.dart';
import 'package:openwave/Nucleo/IListaReproduccion.dart';
import 'package:openwave/Reproduccion/IReproductor.dart';
import 'package:just_audio/just_audio.dart';

class Reproductor implements IReproductor{

  final AudioPlayer _reproductor;

  Reproductor(this._reproductor) : super();

  @override
  bool pasarEmisora() {
    // TODO: implement pasarEmisora
    throw UnimplementedError();
  }

  @override
  void playPause() {
    if (_reproductor.playing) {
      _reproductor.pause();
    } else {
      _reproductor.play();
    }
  }

  @override
  void reproducirEmisora(IEmisora emisora) async {
    await _reproductor.setUrl(emisora.url);
    _reproductor.play();
  }

  @override
  bool reproducirLista(IListaReproduccion lista) {
    // TODO: implement reproducirLista
    throw UnimplementedError();
  }
}