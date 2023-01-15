import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

class CrucigramaLogic {
  late Future ready;
  final List<_Palabra> _palabras = [];

  CrucigramaLogic() {
    ready = Future.wait([
      _loadAsset('assets/files/crucigrama_def.txt').then((value) {
        return value;
      }),
      _loadAsset('assets/files/crucigrama_res.txt').then((value) {
        return value;
      })
    ]).then((values) {
      var defList = values[0].split('\n');
      var resList = values[1].split('\n');
      if (defList.length != resList.length) {
        throw Exception('La definicion y respuesta de la base de datos del crucigrama no contienen '
            'la misma cantidad de elementos');
      }
      for (var i = 0; i < defList.length; i++) {
        _palabras.add(_Palabra(defList[i], resList[i]));
      }
    });
  }

  Future<String> _loadAsset(String key) async {
    return await rootBundle.loadString(key);
  }
}

class _Palabra {
  String definicion;
  String respuesta;
  _Palabra(this.definicion, this.respuesta);
}
