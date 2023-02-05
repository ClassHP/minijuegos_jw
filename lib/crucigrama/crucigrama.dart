import 'package:flutter/material.dart';

class Crucigrama extends StatefulWidget {
  const Crucigrama({Key? key}) : super(key: key);

  @override
  createState() => _CrucigramaState();
}

class _CrucigramaState extends State<Crucigrama> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crucigrama Bíblico'),
      ),
      body: Container(),
    );
  }
}
