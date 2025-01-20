import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibimos la lista de bolillas desde HomeScreen
    final argumentos = ModalRoute.of(context)!.settings.arguments;
    final numerosSorteados = argumentos is List<int> ? argumentos : <int>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        centerTitle: true,
      ),
      body: numerosSorteados.isEmpty
          ? const Center(
              child: Text('No hay bolillas sorteadas aún'),
            )
          : ListView.builder(
              itemCount: numerosSorteados.length,
              itemBuilder: (context, index) {
                final numero = numerosSorteados[index];
                return ListTile(
                  leading: Text('${index + 1}°',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  title: Text('Bolilla: $numero'),
                );
              },
            ),
    );
  }
}
