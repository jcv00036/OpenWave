import 'package:flutter/material.dart';
import 'package:openwave/openwave_app_pantalla_principal.dart';

class OpenWaveApp extends StatelessWidget {

  const OpenWaveApp({super.key});

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
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const OpenWavePantallaPrincipal(),
    );
  }
}
