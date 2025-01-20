import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Controladores de los TextField
  final TextEditingController _desdeCtrl = TextEditingController();
  final TextEditingController _hastaCtrl = TextEditingController();

  bool tiradasIlimitadas = false;
  bool _ttsEnabled = true;
  bool _isSpeaking = false;

  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();

  final List<int> _numerosSorteados = [];

  // Lista que se inyecta desde otra pantalla (p.ej. /help)
  List<int> _customNumbers = [];

  // Nueva variable para controlar si ya podemos usar los _customNumbers
  bool _customNumbersActivated = false;

  int? _numeroActual;

  bool _isAnimatingSphere = false;
  Timer? _animationTimer;
  int _tempAnimationNumber = 0;

  bool _sphereFlash = false;
  bool _hasTappedSphere = false; // Controla si ya se tocó la esfera

  // Para el parpadeo de "Sortear"
  late final AnimationController _blinkController;
  late final Animation<double> _blinkOpacity;

  @override
  void initState() {
    super.initState();

    _flutterTts.setLanguage('es-ES');
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
    _flutterTts.setCancelHandler(() {
      setState(() => _isSpeaking = false);
    });

    // Configuramos la animación de parpadeo
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _blinkOpacity =
        Tween<double>(begin: 0.3, end: 1.0).animate(_blinkController);
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  // Al llamar a este método (por ejemplo, desde /help),
  // guardamos la lista, pero NO la activamos todavía.
  void _setCustomNumbers(List<int> nums) {
    setState(() {
      _customNumbers = nums;
      _customNumbersActivated = false; // Aún no se usan
    });
  }

  // Al tocar la esfera
  void _onSphereTap() {
    if (!_hasTappedSphere) {
      setState(() => _hasTappedSphere = true);
    }
    // Efecto flash
    setState(() => _sphereFlash = true);
    Timer(const Duration(milliseconds: 200), () {
      setState(() => _sphereFlash = false);
    });
    // Sorteamos
    _sortearNumero();
  }

  Future<void> _sortearNumero() async {
    if (_isSpeaking) return;

    final desde = int.tryParse(_desdeCtrl.text);
    final hasta = int.tryParse(_hastaCtrl.text);

    if (desde == null || hasta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa "Desde" y "Hasta".')),
      );
      return;
    }
    if (desde > hasta) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('"Desde" > "Hasta" - Rango inválido.')),
      );
      return;
    }

    final totalRange = (hasta - desde + 1);

    if (!tiradasIlimitadas && _numerosSorteados.length >= totalRange) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya se sortearon todos los números.')),
      );
      return;
    }

    setState(() => _isSpeaking = true);

    int numeroFinal;

    // PRIMER número
    if (_numerosSorteados.isEmpty) {
      if (_customNumbersActivated) {
        // Si está activado el uso de customNumbers
        do {
          numeroFinal = _random.nextInt(totalRange) + desde;
          // Si el random choca con uno ya inyectado, repetimos,
          // OJO: la lógica original decía: "while _customNumbers.contains(num) || _numerosSorteados.contains(num)"
          // Pero aquí dices que la 1ra tirada no se tome de _customNumbers directamente, sino que se descarte si coincide
        } while (_customNumbers.contains(numeroFinal) ||
            _numerosSorteados.contains(numeroFinal));
      } else {
        // Aún no usamos custom
        do {
          numeroFinal = _random.nextInt(totalRange) + desde;
        } while (_numerosSorteados.contains(numeroFinal));
      }
    } else {
      // SUBSECUENTES
      if (_customNumbersActivated && _customNumbers.isNotEmpty) {
        // Si hay customNumbers activos, usamos el primero
        numeroFinal = _customNumbers.removeAt(0);
      } else {
        // Caso normal
        if (!tiradasIlimitadas) {
          do {
            numeroFinal = _random.nextInt(totalRange) + desde;
          } while (_numerosSorteados.contains(numeroFinal));
        } else {
          numeroFinal = _random.nextInt(totalRange) + desde;
        }
      }
    }

    _startSphereAnimation(desde, hasta, numeroFinal);
  }

  void _startSphereAnimation(int minVal, int maxVal, int finalNumber) {
    _isAnimatingSphere = true;
    int count = 0;
    const totalCycles = 8;
    _animationTimer?.cancel();

    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        setState(() {
          _tempAnimationNumber =
              _random.nextInt((maxVal - minVal + 1)) + minVal;
        });
        count++;
        if (count >= totalCycles) {
          timer.cancel();
          setState(() {
            _isAnimatingSphere = false;
            _numeroActual = finalNumber;
          });

          if (!tiradasIlimitadas) {
            _numerosSorteados.add(finalNumber);
          }

          if (_ttsEnabled) {
            _flutterTts.speak('$finalNumber');
          } else {
            setState(() => _isSpeaking = false);
          }
        }
      },
    );
  }

  // Reiniciar: además de limpiar, activamos los _customNumbers
  void _reiniciar() {
    setState(() {
      _hasTappedSphere = false;
      _numerosSorteados.clear();
      _numeroActual = null;

      // Activamos la lista inyectada (si la hubiera)
      _customNumbersActivated = true;
    });
  }

  // Toggle TTS
  void _toggleTts() {
    setState(() => _ttsEnabled = !_ttsEnabled);
  }

  // Pantalla "Ver más"
  void _verTodos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullListScreenSimple(numeros: _numerosSorteados),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final numeroEnEsfera =
        _isAnimatingSphere ? _tempAnimationNumber : (_numeroActual ?? 0);
    final mostrandoSortear = (numeroEnEsfera == 0);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior "Anuncio"
            Container(
              color: Colors.grey[900],
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              alignment: Alignment.center,
              child: Text(
                "Anuncio",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
            const SizedBox(height: 4),

            // Título
            const Text(
              "SIN REPETICIÓN",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Fila: Desde y Hasta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildNumberField(_desdeCtrl, hint: "Desde"),
                  const SizedBox(width: 16),
                  _buildNumberField(_hastaCtrl, hint: "Hasta"),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // "Tiradas Ilimitadas"
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: [
                  const Text(
                    "Tiradas Ilimitadas",
                    style: TextStyle(color: Colors.white),
                  ),
                  Switch(
                    value: tiradasIlimitadas,
                    activeColor: Colors.red,
                    onChanged: (val) {
                      setState(() => tiradasIlimitadas = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---------------- CENTRO: LISTA IZQ + ESFERA + "BOLILLA" DEBAJO ----------------
            Expanded(
              child: Row(
                mainAxisAlignment: _hasTappedSphere
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Lista a la izquierda sólo si la esfera ha sido tocada
                  if (_hasTappedSphere) ...[
                    Container(
                      width: 90, // Ajustado para evitar overflow
                      height: 250,
                      margin: const EdgeInsets.only(left: 8.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              // Lista animada (1º, 2º, 3º...)
                              Positioned.fill(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 50),
                                  itemCount: _numerosSorteados.length,
                                  itemBuilder: (context, index) {
                                    final numero = _numerosSorteados[index];
                                    return _AnimatedListItem(
                                      position: index + 1,
                                      number: numero,
                                    );
                                  },
                                ),
                              ),
                              // Botón "Ver más" si hay muchos
                              if (_numerosSorteados.length > 6)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: _verTodos,
                                    child: Container(
                                      height: 36,
                                      alignment: Alignment.center,
                                      color: Colors.grey[700],
                                      child: const Text(
                                        "Ver más",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Columna con la esfera y debajo "Bolilla"
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ESFERA
                        GestureDetector(
                          onTap: _onSphereTap,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/esfera.png',
                                height: 250,
                              ),
                              if (_sphereFlash)
                                ClipOval(
                                  child: Container(
                                    width: 250,
                                    height: 250,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),

                              // Parpadeo "Sortear"
                              if (mostrandoSortear)
                                FadeTransition(
                                  opacity: _blinkOpacity,
                                  child: const Text(
                                    "Sortear",
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  "$numeroEnEsfera",
                                  style: const TextStyle(
                                    fontSize: 150,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // BOLILLA debajo de la esfera
                        if (_numeroActual != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            "Bolilla: $_numeroActual",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600, // un poco más grueso
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // -------- BARRA INFERIOR --------
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón atrás -> cierra app
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.red,
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                  // Botón REINICIAR
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _reiniciar,
                    child: const Text("REINICIAR"),
                  ),
                  // Volumen ON/OFF
                  IconButton(
                    icon: Icon(
                      _ttsEnabled ? Icons.volume_up : Icons.volume_off,
                    ),
                    color: Colors.white,
                    onPressed: _toggleTts,
                  ),
                  // Interrogación -> Help
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pushNamed(context, '/help').then((result) {
                        if (result is List<int>) {
                          _setCustomNumbers(result);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TextField sin label, con hint centrado
  Widget _buildNumberField(TextEditingController ctrl, {required String hint}) {
    return Expanded(
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: false,
          signed: true,
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white70,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

//--------------------------------------------------------
// LISTA COMPLETA (ESTILO SIMPLE) => al pulsar "Ver más"
// => "Bolilla Nº1: 42", etc.
//--------------------------------------------------------
class FullListScreenSimple extends StatelessWidget {
  final List<int> numeros;
  const FullListScreenSimple({Key? key, required this.numeros})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Lista Completa"),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: numeros.length,
        itemBuilder: (context, index) {
          final numero = numeros[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "Bolilla Nº${index + 1}: $numero",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}

//--------------------------------------------------------
// ÍTEM DE LA LISTA (ESTILO ANIMADO) => "1º, 2º, 3º, ..."
//--------------------------------------------------------
class _AnimatedListItem extends StatefulWidget {
  final int position; // 1, 2, 3...
  final int number;

  const _AnimatedListItem({
    Key? key,
    required this.position,
    required this.number,
  }) : super(key: key);

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _rotation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Inicia la animación cuando se monta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get positionLabel => "${widget.position}º";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RotationTransition(
          turns: _rotation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                positionLabel, // "1º", "2º", etc.
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              // Línea gris vertical
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 2,
                height: 20,
                color: Colors.grey,
              ),
              Text(
                "${widget.number}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Línea roja
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          height: 2,
          color: Colors.red,
          width: 60,
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
