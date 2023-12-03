import 'dart:async' show Future;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class TriviaLogic {
  late Future ready;
  final List<Question> _questions = [];
  final Random _random = Random();
  Random get random => _random;
  Question? currentQuestion;

  TriviaLogic() {
    ready = _loadAsset('assets/files/trivia.txt').then((text) {
      try {
        var count = 0;
        var max = 0;
        var min = 100000;
        var list = text.split('\n');
        for (var line in list) {
          var split = line.split('\t');
          var text = split[0];
          var correct = split[1];
          var incorrects = split[2].split(';').map((e) => e.trim()[0].toUpperCase() + e.trim().substring(1)).toList();
          var level = int.parse(split[3]);
          _questions.add(Question(text, correct, incorrects, level));
          count ++;
          max = max > incorrects.length ? max : incorrects.length;
          min = min < incorrects.length ? min : incorrects.length;
        }
        if (kDebugMode) {
          print('Count: $count');
          print('Max: $max');
          print('Min: $min');
        }

      } catch(e, stacktrace) {
        if (kDebugMode) {
          print('Exception: $e');
          print('Stacktrace: $stacktrace');
        }
      }
    });
  }

  Future<String> _loadAsset(String key) async {
    return await rootBundle.loadString(key);
  }

  Question nextQuestion(int level) {
    var questionsLevel = _questions.where((element) => element.level == level).toList();
    currentQuestion = questionsLevel[_random.nextInt(questionsLevel.length)];
    currentQuestion!.prepare(_random);
    return currentQuestion!;
  }

  bool init() {
    nextQuestion(1);
    return true;
  }
}

class Question {
  String text;
  String correct;
  List<String> incorrects;
  int level;
  List<String> options = [];
  
  Question(this.text, this.correct, this.incorrects, this.level);
  
  void prepare(Random random) {
    options.clear();
    options.add(correct);
    incorrects.shuffle(random);
    options.addAll(incorrects.take(3));
    options.shuffle(random);
  }
}

class Option {
  String text;
  Option(this.text);
}
