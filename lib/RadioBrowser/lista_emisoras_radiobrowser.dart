import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openwave/constantes.dart';
import 'package:openwave/l10n/textos_app.dart';

import '../Nucleo/emisora.dart';

class ListaEmisorasRadiobrowser extends StatefulWidget {
  const ListaEmisorasRadiobrowser({super.key, required this.filtro, required this.agregarEmisora, required this.context});

  final String filtro;
  final String urlApi = API_RADIOBROWSER;
  final BuildContext context;

  final Function(Emisora) agregarEmisora;

  @override
  State<ListaEmisorasRadiobrowser> createState() => _ListaEmisorasRadiobrowserState();
}

class _ListaEmisorasRadiobrowserState extends State<ListaEmisorasRadiobrowser> {

  List<Emisora> _emisorasEncontradas = [];

  Future<List<Emisora>> buscarEmisorasRadioBrowser(String filtro) async {
    List<Emisora> emisoras = [];

    //Hago una llamada a la api para buscar emisoras por su nombre
    final uri = Uri.parse(widget.urlApi + "?name=" + filtro);
    final response = await http.get(uri);

    // Convierto la lista de emisoras en un json
    final json = response.body;

    // Convierto el json en una lista de emisoras
    final emisorasJson = jsonDecode(json);
    for (var emisora in emisorasJson){
      emisoras.add(Emisora.fromJson(emisora));
    }

    return emisoras;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: buscarEmisorasRadioBrowser(widget.filtro),
        builder: (context, snapshot) {
          if (widget.filtro == ""){
            return Text(TextosApp.getTexto("busqueda_sin_filtro"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text(TextosApp.getTexto("error_conexion_api_busqueda"));
          } else { // Si la llamada ha ido bien
            _emisorasEncontradas = snapshot.data!;
            if (_emisorasEncontradas.isEmpty) {
              return Text(TextosApp.getTexto("filtros_no_resultados"));
            }
            // Si hay resultados
            return ListView.builder(
              itemCount: _emisorasEncontradas.length,
              itemBuilder: (context, index) {
                final emisora = _emisorasEncontradas[index];
                return InkWell(
                  onTap: () => widget.agregarEmisora(emisora),
                  child: ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: emisora.imagen ?? Image.asset(IMAGEN_EMISORA_POR_DEFECTO),
                      ),
                    // Icono a la izquierda
                    title: Text(emisora.nombre, overflow: TextOverflow.ellipsis,),
                    subtitle: Text(emisora.url, overflow: TextOverflow.ellipsis,),
                    //Botón de añadir
                    trailing: ElevatedButton(
                      onPressed: () {
                        widget.agregarEmisora(emisora);
                      },
                      child:  SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                );
              }
            );
          }
        }
    );
  }
}
