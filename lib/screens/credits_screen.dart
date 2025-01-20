import 'package:flutter/material.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({Key? key}) : super(key: key);

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  final TextEditingController _numbersController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créditos'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'by Paulo Daniel Batuani Hurtado & O1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lista (escribe números separados por comas, espacios o saltos de línea)',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _numbersController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ej: 5, 7, 9, 10',
                    hintStyle: const TextStyle(color: Colors.white54),
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
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final text = _numbersController.text.trim();
                  if (text.isEmpty) {
                    Navigator.pop(context, <int>[]);
                    return;
                  }

                  final parts = text.split(RegExp(r'[,;\s]+'));
                  final customNumbers = <int>[];
                  for (var p in parts) {
                    if (p.isNotEmpty) {
                      final val = int.tryParse(p);
                      if (val != null) {
                        customNumbers.add(val);
                      }
                    }
                  }

                  Navigator.pop(context, customNumbers);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
