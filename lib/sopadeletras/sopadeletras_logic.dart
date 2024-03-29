import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:word_search_safety/word_search_safety.dart';

class SopadeletrasLogic {
  final int _minSize = 7;
  List<String> _board = [];
  List<String> get board => _board;
  Map<String, WordData> _words = {};
  Map<String, WordData> get words => _words;
  late final Future ready;
  static final List<_Data> _dataList = [];
  _Data? _data;
  String get title => _data?.title ?? '';
  bool _isEnd = false;
  bool get isEnd => _isEnd;
  int _size = 0;
  int get size => _size;
  final List<WordData> _textList = [];
  List<WordData> get textList => _textList;
  final Random _random = Random();
  Random get random => _random;

  SopadeletrasLogic() {
    if (_dataList.isEmpty) {
      ready = _loadDataList();
    } else {
      ready = Future(() => null);
    }
  }

  Future _loadDataList() {
    return rootBundle.loadString('assets/files/sopadeletras.txt').then((value) {
      var lines = value.split('\r\n');
      for (var line in lines) {
        var cols = line.split('|');
        var category = cols[0];
        var title = cols[1];
        var text = cols[2];
        var words = cols[3].split(',').map((e) => WordData()..word = e).toList();
        var shuffle = false;
        var maxWords = 0;
        if (cols[0] == 'Lista') {
          var conf = text.split(',');
          text = '';
          shuffle = conf[0] == '1';
          maxWords = int.parse(conf[1]);
        }
        _dataList.add(_Data()
          ..category = category
          ..title = title
          ..text = text
          ..words = words
          ..shuffle = shuffle
          ..maxWords = maxWords);
      }
    });
  }

  bool init() {
    _isEnd = false;
    _textList.clear();
    _data = _dataList[_random.nextInt(_dataList.length)];
    var wordsTop = _data!.words.toList();
    if (_data!.shuffle) {
      wordsTop.shuffle();
    }
    if (_data!.maxWords > 0) {
      wordsTop = wordsTop.take(_data!.maxWords).toList();
    }
    if (_data!.text != '') {
      var text = _data!.text;
      for (var word in wordsTop) {
        var split = text.split(word.word);
        _textList.add(WordData()
          ..static = true
          ..word = split.removeAt(0));
        _textList.add(word);
        text = split.join(word.word);
      }
      if (text != '') {
        _textList.add(WordData()
          ..static = true
          ..word = text);
      }
      //print(_textList.map((e) => e.text).join());
    }
    //var wordsList = wordsTop.map((e) => _cleanWord(e).toUpperCase()).toList();
    _words = {for (var e in wordsTop) _cleanWord(e.word).toUpperCase(): e};
    _board = [];

    // Create the puzzle setting object
    final WSSettings ws = WSSettings(
      width: _minSize,
      height: _minSize,
      preferOverlap: false,
      fillBlanks: () {
        const fancyStrings = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
        //const fancyStrings = ' ';
        return fancyStrings[_random.nextInt(fancyStrings.length)];
      },
      orientations: List.from([
        WSOrientation.horizontal,
        WSOrientation.vertical,
        WSOrientation.diagonal,
        WSOrientation.diagonalUp,
        WSOrientation.horizontalBack,
        WSOrientation.verticalUp,
        WSOrientation.diagonalBack,
        WSOrientation.diagonalUpBack,
      ]),
    );

    // Create new instance of the WordSearch class
    final wordSearch = WordSearchSafety();

    // Create a new puzzle
    final WSNewPuzzle newPuzzle = wordSearch.newPuzzle(_words.keys.toList(), ws);

    /// Check if there are errors generated while creating the puzzle
    if (newPuzzle.errors!.isEmpty) {
      for (var row in newPuzzle.puzzle!) {
        for (var col in row) {
          _board.add(col);
        }
      }
      _size = sqrt(board.length).toInt();
    } else {
      _isEnd = true;
      _size = 0;
      return false;
    }
    return true;
  }

  void wordMark(String word, Color color) {
    _words[word]?.color = color;
    _isEnd = _words.entries.every((element) => element.value.color != null);
  }

  String _cleanWord(String w) {
    const mapSpecials = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'};
    var cleanWord = '';
    for (var i = 0; i < w.length; i++) {
      cleanWord += mapSpecials[w[i]] ?? w[i];
    }
    return cleanWord;
  }
}

class _Data {
  late String category;
  late String title;
  late String text;
  late List<WordData> words;
  late bool shuffle;
  late int maxWords;
}

class WordData {
  late String word;
  Color? color;
  bool static = false;
  String get _textCap => word[0] + ''.padRight(word.length - 1, '_');
  String get textUnmarked => static ? word : _textCap;
  String get text => static || color != null ? word : _textCap;
}
