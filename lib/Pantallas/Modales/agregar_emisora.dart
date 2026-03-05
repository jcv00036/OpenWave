import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Nucleo/gestor_emisoras.dart';
import '../../l10n/textos_app.dart';

class PantallaAgregarEmisora extends StatefulWidget {
  const PantallaAgregarEmisora({super.key, required this.agregarEmisora});

  final Function(String, String) agregarEmisora;

  @override
  State<PantallaAgregarEmisora> createState() => _PantallaAgregarEmisoraState();
}

class _PantallaAgregarEmisoraState extends State<PantallaAgregarEmisora> {
  String nombre = "";
  String url = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: //SingleChildScrollView(
        /*child:*/ Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                TextosApp.getTexto("agregar_emisora"),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                TextosApp.getTexto("nombre_emisora"),
                textAlign: TextAlign.center,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: TextosApp.getTexto("nombre_emisora"),
                ),
                onChanged: (nombre_nuevo) {
                  setState(() {
                    nombre = nombre_nuevo;
                  });
                },
              ),
              Text(
                TextosApp.getTexto("url_emisora"),
                textAlign: TextAlign.center,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: TextosApp.getTexto("url_emisora"),
                ),
                onChanged: (url_nueva) {
                  setState(() {
                    url = url_nueva;
                  });
                },
              ),
            ],
          ),
        ),
      //),
      persistentFooterButtons: [
        Center(
          child: ElevatedButton(
            style: ButtonStyle(
              alignment: Alignment.center,
              fixedSize: WidgetStateProperty.all(const Size(200, 50)),
            ),
            onPressed: () {
              if (nombre == "" || url == "") {
                // Mostrar un mensaje de error
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(TextosApp.getTexto("atencion_titulo")),
                    content: Text(TextosApp.getTexto("error_campos")),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: Text(TextosApp.getTexto("boton_aceptar")),
                      ),
                    ],
                  ),
                );
              } else {
                widget.agregarEmisora(nombre, url);
                Navigator.pop(context);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.plus),
                SizedBox(width: 8), // Espacio entre el icono y el texto
                Text(TextosApp.getTexto("agregar_emisora")),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
