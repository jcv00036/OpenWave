import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:openwave/Pantallas/Modales/agregar_emisora.dart';
import 'package:provider/provider.dart';

import '../Nucleo/emisora.dart';
import '../Nucleo/gestor_emisoras.dart';
import '../Reproduccion/reproductor.dart';

class OpenwaveAppPantallaEmisoras extends StatefulWidget {
  const OpenwaveAppPantallaEmisoras({super.key});

  @override
  State<OpenwaveAppPantallaEmisoras> createState() =>
      _OpenwaveAppPantallaEmisorasState();
}

class _OpenwaveAppPantallaEmisorasState extends State<OpenwaveAppPantallaEmisoras> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => botonAgregarPulsado(),
        shape: const CircleBorder(),
        child: Icon(CupertinoIcons.plus),
      ),
      body: SafeArea(
        child: Consumer2<GestorEmisoras, Reproductor>(
          builder: (context, manager, reproductor, child) {
            return ListView.builder(
              // Obtenemos la cantidad de emisoras
              padding: EdgeInsets.only(bottom: 56),
              itemCount: manager.emisoras.length,
              itemBuilder: (context, index) {
                final emisora = manager.emisoras[index];
                return ListTile(
                  leading: const Icon(Icons.radio),
                  // Icono a la izquierda
                  title: Text(emisora.nombre),
                  // Nombre de la emisora
                  subtitle: Text(emisora.url),
                  // URL
                  //onLongPress: , TODO: Modificar emisora
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () => botonAgregarPulsado, // TODO: Añadir opción
                          icon: Icon(Icons.settings)),
                      ElevatedButton(
                        onPressed: () =>
                            botonEmisoraPulsado(emisora, reproductor),
                        child: emisora == reproductor.emisoraSeleccionada
                            ? const Icon(Icons.stop_rounded)
                            : const Icon(Icons.play_arrow_rounded),
                      ),
                    ],
                  ),
                  // Botón de reproducción a la derecha
                  onTap: () {
                    print("Reproduciendo: ${emisora.nombre}");
                    setState(() {
                      if (reproductor.emisoraSeleccionada == emisora) {
                        reproductor.emisoraSeleccionada = Emisora("0", "", "", [], []);
                        reproductor.pararReproduccion();
                      } else {
                        reproductor.emisoraSeleccionada = emisora;
                        reproductor.reproducirEmisora(emisora);
                      }
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void botonEmisoraPulsado(Emisora emisora, Reproductor reproductor) {
    print("Reproduciendo: ${emisora.nombre}");
    setState(() {
      if (reproductor.emisoraSeleccionada == emisora) {
        reproductor.pararReproduccion();
      } else {
        reproductor.emisoraSeleccionada = emisora;
        reproductor.reproducirEmisora(emisora);
      }
    });
  }

  void botonAgregarPulsado() {
    final manager = Provider.of<GestorEmisoras>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PantallaAgregarEmisora(
            agregarEmisora: (nombre, url) =>
                manager.agregarEmisora(nombre, url),
          );
        },
      ),
    );
  }
}
