import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../Nucleo/emisora.dart';
import '../constantes.dart';

enum PresetsEcualizador{
  user("ecualizador_preset_user", [0,0,0,0,0]),
  plano("ecualizador_preset_plano", [0,0,0,0,0]),
  rock("ecualizador_preset_rock", [3,2,0,2,7]),
  pop("ecualizador_preset_pop", [0,1,4,6,-2]),
  radioHablada("ecualizador_preset_radio_hablada", [0,5,7,9,0]),
  auriculares("ecualizar_preset_altavoces_pequeños", [4,3,1,-1,-3]),
  electronica("ecualizador_preset_electronica", [3,-1,2,1,4]),
  ;

  final String nombrePreset;
  final List<int> _valores;
  const PresetsEcualizador(this.nombrePreset, valores) : _valores = valores;

  List<int>? get valores => nombrePreset == PresetsEcualizador.user.nombrePreset ? null : _valores;
}

class Reproductor extends ChangeNotifier{

  Emisora _emisoraSeleccionada = Emisora("0", "", "", [], []);
  List<Emisora> _emisorasEscuchando = [];
  AndroidEqualizer ecualizador = AndroidEqualizer();
  late AudioPlayer _reproductor = AudioPlayer(userAgent: USER_AGENT,
                                              useProxyForRequestHeaders: true,
                                              audioPipeline: AudioPipeline(androidAudioEffects: [ecualizador]));

  PresetsEcualizador preset = PresetsEcualizador.plano;
  PresetsEcualizador ultimoPreset = PresetsEcualizador.plano;
  List<int> ecualizadorUsuario = [0,0,0,0,0];

  bool _cargando = false;
  Reproductor() : super(){
    // Cargo el ecualizador del usuario desde ecualizador_usuario.json
    cargarInfoEcualizador();
  }

  Future<void> cargarInfoEcualizador() async {
    var listaRaw = jsonDecode(await rootBundle.loadString(ASSET_ECUALIZADOR_USUARIO));
    ecualizadorUsuario = List<int>.from(listaRaw["valores"]);
    var presets = PresetsEcualizador.values;
    try {
      ultimoPreset = presets.where((preset) => preset.nombrePreset == listaRaw["ultimo_preset"]).first;
    }
    catch (e){
      ultimoPreset = PresetsEcualizador.plano;
    }
    await setPresetEcualizador(ultimoPreset);
  }

  void pasarEmisora() async{
    // Compruebo el siguiente índice
    int siguiente = _reproductor.currentIndex! + 1;
    if (siguiente < _emisorasEscuchando.length) {
      reproducirEmisora(_emisorasEscuchando[siguiente], _emisorasEscuchando);
    }else{
      reproducirEmisora(_emisorasEscuchando[0], _emisorasEscuchando);
    }
  }

  void retrocederEmisora() async {
    int anterior = _reproductor.currentIndex! - 1;
    if (anterior >= 0){
      reproducirEmisora(_emisorasEscuchando[anterior], _emisorasEscuchando);
    }else{
      reproducirEmisora(_emisorasEscuchando.last, _emisorasEscuchando);
    }
  }

  void playPause() {
    if (_reproductor.playing) {
      _reproductor.pause();
    } else {
      _reproductor.play();
    }
    notifyListeners();
  }

  Future<bool> reproducirEmisora(Emisora emisora, List<Emisora> emisoras) async {

    var indiceEmisora = emisoras.indexOf(emisora);
    if (indiceEmisora == -1) {
      return false;
    }

    _emisoraSeleccionada = emisora;
    _emisorasEscuchando = emisoras;

    _cargando = true;
    notifyListeners();
    try{
      await _reproductor.setAudioSources(
        emisoras.map((emisora) => AudioSource.uri(Uri.parse(emisora.url), tag: MediaItem(id: emisora.id, title: emisora.nombre, isLive: true, duration: null, artUri: UriData.fromString(IMAGEN_EMISORA_POR_DEFECTO).uri, displaySubtitle: emisora.etiquetas.join(", ")))).toList(),
        initialIndex: indiceEmisora,
      );
    }on PlayerException catch (e){
      print("Error al reproducir emisora: $e");
      pararReproduccion();
      notifyListeners();
      return false;
    }

    _cargando = false;
    _reproductor.play();
    setPresetEcualizador(ultimoPreset);
    ecualizador.setEnabled(true);
    notifyListeners();
    return true;
  }

  void pararReproduccion() {
    _emisoraSeleccionada = Emisora("0", "", "", [], []);
    _reproductor.stop();

    ultimoPreset = preset;
    ecualizador.setEnabled(false);

    notifyListeners();
  }

  Future<void> setPresetEcualizador(PresetsEcualizador preset) async {
    this.preset = preset;

    var parametros = await ecualizador.parameters;
    if(this.preset != PresetsEcualizador.user){
      for (var i = 0; i < 5; i++) {
        parametros.bands[i].setGain(preset.valores![i].toDouble());
      }
    }else{
      for (var i = 0; i < 5; i++) {
        parametros.bands[i].setGain(ecualizadorUsuario[i].toDouble());
      }
    }
  }

  Future<void> actualizarEcualizadorUsuario(List<int> ecualizadorUsuario) async {
    print(this.ecualizadorUsuario);
    this.ecualizadorUsuario = ecualizadorUsuario;
    print(this.ecualizadorUsuario);
    notifyListeners();

    // Almacena el nuevo ecualizador en el json
    var listaRaw = jsonDecode(await rootBundle.loadString(ASSET_ECUALIZADOR_USUARIO));
    listaRaw["valores"] = this.ecualizadorUsuario;

    final directorio = await getApplicationDocumentsDirectory();
    final archivo = File('${directorio.path}/${ASSET_ECUALIZADOR_USUARIO.split("/")[1]}');
    await archivo.writeAsString(jsonEncode(listaRaw));
  }

  @override
  void dispose() async{
    // Almacena el último preset utilizado en el json
    var listaRaw = jsonDecode(await rootBundle.loadString(ASSET_ECUALIZADOR_USUARIO));
    listaRaw["ultimo_preset"] = preset.nombrePreset;

    final directorio = await getApplicationDocumentsDirectory();
    final archivo = File('${directorio.path}/${ASSET_ECUALIZADOR_USUARIO.split("/")[1]}');
    await archivo.writeAsString(jsonEncode(listaRaw));

    _reproductor.dispose();
    super.dispose();
  }

  List<Emisora> get emisorasEscuchando => List.of(_emisorasEscuchando);
  Emisora get emisoraSeleccionada => _emisoraSeleccionada;
  void set emisoraSeleccionada(Emisora emisora) => _emisoraSeleccionada = emisora;

  bool get reproduciendo => _reproductor.playing;
  bool get parado => _emisoraSeleccionada.id == "0";

  bool get cargando => _cargando;
  bool get haySiguiente => _reproductor.currentIndex !+ 1 < _emisorasEscuchando.length;
  bool get hayAnterior => _reproductor.currentIndex != 0;

  Stream<IcyMetadata?> get metadataStream => _reproductor.icyMetadataStream;
}