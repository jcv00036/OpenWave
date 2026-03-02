import 'package:openwave/Nucleo/IEmisora.dart';
import 'package:openwave/Nucleo/IListaReproduccion.dart';

abstract class IReproductor {
  static void playPause() {
    // TODO: implement playPause
  }
  static void reproducirEmisora(IEmisora emisora) {
    // TODO: implement reproducirEmisora
  }
  static bool reproducirLista(IListaReproduccion lista) {
    // TODO: implement reproducirLista
    throw UnimplementedError();
  }
  static bool pasarEmisora() {
    // TODO: implement pasarEmisora
    throw UnimplementedError();
  }
}