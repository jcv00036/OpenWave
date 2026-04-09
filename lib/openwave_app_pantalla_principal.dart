import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openwave/Pantallas/Modales/pantalla_reproduccion.dart';
import 'package:openwave/Pantallas/Widgets/minireproductor.dart';
import 'package:openwave/Pantallas/openwave_app_pantalla_emisoras.dart';
import 'package:openwave/Pantallas/openwave_app_pantalla_listas.dart';
import 'package:openwave/Reproduccion/reproductor.dart';
import 'package:openwave/constantes.dart';
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
  final _pantallas = <Widget>[OpenwaveAppPantallaEmisoras(), OpenwaveAppPantallaListas()];

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
              return Minireproductor(reproductor: manager, context : context);
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
            icon: Icon(Icons.list),
            label: TextosApp.getTexto("nav_listas"),
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
