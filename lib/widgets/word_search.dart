import 'package:flutter/material.dart';

class WordSearch extends StatefulWidget {
  const WordSearch(
      {Key? key, required this.alphabet, required this.words, required this.wordsPerLine})
      : super(key: key);

  final int wordsPerLine;
  final List<String> alphabet;
  final List<String> words;

  @override
  createState() => _WordSearchState();
}

class _WordSearchState extends State<WordSearch> {
  final markers = <WordMarker>[];
  int correctAnswers = 0;
  late List<Map<String, Object>> uniqueLetters;

  @override
  void initState() {
    super.initState();
    uniqueLetters =
        widget.alphabet.map((letter) => {'letter': letter, 'key': GlobalKey()}).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GridView.count(
          crossAxisCount: widget.wordsPerLine,
          children: <Widget>[
            for (int i = 0; i != uniqueLetters.length; ++i)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    final key = uniqueLetters[i]['key'] as GlobalKey;
                    final renderBox = key.currentContext?.findRenderObject() as RenderBox;
                    final markerRect =
                        renderBox.localToGlobal(Offset.zero, ancestor: context.findRenderObject()) &
                            renderBox.size;
                    if (markers.length == correctAnswers) {
                      addMarker(markerRect, i);
                    } else if (widget.words.contains(pathAsString(markers.last.startIndex, i))) {
                      markers.last = adjustedMarker(markers.last, markerRect);
                      ++correctAnswers;
                    } else {
                      markers.removeLast();
                    }
                  });
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    key: uniqueLetters[i]['key'] as GlobalKey,
                    child: Text(
                      uniqueLetters[i]['letter'] as String,
                    ),
                  ),
                ),
              ),
          ],
        ),
        ...markers,
      ],
    );
  }

  void addMarker(Rect rect, int startIndex) {
    markers.add(WordMarker(
      rect: rect,
      startIndex: startIndex,
    ));
  }

  WordMarker adjustedMarker(WordMarker originalMarker, Rect endRect) {
    return originalMarker.copyWith(rect: originalMarker.rect.expandToInclude(endRect));
  }

  String pathAsString(int start, int end) {
    final isHorizontal = start ~/ widget.wordsPerLine == end ~/ widget.wordsPerLine;
    final isVertical = start % widget.wordsPerLine == end % widget.wordsPerLine;

    String result = '';

    if (isHorizontal) {
      result = widget.alphabet.sublist(start, end + 1).join();
    } else if (isVertical) {
      for (int i = start; i < widget.alphabet.length; i += widget.wordsPerLine) {
        result += widget.alphabet[i];
      }
    }

    return result;
  }
}

class WordMarker extends StatelessWidget {
  const WordMarker({
    Key? key,
    required this.rect,
    required this.startIndex,
    this.color = Colors.yellow,
    this.width = 2.0,
    this.radius = 6.0,
  }) : super(key: key);

  final Rect rect;
  final Color color;
  final double width;
  final double radius;
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: rect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: color,
            width: width,
          ),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  WordMarker copyWith({Rect? rect}) {
    return WordMarker(
      key: key,
      rect: rect ?? this.rect,
      startIndex: startIndex,
      color: color,
      width: width,
      radius: radius,
    );
  }
}
