import 'package:flutter/material.dart';

import '../../Nucleo/emisora.dart';
import '../Modales/agregar_a_playlist.dart';

class BotonAgregarALista extends StatefulWidget {
  const BotonAgregarALista({super.key, required Emisora emisoraEditar}): _emisoraEditar = emisoraEditar;

  final Emisora _emisoraEditar;
  @override
  State<BotonAgregarALista> createState() => _BotonAgregarAListaState();
}

class _BotonAgregarAListaState extends State<BotonAgregarALista> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) {
                    return AgregarAPlaylist(emisora: widget._emisoraEditar);
                  }
              )
          );
        }),
        icon: Icon(Icons.add_circle_outline)
    );
  }
}
