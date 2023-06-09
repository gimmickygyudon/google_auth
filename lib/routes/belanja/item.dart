import 'package:flutter/material.dart';

import '../../styles/theme.dart';

class ItemRoute extends StatelessWidget {
  const ItemRoute({
    super.key, 
    required this.hero,
    required this.items, 
  });

  final List<Map> items;
  final String hero;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context),
      ),
      child: Scaffold(
        body: Hero(
          tag: hero,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(hero),
                flexibleSpace: const FlexibleSpaceBar(),
              ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, mainAxisSpacing: 12, crossAxisSpacing: 12),
                delegate: SliverChildListDelegate(items.map((element) {
                  return GridTile(
                    footer: Text(element['name']),
                    child: FlutterLogo(),
                  );
                }).toList()), 
            )],
          ),
        ),
      ),
    );
  }
}