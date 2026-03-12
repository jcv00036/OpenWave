import 'package:flutter/material.dart';
import 'package:openwave/Reproduccion/reproductor.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

class PantallaReproduccion extends StatefulWidget {
  const PantallaReproduccion({super.key});

  @override
  State<PantallaReproduccion> createState() => _PantallaReproduccionState();
}

class _PantallaReproduccionState extends State<PantallaReproduccion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(TextosApp.getTexto("reproductor_titulo")),),
      body: Center(
        child: Consumer<Reproductor>(
          builder: (context, reproductor, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: reproductor.emisoraSeleccionada.imagen!.image,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 40),
                Text(
                  reproductor.emisoraSeleccionada.nombre,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 50,
                      onPressed: () {
                        reproductor.pararReproduccion();
                        Navigator.pop(context); // Volver atrás al detener
                      },
                      icon: Icon(Icons.stop_outlined),
                    ),
                    IconButton.filled(
                      iconSize: 75,
                      onPressed: () => reproductor.playPause(),
                      icon: Icon(
                        reproductor.reproduciendo
                            ? Icons.pause
                            : Icons.play_arrow_rounded,
                      ),
                    ),
                    IconButton(
                      iconSize: 50,
                      onPressed: () => reproductor.pasarEmisora(),
                      icon: Icon(Icons.skip_next),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20, left: 70, right: 70),
                  child: ElevatedButton(onPressed: () => {/*TODO: Hacer*/}, child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.equalizer), Text(TextosApp.getTexto("ecualizador"))],),
                  )),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
