import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openwave/Nucleo/Emisora.dart';
import 'package:openwave/Nucleo/GestorEmisoras.dart';
import 'package:openwave/OpenWave.dart';
import 'package:openwave/Reproduccion/Reproductor.dart';
import 'package:openwave/Reproduccion/IReproductor.dart';
import 'package:openwave/l10n/textosApp.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'constantes.dart';


Future<void> main() async {
  // WidgetsFlutterBinding();
  //
  WidgetsFlutterBinding.ensureInitialized();
  await TextosApp.cargarTextos("es");
  // FIXME: PARA PRUEBAS
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Inicializa la factoría para escritorio
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await GestorEmisoras.init();
  runApp(const OpenWave());
  // Emisora emisora = Emisora('Test', 'https://dispatcher.rndfnk.com/crtve/rne5/main/mp3/high', [], []);
  // reproductor.reproducirEmisora(emisora);
}
