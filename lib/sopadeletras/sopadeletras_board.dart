import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/fitted_text.dart';
import 'sopadeletras_colors.dart';
import 'sopadeletras_logic.dart';

class SopadeletrasBoard extends StatefulWidget {
  final SopadeletrasLogic _logic;
  final Future<bool> Function(String, Color)? onWordMarked;

  const SopadeletrasBoard({Key? key, required logic, this.onWordMarked})
      : _logic = logic,
        super(key: key);

  @override
  createState() => _SopadeletrasBoardState();
}

class _SopadeletrasBoardState extends State<SopadeletrasBoard> {
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
                    _firstSelected!, _lastSelected!, widget._logic.size, _colorSelected!),
              ),
            Listener(
              onPointerDown: _detectTapedItem,
              onPointerMove: _detectTapedItem,
              onPointerUp: _clearSelection,
              child: GridView.builder(
                key: key,
                itemCount: widget._logic.board.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget._logic.size,
                  childAspectRatio: 1,
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(5),
                    child: FittedText(
                      widget._logic.board[index],
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
    var x = event.localPosition.dx ~/ (box.size.width / widget._logic.size);
    var y = event.localPosition.dy ~/ (box.size.height / widget._logic.size);
    if (x >= 0 && y >= 0 && x < widget._logic.size && y < widget._logic.size) {
      _selectIndex(Point(x, y));
    }
  }

  _selectIndex(Point point) {
    setState(() {
      var dir = point - (_firstSelected ?? point);
      if (dir.x.abs() == dir.y.abs() || dir.x == 0 || dir.y == 0) {
        _lastSelected = point;
        _firstSelected ??= _lastSelected;
        _colorSelected ??=
            markerColors[widget._logic.random.nextInt(markerColors.length)].withOpacity(0.7);
      }
    });
  }

  void _clearSelection(PointerUpEvent event) {
    setState(() {
      var word = _getWord();
      if (widget._logic.words.containsKey(word) && widget._logic.words[word]!.color == null) {
        _markers.add(_WordMarkerPainter(
          _firstSelected!,
          _lastSelected!,
          widget._logic.size,
          _colorSelected!,
        ));
        widget._logic.words[word]!.color = _colorSelected!.withOpacity(1);
        if (widget.onWordMarked != null) {
          widget.onWordMarked!(word, widget._logic.words[word]!.color!).then((value) {
            if (value) {
              setState(() {
                _markers.clear();
              });
            }
          });
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
    var result = widget._logic.board[(recY * widget._logic.size + recX).toInt()];
    while (recX != _lastSelected!.x || recY != _lastSelected!.y) {
      recX += dir.x;
      recY += dir.y;
      result += widget._logic.board[(recY * widget._logic.size + recX).toInt()];
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
