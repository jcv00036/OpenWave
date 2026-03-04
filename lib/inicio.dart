import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/BaseDatos.dart';
import 'package:openwave/Nucleo/Emisora.dart';
import 'package:openwave/Pantallas/AgregarEmisora.dart';
import 'package:openwave/Reproduccion/Reproductor.dart';
import 'package:openwave/l10n/textosApp.dart';
import 'package:openwave/Nucleo/GestorEmisoras.dart';

import 'Nucleo/IEmisora.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> with WidgetsBindingObserver {
  IEmisora _emisoraSeleccionada = Emisora("0", "", "", [], []);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TextosApp.getTexto("titulo_inicio")),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const Drawer(),
      body: SafeArea(
        child: ListView.builder(
          // Obtenemos la cantidad de emisoras
          itemCount: GestorEmisoras.emisoras.length + 1,
          itemBuilder: (context, index) {
            if (index == GestorEmisoras.emisoras.length) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    alignment: Alignment.center,
                    fixedSize: WidgetStateProperty.all(const Size(200, 50)),
                  ),
                  onPressed:
                      () async{await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PantallaAgregarEmisora()),
                                );
                              },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.plus),
                      SizedBox(width: 8), // Espacio entre el icono y el texto
                      Text(TextosApp.getTexto("agregar_emisora")),
                    ],
                  ),
                ),
              );
            } else {
              final emisora = GestorEmisoras.emisoras[index];
              return ListTile(
                leading: const Icon(Icons.radio), // Icono a la izquierda
                title: Text(emisora.nombre), // Nombre de la emisora
                subtitle: Text(emisora.url), // URL
                //onLongPress: , TODO: Modificar emisora
                trailing: ElevatedButton(
                  onPressed: () {
                    print("Reproduciendo: ${emisora.nombre}");
                    setState(() {
                      if (_emisoraSeleccionada == emisora) {
                        _emisoraSeleccionada = Emisora("0", "", "", [], []);
                        Reproductor.pararReproduccion();
                      } else {
                        _emisoraSeleccionada = emisora;
                        Reproductor.reproducirEmisora(emisora);
                      }
                    });
                  },
                  child: emisora == _emisoraSeleccionada
                      ? const Icon(Icons.stop_rounded)
                      : const Icon(Icons.play_arrow_rounded),
                ), // Botón de reproducción a la derecha
                onTap: () {
                  print("Reproduciendo: ${emisora.nombre}");
                  setState(() {
                    if (_emisoraSeleccionada == emisora) {
                      _emisoraSeleccionada = Emisora("0", "", "", [], []);
                      Reproductor.pararReproduccion();
                    } else {
                      _emisoraSeleccionada = emisora;
                      Reproductor.reproducirEmisora(emisora);
                    }
                  });
                },
              );
            }
          },
        ),
      ),
    );
  }
}
