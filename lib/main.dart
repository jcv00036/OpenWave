import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/gestor_emisoras.dart';
import 'package:openwave/openwave_app.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:system_theme/system_theme.dart';


Future<void> main() async {
  // WidgetsFlutterBinding();
  //
  WidgetsFlutterBinding.ensureInitialized();
  await TextosApp.cargarTextos("es");
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Inicializa la factoría para escritorio
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Se cargan los colores
  SystemTheme.fallbackColor = Colors.amber;
  await SystemTheme.accentColor.load();

  runApp(const OpenWaveApp());
  // Emisora emisora = Emisora('Test', 'https://dispatcher.rndfnk.com/crtve/rne5/main/mp3/high', [], []);
  // reproductor.reproducirEmisora(emisora);
}
