import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openwave/openwave_app.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:system_theme/system_theme.dart';
import 'package:audio_session/audio_session.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TextosApp.cargarTextos(Platform.localeName.split('_').first);
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Inicializa la factoría para escritorio
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Se cargan los colores
  SystemTheme.fallbackColor = Colors.amber;
  await SystemTheme.accentColor.load();

  final sesionAudio = await AudioSession.instance;
  sesionAudio.configure(AudioSessionConfiguration.music());

  runApp(const OpenWaveApp());
}
