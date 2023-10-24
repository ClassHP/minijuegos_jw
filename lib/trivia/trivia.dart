import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:minijuegos_jw/trivia/trivia_logic.dart';

class Trivia extends StatefulWidget {
  const Trivia({Key? key}) : super(key: key);

  @override
  createState() => _TriviaState();
}

class _TriviaState extends State<Trivia> {
  final TriviaLogic _logic = TriviaLogic();

  @override
  void initState() {
    super.initState();
    next();
  }

  void next() {
    _logic.ready.then((_) {
      setState(() {
        _logic.init();
      });
    });
  }

  void evaluate(text) {
    if (text == _logic.currentPregunta!.correcta) {
      next();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia Bíblico'),
      ),
      body: Column(
        children: [
          if (!_logic.currentPregunta.isNull) ...{
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _logic.currentPregunta!.pregunta,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final text = _logic.currentPregunta!.opciones[index];
                  return Option(
                    index: index + 1,
                    text: text,
                    onTap: () {
                      evaluate(text);
                    },
                  );
                },
                itemCount: _logic.currentPregunta!.opciones.length,
              ),
            ),
          },
        ],
      ),
    );
  }
}

class Option extends StatelessWidget {
  final int index;
  final String text;
  final VoidCallback? onTap;

  const Option({Key? key, required this.index, required this.text, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Text('$index'),
      ),
      title: Text(text),
      onTap: onTap,
      contentPadding: const EdgeInsets.all(10)
    );
  }
}
