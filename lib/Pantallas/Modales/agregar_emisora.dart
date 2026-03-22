import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../Nucleo/gestor_emisoras.dart';
import '../../constantes.dart';
import '../../l10n/textos_app.dart';

class PantallaAgregarEmisora extends StatefulWidget {
  const PantallaAgregarEmisora({super.key, required this.agregarEmisora});

  final Function(String, String, Image, List<String>) agregarEmisora;

  @override
  State<PantallaAgregarEmisora> createState() => _PantallaAgregarEmisoraState();
}

class _PantallaAgregarEmisoraState extends State<PantallaAgregarEmisora> {
  String nombre = "";
  String url = "";
  Image imagen = Image.asset(IMAGEN_EMISORA_POR_DEFECTO,
                             width: 200,
                             height: 200);
  List<String> etiquetas = <String>[];
  String buffer = "";

  final TextEditingController _etiquetasController = TextEditingController();

  @override
  void dispose() {
    _etiquetasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(TextosApp.getTexto("agregar_emisora")),),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      imagen,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                            onPressed: () {
                              // Cargamos la imagen que introduce el usuario con el image_picker
                              final picker = ImagePicker();
                              picker.pickImage(source: ImageSource.gallery).then((value) {
                                if (value != null) {
                                  setState(() {
                                    imagen = Image.file(File(value.path), width: 200, height: 200);
                                  });
                                }
                              });
                            },
                            child: Icon(Icons.add_a_photo)),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  TextosApp.getTexto("nombre_emisora"),
                  textAlign: TextAlign.center,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: TextosApp.getTexto("nombre_emisora"),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    prefixIcon: Icon(Icons.radio),
                  ),
                  onChanged: (nombre_nuevo) {
                    setState(() {
                      nombre = nombre_nuevo;
                    });
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  TextosApp.getTexto("url_emisora"),
                  textAlign: TextAlign.center,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: TextosApp.getTexto("url_emisora"),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    prefixIcon: Icon(Icons.link),
                  ),
                  onChanged: (url_nueva) {
                    setState(() {
                      url = url_nueva;
                    });
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  TextosApp.getTexto("etiquetas_emisora"),
                  textAlign: TextAlign.center,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: TextosApp.getTexto("etiquetas_emisora"),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          prefixIcon: Icon(CupertinoIcons.tag),
                        ),
                        controller: _etiquetasController,
                        onSubmitted: (etiqueta_nueva) {
                          agregarEtiqueta(etiqueta_nueva, context);
                          // Borramos el buffer
                          setState(() {
                            buffer = "";
                          });
                          // Borramos lo que ha escrito el usuario
                          _etiquetasController.clear();
                        },
                        onChanged: (etiqueta_nueva) => {
                          setState(() {
                            buffer = etiqueta_nueva;
                          })
                        },
                      ),
                    ),
                    IconButton.filled(onPressed: () {
                      agregarEtiqueta(buffer, context);
                    }, icon: Icon(Icons.add))
                  ],
                ),
                // Muestro las etiquetas como globos con una x para eliminarlas si fuera necesario
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.of(etiquetas.map((etiqueta){
                      return Chip(
                        label: Text(etiqueta),
                        deleteIcon: Icon(CupertinoIcons.xmark),
                        onDeleted: () {
                          setState(() {
                            etiquetas.remove(etiqueta);
                          });
                        },
                      );
                    }),
                ))),
              ],
            ),
          ),
      ),
      persistentFooterButtons:
      [
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
                widget.agregarEmisora(nombre, url, imagen, etiquetas);
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

  void agregarEtiqueta(String etiqueta, BuildContext context){
    bool agregada = false;
    bool copia = false;
    for (String e in etiquetas) {
      if (e == etiqueta) copia = true;
    }
    // Si la etiqueta ya existe, no la agregamos y mostramos un mensaje de error
    if (copia || etiqueta == "") {
      // Mostrar un mensaje de error
      showDialog(
        context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(TextosApp.getTexto("atencion_titulo")),
            content: Text(TextosApp.getTexto("error_etiqueta_incorrecta")),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: Text(TextosApp.getTexto("boton_aceptar")),
              ),
            ],
          ),
      );
      return;
    }
    setState(() {
      etiquetas.add(etiqueta);
      agregada = true;
      // Borramos el buffer
      buffer = "";
      _etiquetasController.clear();
    });
  }
}