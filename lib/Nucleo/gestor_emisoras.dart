import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:openwave/Nucleo/base_datos.dart';
import 'package:openwave/Nucleo/emisora.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image/image.dart' as img;

class GestorEmisoras extends ChangeNotifier{

  static List<Emisora> _emisoras = [];
  static late final Database _database;

  Future<void> _cargarEmisoras() async{
    var listaEmisorasRaw = await _database.query("emisora");
    listaEmisorasRaw.forEach((Map<String, Object?> mapa) {
      _emisoras.add(Emisora(mapa["id"].toString(), mapa["nombre"].toString(), mapa["url"].toString(), [], []));
      Image imagen;
      if(mapa["imagen"] == null){
        imagen = Image.asset("assets/img/emisora_default.png");
      }else{
        Uint8List imagenBytes = mapa["imagen"] as Uint8List;
        imagen = Image.memory(imagenBytes);
      }
      _emisoras.last.imagen = imagen;
      if(mapa["etiquetas"] == null) {
        _emisoras.last.etiquetas = [];
      }else if(mapa["etiquetas"].toString().isEmpty){
        _emisoras.last.etiquetas = [];
      }else{
        _emisoras.last.etiquetas = mapa["etiquetas"].toString().split(",");
      }
    });
  }

  Future<void> init() async{
    // Carga la base de datos
    _database = await BaseDatos.db;
    await _cargarEmisoras();
    notifyListeners();
  }

  List<Emisora> get emisoras {
    if (_emisoras.isEmpty) {
      init();
    }
    return List.of(_emisoras);
  }

  Future<bool> agregarEmisora(String nombre, String url, Image imagen, List<String> etiquetas) async{
    try {
      // Convierto la imagen a bytes
      final Completer<ui.Image> completer = Completer<ui.Image>();
      final ImageStream stream = imagen.image.resolve(const ImageConfiguration());
      late ImageStreamListener listener;

      listener = ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      });
      stream.addListener(listener);

      final ui.Image uiImage = await completer.future;
      final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List imagenBytes = byteData!.buffer.asUint8List();

      int id = await _database.insert("emisora", {"nombre": nombre, "url": url, "imagen": imagenBytes, "etiquetas": etiquetas.join(",")});
      _emisoras.add(Emisora(id.toString(), nombre, url, [], etiquetas));
      _emisoras.last.imagen = imagen;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error al agregar emisora: $e");
      return false;
    }
  }

  Future<bool> agregarEmisoraCopia(Emisora emisora) async {

    // Si las etiquetas es una lista con cadenas vacías, la convierto en una lista vacía
    if (emisora.etiquetas.toSet().length == 1 && emisora.etiquetas.first.isEmpty) {
      emisora.etiquetas = [];
    }

    // Si hay alguna etiqueta vacía, la saco
    emisora.etiquetas.removeWhere((etiqueta) => etiqueta.isEmpty);

    try {
      Uint8List? imagenBytes;

      // Si tiene una imagen, la convierto a jpg comprimido 512x512 como el resto de las emisoras
      if (emisora.imagen != null) {
        final Completer<ui.Image> completer = Completer<ui.Image>();
        final ImageStream stream = emisora.imagen!.image.resolve(const ImageConfiguration());
        late ImageStreamListener listener;

        listener = ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info.image);
          stream.removeListener(listener);
        });
        stream.addListener(listener);

        final ui.Image uiImage = await completer.future;
        final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

        final imagen = img.decodeImage(byteData!.buffer.asUint8List());
        if (imagen == null) return false;

        // Redimensiono la imagen a 512x512 o max(img.width, img.height)^2
        final int dimMax = max(imagen.width, imagen.height);
        final int ancho = dimMax > 512 ? 512 : dimMax;
        final int alto = dimMax > 512 ? 512 : dimMax;

        final img.Image imagenRedimensionada = img.copyResize(imagen, width: ancho, height: alto);

        imagenBytes = img.encodeJpg(imagenRedimensionada, quality: 80);

        emisora.imagen = Image.memory(imagenBytes);
      }

      // Añado la emisora a la base de datos
      int id = await _database.insert("emisora", {"nombre": emisora.nombre, "url": emisora.url, "imagen": imagenBytes, "etiquetas": emisora.etiquetas.join(",")});

      // Añade la emisora a la lista de emisoras
      emisora.id = id.toString();
      _emisoras.add(emisora);

      notifyListeners();
      return true;
    }catch (e) {
      print("Error al agregar emisora: $e");
      return false;
    }
  }

  Future<bool> editarEmisora(Emisora emisora, String nombre, String url, Image imagen, List<String> etiquetas) async {
    try {
      // Convierto la imagen a bytes
      final Completer<ui.Image> completer = Completer<ui.Image>();
      final ImageStream stream = imagen.image.resolve(const ImageConfiguration());
      late ImageStreamListener listener;

      listener = ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      });
      stream.addListener(listener);

      final ui.Image uiImage = await completer.future;
      final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List imagenBytes = byteData!.buffer.asUint8List();

      // Edito la emisora en la base de datos
      var id = emisora.id;
      await _database.update("emisora", {"nombre": nombre, "url": url, "imagen": imagenBytes, "etiquetas": etiquetas.join(",")}, where: "id = ?", whereArgs: [id]);
      // Actualizo la emisora en la lista de emisoras
      int indice = _emisoras.indexOf(emisora);
      _emisoras[indice].nombre = nombre;
      _emisoras[indice].url = url;
      _emisoras[indice].imagen = imagen;
      _emisoras[indice].etiquetas = etiquetas;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error al editar emisora: $e");
      return false;
    }
  }

  Future<bool> eliminarEmisora(Emisora emisora) async {
    try{
      await _database.delete("emisora", where: "id = ?", whereArgs: [emisora.id]);

      // Borra también todas las apariciones que tenga en una lista de reproduccion
      await _database.delete("emisora_lista", where: "id_emisora = ?", whereArgs: [emisora.id]);

      _emisoras.remove(emisora);
      notifyListeners();
      return true;
    }catch(e){
      print("Error al eliminar emisora: $e");
      return false;
    }
  }
}