import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/gestor_listas.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

import '../Nucleo/gestor_emisoras.dart';
import '../Reproduccion/reproductor.dart';
import 'openwave_app_pantalla_busqueda.dart';
import 'package:openwave/Pantallas/Modales/agregar_lista.dart';

class OpenwaveAppPantallaListas extends StatefulWidget {
  const OpenwaveAppPantallaListas({super.key});

  @override
  State<OpenwaveAppPantallaListas> createState() => _OpenwaveAppPantallaListasState();
}

class _OpenwaveAppPantallaListasState extends State<OpenwaveAppPantallaListas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TextosApp.getTexto("titulo_inicio_listas")),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OpenwaveAppPantallaBusqueda(buscandoEmisoras: false)));
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
      body: Consumer2<GestorListas, Reproductor>(
        builder: (context, gestorListas, reproductor, child) {
          return ListView.builder(
            itemCount: gestorListas.listas.length,
            itemBuilder: (context, index) {
              final lista = gestorListas.listas[index];
              return ListTile(
                leading: Icon(lista.nombre == TextosApp.getTexto("lista_favoritos") ? Icons.favorite : Icons.list),
                title: Text(lista.nombre),
                subtitle: Text(lista.emisoras.isEmpty ? TextosApp.getTexto("lista_vacia") : "${lista.emisoras.length} ${TextosApp.getTexto("emisoras_nombre_plural")}"),
                  trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () => botonEditarPulsado(lista),
                            icon: Icon(Icons.edit)
                        ),
                        ElevatedButton(
                          onPressed: () => botonListaPulsado(lista),
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
              );
            }
          );
        }
      ),
    );
  }

  void botonAgregarPulsado(){
    final manager = Provider.of<GestorListas>(context, listen: false);
    final managerEmisoras = Provider.of<GestorEmisoras>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PantallaAgregarLista(agregarLista: (nombre, emisoras) async {
            bool resultado = await manager.agregarLista(nombre, emisoras);
            if(resultado){
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${TextosApp.getTexto(
                      "lista_agregada")} $nombre")));
            }else{
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(TextosApp.getTexto("error_lista_agregar"))));
            }
          },
          managerEmisoras: managerEmisoras,
          );
        },
      ),
    );
  }

  void botonEditarPulsado(lista){
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

  void botonListaPulsado(ListaReproduccion lista){
    if(lista.emisoras.isEmpty){
      // Muestra un snackbar con un mensaje de que la lista está vacía
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(TextosApp.getTexto("error_lista_vacia"))));
    }
  }
}
