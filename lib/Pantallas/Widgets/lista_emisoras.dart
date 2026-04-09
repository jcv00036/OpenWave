import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/emisora.dart';
import 'package:openwave/Reproduccion/reproductor.dart';
import 'package:provider/provider.dart';

import '../../Nucleo/gestor_emisoras.dart';
import '../../Nucleo/gestor_listas.dart';
import '../../constantes.dart';
import '../../l10n/textos_app.dart';
import '../Modales/agregar_emisora.dart';

class ListaEmisoras extends StatefulWidget {
  const ListaEmisoras({super.key, required this.emisoras});

  final List<Emisora> emisoras;

  @override
  State<ListaEmisoras> createState() => _ListaEmisorasState();
}

class _ListaEmisorasState extends State<ListaEmisoras> {
  @override
  Widget build(BuildContext context) {
    final Reproductor reproductor = Provider.of<Reproductor>(context);

    return ListView.builder(
      // Obtenemos la cantidad de emisoras
      padding: EdgeInsets.only(bottom: 56),
      itemCount: widget.emisoras.length,
      itemBuilder: (context, index) {
        final emisora = widget.emisoras[index];
        return ListTile(
          leading: SizedBox(
            width: 40,
            height: 40,
            child: Image(
                width: 40,
                height: 40,
                image: emisora.imagen != null ? emisora.imagen!.image : AssetImage(IMAGEN_EMISORA_POR_DEFECTO),
                fit: BoxFit.cover
            ),
          ),
          // Icono a la izquierda
          title: Text(emisora.nombre),
          // Nombre de la emisora
          subtitle: Text(emisora.etiquetas.isEmpty
              ? emisora.url
              : emisora.etiquetas.join(", "), overflow: TextOverflow.ellipsis,),
          // URL
          onLongPress: () => editarEmisora(emisora, context),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () => editarEmisora(emisora, context),
                  icon: Icon(Icons.edit)),
              ElevatedButton(
                onPressed: () {
                print("Reproduciendo: ${emisora.nombre}");
                  setState(() {
                    if (reproductor.emisoraSeleccionada == emisora) {
                      reproductor.emisoraSeleccionada = Emisora("0", "", "", [], []);
                      reproductor.pararReproduccion();
                    } else {
                      reproductor.emisoraSeleccionada = emisora;
                      reproducirEmisora(emisora, context);
                    }
                  });
                },
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
                reproducirEmisora(emisora, context);
              }
            });
          },
        );
      },
    );
  }

  void editarEmisora(Emisora emisora, BuildContext context) {
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

  Future<void> reproducirEmisora(Emisora emisora, BuildContext context) async {
    final reproductor = Provider.of<Reproductor>(context, listen: false);
    bool resultado = await reproductor.reproducirEmisora(emisora, widget.emisoras);
    if(!resultado){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(TextosApp.getTexto("error_reproduciendo")))
      );
    }
  }
}
