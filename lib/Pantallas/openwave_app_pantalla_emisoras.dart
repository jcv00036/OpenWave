import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:openwave/Pantallas/Modales/agregar_emisora.dart';
import 'package:openwave/Pantallas/Widgets/lista_emisoras.dart';
import 'package:openwave/Pantallas/openwave_app_pantalla_busqueda.dart';
import 'package:openwave/constantes.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

import '../Nucleo/emisora.dart';
import '../Nucleo/gestor_emisoras.dart';
import '../Nucleo/gestor_listas.dart';
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
            if(manager.emisoras.isEmpty){
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(TextosApp.getTexto("no_hay_emisoras"), overflow: TextOverflow.clip, textAlign: TextAlign.center,),
                ),
              );
            }
            else {
              return ListaEmisoras(emisoras: manager.emisoras);
            }
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
            agregarEmisora: (nombre, url, imagen, etiquetas) async {
              if (await manager.agregarEmisora(nombre, url, imagen, etiquetas)){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${TextosApp.getTexto("emisora_agregada"
                      )} $nombre"))
                );
              }
            },
            agregarEmisoraCopia: (emisora) async {
              if (await manager.agregarEmisoraCopia(emisora)){
                // Vuelve a la pantalla de inicio
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${TextosApp.getTexto("emisora_agregada"
                    )} ${emisora.nombre}"))
                );
              }
            }
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
            agregarEmisora: (nombre, url, imagen, etiquetas) async {
              if (await manager.editarEmisora(emisora, nombre, url, imagen, etiquetas)) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("${TextosApp.getTexto("emisora_editada"
                        )} ${emisora.nombre}"))
                );
              }
            },
            emisora: emisora,
            eliminarEmisora: (emisora) async {
              if (await manager.eliminarEmisora(emisora)) {
                var gestorListas = Provider.of<GestorListas>(context, listen: false);
                gestorListas.recargarListas();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("${TextosApp.getTexto("emisora_eliminada"
                        )} ${emisora.nombre}"))
                );
              }
            },);
          },
      ),
    );
  }
}
