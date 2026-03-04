import 'package:flutter/material.dart';
import 'package:openwave/inicio.dart';

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
