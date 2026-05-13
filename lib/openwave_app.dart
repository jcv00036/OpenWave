import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openwave/Nucleo/gestor_emisoras.dart';
import 'package:openwave/Nucleo/gestor_listas.dart';
import 'package:openwave/Reproduccion/reproductor.dart';
import 'package:openwave/openwave_app_pantalla_principal.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme_builder.dart';

class OpenWaveApp extends StatelessWidget {
  const OpenWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Impido que la pantalla se pueda girar
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return SystemThemeBuilder(
      builder: (context, color) {
        return ColoredBox(
          color:
              color.accent, // Automatically updates when system theme changes
          child: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (context) => GestorEmisoras()),
                ChangeNotifierProvider(create: (context) => GestorListas(Provider.of<GestorEmisoras>(context, listen: false))),
                ChangeNotifierProvider(create: (context) => Reproductor()),
              ],
              child:MaterialApp(
                title: "OpenWave",
                theme: ThemeData.from(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: color.accent,
                    brightness: Brightness.light,
                  ),
                  useMaterial3: true,
                ),
                darkTheme: ThemeData.from(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: color.accent,
                    brightness: Brightness.dark,
                  ),
                ),
                themeMode: ThemeMode.system,
                home: const OpenWavePantallaPrincipal(),
              )
          )
        );
      },
    );
  }
}
