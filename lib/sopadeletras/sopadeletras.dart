import 'package:flutter/material.dart';
import 'package:minijuegos_jw/sopadeletras/sopadeletras_logic.dart';
import 'package:minijuegos_jw/widgets/word_search_board.dart';
//import '../widgets/word_search.dart';

class Sopadeletras extends StatefulWidget {
  const Sopadeletras({Key? key}) : super(key: key);

  @override
  createState() => _SopadeletrasState();
}

class _SopadeletrasState extends State<Sopadeletras> {
  final SopadeletrasLogic _logic = SopadeletrasLogic();

  @override
  void initState() {
    super.initState();
    _logic.ready.then((_) {
      setState(() {
        _logic.init();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sopa de letras Bíblico'),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_logic.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: _logic.words.entries
                  .map<Widget>((key) => Chip(
                        backgroundColor: key.value,
                        label: Text(key.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                        avatar: key.value != null ? const Icon(Icons.check) : null,
                        /*avatar: Icon(key.value != null ? Icons.check : Icons.search,
                            color: key.value != null ? Colors.green : Colors.white),*/
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            if (_logic.board.isNotEmpty)
              Flexible(
                child: WordSearchBoard(
                  board: _logic.board,
                  words: _logic.words,
                  onWordMarked: _onWordMarked,
                ),
              ),
          ],
        ),
      ),
    );
  }

  _onWordMarked(String word, Color color) {
    setState(() {
      _logic.words[word] = color;
    });
  }
}
