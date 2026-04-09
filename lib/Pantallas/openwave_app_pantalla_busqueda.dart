import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/emisora.dart';
import 'package:openwave/Nucleo/gestor_listas.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';
import 'package:openwave/Pantallas/Widgets/lista_emisoras.dart';
import 'package:openwave/Pantallas/Widgets/lista_listas.dart';
import 'package:openwave/RadioBrowser/lista_emisoras_radiobrowser.dart';
import 'package:openwave/Reproduccion/reproductor.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

import '../Nucleo/gestor_emisoras.dart';
import '../constantes.dart';

class OpenwaveAppPantallaBusqueda extends StatefulWidget {
  const OpenwaveAppPantallaBusqueda({super.key, required this.buscandoEmisoras, this.editarEmisora, this.buscandoOnline = false, this.agregarEmisora, this.agregarEmisoraCopia, this.listaEmisorasBuscar, this.listaListasBuscar});
  final buscandoEmisoras;
  final buscandoOnline;
  final List<Emisora>? listaEmisorasBuscar;
  final List<ListaReproduccion>? listaListasBuscar;

  final Function(Emisora)? editarEmisora;
  final Function(String, String, String, List<String>)? agregarEmisora;
  final Function(Emisora)? agregarEmisoraCopia;

  @override
  State<OpenwaveAppPantallaBusqueda> createState() => _OpenwaveAppPantallaBusquedaState();
}

class _OpenwaveAppPantallaBusquedaState extends State<OpenwaveAppPantallaBusqueda> {

  final TextEditingController _busquedaController = TextEditingController();
  List<Emisora> _emisoras_visibles = <Emisora>[];
  List<ListaReproduccion> _listas_visibles = <ListaReproduccion>[];

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
            child: widget.buscandoEmisoras ? widget.buscandoOnline ?? false ? listaEmisorasEncontradasOnline() : listaEmisorasFiltrada() : listaListasFiltrada(),
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
        _listas_visibles = !filtroVacio ? buscarListas(filtro) : [];
      }
    });
  }

  Widget listaEmisorasFiltrada(){
    if (_emisoras_visibles.isEmpty) {
      return pantallaBusquedaVacia();
    }else{
      return ListaEmisoras(emisoras: _emisoras_visibles);
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

  Widget listaListasFiltrada(){
    if (_listas_visibles.isEmpty) {
      return pantallaBusquedaVacia();
    }else{
      return ListaListas(listas: _listas_visibles);
    }
  }

  List<ListaReproduccion> buscarListas(String filtro){
    var listas = widget.listaListasBuscar ?? Provider.of<GestorListas>(context, listen: false).listas;
    var listasFiltradas = listas.where((lista) => lista.nombre.toLowerCase().contains(filtro.toLowerCase()));
    return listasFiltradas.toList();
  }

  Widget pantallaBusquedaVacia(){
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 30),
      child: Text(TextosApp.getTexto(_promptVacio ? "busqueda_sin_filtro" : "filtros_no_resultados")),
    );
  }
}
