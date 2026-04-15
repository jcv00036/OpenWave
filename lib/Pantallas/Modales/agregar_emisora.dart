import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openwave/Pantallas/Widgets/openwave_app_agregar_lista_boton.dart';
import 'package:openwave/Pantallas/Widgets/openwave_app_corazon_favoritos.dart';
import 'package:openwave/Pantallas/openwave_app_pantalla_busqueda.dart';
import 'package:provider/provider.dart';

import '../../Nucleo/emisora.dart';
import '../../Nucleo/gestor_listas.dart';
import '../../constantes.dart';
import '../../l10n/textos_app.dart';

class PantallaAgregarEmisora extends StatefulWidget {
  PantallaAgregarEmisora({
    super.key,
    required this.agregarEmisora,
    emisora,
    this.eliminarEmisora,
    this.agregarEmisoraCopia
  }) : _emisoraEditar = emisora,
       _modoEditar = emisora != null;

  final Function(String, String, Image, List<String>) agregarEmisora;
  final Function(Emisora)? eliminarEmisora;
  final Function(Emisora)? agregarEmisoraCopia;
  final Emisora? _emisoraEditar;
  late final _modoEditar;

  @override
  State<PantallaAgregarEmisora> createState() => _PantallaAgregarEmisoraState();
}

class _PantallaAgregarEmisoraState extends State<PantallaAgregarEmisora> {
  late String nombre = widget._modoEditar ? widget._emisoraEditar!.nombre : "";
  late String url = widget._modoEditar ? widget._emisoraEditar!.url : "";
  late Image imagen = widget._modoEditar
      ? widget._emisoraEditar?.imagen ?? Image.asset(IMAGEN_EMISORA_POR_DEFECTO)
      : Image.asset(IMAGEN_EMISORA_POR_DEFECTO, width: 200, height: 200);
  late List<String> etiquetas = widget._modoEditar
      ? widget._emisoraEditar!.etiquetas
      : [];
  String buffer = "";

  final TextEditingController _etiquetasController = TextEditingController();
  late final TextEditingController _nombreController = TextEditingController(
    text: nombre,
  );
  late final TextEditingController _urlController = TextEditingController(
    text: url,
  );

  late final String _titulo = widget._modoEditar
      ? TextosApp.getTexto("editar_emisora")
      : TextosApp.getTexto("agregar_emisora");

  @override
  void dispose() {
    _etiquetasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarYRecortarImagen() async {
    final picker = ImagePicker();
    final XFile? fichero = await picker.pickImage(source: ImageSource.gallery);

    if (fichero != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: fichero.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80, // Compresión para evitar "Row too big"
        maxWidth: 512, // Límite de resolución razonable
        maxHeight: 512,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: TextosApp.getTexto("recortar_imagen"),
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: TextosApp.getTexto("recortar_imagen"),
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      // Compruebo que el tamaño de la imagen no sea mayor a 1.8Mb
      if (croppedFile != null) {
        final bytes = await croppedFile.readAsBytes();
        final size = bytes.lengthInBytes;
        if (size > 1800000) {
          // Muestro un diálogo de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(TextosApp.getTexto("imagen_muy_grande"))),
          );
          return;
        }
      }

      if (croppedFile != null) {
        setState(() {
          imagen = Image.file(
            File(croppedFile.path),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_titulo),
          actions: [
            if (widget._modoEditar) BotonAgregarALista(emisoraEditar: widget._emisoraEditar ?? Emisora("0", "", "", [], [])),
            if (widget._modoEditar) CorazonFavoritos(emisoraEditar: widget._emisoraEditar ?? Emisora("0", "", "", [], [])),
          ],
      ),
      floatingActionButton: widget._modoEditar ? null : FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          // Abrimos la pantalla de búsqueda
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OpenwaveAppPantallaBusqueda(
                buscandoEmisoras: true,
                buscandoOnline: true,
                agregarEmisoraCopia: widget.agregarEmisoraCopia,
              ),
            ),
          );
        },
        child: Icon(Icons.search),
      ),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image(
                        image: imagen.image,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 55,
                        height: 55,
                        child: IconButton.filled(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.inversePrimary,
                            ),
                            foregroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            iconSize: WidgetStateProperty.all(25),
                            iconAlignment: IconAlignment.start,
                          ),
                          onPressed: _seleccionarYRecortarImagen,
                          icon: Icon(Icons.add_a_photo),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                TextosApp.getTexto("nombre_emisora"),
                textAlign: TextAlign.center,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: TextosApp.getTexto("nombre_emisora"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  prefixIcon: Icon(Icons.radio),
                ),
                controller: _nombreController,
                onChanged: (nombre_nuevo) {
                  setState(() {
                    nombre = nombre_nuevo;
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                TextosApp.getTexto("url_emisora"),
                textAlign: TextAlign.center,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: TextosApp.getTexto("url_emisora"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  prefixIcon: Icon(Icons.link),
                ),
                controller: _urlController,
                onChanged: (url_nueva) {
                  setState(() {
                    url = url_nueva;
                  });
                },
              ),
              SizedBox(height: 16),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        }),
                      },
                    ),
                  ),
                  IconButton.filled(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.inversePrimary,
                      ),
                      foregroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onPressed: () {
                      agregarEtiqueta(buffer, context);
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              // Muestro las etiquetas como globos con una x para eliminarlas si fuera necesario
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.of(
                    etiquetas.map((etiqueta) {
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget._modoEditar)
                ElevatedButton(
                  style: ButtonStyle(
                    alignment: Alignment.center,
                    fixedSize: WidgetStateProperty.all(const Size(180, 50)),
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.errorContainer,
                    ),
                  ),
                  onPressed: () async {
                    // Mostramos un diálogo de confirmación
                    var opcion = await showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(TextosApp.getTexto("atencion_titulo")),
                        content: Text(
                          TextosApp.getTexto("eliminar_emisora_pregunta"),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancelar'),
                            child: Text(TextosApp.getTexto("boton_cancelar")),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Aceptar'),
                            child: Text(TextosApp.getTexto("boton_aceptar")),
                          ),
                        ],
                      ),
                    );
                    if (opcion == 'Cancelar') return;
                    widget.eliminarEmisora!(widget._emisoraEditar!);
                    Navigator.pop(context);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8), // Espacio entre el icono y el texto
                      Expanded(
                        child: Text(
                          TextosApp.getTexto("eliminar_emisora"),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ElevatedButton(
                style: ButtonStyle(
                  alignment: Alignment.center,
                  fixedSize: WidgetStateProperty.all(const Size(180, 50)),
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.inversePrimary,
                  ),
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
                    Icon(widget._modoEditar ? Icons.edit : CupertinoIcons.plus),
                    SizedBox(width: 8), // Espacio entre el icono y el texto
                    Text(_titulo, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void agregarEtiqueta(String etiqueta, BuildContext context) {
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
      // Borramos el buffer
      buffer = "";
      _etiquetasController.clear();
    });
  }
}
