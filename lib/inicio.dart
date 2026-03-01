import 'package:flutter/material.dart';
import 'package:openwave/l10n/textosApp.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TextosApp.getTexto("titulo_inicio")),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const Drawer(
        
      ),
      body: const SafeArea(
          child: Center())
    );
  }
}
