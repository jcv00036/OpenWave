import 'package:openwave/Nucleo/IEmisora.dart';
import 'package:openwave/Nucleo/IListaReproduccion.dart';

abstract class IReproduccion {
  bool pausar();
  bool reproducirEmisora(IEmisora emisora);
  bool reproducirLista(IListaReproduccion lista);
  bool pasarEmisora();
}