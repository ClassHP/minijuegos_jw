import 'package:flutter/material.dart';

class FittedText extends StatelessWidget {
  final String _text;
  final Color? _color;
  final FontWeight? _fontWeight;

  const FittedText(
    String text, {
    Key? key,
    Color? color,
    FontWeight? fontWeight,
  })  : _text = text,
        _color = color,
        _fontWeight = fontWeight,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Text(
        _text,
        style: TextStyle(fontSize: 500, color: _color, fontWeight: _fontWeight),
      ),
    );
  }
}
