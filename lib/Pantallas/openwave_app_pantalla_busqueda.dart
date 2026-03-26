import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/emisora.dart';
import 'package:openwave/RadioBrowser/lista_emisoras_radiobrowser.dart';
import 'package:openwave/Reproduccion/reproductor.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

import '../Nucleo/gestor_emisoras.dart';
import '../constantes.dart';

class OpenwaveAppPantallaBusqueda extends StatefulWidget {
  const OpenwaveAppPantallaBusqueda({super.key, required this.buscandoEmisoras, this.editarEmisora, this.buscandoOnline = false, this.agregarEmisora, this.agregarEmisoraCopia, this.listaEmisorasBuscar});
  final buscandoEmisoras;
  final buscandoOnline;
  final List<Emisora>? listaEmisorasBuscar;

  final Function(Emisora)? editarEmisora;
  final Function(String, String, String, List<String>)? agregarEmisora;
  final Function(Emisora)? agregarEmisoraCopia;

  @override
  State<OpenwaveAppPantallaBusqueda> createState() => _OpenwaveAppPantallaBusquedaState();
}

class _OpenwaveAppPantallaBusquedaState extends State<OpenwaveAppPantallaBusqueda> {

  final TextEditingController _busquedaController = TextEditingController();
  List<Emisora> _emisoras_visibles = <Emisora>[];
  bool _promptVacio = true;

  String? _filtroRadioBrowser;

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
                    onChanged: (value) => widget.buscandoOnline ?? false ? setState(() => _filtroRadioBrowser = value) : buscar(value),
                    onSubmitted: (value) => widget.buscandoOnline ?? false ? setState(() => _filtroRadioBrowser = value) : buscar(value),
                    autoFocus: true,
          ),
          SizedBox(height: 16,),
          // Lista de emisoras o listas
          Expanded(
            child: widget.buscandoEmisoras ? widget.buscandoOnline ?? false ? listaEmisorasEncontradasOnline() : listaEmisorasFiltrada() : Text(TextosApp.getTexto("busqueda_listas")), //TODO: Añadir funcionalidad
          )
        ]
      )
    );
  }

  void buscar(String filtro){
    bool filtroVacio = filtro.toLowerCase().trim() == "";
    setState(() {
      if(filtroVacio) {
        _promptVacio = true;
      } else {
        _promptVacio = false;
      }

      if (widget.buscandoEmisoras) {
        _emisoras_visibles = !filtroVacio ? buscarEmisoras(filtro) : [];
      }else{
        //FIXME: Añadir la funcionalidad de buscar listas
      }
    });
  }

  Widget listaEmisorasFiltrada(){
    if (_emisoras_visibles.isEmpty) {
      return pantallaBusquedaVacia();
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
                  child: emisora.imagen ?? Image.asset(IMAGEN_EMISORA_POR_DEFECTO),
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
                        icon: Icon(Icons.edit)),
                    ElevatedButton(
                      onPressed: ()
                      {
                        setState(() {
                          if (reproductor.emisoraSeleccionada == emisora) {
                            reproductor.emisoraSeleccionada = Emisora("0", "", "", [], []);
                            reproductor.pararReproduccion();
                          } else {
                            reproductor.emisoraSeleccionada = emisora;
                            reproductor.reproducirEmisora(emisora, _emisoras_visibles);
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
                      reproductor.reproducirEmisora(emisora, _emisoras_visibles);
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

  Widget listaEmisorasEncontradasOnline(){
    return ListaEmisorasRadiobrowser(filtro: _filtroRadioBrowser ?? "", agregarEmisora: widget.agregarEmisoraCopia!, context : context);
  }

  List<Emisora> buscarEmisoras(String filtro){
    var emisoras = widget.listaEmisorasBuscar ?? Provider.of<GestorEmisoras>(context, listen: false).emisoras;
    var emisorasFiltradas = emisoras.where((emisora) => emisora.nombre.toLowerCase().contains(filtro.toLowerCase())).toSet();
    emisorasFiltradas.addAll(emisoras.where((emisora) => emisora.etiquetas.any((etiqueta) => etiqueta.toLowerCase().contains(filtro.toLowerCase()))));
    return emisorasFiltradas.toList();
  }

  Widget pantallaBusquedaVacia(){
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 30),
      child: Text(TextosApp.getTexto(_promptVacio ? "busqueda_sin_filtro" : "filtros_no_resultados")),
    );
  }
}
