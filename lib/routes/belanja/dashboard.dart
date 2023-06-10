import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';

class BelanjaRoute extends StatefulWidget {
  const BelanjaRoute({super.key});

  @override
  State<BelanjaRoute> createState() => _BelanjaRouteState();
}

List<Map> recommendItems = [
  {
    'name': 'Indostar',
    'subitem': [ 
      {
        'name': 'Indostar Plank',
        'img': 'assets/Indostar Plank.png'
      }, {
        'name': 'Indostar Board',
        'img': 'assets/Indostar Board.png'
      }, {
        'name': 'Indostarbes',
        'img': 'assets/Indostar Bes.png'
      }
    ],
    'img': 'assets/Logo Indostar.png',
    'bg': 'assets/background-1a.jpg',
    'color': Colors.blueGrey
  },
  {
    'name': 'ECO',
    'subitem': [ 
      {
        'name': 'ECO Board',
        'img': 'assets/Indostar Board.png'
      }, {
        'name': 'ECObes',
        'img': 'assets/Indostar Bes.png'
      }
    ],
    'img': 'assets/Logo Merk ECO.png',
    'bg': 'assets/background-2a.png',
    'color': Colors.lightGreen
  }
];

class _BelanjaRouteState extends State<BelanjaRoute> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    surfaceTintColor: Colors.transparent,
                    color: Theme.of(context).hoverColor,
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {},
                          style: Theme.of(context).textTheme.titleMedium,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                            border: InputBorder.none,
                            hintText: 'Bahan apa yang anda cari ?',
                            hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.only(left: 6, right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.7),
                                color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 2),
                                  Text('Cari', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary
                                  ))
                                ],
                              )
                            )
                          ),
                        ),
                      ]
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          onSelected: (value) {},
                          avatar: const FlutterLogo(),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide.none,
                          backgroundColor: Theme.of(context).hoverColor,
                          label: const Text('Produk'),
                        ),
                      );
                    }),
                  )
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.recommend, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                          Text('Rekomendasi', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary
                          )),
                        ],
                      ),
                      TextButton(onPressed: () {}, child: const Text('Lihat Semua'))
                    ],
                  ),
                ),
                SizedBox(
                  height: 158,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: recommendItems.map((element) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => pushItemPage(
                            context: context, 
                            hero: element['name'],
                            items: element['subitem'],
                            background: element['bg'],
                            color: element['color'],
                            logo: element['img']
                          ),
                          child: Hero(
                            tag: element['name'],
                            child: CardItem(item: element)
                          )
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class CardItem extends StatelessWidget {
  const CardItem({super.key, required this.item});

  final Map item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      height: 200,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Container(
          foregroundDecoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: item['color'], width: 4))
          ),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(                  
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(item['bg'])
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).hoverColor,
                      Colors.black26,
                    ]
                  )
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 52),
                child: Image.asset(item['img']),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton.icon(
                    onPressed: () {}, 
                    style: ButtonStyle(
                      shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                      alignment: FractionalOffset.centerLeft,
                      visualDensity: const VisualDensity(vertical: -4),
                      backgroundColor: MaterialStatePropertyAll(item['color'])
                    ),
                    icon: Text('Lihat Produk', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.surface)
                    ),
                    label: Icon(Icons.arrow_forward, size: 18, color: Theme.of(context).colorScheme.surface),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}