import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openwave/Reproduccion/reproductor.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

class PantallaEcualizador extends StatefulWidget {
  const PantallaEcualizador({super.key});

  @override
  State<PantallaEcualizador> createState() => _PantallaEcualizadorState();
}

class _PantallaEcualizadorState extends State<PantallaEcualizador> {

  TextEditingController menuController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var reproductor = Provider.of<Reproductor>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(TextosApp.getTexto("titulo_ecualizador")),
      ),
      body: SafeArea(
        child: Column(
          children: [
            DropdownMenu(
              controller: menuController,
              dropdownMenuEntries: [
                for (PresetsEcualizador preset in PresetsEcualizador.values)
                  DropdownMenuEntry(value: preset, label: TextosApp.getTexto(preset.nombrePreset))
              ],
              initialSelection: reproductor.preset,
              onSelected: (value) async {
                await reproductor.setPresetEcualizador(value as PresetsEcualizador);
                setState(() {
                });
              },
            ),
            Expanded(
              child: RotatedBox(
                  quarterTurns: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FutureBuilder(
                            future: reproductor.ecualizador.parameters,
                            builder: (context, asyncSnapshot) {
                              final parameters = asyncSnapshot.data;
                              if (parameters == null) {
                                return SizedBox();
                              }
                              var bandas = parameters.bands;
                              return ListView.builder(
                                  itemCount: bandas.length,
                                  itemBuilder: (context, index) {
                                    var nombreBanda = bandas[index].centerFrequency > 1000 ? "${bandas[index].centerFrequency / 1000}KHz" : "${bandas[index].centerFrequency}Hz";
                                    return Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          RotatedBox(
                                              quarterTurns: 1,
                                              child: Text(nombreBanda)
                                          ),
                                          Expanded(
                                            child: StreamBuilder(
                                              stream: bandas[index].gainStream,
                                              builder: (context, asyncSnapshot) {
                                                var gain = asyncSnapshot.data;
                                                if (gain == null) {
                                                  return SizedBox();
                                                }
                                                return Slider(
                                                    value: bandas[index].gain,
                                                    min: parameters.minDecibels + (parameters.minDecibels % 2),
                                                    max: parameters.maxDecibels - (parameters.maxDecibels % 2),
                                                    divisions: parameters.maxDecibels.toInt() - (parameters.maxDecibels.toInt() % 2),
                                                    onChanged: (value) async{
                                                      List<int> ecualizadorActual = bandas.map((banda) => banda.gain.toInt()).toList();
                                                      await reproductor.actualizarEcualizadorUsuario(ecualizadorActual);
                                                      await reproductor.setPresetEcualizador(PresetsEcualizador.user);
                                                      setState(() {
                                                        bandas[index].setGain(value);
                                                        menuController.value = TextEditingValue(text: TextosApp.getTexto(PresetsEcualizador.user.nombrePreset));
                                                      });
                                                    },
                                                );
                                              }
                                            ),
                                          ),
                                          RotatedBox(
                                              quarterTurns: 1,
                                              child: Text("${bandas[index].gain.toString()}db")
                                          ),
                                        ]
                                      ),
                                    );
                                  }
                              );
                            }
                          ),
                        )
                      ],
                    ),
                  )
              ),
            ),
          ],
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        ElevatedButton(
          style: ButtonStyle(
            alignment: Alignment.center,
            fixedSize: WidgetStateProperty.all(const Size(180, 50)),
            backgroundColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.equalizer),
              SizedBox(width: 8), // Espacio entre el icono y el texto
              Text(TextosApp.getTexto("boton_aceptar"), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
