import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minijuegos_jw/trivia/trivia.dart';
import 'crucigrama/crucigrama.dart';
import 'home.dart';
import 'sopadeletras/sopadeletras.dart';

class MainRouter {
  static GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const Home();
        },
        routes: [
          GoRoute(path: 'crucigrama', builder: (context, state) => const Crucigrama()),
          GoRoute(path: 'sopadeletras', builder: (context, state) => const Sopadeletras()),
          GoRoute(path: 'trivia', builder: (context, state) => const Trivia()),
        ],
      ),
    ],
  );
}
