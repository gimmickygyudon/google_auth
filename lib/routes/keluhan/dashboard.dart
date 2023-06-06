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
      'icon': Icons.payment_outlined
    },
    {
      'name': 'Kualitas',
      'icon': Icons.layers_outlined
    },
    {
      'name': 'Pelayanan',
      'icon': Icons.groups_outlined
    },
    {
      'name': 'Purna Jual',
      'icon': Icons.local_shipping_outlined
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
            toolbarHeight: kToolbarHeight + 110,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text('Umpan Balik', 
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          letterSpacing: 0
                        )
                      ),
                      const SizedBox(height: 4),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                        child: Text('Kritik adalah ketaksetujuan orang, bukan\nkarena memiliki kesalahan.', 
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary
                          )
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 0),
                          ElevatedButton.icon(
                            onPressed: () => pushReportPage(context: context, laporanList: laporanList), 
                            icon: const Icon(Icons.add), 
                            label: const Text('Buat'),
                            style: Styles.buttonForm(context: context),
                          ),
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
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 36),
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
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 160, mainAxisSpacing: 20, crossAxisSpacing: 20
                          ),
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
    this.isSelected
  });

  final List<Map> laporanList;
  final Function? pushReportPage;
  final bool? isSelected;
  final Map item;
  final double? size = 30;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.inversePrimary.withOpacity(isSelected == true ? 0.25 : 0.05),
        child: InkWell(
          onTap: pushReportPage != null ? () {
             pushReportPage!(context: context, laporan: item, laporanList: laporanList);
          } : null,
          splashColor: isSelected == true 
            ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.05)
            : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
          highlightColor: isSelected == true 
            ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.05)
            : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
          child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: isSelected == true ? 2 : 1, 
              color: isSelected == true ? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.outlineVariant.withOpacity(1)
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item['icon'], 
                size: size, 
                color: Theme.of(context).colorScheme.primary
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(item['name'], 
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 0
                        )
                      ),
                      const SizedBox(width: 4),
                      if(isSelected == null) Icon(Icons.arrow_forward, size: 16, color: Theme.of(context).colorScheme.primary)
                    ],
                  ),
                  if(isSelected == true) Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary)
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}