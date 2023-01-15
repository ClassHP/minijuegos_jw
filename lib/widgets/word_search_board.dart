import 'dart:math';
import 'package:flutter/material.dart';
import 'fitted_text.dart';
import 'marker_colors.dart';

class WordSearchBoard extends StatefulWidget {
  final List<String> board;
  final Map<String, Color?> words;
  final int size;
  final Function(String, Color)? onWordMarked;

  WordSearchBoard({Key? key, required this.board, required this.words, this.onWordMarked})
      : size = sqrt(board.length).toInt(),
        super(key: key);

  @override
  createState() => _WordSearchBoardState();
}

class _WordSearchBoardState extends State<WordSearchBoard> {
  final key = GlobalKey();
  Point? _firstSelected;
  Point? _lastSelected;
  Color? _colorSelected;
  final List<_WordMarkerPainter> _markers = [];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Stack(
          children: [
            ..._markers.map((e) => CustomPaint(size: Size.infinite, painter: e)),
            if (_firstSelected != null)
              CustomPaint(
                size: Size.infinite,
                painter: _WordMarkerPainter(
                    _firstSelected!, _lastSelected!, widget.size, _colorSelected!),
              ),
            Listener(
              onPointerDown: _detectTapedItem,
              onPointerMove: _detectTapedItem,
              onPointerUp: _clearSelection,
              child: GridView.builder(
                key: key,
                itemCount: widget.board.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.size,
                  childAspectRatio: 1,
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(5),
                    child: FittedText(
                      widget.board[index],
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _detectTapedItem(PointerEvent event) {
    final RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    var x = event.localPosition.dx ~/ (box.size.width / widget.size);
    var y = event.localPosition.dy ~/ (box.size.height / widget.size);
    if (x >= 0 && y >= 0 && x < widget.size && y < widget.size) {
      _selectIndex(Point(x, y));
    }
  }

  _selectIndex(Point point) {
    setState(() {
      var dir = point - (_firstSelected ?? point);
      if (dir.x.abs() == dir.y.abs() || dir.x == 0 || dir.y == 0) {
        _lastSelected = point;
        _firstSelected ??= _lastSelected;
        _colorSelected ??= markerColors[Random().nextInt(markerColors.length)].withOpacity(0.7);
      }
    });
  }

  void _clearSelection(PointerUpEvent event) {
    setState(() {
      var word = _getWord();
      if (widget.words.containsKey(word) && widget.words[word] == null) {
        _markers.add(_WordMarkerPainter(
          _firstSelected!,
          _lastSelected!,
          widget.size,
          _colorSelected!,
        ));
        widget.words[word] = _colorSelected!.withOpacity(1);
        if (widget.onWordMarked != null) {
          widget.onWordMarked!(word, widget.words[word]!);
        }
      }
      _firstSelected = null;
      _lastSelected = null;
      _colorSelected = null;
    });
  }

  String _getWord() {
    var dir = _lastSelected! - _firstSelected!;
    dir = Point((dir.x > 0 ? 1 : (dir.x < 0 ? -1 : 0)), (dir.y > 0 ? 1 : (dir.y < 0 ? -1 : 0)));
    var recX = _firstSelected!.x;
    var recY = _firstSelected!.y;
    var result = widget.board[(recY * widget.size + recX).toInt()];
    while (recX != _lastSelected!.x || recY != _lastSelected!.y) {
      recX += dir.x;
      recY += dir.y;
      result += widget.board[(recY * widget.size + recX).toInt()];
    }
    return result;
  }
}

class _WordMarkerPainter extends CustomPainter {
  final Point box1, box2;
  final int boardSize;
  final Color color;

  _WordMarkerPainter(this.box1, this.box2, this.boardSize, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final boxSize = size.width / boardSize;
    final strokeWidth = boxSize * 0.7;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.fill
      ..color = color
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(boxSize * box1.x + boxSize / 2, boxSize * box1.y + boxSize / 2),
        Offset(boxSize * box2.x + boxSize / 2, boxSize * box2.y + boxSize / 2), paint);
  }

  @override
  bool shouldRepaint(_WordMarkerPainter oldDelegate) {
    return oldDelegate.boardSize != boardSize ||
        oldDelegate.box1 != box1 ||
        oldDelegate.box2 != box2;
  }
}
