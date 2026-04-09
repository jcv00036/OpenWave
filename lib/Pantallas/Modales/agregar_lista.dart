import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';

import '../../l10n/textos_app.dart';

class PantallaAgregarLista extends StatefulWidget {
  PantallaAgregarLista({
    super.key,
    required this.agregarLista,
    emisora,
    this.eliminarLista,
  }) : _listaEditar = emisora,
        _modoEditar = emisora != null;

  final Function(String) agregarLista;
  final Function(ListaReproduccion)? eliminarLista;
  final ListaReproduccion? _listaEditar;
  late final _modoEditar;

  @override
  State<PantallaAgregarLista> createState() => _PantallaAgregarListaState();
}

class _PantallaAgregarListaState extends State<PantallaAgregarLista> {
  late String nombre = widget._modoEditar ? widget._listaEditar!.nombre : "";

  late final TextEditingController _nombreController = TextEditingController(
    text: nombre,
  );

  late final String _titulo = widget._modoEditar
      ? TextosApp.getTexto("editar_lista")
      : TextosApp.getTexto("agregar_lista");

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulo)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                TextosApp.getTexto("nombre_lista"),
                textAlign: TextAlign.center,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: TextosApp.getTexto("nombre_lista"),
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
            ],
          ),
        ),
      ),
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
                          TextosApp.getTexto("eliminar_lista_pregunta"),
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
                    widget.eliminarLista!(widget._listaEditar!);
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
                          TextosApp.getTexto("eliminar_lista"),
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
                  if (nombre == "") {   // TODO: poner los campos obligatorios
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
                    widget.agregarLista(nombre);
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
}
