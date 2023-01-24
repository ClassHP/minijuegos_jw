import 'package:flutter/material.dart';
import 'package:minijuegos_jw/Tools.dart';
import 'package:minijuegos_jw/sopadeletras/sopadeletras_logic.dart';
import 'package:minijuegos_jw/sopadeletras/sopadeletras_board.dart';
import 'package:share_plus/share_plus.dart';
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
        title: const Text('Sopa de letras bíblico'),
        actions: [
          IconButton(
            onPressed: _share,
            icon: const Icon(Icons.share),
          ),
        ],
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
            if (_logic.textList.isEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 4.0, // gap between lines
                children: _logic.words.entries
                    .map<Widget>((key) => Chip(
                          backgroundColor: key.value.color,
                          label: Text(key.value.word,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          avatar: key.value.color != null ? const Icon(Icons.check) : null,
                          /*avatar: Icon(key.value != null ? Icons.check : Icons.search,
                            color: key.value != null ? Colors.green : Colors.white),*/
                        ))
                    .toList(),
              )
            else
              _Text(textList: _logic.textList),
            const SizedBox(height: 10),
            if (_logic.board.isNotEmpty)
              Flexible(
                child: SopadeletrasBoard(
                  logic: _logic,
                  onWordMarked: _onWordMarked,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWordMarked(String word, Color color) async {
    setState(() {
      _logic.wordMark(word, color);
    });
    var ret = _logic.isEnd;
    if (_logic.isEnd) {
      var value = await _showEndDialog(context);
      if (value == 'Compartir') {
        await _share();
      }
      setState(() {
        _logic.init();
      });
    }
    return ret;
  }

  Future<void> _share() async {
    var text = '*Sopa de letras bíblico*\n';
    text += '${_logic.title}\n';
    if (_logic.textList.isNotEmpty) {
      text += '${_logic.textList.map((e) => e.textUnmarked).join()}\n';
    } else {
      text += '${_logic.words.entries.map((e) => e.value.word).join(', ')}\n';
    }
    for (var i = 0; i < _logic.size; i++) {
      text += '```${_logic.board.skip(i * _logic.size).take(_logic.size).join(' ')}```\n';
    }
    text += '\nDescarga la app y juega: \n';
    text += Tools.urlApp;
    print(text);
    return Share.share(text, subject: 'Juegos bíblicos JW');
  }

  Future<String?> _showEndDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('¡Ganaste! 🥳🎉'),
        content: const Text('Encontraste todas las palabras ¡Bien jugado!'),
        actions: <Widget>[
          if (Tools.isNotWeb)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary),
              onPressed: () => Navigator.pop(context, 'Compartir'),
              icon: const Icon(Icons.share),
              label: const Text('Compartir'),
            ),
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
}

class _Text extends StatelessWidget {
  List<WordData> textList = [];
  _Text({Key? key, required this.textList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          style: Theme.of(context).textTheme.headline6,
          children: textList
              .map<TextSpan>((e) => TextSpan(
                    text: e.text,
                    style:
                        TextStyle(backgroundColor: e.color, letterSpacing: !e.static ? 3.0 : null),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
