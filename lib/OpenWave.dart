import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openwave/Reproduccion/IReproductor.dart';
import 'package:openwave/inicio.dart';

import 'Reproduccion/Reproductor.dart';
import 'constantes.dart';

class OpenWave extends StatelessWidget {

  const OpenWave({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "OpenWave",
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.amber
          ),
          useMaterial3: true
      ),

      home: const Inicio(),
    );
  }
}
