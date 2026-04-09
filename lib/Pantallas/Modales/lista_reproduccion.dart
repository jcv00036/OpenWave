import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';
import 'package:openwave/Pantallas/Widgets/lista_emisoras.dart';
import 'package:openwave/Pantallas/openwave_app_pantalla_busqueda.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

import '../../Nucleo/gestor_emisoras.dart';
import '../../Nucleo/gestor_listas.dart';
import '../../Reproduccion/reproductor.dart';
import '../Widgets/minireproductor.dart';
import 'agregar_lista.dart';

class PantallaListaReproduccion extends StatefulWidget {
  const PantallaListaReproduccion({
    super.key,
    required this.lista,
    required this.reproducirLista,
  });

  final ListaReproduccion lista;
  final Function(ListaReproduccion) reproducirLista;

  @override
  State<PantallaListaReproduccion> createState() =>
      _PantallaListaReproduccionState();
}

class _PantallaListaReproduccionState extends State<PantallaListaReproduccion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lista.nombre),
        actions: [
          IconButton(
            onPressed: () => botonEditarPulsado(context),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => botonBuscarPulsado(context),
            icon: const Icon(Icons.search),
          ),
          IconButton.filled(
            onPressed: () => widget.reproducirLista(widget.lista),
            icon: const Icon(Icons.play_arrow),
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ],
      ),
      body: Consumer<GestorListas>(
        builder: (context, manager, child) {
          var index = manager.listas.indexWhere((element) => element.id == widget.lista.id);
          var lista = manager.listas[index];
          return Column(
            children: [
              Expanded(child: ListaEmisoras(emisoras: lista.emisoras)),
            ],
          );
        }
      ),
      bottomNavigationBar: Consumer<Reproductor>(
        builder: (context, manager, child) {
          if (manager.parado) {
            return SafeArea(
              maintainBottomViewPadding: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [const SizedBox.shrink()],
              ),
            );
          }
          return SafeArea(
            maintainBottomViewPadding: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Minireproductor(reproductor: manager, context: context),
              ],
            ),
          );
        },
      ),
    );
  }

  void botonEditarPulsado(BuildContext context) {
    final manager = Provider.of<GestorListas>(context, listen: false);
    final managerEmisoras = Provider.of<GestorEmisoras>(context, listen: false);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) {
              return PantallaAgregarLista(
                  agregarLista: (nombre, emisoras) {},
                  managerEmisoras: managerEmisoras,
                  lista: widget.lista,
                  editarLista: (nombre, emisoras) async {
                    bool resultado = await manager.editarLista(widget.lista, nombre, emisoras);
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

  void botonBuscarPulsado(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OpenwaveAppPantallaBusqueda(
          buscandoEmisoras: true,
          buscandoOnline: false,
          listaEmisorasBuscar: widget.lista.emisoras,
        ),
      ),
    );
  }
}
