import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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
  late final AudioPlayer _reproductor = AudioPlayer(userAgent: USER_AGENT,
                                               useProxyForRequestHeaders: true,
                                               audioPipeline: AudioPipeline(androidAudioEffects: [ecualizador]));

  PresetsEcualizador preset = PresetsEcualizador.plano;

  bool _cargando = false;
  Reproductor() : super();

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
        emisoras.map((emisora) => AudioSource.uri(Uri.parse(emisora.url))).toList(),
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
    ecualizador.setEnabled(true);
    setPresetEcualizador(PresetsEcualizador.plano);
    notifyListeners();
    return true;
  }

  void pararReproduccion() {
    _emisoraSeleccionada = Emisora("0", "", "", [], []);
    _reproductor.stop();
    notifyListeners();
  }

  Future<void> setPresetEcualizador(PresetsEcualizador preset) async {
    this.preset = preset;

    if(this.preset != PresetsEcualizador.user){
      var parametros = await ecualizador.parameters;
      for (var i = 0; i < 5; i++) {
        parametros.bands[i].setGain(preset.valores![i].toDouble());
      }
    }
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