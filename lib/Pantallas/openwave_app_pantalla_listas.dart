import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/gestor_listas.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';
import 'package:openwave/Pantallas/Widgets/lista_listas.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

import '../Nucleo/gestor_emisoras.dart';
import '../Reproduccion/reproductor.dart';
import 'Modales/lista_reproduccion.dart';
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
          return ListaListas(listas: gestorListas.listas);
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
}
