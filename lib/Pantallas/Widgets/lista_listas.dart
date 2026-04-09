import 'package:flutter/material.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

import '../../Nucleo/gestor_emisoras.dart';
import '../../Nucleo/gestor_listas.dart';
import '../../Nucleo/lista_reproduccion.dart';
import '../../Reproduccion/reproductor.dart';
import '../Modales/agregar_lista.dart';
import '../Modales/lista_reproduccion.dart';

class ListaListas extends StatefulWidget {
  const ListaListas({super.key, required this.listas});

  final List<ListaReproduccion> listas;


  @override
  State<ListaListas> createState() => _ListaListasState();
}

class _ListaListasState extends State<ListaListas> {
  @override
  Widget build(BuildContext context) {

    var reproductor = Provider.of<Reproductor>(context, listen: false);

    return ListView.builder(
        itemCount: widget.listas.length,
        itemBuilder: (context, index) {
          final lista = widget.listas[index];
          return ListTile(
            leading: Icon(lista.nombre == TextosApp.getTexto("lista_favoritos") ? Icons.favorite : Icons.list),
            title: Text(lista.nombre),
            subtitle: Text(lista.emisoras.isEmpty ? TextosApp.getTexto("lista_vacia") : "${lista.emisoras.length} ${TextosApp.getTexto("emisoras_nombre_plural")}"),
            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () => botonEditarPulsado(lista, context),
                      icon: Icon(Icons.edit)
                  ),
                  ElevatedButton(
                    onPressed: () => botonListaPulsado(lista, context),
                    child:  SizedBox(
                      width: 24,
                      height: 24,
                      child: lista.emisoras.isEmpty ? const Icon(Icons.play_disabled) : reproductor.cargando && reproductor.emisoraSeleccionada == lista.emisoras.first && reproductor.emisorasEscuchando == lista.emisoras
                          ? const CircularProgressIndicator()
                          : reproductor.emisoraSeleccionada == lista.emisoras.first && reproductor.emisorasEscuchando == lista.emisoras
                          ? const Icon(Icons.stop_rounded)
                          : const Icon(Icons.play_arrow_rounded),
                    ),
                  ),
                ]
            ),
            onTap: () => listaPulsada(lista, context),
          );
        }
    );
  }

  void botonEditarPulsado(ListaReproduccion lista, BuildContext context){
    final manager = Provider.of<GestorListas>(context, listen: false);
    final managerEmisoras = Provider.of<GestorEmisoras>(context, listen: false);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) {
              return PantallaAgregarLista(
                  agregarLista: (nombre, emisoras) {},
                  managerEmisoras: managerEmisoras,
                  lista: lista,
                  editarLista: (nombre, emisoras) async {
                    bool resultado = await manager.editarLista(lista, nombre, emisoras);
                    if(resultado){
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${TextosApp.getTexto(
                              "lista_editada")} $nombre")));
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(TextosApp.getTexto("error_lista_editar"))));
                    }
                  },
                  eliminarLista: (lista) async {
                    bool resultado = await manager.eliminarLista(lista);
                    if(resultado){
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${TextosApp.getTexto(
                              "lista_eliminada")} ${lista.nombre}")));
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(TextosApp.getTexto("error_lista_eliminar"))));
                    }
                  }
              );
            })
    );
  }

  Future<void> botonListaPulsado(ListaReproduccion lista, BuildContext context) async {
    if(lista.emisoras.isEmpty){
      // Muestra un snackbar con un mensaje de que la lista está vacía
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(TextosApp.getTexto("error_lista_vacia"))));
      return;
    }

    // Si no, comenzamos la reproducción de la lista
    final reproductor = Provider.of<Reproductor>(context, listen: false);
    bool resultado = await reproductor.reproducirEmisora(lista.emisoras.first, lista.emisoras);
    if(!resultado){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(TextosApp.getTexto("error_reproduciendo")))
      );
    }
  }

  void listaPulsada(ListaReproduccion lista, BuildContext context){
    // Nos movemos a la pantalla de la lista
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PantallaListaReproduccion(lista: lista, reproducirLista: (lista) => botonListaPulsado(lista, context));
        },
      ),
    );
  }
}
