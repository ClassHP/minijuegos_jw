import 'dart:async' show Future;
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class TriviaLogic {
  late Future ready;
  final List<Pregunta> _preguntas = [];
  final Random _random = Random();
  Random get random => _random;
  Pregunta? currentPregunta;

  TriviaLogic() {
    ready = _loadAsset('assets/files/trivia.txt').then((text) {
      try {
        var count = 0;
        var max = 0;
        var min = 100000;
        var list = text.split('\n');
        for (var line in list) {          
          //print(line);
          var split = line.split('\t');
          var pregunta = split[0];
          var correcta = split[1];
          var erroneas = split[2].split(',').map((e) => e.trim()[0].toUpperCase() + e.trim().substring(1)).toList();
          var nivel = int.parse(split[3]);
          _preguntas.add(Pregunta(pregunta, correcta, erroneas, nivel));
          count ++;
          max = max > erroneas.length ? max : erroneas.length;
          min = min < erroneas.length ? min : erroneas.length;
        }
        print('Count: ' + count.toString());
        print('Max: ' + max.toString());
        print('Min: ' + min.toString());

      } catch(e, stacktrace) {
        print('Exception: ' + e.toString());
        print('Stacktrace: ' + stacktrace.toString());
      }
    });
  }

  Future<String> _loadAsset(String key) async {
    return await rootBundle.loadString(key);
  }

  Pregunta nextPregunta() {
    currentPregunta = _preguntas[_random.nextInt(_preguntas.length)];
    currentPregunta!.prepare(_random);
    return currentPregunta!;
  }

  bool init() {
    nextPregunta();
    return true;
  }
}

class Pregunta {
  String pregunta;
  String correcta;
  List<String> erroneas;
  int nivel;
  List<String> opciones = [];
  
  Pregunta(this.pregunta, this.correcta, this.erroneas, this.nivel);
  
  void prepare(Random random) {
    opciones.clear();
    opciones.add(correcta);
    erroneas.shuffle(random);
    opciones.addAll(erroneas.take(3));
    opciones.shuffle(random);
  }
}

class Option {
  String text;
  Option(this.text);
}
