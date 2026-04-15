import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/emisora.dart';
import 'package:openwave/Nucleo/gestor_listas.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';
import 'package:provider/provider.dart';

import '../../l10n/textos_app.dart';

class AgregarAPlaylist extends StatefulWidget {
  const AgregarAPlaylist({super.key, required emisora}): _emisoraAgregar = emisora;

  final Emisora _emisoraAgregar;
  
  @override
  State<AgregarAPlaylist> createState() => _AgregarAPlaylistState();
}

class _AgregarAPlaylistState extends State<AgregarAPlaylist> {

  Set<ListaReproduccion> _listas = <ListaReproduccion>{};
  bool _inicializado = false;
  @override
  Widget build(BuildContext context) {
    GestorListas gestorListas = Provider.of<GestorListas>(context);
    var listasTotales = gestorListas.listas;

    if (!_inicializado) {
      _listas = listasTotales.where((lista) =>
          lista.emisoras.contains(widget._emisoraAgregar)).toSet();
      _inicializado = true;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(TextosApp.getTexto("emisoras_agregar_lista")),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                TextosApp.getTexto("titulo_inicio_listas"),
                textAlign: TextAlign.center,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme
                      .of(context)
                      .colorScheme
                      .outline),
                  borderRadius: BorderRadius.circular(12),
                  color: Theme
                      .of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                ),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: listasTotales.length,
                    itemBuilder: (context, index) {
                      var lista = listasTotales[index];

                      return ListTile(
                        leading: lista.nombre ==
                            TextosApp.getTexto("lista_favoritos") ? Icon(
                            Icons.favorite) : Icon(Icons.list),
                        title: Text(lista.nombre),
                        trailing: Checkbox(
                          value: _listas.contains(lista),
                          onChanged: (value) {
                            if (value == true) {
                              setState(() {
                                _listas.add(lista);
                              });
                            } else {
                              setState(() {
                                _listas.remove(lista);
                              });
                            }
                          },
                        ),
                      );
                    }
                ),
              ),
            ],
          ),
        ),
        persistentFooterAlignment: AlignmentDirectional.center,
        persistentFooterButtons: [
          ElevatedButton(
            style: ButtonStyle(
              alignment: Alignment.center,
              fixedSize: WidgetStateProperty.all(const Size(180, 50)),
              backgroundColor: WidgetStateProperty.all(
                Theme
                    .of(context)
                    .colorScheme
                    .surfaceContainerHigh,
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.playlist_remove),
                SizedBox(width: 8), // Espacio entre el icono y el texto
                Text(TextosApp.getTexto("boton_cancelar"),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              alignment: Alignment.center,
              fixedSize: WidgetStateProperty.all(const Size(180, 50)),
              backgroundColor: WidgetStateProperty.all(
                Theme
                    .of(context)
                    .colorScheme
                    .inversePrimary,
              ),
            ),
            onPressed: () async {
              Set<ListaReproduccion> listasOriginales = listasTotales.where((lista) => lista.emisoras.contains(widget._emisoraAgregar)).toSet();

              // Primero hacemos el bucle de borrados
              Set<ListaReproduccion> listasBorradas = listasOriginales.difference(_listas);
              for (ListaReproduccion lista in listasBorradas) {
                List<Emisora> emisoras = lista.emisoras.toList();
                emisoras.remove(widget._emisoraAgregar);
                gestorListas.editarLista(lista, lista.nombre, emisoras);
              }

              // Ahora hacemos el bucle de añadir
              Set<ListaReproduccion> listasAnadidas = _listas.difference(listasOriginales);
              for (ListaReproduccion lista in listasAnadidas) {
                List<Emisora> emisoras = lista.emisoras.toList();
                emisoras.add(widget._emisoraAgregar);

                gestorListas.editarLista(lista, lista.nombre, emisoras);
              }

              Navigator.pop(context);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.playlist_add_check),
                SizedBox(width: 8), // Espacio entre el icono y el texto
                Text(TextosApp.getTexto("boton_aceptar"),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ]
    );
  }
}
