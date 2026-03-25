import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:openwave/Pantallas/Modales/agregar_emisora.dart';
import 'package:openwave/Pantallas/openwave_app_pantalla_busqueda.dart';
import 'package:openwave/l10n/textos_app.dart';
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
      appBar: AppBar(
        title: Text(TextosApp.getTexto("titulo_inicio_emisoras")),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OpenwaveAppPantallaBusqueda(buscandoEmisoras: true, editarEmisora: (emisora) => botonEditarPulsado(emisora),)));
              },
              icon: Icon(Icons.search)
          )
        ],
      ),
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
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: emisora.imagen,
                  ),
                  // Icono a la izquierda
                  title: Text(emisora.nombre),
                  // Nombre de la emisora
                  subtitle: Text(emisora.etiquetas.isEmpty
                                 ? emisora.url
                                 : emisora.etiquetas.join(", "), overflow: TextOverflow.ellipsis,),
                  // URL
                  //onLongPress: , TODO: Modificar emisora
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () => botonEditarPulsado(emisora),
                          icon: Icon(Icons.settings)),
                      ElevatedButton(
                        onPressed: () =>
                            botonEmisoraPulsado(emisora, reproductor),
                        child:  SizedBox(
                          width: 24,
                          height: 24,
                          child: reproductor.cargando && reproductor.emisoraSeleccionada == emisora
                                  ? const CircularProgressIndicator()
                                  : reproductor.emisoraSeleccionada == emisora
                                    ? const Icon(Icons.stop_rounded)
                                    : const Icon(Icons.play_arrow_rounded),
                        ),
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
                        reproductor.reproducirEmisora(emisora, Provider.of<GestorEmisoras>(context, listen: false).emisoras);
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
        reproductor.reproducirEmisora(emisora, Provider.of<GestorEmisoras>(context, listen: false).emisoras);
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
            agregarEmisora: (nombre, url, imagen, etiquetas) =>
                manager.agregarEmisora(nombre, url, imagen, etiquetas),
          );
        },
      ),
    );
  }

  void botonEditarPulsado(Emisora emisora) {
    final manager = Provider.of<GestorEmisoras>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PantallaAgregarEmisora(
            agregarEmisora: (nombre, url, imagen, etiquetas) =>
                manager.editarEmisora(emisora, nombre, url, imagen, etiquetas),
            emisora: emisora,
            eliminarEmisora: (emisora) => manager.eliminarEmisora(emisora),);
          },
      ),
    );
  }
}
