import 'package:flutter/material.dart';
import 'package:openwave/Reproduccion/Reproductor.dart';
import 'package:openwave/l10n/textosApp.dart';
import 'package:openwave/Nucleo/GestorEmisoras.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TextosApp.getTexto("titulo_inicio")),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const Drawer(
      ),
      body: SafeArea(
        child: ListView.builder(
          // Obtenemos la cantidad de emisoras
          itemCount: GestorEmisoras.emisoras.length,
          itemBuilder: (context, index) {
            final emisora = GestorEmisoras.emisoras[index];

            return ListTile(
              leading: const Icon(Icons.radio), // Icono a la izquierda
              title: Text(emisora.nombre),     // Nombre de la emisora
              subtitle: Text(emisora.url),     // URL o frecuencia debajo
              trailing: const Icon(Icons.play_arrow), // Botón de play a la derecha
              onTap: () {
                print("Reproduciendo: ${emisora.nombre}");
                // Aquí llamarías a tu reproductor
                Reproductor.reproducirEmisora(emisora);
              },
            );
          },
        ),
      )
    );
  }
}
