import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/emisora.dart';
import 'package:openwave/Reproduccion/reproductor.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

import '../Nucleo/gestor_emisoras.dart';

class OpenwaveAppPantallaBusqueda extends StatefulWidget {
  OpenwaveAppPantallaBusqueda({super.key, required this.buscandoEmisoras, this.editarEmisora});
  final buscandoEmisoras;

  final Function(Emisora)? editarEmisora;

  @override
  State<OpenwaveAppPantallaBusqueda> createState() => _OpenwaveAppPantallaBusquedaState();
}

class _OpenwaveAppPantallaBusquedaState extends State<OpenwaveAppPantallaBusqueda> {

  final TextEditingController _busquedaController = TextEditingController();
  List<Emisora> _emisoras_visibles = <Emisora>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.buscandoEmisoras ? Text(TextosApp.getTexto("busqueda_emisoras")) : Text(TextosApp.getTexto("busqueda_listas")),
      ),
      body: Column(

        children: [
          // Barra de búsqueda
          SearchBar(controller: _busquedaController,
                    leading: Icon(Icons.search),
                    hintText: widget.buscandoEmisoras ? TextosApp.getTexto("pista_busqueda_emisoras") : TextosApp.getTexto("pista_busqueda_emisoras"),
                    onChanged: (value) => buscar(value),
                    onSubmitted: (value) => buscar(value),
                    autoFocus: true,
          ),
          SizedBox(height: 16,),
          // Lista de emisoras o listas
          Expanded(
            child: widget.buscandoEmisoras ? listaEmisorasFiltrada() : Text("busqueda_listas"), //TODO: Añadir funcionalidad
          )
        ]
      )
    );
  }

  void buscar(String filtro){
    setState(() {
      if (widget.buscandoEmisoras) {
        _emisoras_visibles = buscarEmisoras(filtro);
      }else{
        //FIXME: Añadir la funcionalidad de buscar listas
      }
    });
  }

  Widget listaEmisorasFiltrada(){
    if (_emisoras_visibles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 30),
        child: Text(TextosApp.getTexto("filtros_no_resultados")),
      );
    }else{
      return ListView.builder(
        itemCount: _emisoras_visibles.length,
        itemBuilder: (context, index) {
          final emisora = _emisoras_visibles[index];
          return Consumer<Reproductor>(
            builder: (context, reproductor, child) {
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
                        onPressed: () => widget.editarEmisora?.call(emisora),
                        icon: Icon(Icons.settings)),
                    ElevatedButton(
                      onPressed: ()
                      {
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
            }
          );
        }
      );
    }
  }

  List<Emisora> buscarEmisoras(String filtro){
    var emisoras = Provider.of<GestorEmisoras>(context, listen: false).emisoras;
    var emisorasFiltradas = emisoras.where((emisora) => emisora.nombre.toLowerCase().contains(filtro.toLowerCase())).toSet();
    emisorasFiltradas.addAll(emisoras.where((emisora) => emisora.etiquetas.any((etiqueta) => etiqueta.toLowerCase().contains(filtro.toLowerCase()))));
    return emisorasFiltradas.toList();
  }
}
