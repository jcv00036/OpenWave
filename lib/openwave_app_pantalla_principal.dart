import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openwave/Pantallas/Modales/pantalla_reproduccion.dart';
import 'package:openwave/Pantallas/openwave_app_pantalla_emisoras.dart';
import 'package:openwave/Reproduccion/reproductor.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';

class OpenWavePantallaPrincipal extends StatefulWidget {
  const OpenWavePantallaPrincipal({super.key});

  @override
  State<OpenWavePantallaPrincipal> createState() =>
      _OpenWavePantallaPrincipalState();
}

// TODO: Eliminar el menú lateral de navegación y añadir una barra inferior de navegación
// TODO: Añadir la barra de reproducción en la parte inferior de la pantalla

class _OpenWavePantallaPrincipalState extends State<OpenWavePantallaPrincipal>
    with WidgetsBindingObserver {
  final _pantallas = <Widget>[OpenwaveAppPantallaEmisoras(), Placeholder()];

  int _indice = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 125),
              child: _pantallas[_indice],
            ),
          ),
          Consumer<Reproductor>(
            builder: (context, manager, child) {
              if (manager.parado) {
                return const SizedBox.shrink();
              }
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
                          image: manager.emisoraSeleccionada.imagen!.image,
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
                                manager.emisoraSeleccionada.nombre,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                                StreamBuilder<IcyMetadata?>(
                                  key: ValueKey(manager.emisoraSeleccionada.id),
                                  initialData: null,
                                  stream: manager.metadataStream,
                                  builder: (context, snapshot) {
                                    final metadata = snapshot.data;
                                    final title = metadata?.info?.title ?? '';
                                    final urlTransmision = metadata?.info?.url ?? '';
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
                          onPressed: manager.retrocederEmisora,
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
                            child: manager.cargando
                                ? CircularProgressIndicator()
                                : Icon(Icons.stop_outlined, size: 30),
                          ),
                          onPressed: () => manager.pararReproduccion(),
                        ),
                        IconButton(
                          onPressed: manager.pasarEmisora,
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
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.radio),
            label: TextosApp.getTexto("nav_emisoras"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_mark),
            label: "Placeholder",
          ),
          //TODO: Añadir los menús que falten
        ],
        currentIndex: _indice,
        onTap: (index) {
          setState(() {
            _indice = index;
          });
        },
      ),
    );
  }
}
