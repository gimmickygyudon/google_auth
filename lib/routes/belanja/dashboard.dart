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
        'name': 'Indostar Plank'
      }, {
        'name': 'Indostar Board'
      }, {
        'name': 'Indostarbes'
      }
    ],
    'img': 'assets/Logo Indostar.png',
    'color': Colors.blueGrey
  },
  {
    'name': 'ECO',
    'subitem': [ 
      {
        'name': 'ECO Board'
      }, {
        'name': 'ECObes'
      }
    ],
    'img': 'assets/Logo Merk ECO.png',
    'color': Colors.lightGreen
  }
];

class _BelanjaRouteState extends State<BelanjaRoute> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).hoverColor,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Text('Nyaman dan Aman dengan Indostarboard', 
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    )
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 158,
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/dashboard_header.png')
                              )
                            ),
                          ),
                          TextField(
                            onChanged: (value) {},
                            style: Theme.of(context).textTheme.titleMedium,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                              border: InputBorder.none,
                              hintText: 'Bahan apa yang anda cari ?',
                              suffixIcon: Transform.translate(
                                offset: const Offset(0, 5),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.7),
                                    color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25)
                                  ),
                                  child: Icon(Icons.search, color: Theme.of(context).colorScheme.primary)
                                ),
                              )
                            ),
                          )
                        ]
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rekomendasi', style: Theme.of(context).textTheme.titleMedium),
                      TextButton(onPressed: () {}, child: const Text('Lihat Semua'))
                    ],
                  ),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: recommendItems.map((element) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () => pushItemPage(
                              context: context, 
                              hero: element['name'],
                              items: element['subitem'], 
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
      ),
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
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: item['color'].withOpacity(0.5),
                  padding: const EdgeInsets.all(12),
                  height: 100,
                  child: Image.asset(item['img']),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Text(item['name'], style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      )),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 18)
                    ],
                  ),
                )
              ],
            ),
            Align(
              heightFactor: 2.5,
              widthFactor: 2.2,
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ButtonStyle(
                  elevation: const MaterialStatePropertyAll(0),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                ),
                label: const Text('3 Tipe'),
                icon: const Icon(Icons.layers_outlined),
              ),
            )
          ],
        )
      ),
    );
  }
}