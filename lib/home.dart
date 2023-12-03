import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Tools.dart';
import 'main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  final String title = 'Minijuegos JW | Juegos bíblicos';

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<_MenuItem> _menuItems = [
    /*_MenuItem(
      title: 'Crucigrama',
      descrip: 'Juego de palabras cruzadas',
      assetName: 'assets/images/crucigrama.jpg',
      location: '/crucigrama',
    ),*/
    _MenuItem(
      title: 'Sopa de letras',
      descrip: 'Encuentra las palabras',
      assetName: 'assets/images/sopadeletras.jpg',
      location: '/sopadeletras',
    ),
    _MenuItem(
      title: 'Trivia',
      descrip: 'Responde las preguntas',
      assetName: 'assets/images/trivia.png',
      location: '/trivia',
    ),
  ];

  _openClassHP() {
    launchUrl(
      Uri.parse('https://twitter.com/classhp'),
      mode: LaunchMode.externalApplication,
    );
  }

  _openAndroid() {
    launchUrl(
      Uri.parse(Tools.urlApp),
      mode: LaunchMode.externalApplication,
    );
  }

  _openRepository() {
    launchUrl(
      Uri.parse('https://github.com/ClassHP/minijuegos_jw'),
      mode: LaunchMode.externalApplication,
    );
  }

  _share() {
    Share.share('MinijuegosJW - Juegos Bíblicos \n${Tools.urlApp}');
  }

  @override
  Widget build(BuildContext context) {
    if (MyApp.of(context).themeMode == ThemeMode.system) {
      MyApp.of(context).setTheme(MediaQuery.of(context).platformBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light);
    }
    var crossAxisCount = MediaQuery.of(context).orientation == Orientation.landscape ? 5 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.count(
        restorationId: 'grid_view_demo_grid_offset',
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.all(8),
        childAspectRatio: 1,
        children: _menuItems.map<Widget>((menuItem) {
          return InkResponse(
            onTap: () {
              GoRouter.of(context).go(menuItem.location);
            },
            child: GridTile(
              footer: Material(
                color: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                clipBehavior: Clip.antiAlias,
                child: GridTileBar(
                  backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.90),
                  title: Text(
                    menuItem.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    menuItem.descrip,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              child: Material(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  menuItem.assetName,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: UniqueKey(),
        onPressed: () => MyApp.of(context).toggleTheme(),
        tooltip: 'Tema',
        child: const Icon(Icons.brightness_6),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Theme.of(context).colorScheme.primary,
        child: Container(
          padding: const EdgeInsets.fromLTRB(5, 5, 70, 5),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 5,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                icon: const Icon(Icons.bolt),
                label: const Text("by @ClassHP"),
                onPressed: _openClassHP,
              ),
              if (Tools.isWeb) ...[
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.call_split),
                  label: const Text("GitHub"),
                  onPressed: _openRepository,
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.android),
                  label: const Text("Instala la app Android"),
                  onPressed: _openAndroid,
                ),
              ],
              if (Tools.isNotWeb)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text("Compartir"),
                  onPressed: _share,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  _MenuItem({
    required this.title,
    required this.descrip,
    required this.assetName,
    required this.location,
  });

  final String title;
  final String descrip;
  final String assetName;
  final String location;
}
