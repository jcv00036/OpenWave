import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:openwave/Reproduccion/reproductor.dart';

import '../../constantes.dart';
import '../../l10n/textos_app.dart';
import '../Modales/pantalla_reproduccion.dart';

class Minireproductor extends StatefulWidget {
  const Minireproductor({super.key, required this.reproductor, required BuildContext this.context});

  final Reproductor reproductor;
  final BuildContext context;
  
  @override
  State<Minireproductor> createState() => _MinireproductorState();
}

class _MinireproductorState extends State<Minireproductor> {
  @override
  Widget build(BuildContext context) {
    context = widget.context;
    return Material(
      elevation:
      8, // Añade una pequeña sombra para separarlo del contenido
      color:
      Theme.of(context).bottomAppBarTheme.color ??
          Theme.of(context).colorScheme.surfaceContainer,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Row(
            children: [
              Image(
                image: widget.reproductor.emisoraSeleccionada.imagen?.image ?? AssetImage(IMAGEN_EMISORA_POR_DEFECTO),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reproductor.emisoraSeleccionada.nombre,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    StreamBuilder<IcyMetadata?>(
                      key: ValueKey(widget.reproductor.emisoraSeleccionada.id),
                      initialData: null,
                      stream: widget.reproductor.metadataStream,
                      builder: (context, snapshot) {
                        final metadata = snapshot.data;
                        final title = metadata?.info?.title ?? '';
                        if (title != '') {
                          return SizedBox(
                            height:
                            20, // Altura suficiente para el texto labelLarge
                            child: Marquee(
                              text:
                              "${TextosApp.getTexto("reproduciendo")}: $title",
                              style: Theme.of(
                                context,
                              ).textTheme.labelLarge,
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              blankSpace:
                              50.0, // Espacio entre el final del texto y el inicio de la repetición
                              velocity:
                              30.0, // Velocidad del movimiento
                              pauseAfterRound: const Duration(
                                seconds: 0,
                              ), // Pausa al completar una vuelta
                              accelerationDuration: const Duration(
                                seconds: 1,
                              ),
                              accelerationCurve: Curves.linear,
                              decelerationDuration: const Duration(
                                milliseconds: 500,
                              ),
                              decelerationCurve: Curves.easeOut,
                            ),
                          );
                        }
                        return Container(
                          height: 0,
                          padding: EdgeInsets.zero,
                        );
                      },
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: widget.reproductor.retrocederEmisora,
                icon: Icon(Icons.skip_previous),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  fixedSize: const Size(60, 60),
                  padding: EdgeInsets.zero,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.inversePrimary,
                ),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: widget.reproductor.cargando
                      ? CircularProgressIndicator()
                      : Icon(Icons.stop, size: 30),
                ),
                onPressed: () => widget.reproductor.pararReproduccion(),
              ),
              IconButton(
                onPressed: widget.reproductor.pasarEmisora,
                icon: Icon(Icons.skip_next),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaReproduccion(),
            ),
          ),
        },
      ),
    );
  }
}
