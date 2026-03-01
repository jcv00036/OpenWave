import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openwave/Nucleo/Emisora.dart';
import 'package:openwave/OpenWave.dart';
import 'package:openwave/Reproduccion/Reproductor.dart';
import 'package:openwave/Reproduccion/IReproductor.dart';
import 'package:openwave/l10n/textosApp.dart';


Future<void> main() async {
  // WidgetsFlutterBinding();
  //
  // var reproductorAudio = AudioPlayer(userAgent: 'myradioapp/1.0 (Linux;Android 11) https://myradioapp.com',
  //   useProxyForRequestHeaders: true, // default
  // );
  await TextosApp.cargarTextos("es");
  runApp(const OpenWave());
  // Emisora emisora = Emisora('Test', 'https://dispatcher.rndfnk.com/crtve/rne5/main/mp3/high', [], []);
  // IReproductor reproductor = Reproductor(reproductorAudio);
  // reproductor.reproducirEmisora(emisora);
}
