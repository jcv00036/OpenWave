import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/gestor_listas.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

import 'openwave_app_pantalla_busqueda.dart';

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
      body: Consumer<GestorListas>(
        builder: (context, manager, child) {
          return ListView.builder(
            itemCount: manager.listas.length,
            itemBuilder: (context, index) {
              final lista = manager.listas[index];
              return ListTile(
                leading: Icon(Icons.list),
                title: Text(lista.nombre),
                subtitle: Text(lista.emisoras.isEmpty ? TextosApp.getTexto("lista_vacia") : "${lista.emisoras.length} ${TextosApp.getTexto("emisoras_nombre_plural")}"),

              );
            }
          );
        }
      ),
    );
  }

  void botonAgregarPulsado(){
    // TODO: Implementar
  }

  void botonBuscarPulsado(){
  }
}
