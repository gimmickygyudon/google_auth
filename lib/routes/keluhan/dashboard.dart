import 'package:flutter/material.dart';

import '../../functions/push.dart';
import '../../styles/theme.dart';

class KeluhanRoute extends StatefulWidget {
  const KeluhanRoute({super.key});

  @override
  State<KeluhanRoute> createState() => _KeluhanRouteState();
}

class _KeluhanRouteState extends State<KeluhanRoute> with SingleTickerProviderStateMixin {
  final List<Map> laporanList = [
    {
      'name': 'Harga',
      'icon': Icons.payments_outlined
    },
    {
      'name': 'Kualitas',
      'icon': Icons.high_quality_outlined
    },
    {
      'name': 'Pelayanan',
      'icon': Icons.diversity_3_outlined
    },
    {
      'name': 'Purna Jual',
      'icon': Icons.support_agent_outlined
    },
    {
      'name': 'Promo',
      'icon': Icons.star_half_outlined
    },
  ];

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: Themes.appBarTheme(context)),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            snap: true,
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false,
            toolbarHeight: kToolbarHeight + 100,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Umpan Balik', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('Kritik adalah ketaksetujuan orang, bukan karena memiliki kesalahan.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Chip(label: Text('0 Laporan')),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Buat')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Buat Laporan'),
                Tab(text: 'Ticket'),
              ]
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 26),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - kToolbarHeight - 100,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 160, mainAxisSpacing: 20, crossAxisSpacing: 20),
                          children: laporanList.map((item) { 
                            return LaporanCard(
                              laporanList: laporanList, 
                              pushReportPage: pushReportPage, 
                              item: item
                            );
                          }).toList(),  
                        ),
                      ],
                    ),
                    const Placeholder()
                  ]
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LaporanCard extends StatelessWidget {
  const LaporanCard({
    super.key, 
    required this.laporanList, 
    required this.pushReportPage, 
    required this.item,
    this.disableHero,
    this.isSelected
  });

  final List<Map> laporanList;
  final Function? pushReportPage;
  final bool? disableHero;
  final bool? isSelected;
  final Map item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.inversePrimary.withOpacity(isSelected == true ? 0.25 : 0.05),
        child: InkWell(
          onTap: pushReportPage != null ? () {
             pushReportPage!(context, item, laporanList);
          } : null,
          splashColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
          highlightColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
          child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: isSelected == true ? 2 : 1, 
              color: isSelected == true ? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.25)
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'], 
                size: 36, 
                color: Theme.of(context).colorScheme.primary
              ),
              const SizedBox(height: 12),
              Text(item['name'], 
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary
                )
              )
            ],
          ),
        ),
      )
    );
  }
}