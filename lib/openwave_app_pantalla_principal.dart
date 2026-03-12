import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/base_datos.dart';
import 'package:openwave/Nucleo/emisora.dart';
import 'package:openwave/Pantallas/Modales/agregar_emisora.dart';
import 'package:openwave/Pantallas/openwave_app_pantalla_emisoras.dart';
import 'package:openwave/Reproduccion/reproductor.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:openwave/Nucleo/gestor_emisoras.dart';
import 'package:provider/provider.dart';

class OpenWavePantallaPrincipal extends StatefulWidget {
  const OpenWavePantallaPrincipal({super.key});

  @override
  State<OpenWavePantallaPrincipal> createState() => _OpenWavePantallaPrincipalState();
}

// TODO: Eliminar el menú lateral de navegación y añadir una barra inferior de navegación
// TODO: Añadir la barra de reproducción en la parte inferior de la pantalla

class _OpenWavePantallaPrincipalState extends State<OpenWavePantallaPrincipal> with WidgetsBindingObserver {

  final _pantallas = <Widget>[
    OpenwaveAppPantallaEmisoras(),
    Placeholder()
  ];

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
      appBar: AppBar(
        title: Text(TextosApp.getTexto("titulo_inicio")),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 125),
              child: _pantallas[_indice]
            ),
          ),
          Consumer<Reproductor>(
              builder: (context, manager, child) {
                if (manager.parado) {
                  return Container();
                }
                return BottomAppBar(
                    child: Row(
                        children: [
                          Text(manager.emisoraSeleccionada.nombre, style: Theme.of(context).textTheme.titleMedium),
                          Spacer(),
                          IconButton(
                              onPressed: manager.pararReproduccion,
                              icon: Icon(Icons.stop_outlined),
                              style: ButtonStyle(visualDensity: VisualDensity.compact),),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              fixedSize: const Size(60, 60),
                               padding: EdgeInsets.zero,
                               backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                            ),
                            child: Icon(manager.reproduciendo ? Icons.pause : Icons.play_arrow_rounded, size: 30,),
                            onPressed: () => manager.playPause(),
                          ),
                          IconButton(
                            onPressed: manager.pasarEmisora,
                            icon: Icon(Icons.skip_next),
                            style: ButtonStyle(visualDensity: VisualDensity.compact),),
                        ]
                    )
                );
              }
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: const Icon(Icons.radio),
                  label: TextosApp.getTexto("nav_emisoras")
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.question_mark),
                  label: "Placeholder")
            //TODO: Añadir los menús que falten
            ],
          currentIndex: _indice,
          onTap: (index) {
            setState(() {
              _indice = index;
            });
          }
      ),
    );
  }
}
