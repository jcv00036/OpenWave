import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/lista_reproduccion.dart';
import 'package:openwave/Pantallas/Widgets/lista_emisoras.dart';
import 'package:provider/provider.dart';

import '../../Reproduccion/reproductor.dart';
import '../Widgets/minireproductor.dart';

class PantallaListaReproduccion extends StatefulWidget {
  const PantallaListaReproduccion({super.key, required this.lista, required this.reproducirLista});

  final ListaReproduccion lista;
  final Function(ListaReproduccion) reproducirLista;

  @override
  State<PantallaListaReproduccion> createState() => _PantallaListaReproduccionState();
}

class _PantallaListaReproduccionState extends State<PantallaListaReproduccion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lista.nombre),
        actions: [
          IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.search)
          ),
          IconButton.filled(
            onPressed: () => widget.reproducirLista,
            icon: const Icon(Icons.play_arrow),
            color: Theme.of(context).colorScheme.inversePrimary,
          )
        ]
      ),
      body: Column(
        children: [
          Expanded(
              child: ListaEmisoras(emisoras: widget.lista.emisoras)
          ),
        ],
      ),
      bottomNavigationBar:  Consumer<Reproductor>(
                              builder: (context, manager, child) {
                                if (manager.parado) {
                                  return const SizedBox.shrink();
                                }
                                return SafeArea(
                                    maintainBottomViewPadding: true,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Minireproductor(reproductor: manager, context : context),
                                      ],
                                    )
                                );
                              },
                            ),
    );
  }
}
