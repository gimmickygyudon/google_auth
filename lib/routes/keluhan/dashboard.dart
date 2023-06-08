import 'package:flutter/material.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:intl/intl.dart';

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

  String getLaporan(String laporan) {
    switch (laporan) {
      case 'Price':
        return 'Harga';
      case 'Quality':
        return 'Kualitas';
      case 'Service':
        return 'Pelayanan';
      case 'After Sales':
        return 'Purna Jual';
      default:
        return laporan;
    }
  }

  late TabController _tabController;
  List<String> sortList = ['Request', 'Nama', 'Tipe'];
  late String sortValue;
  late ScrollController _scrollController;

  @override
  void initState() {
    sortValue = sortList.first;
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: Themes.appBarTheme(context)),
      child: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            snap: true,
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false,
            toolbarHeight: kToolbarHeight + 110,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Umpan Balik', 
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w500
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
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            BuatLaporanWidget(scrollController: _scrollController, laporanList: laporanList),
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
                  sliver: SliverToBoxAdapter(
                    child: FutureBuilder(
                      future: UserReport.getList(limit: 2, offset: 0),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.check_circle, size: 20, color: Theme.of(context).colorScheme.secondary),
                                      const SizedBox(width: 8),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          value: sortValue,
                                          onChanged: (value) {
                                            setState(() {
                                              sortValue = value!;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          items: sortList.map((item) {
                                            return DropdownMenuItem(
                                              value: item,
                                              child: Text(item, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: Theme.of(context).colorScheme.secondary,
                                              ))
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(snapshot.data!.length.toString(), style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.secondary
                                      )),
                                      const SizedBox(width: 2),
                                      Icon(Icons.question_answer, size: 18, color: Theme.of(context).colorScheme.secondary),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              ListView.builder(
                                controller: _scrollController,
                                shrinkWrap: true,
                                itemCount: snapshot.data?.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  DateTime dateTime = DateTime.parse(snapshot.data?[index]['document_date']);
                                  dateTime = dateTime.add(DateTime.parse(snapshot.data?[index]['document_date']).timeZoneOffset);
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            child: Icon(
                                              laporanList.singleWhere((element) {
                                                return element['name'] == getLaporan(snapshot.data?[index]['SFB1']['type_feed']);
                                              })['icon'], 
                                              color: Theme.of(context).colorScheme.primary
                                            )
                                          ),
                                          const SizedBox(width: 12),
                                          Text(snapshot.data?[index]['SFB1']['type_feed'], style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                          )),
                                          Text(' #${snapshot.data![index]['id_osfb'].toString()}', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                                          )),
                                        ],
                                      ),
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(snapshot.data?[index]['SFB1']['description']),
                                        titleTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          letterSpacing: 0,
                                          height: 2
                                        ),
                                        subtitle: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(DateFormat('EEEE, dd MMMM, ''yyyy', 'id').format(dateTime), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.75),
                                            )),
                                            Text(DateFormat('HH:mm', 'id').format(DateTime.parse(snapshot.data?[index]['document_date'])), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.75),
                                            )),
                                          ],
                                        ),
                                      ),
                                      Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.25)),
                                      const SizedBox(height: 12)
                                    ],
                                  );
                              }),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 54,
                              width: 54,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                ),
              ],
            )
          ]
        ),
      ),
    );
  }
}

class TicketWidget extends StatefulWidget {
  const TicketWidget({super.key});

  @override
  State<TicketWidget> createState() => _TicketWidgetState();
}

class _TicketWidgetState extends State<TicketWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class BuatLaporanWidget extends StatelessWidget {
  const BuatLaporanWidget({super.key, required this.scrollController, required this.laporanList});

  final ScrollController scrollController;
  final List<Map> laporanList;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(top: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160, 
                    mainAxisSpacing: (MediaQuery.of(context).size.height > 750) ? 20 : 10, 
                    crossAxisSpacing: (MediaQuery.of(context).size.height > 750) ? 20 : 10
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
          ),
        ),
      ],
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
              color: isSelected == true ? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.primary.withOpacity(0.25)
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