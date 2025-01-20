import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final String infoText = '''
CON REPETICIÓN:
Sorteo de números con admisión a que estos se repitan.

SIN REPETICIÓN:
Sorteo de números sin que estos se repitan.

DESDE:
Valor mínimo del intervalo de números a sortear.
Tiene que ser menor al valor ingresado en Hasta.
Se podrán elegir números desde el -999 hasta el 999.

HASTA:
Valor máximo del intervalo de números a sortear.
Tiene que ser mayor al valor ingresado en Desde.
Se podrán elegir números desde el -999 hasta el 999.

TIRADAS ILIMITADAS:
Pone un límite a la cantidad de números que se sortean.

HABLAR:
Lee en voz alta todos los números sorteados.

REINICIAR:
Listo para un nuevo sorteo.
''';

  // Lista temporal para almacenar los números que vengan de Credits
  List<int> _tempNumbers = [];

  Future<void> _goToCredits() async {
    final result = await Navigator.pushNamed(context, '/credits');
    if (result != null && result is List<int>) {
      setState(() {
        _tempNumbers = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Retornamos _tempNumbers a HomeScreen
            Navigator.pop(context, _tempNumbers);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Color(0xFF880000),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Texto de ayuda
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      infoText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),

                // Botón "Volver al inicio" (opcional)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context, _tempNumbers);
                  },
                  child: const Text('Volver al inicio'),
                ),
              ],
            ),
          ),
        ),
      ),
      // FAB con icono de lápiz -> credits
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _goToCredits,
        child: const Icon(Icons.edit),
      ),
    );
  }
}
