import 'package:flutter/material.dart';
import 'package:openwave/openwave_app_pantalla_principal.dart';
import 'package:system_theme/system_theme_builder.dart';

class OpenWaveApp extends StatelessWidget {

  const OpenWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(
      builder: (context, color) {
        return ColoredBox(
          color: color.accent, // Automatically updates when system theme changes
          child: MaterialApp(
            title: "OpenWave",
            theme: ThemeData.from(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: color.accent,
                    brightness: Brightness.light
                ),
                useMaterial3: true
            ),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
            home: const OpenWavePantallaPrincipal(),
          ),
        );
      },
    );
  }
}
