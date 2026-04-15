import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Nucleo/emisora.dart';
import '../../Nucleo/gestor_listas.dart';
import '../../l10n/textos_app.dart';

class CorazonFavoritos extends StatefulWidget {
  const CorazonFavoritos({super.key, required Emisora emisoraEditar}): _emisoraEditar = emisoraEditar;

  final Emisora _emisoraEditar;
  @override
  State<CorazonFavoritos> createState() => _CorazonFavoritosState();
}

class _CorazonFavoritosState extends State<CorazonFavoritos> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => setState(() {
          cambiarFavorita(context);
        }),
        icon: Consumer<GestorListas>(
            builder: (context, gestorListas, child) {
              return FutureBuilder(
                  future: esFavorita(context),
                  builder: (context, snapshot) {
                    return Icon(
                        snapshot.hasData && snapshot.data!
                            ? Icons.favorite
                            : Icons.favorite_border);
                  });
            }
        )
    );
  }

  Future<void> cambiarFavorita(BuildContext context) async {
    var gestorListas = Provider.of<GestorListas>(context, listen: false);

    // Editamos la emisora
    var listaFavoritos = await gestorListas.listaFavoritos;
    var favoritos = listaFavoritos.emisoras.toSet();

    bool agregando = false;
    if(favoritos.contains(widget._emisoraEditar)){
      favoritos.remove(widget._emisoraEditar);
    }else{
      favoritos.add(widget._emisoraEditar);
      agregando = true;
    }

    bool resultado = await gestorListas.editarLista(listaFavoritos, listaFavoritos.nombre, favoritos.toList());
    if(resultado){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                agregando
                    ? TextosApp.getTexto("favorito_agregado")
                    : TextosApp.getTexto("favorito_no_agregado")
            ),
            duration: const Duration(seconds: 1),
          )
      );
    }
  }

  Future<bool> esFavorita(BuildContext context) async {
    var gestorListas = Provider.of<GestorListas>(context, listen: false);

    var listaFavoritos = await gestorListas.listaFavoritos;
    var favoritos = listaFavoritos.emisoras.toSet();
    return favoritos.contains(widget._emisoraEditar);
  }
}
