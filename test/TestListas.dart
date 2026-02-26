import 'package:flutter_test/flutter_test.dart';
import 'package:openwave/Nucleo/Emisora.dart';
import 'package:openwave/Nucleo/ListaReproduccion.dart';

void main() {
  group('Pruebas de Ordenación de ListaReproduccion', () {
    late ListaReproduccion playlist;

    setUp(() {
      playlist = ListaReproduccion('Test Playlist');
    });

    test('Debe devolver emisoras en orden alfabético cuando no es rutina', () {
      playlist.emisoras = [
        Emisora('Zeta', 'url1', [], []),
        Emisora('Alpha', 'url2', [], []),
        Emisora('Beta', 'url3', [], []),
      ];

      final resultado = playlist.emisoras;

      expect(resultado.map((e) => e.nombre),
          orderedEquals(['Alpha', 'Beta', 'Zeta']));
    });

    test('Debe devolver emisoras por orden de tiempo cuando es rutina', () {
      final e1 = Emisora('Mañana', 'url1', [], []);
      final e2 = Emisora('Tarde', 'url2', [], []);
      final e3 = Emisora('Noche', 'url3', [], []);

      // Seteamos la temporización. El setter pondrá esRutina = true.
      playlist.temporizacion = {
        10: e1,
        20: e2,
        30: e3,
      };

      final resultado = playlist.emisoras;

      expect(resultado.map((e) => e.nombre),
          orderedEquals(['Mañana', 'Tarde', 'Noche']));
    });
  });
}
