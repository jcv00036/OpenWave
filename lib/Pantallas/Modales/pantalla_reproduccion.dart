import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:openwave/Pantallas/Widgets/openwave_app_agregar_lista_boton.dart';
import 'package:openwave/Pantallas/Widgets/openwave_app_corazon_favoritos.dart';
import 'package:openwave/Reproduccion/reproductor.dart';
import 'package:openwave/constantes.dart';
import 'package:openwave/l10n/textos_app.dart';
import 'package:provider/provider.dart';

class PantallaReproduccion extends StatefulWidget {
  const PantallaReproduccion({super.key});

  @override
  State<PantallaReproduccion> createState() => _PantallaReproduccionState();
}

class _PantallaReproduccionState extends State<PantallaReproduccion> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TextosApp.getTexto("reproductor_titulo")), 
        backgroundColor: Colors.transparent, 
        scrolledUnderElevation: 0,
        actions: [
          BotonAgregarALista(emisoraEditar: Provider.of<Reproductor>(context).emisoraSeleccionada),
          CorazonFavoritos(emisoraEditar: Provider.of<Reproductor>(context).emisoraSeleccionada)
        ],
      ),
      body: Consumer<Reproductor>(
        builder: (context, reproductor, child) {
      return Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_sheetController.isAttached && _sheetController.size > 0.12) {
                _sheetController.animateTo(
                  0.12,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // SECCIÓN DE CABECERA
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: reproductor.cargando
                        ? CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      strokeWidth: 20,
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image(
                        image: reproductor.emisoraSeleccionada.id == "0"
                            ? Image.asset(IMAGEN_EMISORA_POR_DEFECTO).image
                            : (reproductor.emisoraSeleccionada.imagen?.image ?? Image.asset(IMAGEN_EMISORA_POR_DEFECTO).image),
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // NOMBRE DE LA EMISORA (Marquee)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 45,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final String texto = reproductor.cargando
                              ? TextosApp.getTexto("reproductor_titulo_cargando")
                              : reproductor.emisoraSeleccionada.nombre;
                          final style = Theme.of(context).textTheme.headlineMedium;

                          final textPainter = TextPainter(
                            text: TextSpan(text: texto, style: style),
                            maxLines: 1,
                            textDirection: TextDirection.ltr,
                          )..layout();

                          if (textPainter.width < constraints.maxWidth) {
                            return Center(
                              child: Text(texto, style: style, textAlign: TextAlign.center),
                            );
                          }

                          return Marquee(
                            text: texto,
                            style: style,
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 50.0,
                            velocity: 30.0,
                            pauseAfterRound: const Duration(seconds: 2),
                            accelerationDuration: const Duration(seconds: 1),
                            accelerationCurve: Curves.linear,
                            decelerationDuration: const Duration(milliseconds: 500),
                            decelerationCurve: Curves.easeOut,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<IcyMetadata?>(
                    stream: reproductor.metadataStream,
                    builder: (context, snapshot) {
                      final metadata = snapshot.data;
                      final title = metadata?.info?.title ?? '';
                      final fullText = "${TextosApp.getTexto("reproduciendo")}: $title";
                      if (title != '') {
                        return SizedBox(
                          height: 20,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final textPainter = TextPainter(
                                text: TextSpan(text: fullText, style: Theme.of(context).textTheme.labelLarge),
                                maxLines: 1,
                                textDirection: TextDirection.ltr,
                              )..layout();

                              if (textPainter.width < constraints.maxWidth) {
                                return Center(
                                  child: Text(fullText, style: Theme.of(context).textTheme.labelLarge),
                                );
                              }

                              return Marquee(
                                text: fullText,
                                style: Theme.of(context).textTheme.labelLarge,
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 50.0,
                                velocity: 30.0,
                                pauseAfterRound: const Duration(seconds: 2),
                                accelerationDuration: const Duration(seconds: 1),
                                accelerationCurve: Curves.linear,
                                decelerationDuration: const Duration(milliseconds: 500),
                                decelerationCurve: Curves.easeOut,
                              );
                            },
                          ),
                        );
                      }
                      return Container(height: 0, padding: EdgeInsets.zero,);
                    },
                  ),

                  const SizedBox(height: 40),

                  // CONTROLES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 50,
                        onPressed: () => reproductor.retrocederEmisora(),
                        icon: const Icon(Icons.skip_previous),
                      ),
                      const SizedBox(width: 20),
                      IconButton.filled(
                        iconSize: 75,
                        onPressed: () {
                          reproductor.pararReproduccion();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.stop),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        iconSize: 50,
                        onPressed: () => reproductor.pasarEmisora(),
                        icon: const Icon(Icons.skip_next),
                      ),
                    ],
                  ),

                  // BOTÓN ECUALIZADOR
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 70),
                    child: ElevatedButton(
                      onPressed: () => {/*TODO*/},
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.equalizer),
                            const SizedBox(width: 10),
                            Text(TextosApp.getTexto("ecualizador")),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.12,
              minChildSize: 0.12,
              maxChildSize: 0.85,
              snap: true,
              snapSizes: const [0.12, 0.85],
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Text(
                              TextosApp.getTexto("reproductor_titulo_cola"),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8,),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(10),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final emisora = reproductor.emisorasEscuchando[index];
                              final esSeleccionada = emisora == reproductor.emisoraSeleccionada;

                              return Card(
                                elevation: 0,
                                color: esSeleccionada
                                    ? Theme.of(context).colorScheme.inversePrimary
                                    : Colors.transparent,
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: emisora.imagen ?? const Icon(Icons.radio),
                                    ),
                                  ),
                                  title: Text(
                                    emisora.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    reproductor.reproducirEmisora(emisora, reproductor.emisorasEscuchando);
                                    if (_sheetController.size > 0.25){
                                      // Cierro el cajón
                                      _sheetController.animateTo(
                                        0.25,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                            childCount: reproductor.emisorasEscuchando.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
          )
        ],
      );
    },
    ),
    );
  }
}
