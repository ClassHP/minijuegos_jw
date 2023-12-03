import 'dart:js_interop';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:minijuegos_jw/trivia/trivia_logic.dart';

import '../widgets/countdown_timer.dart';
import '../widgets/fitted_text.dart';

class Trivia extends StatefulWidget {
  const Trivia({Key? key}) : super(key: key);

  @override
  createState() => _TriviaState();
}

class _TriviaState extends State<Trivia> {
  final TriviaLogic _logic = TriviaLogic();
  int _streak = 0;
  int _level = 1;
  final GlobalKey<QuestionWidgetState> _questionWidgetKey =
      GlobalKey<QuestionWidgetState>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    _logic.ready.then((_) {
      setState(() {
        _logic.init();
      });
    });
  }

  void _next() {
    setState(() {
      _logic.nextQuestion(_level);
      _questionWidgetKey.currentState?.restart();
    });
  }

  Future<void> _onSelect(String text) async {
    String title = '';
    String content = '';
    if (text == _logic.currentQuestion!.correct) {
      title = 'Respuesta correcta 😁👍';
      _streak++;
      _level = _level == 6 ? 1 : _level + 1;
      content = 'Racha de preguntas correctas: $_streak';
    }
    else {
      title = 'Respuesta incorrecta 😓';
      content = 'Racha conseguida: $_streak';
      if (text == 'timeout') {
        title = 'Se te acabo el tiempo ⏲️';
      }
      _streak = 0;
      _level = 1;
    }
    await _showDialog(title, content, context);
    _next();
  }

  Future<String?> _showDialog(
      String title, String content, BuildContext context) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context, 'Siguiente');
            },
            icon: const Icon(Icons.skip_next),
            label: const Text('Siguiente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia Bíblico'),
      ),
      body: Stack(
        children: <Widget>[
          // Imagen de fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/trivia_bg.png"), // Reemplaza con tu imagen
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Efecto Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0), // Ajusta el nivel de blur
            child: Container(
              color: Colors.black.withOpacity(0.0), // Color transparente
            ),
          ),
          // Contenido del Scaffold
          (!_logic.currentQuestion.isNull)
          ? QuestionWidget(
              key: _questionWidgetKey,
              question: _logic.currentQuestion!,
              onSelect: _onSelect,
            )
          : const Text('Loading...'),
        ],
      ),      
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Theme.of(context).colorScheme.primary,
        child: Container(
          padding: const EdgeInsets.fromLTRB(5, 5, 70, 5),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 5,
            children: [
              Text("Dificultad: $_level/6"),
              Text("Racha: $_streak"),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionWidget extends StatefulWidget {
  final Question question;
  final void Function(String) onSelect;

  const QuestionWidget(
      {Key? key, required this.question, required this.onSelect})
      : super(key: key);

  @override
  State<QuestionWidget> createState() => QuestionWidgetState();
}

class QuestionWidgetState extends State<QuestionWidget> {
  final GlobalKey<CountdownTimerWidgetState> _timerKey =
      GlobalKey<CountdownTimerWidgetState>();

  void _select(text) {
    widget.onSelect(text);
    _timerKey.currentState?.stop();
  }

  void restart() {
    _timerKey.currentState?.restart();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CountdownTimerWidget(
          key: _timerKey,
          initialTimeInSeconds: 60 * 1,
          onTimeEnd: () => _select('timeout'),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              widget.question.text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final text = widget.question.options[index];
              return OptionWidget(
                index: index + 1,
                text: text,
                onTap: () {
                  _select(text);
                },
              );
            },
            itemCount: widget.question.options.length,
          ),
        ),
      ],
    );
  }
}

class OptionWidget extends StatelessWidget {
  final int index;
  final String text;
  final VoidCallback? onTap;

  const OptionWidget(
      {Key? key, required this.index, required this.text, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FittedText(
              '$index',
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.background,
            ),
          ),
        ),
        title: Text(text),
        onTap: onTap,
        contentPadding: const EdgeInsets.all(10),
      ),
    );
  }
}
