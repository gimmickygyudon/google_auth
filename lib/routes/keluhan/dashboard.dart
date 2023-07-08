import 'package:flutter/material.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/widgets/handle.dart';
import 'package:google_auth/widgets/text.dart';
import 'package:intl/intl.dart';

import '../../functions/push.dart';

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
  late int tickets, pageLimit, pageOffset, currentPage;
  late ScrollController _scrollController;
  late Future _getList;

  @override
  void initState() {
    sortValue = sortList.first;
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);

    tickets = 0; // Jumlah Keluhan
    pageLimit = 5;
    pageOffset = 0;
    currentPage = 1;

    _getList = UserReport.getList(limit: pageLimit, offset: pageOffset, setCount: ticketCount).onError((error, stackTrace) {
      return Future.error(error.toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int pages() {
    int pages = 0;
    for (var i = tickets; i > 0; i -= pageLimit) {
      pages++;
    }

    return pages;
  }

  void ticketCount(int count) => tickets = count;

  void changePage(int page) {
    setState(() {
      if (currentPage < page) {
        pageOffset += (pageLimit * (page - currentPage));
      } else {
        pageOffset -= (pageLimit * (currentPage - page));
      }

      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          snap: true,
          pinned: true,
          floating: true,
          automaticallyImplyLeading: false,
          toolbarHeight: kToolbarHeight + 50,
          forceElevated: true,
          surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
          actions: const [ SizedBox() ],
          title: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextIcon(label: 'Keluhan', icon: Icons.help, iconSize: 22),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Kami Sangat Menghargai Pendapat Anda.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.sentiment_satisfied_alt, size: 18, color: Theme.of(context).colorScheme.secondary),
                  ],
                ),
              ],
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(),
            unselectedLabelColor: Theme.of(context).colorScheme.secondary,
            tabs: [
              const Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lapor Keluhan')
                  ],
                )
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Pendapat Anda')
                      ],
                    )
                  ),
                  Visibility(
                    visible: tickets > 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Badge(
                        largeSize: 18,
                        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                        label: Text(tickets.toString()),
                        textColor:Theme.of(context).colorScheme.primary ,
                      )
                    ),
                  )
                ],
              ),
            ]
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          BuatLaporanWidget(scrollController: _scrollController, laporanList: laporanList),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: FutureBuilder(
                    future: _getList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                        return HandleNoInternet(message: snapshot.error.toString(), onPressed: () {});
                      }
                      else if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
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
                                    Text(tickets.toString(), style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                                          backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                                          child: Icon(
                                            laporanList.singleWhere((element) {
                                              return element['name'] == getLaporan(snapshot.data?[index]['SFB1']['type_feed']);
                                            })['icon'],
                                            color: Theme.of(context).colorScheme.primary
                                          )
                                        ),
                                        const SizedBox(width: 12),
                                        Text(getLaporan(snapshot.data?[index]['SFB1']['type_feed']), style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
                                        fontWeight: FontWeight.w500,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int index = 0; index < pages(); index++) ...[
                                  TextButton(
                                    style: ButtonStyle(
                                      padding: const MaterialStatePropertyAll(EdgeInsets.zero),
                                      textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelLarge?.copyWith(
                                        fontWeight: index + 1 == currentPage ? FontWeight.w800 : null)
                                      ),
                                      foregroundColor: MaterialStatePropertyAll(
                                        index + 1 == currentPage ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary.withOpacity(0.75)
                                      )
                                    ),
                                    onPressed: index + 1 != currentPage ? () => changePage(index + 1) : null,
                                    child: Text((index + 1).toString())
                                  )
                                ]
                              ]
                            )
                          ],
                        );
                      } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData == false) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height / 2 - (kToolbarHeight + kBottomNavigationBarHeight),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.handshake_outlined, size: 72, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 24),
                                Text('Kamu Hebat !', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text('Tempat ini sepertinya tidak digunakan.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                  )
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const HandleLoading();
                      }
                    }
                  ),
                ),
              ),
            ],
          )
        ]
      ),
    );
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
                    maxCrossAxisExtent: 260,
                    mainAxisExtent: 130,
                    mainAxisSpacing: (MediaQuery.of(context).size.height > 750) ? 30 : 40,
                    crossAxisSpacing: (MediaQuery.of(context).size.height > 750) ? 30 : 40
                  ),
                  children: laporanList.map((item) {
                    return Hero(
                      tag: item['name'],
                      child: LaporanCard(
                        iconSize: 32,
                        bgRadius: 20,
                        laporanList: laporanList,
                        pushReportPage: pushReportPage,
                        item: item
                      ),
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
    this.iconSize,
    this.bgRadius,
    this.isSelected,
    this.color,
    this.bgColor
  });

  final List<Map> laporanList;
  final Function? pushReportPage;
  final bool? isSelected;
  final Map item;
  final double? iconSize, bgRadius;
  final Color? color, bgColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          borderRadius: BorderRadius.circular(20),
          child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: isSelected == true ? 2 : 1,
              color: isSelected == true
              ? Theme.of(context).colorScheme.inversePrimary
              : Theme.of(context).colorScheme.primary.withOpacity(0.25)
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: bgColor,
                radius: bgRadius,
                child: Icon(item['icon'],
                  size: iconSize ?? 24,
                  color: color ?? Theme.of(context).colorScheme.primary
                ),
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
                    ],
                  ),
                  if(isSelected == null) Icon(Icons.arrow_forward, size: 24, color: Theme.of(context).colorScheme.primary),
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
