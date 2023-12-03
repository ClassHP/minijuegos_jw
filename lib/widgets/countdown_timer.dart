import 'package:flutter/material.dart';
import 'dart:async';

class CountdownTimerWidget extends StatefulWidget {
  final int initialTimeInSeconds;
  final VoidCallback onTimeEnd;
  final VoidCallback? onSecond;

  const CountdownTimerWidget({
    Key? key,
    required this.initialTimeInSeconds,
    required this.onTimeEnd,
    this.onSecond,
  }) : super(key: key);

  @override
  createState() => CountdownTimerWidgetState();
}

class CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late int _currentTimeInSeconds;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void restart() {
    stop();
    _startTimer();
  }

  void stop() {
    _timer.cancel();
  }

  void _startTimer() {
    setState(() {
    _currentTimeInSeconds = widget.initialTimeInSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), _timerCallback);
  }

  void _timerCallback(Timer timer) {
    setState(() {
      if (_currentTimeInSeconds > 0) {
        _currentTimeInSeconds--;
        widget.onSecond?.call();
      } else {
        stop();
        widget.onTimeEnd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _currentTimeInSeconds / widget.initialTimeInSeconds;
    int minutes = (_currentTimeInSeconds ~/ 60);
    int seconds = _currentTimeInSeconds % 60;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        LinearProgressIndicator(
          value: progress,
          minHeight: 35,
        ),
        Text(
          '$minutes:${seconds.toString().padLeft(2, '0')}', 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
