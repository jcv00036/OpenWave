import 'package:openwave/Nucleo/IEmisora.dart';
import 'package:openwave/Nucleo/IListaReproduccion.dart';

abstract class IReproductor {
  void playPause();
  void reproducirEmisora(IEmisora emisora);
  bool reproducirLista(IListaReproduccion lista);
  bool pasarEmisora();
}