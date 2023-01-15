import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
// ignore: import_of_legacy_library_into_null_safe
import 'package:word_search/word_search.dart';

class SopadeletrasLogic {
  int size = 10;
  List<String> board = [];
  Map<String, Color?> words = {};
  late final Future ready;
  final List<_Data> _dataList = [];
  _Data? _data;
  String get title => _data?.title ?? '';

  SopadeletrasLogic() {
    ready = rootBundle.loadString('assets/files/sopadeletras.txt').then((value) {
      var lines = value.split('\r\n');
      for (var line in lines) {
        var cols = line.split('|');
        _dataList.add(_Data()
          ..category = cols[0]
          ..title = cols[1]
          ..text = cols[2]
          ..words = cols[3].split(','));
      }
    });
  }

  bool init() {
    _data = _dataList[Random().nextInt(_dataList.length)];
    var wordsTop = _data!.words.toList();
    if (_data!.text == '') {
      wordsTop.shuffle();
      wordsTop = wordsTop.take(7).toList();
    }
    var wordsList = wordsTop.map((e) => _cleanWord(e).toUpperCase()).toList();
    words = {for (var e in wordsList) e: null};
    board = [];

    // Create the puzzle sessting object
    final WSSettings ws = WSSettings(
      width: 10,
      height: 10,
      fillBlanks: () {
        const fancyStrings = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
        //const fancyStrings = ' ';
        return fancyStrings[Random().nextInt(fancyStrings.length)];
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
    final wordSearch = WordSearch();

    // Create a new puzzle
    final WSNewPuzzle newPuzzle = wordSearch.newPuzzle(wordsList, ws);

    /// Check if there are errors generated while creating the puzzle
    if (newPuzzle.errors.isEmpty) {
      for (var row in newPuzzle.puzzle) {
        for (var col in row) {
          board.add(col);
        }
      }
    } else {
      return false;
    }
    return true;
  }

  String _cleanWord(String w) {
    var specials = 'áéíóúü'.split('');
    var replace = 'aeiouu'.split('');
    for (var i = 0; i < specials.length; i++) {
      w = w.replaceAll(specials[i], replace[i]);
    }
    return w;
  }
}

class _Data {
  late String category;
  late String title;
  late String text;
  late List<String> words;
}
