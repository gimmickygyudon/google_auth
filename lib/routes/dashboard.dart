import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:google_auth/functions/sql_client.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/widgets/image.dart';
import '../functions/authentication.dart';
import '../functions/sqlite.dart';
import '../strings/user.dart';

class DashboardRoute extends StatefulWidget {
  const DashboardRoute({super.key, this.user, required this.loginWith, this.source});

  final User? user;
  final String loginWith;
  final Map? source;

  @override
  State<DashboardRoute> createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> {
  final int currentPage = 0;

  @override
  void initState() {
    if (widget.source != null) {
      currentUser = {
        'email': widget.source?['user_email'], 
        'name': widget.source?['user_name'],
        'photo': widget.source?['photo_url'],
        'loginWith': widget.loginWith,
        'date': DateNowSQL,
      };
    }

    // TODO: form sender wrong its should be 'Email' not 'Nomor'
    Map<String, dynamic> logUser = UserSqlFormat.olog(
      id_olog: null, 
      date_time: DateNowSQL, 
      form_sender: widget.loginWith,
      remarks: widget.source?['user_name'], 
      source: widget.source?['user_email'],
    );

    UserLog.log_user(currentUser['email'], logUser);
    initloginSession();
    super.initState();
  }

  void initloginSession() {
    UserRegister.retrieve(currentUser['email']).then((value) async {
      Map<String, dynamic> item = {
        'id_ousr': (value.last.id_ousr! + 1),
        'login_type': value.last.login_type,
        'user_email': value.last.user_email,
        'user_name': value.last.user_name,
        'phone_number': value.last.phone_number,
        'user_password': value.last.user_password
      };
      if(widget.source != null) if(widget.source!.containsKey('photo_url')) item.addAll({'photo_url': widget.source?['photo_url']});
      Authentication.signIn(item);
    });
  }

  // TODO: MOVE THIS SOMEWHERE
  void insertOLOG() {
    UserLog.retrieve(currentUser['email']).then((value) async {
      SQL.retrieve(value.last.source, 'olog').then((value) {
        Map<String, dynamic> item = {
          'id_olog': value['id_olog'] + 1,
          'date_time': DateFormat('y-MM-d H:m:ss').format(DateTime.now()),
          'form_sender': value['form_sender'],
          'remarks': value['remarks'],
          'source': value['source']
        };
        SQL.insert(item, 'olog');
      });
    }); 
  }

  void insertOUSR() {
    UserRegister.retrieve(currentUser['email']).then((value) async {
      Map<String, dynamic> item = {
        'id_ousr': (value.last.id_ousr! + 1),
        'login_type': value.last.login_type,
        'user_email': value.last.user_email,
        'user_name': value.last.user_name,
        'phone_number': value.last.phone_number,
        'user_password': value.last.user_password
      };
      SQL.insert(item, 'ousr');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: PhotoProfile(photo: widget.source?['photo_url'], size: 58, color: Theme.of(context).colorScheme.surface),
              currentAccountPictureSize: const Size(58, 58),
              accountName: Text(currentUser['name'], style: TextStyle(color: Theme.of(context).colorScheme.surface)),
              accountEmail: Text(currentUser['email'], style: TextStyle(color: Theme.of(context).colorScheme.surfaceVariant,fontSize: 12))
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: true,
            toolbarHeight: kToolbarHeight + 10,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12)
                )
              ),
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(Icons.menu, color: Theme.of(context).colorScheme.surface),
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  );
                }
              ),
              title: Builder(
                builder: (context) {
                  return TextButton(
                    style: const ButtonStyle(visualDensity: VisualDensity(vertical: -4, horizontal: -4)),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentUser['name'], style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                        Text(currentUser['email'], style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.surface
                          )
                        ),
                      ],
                    )
                  );
                }
              ),
              leadingWidth: 28,
              backgroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none), color: Theme.of(context).colorScheme.surface),
                PopupMenuButton(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: PhotoProfile(photo: currentUser['photo'], size: 36),
                        title: Text(currentUser['name'], style: const TextStyle(letterSpacing: 0.5)),
                        subtitle: Text(currentUser['email'],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    ),
                    const PopupMenuItem(enabled: false, height: 0, child: PopupMenuDivider()),
                    PopupMenuItem(
                      onTap: () {
                        Authentication.signOut().whenComplete(() => pushLogout(context));
                      },
                      child: const ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.logout),
                        title: Text('Logout  /  Keluar')
                      )
                    ),
                    PopupMenuItem(
                      enabled: false,
                      height: 28,
                      child: Text('v1.0.0+1 • Logged in $DateNow', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
                    )
                  ],
                  child: PhotoProfile(photo: currentUser['photo'], size: 32, color: Theme.of(context).colorScheme.surface),
                ),
                const SizedBox(width: 12),
              ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: PageView(
                children: [
                  SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Card(
                                    color: Theme.of(context).hoverColor,
                                    elevation: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text.rich(
                                            TextSpan(text: 'Rp', style: const TextStyle(fontSize: 11), children: [                                          
                                              TextSpan(text: '12.000', style: Theme.of(context).textTheme.titleSmall),
                                            ]),
                                          ),
                                          const SizedBox(height: 12),
                                          Text('Update setiap hari $DateNow', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.secondary,
                                              fontSize: 10
                                            )
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 190,
                                child: Card(
                                  color: Theme.of(context).hoverColor,
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Perolehan Kamu', style: Theme.of(context).textTheme.titleSmall),
                                        Expanded(
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            children: const [
                                              IconButtonText(icon: Icons.scale, label: 'Jumlah', value: '0 Ton'),
                                              SizedBox(width: 10),
                                              IconButtonText(icon: Icons.card_giftcard, label: 'Piutang', value: 'Rp. 0'),
                                              SizedBox(width: 10),
                                              IconButtonText(icon: Icons.local_shipping, label: 'Antrean', value: '150'),
                                            ],
                                          ),
                                        ),
                                        TextButton.icon(
                                          style: const ButtonStyle(
                                            visualDensity: VisualDensity(horizontal: -4, vertical: -4)
                                          ),
                                          onPressed: () {}, 
                                          icon: const Text('Rincian'),
                                          label: const Icon(Icons.navigate_next),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 150,
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: const [
                              IconButtonText(icon: Icons.person_add, label: 'Tambah Pelanggan')
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedLabelStyle: Theme.of(context).textTheme.bodySmall,
        unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
        items: [
          for(int i = 0; i < bottomMenu.length; i++)
          BottomNavigationBarItem(
            icon: Icon(currentPage != i ? bottomMenu[i]['icon_outline'] : bottomMenu[i]['icon']), 
            label: bottomMenu[i]['title']
          )
        ]
      ),
    );
  }
}

// TODO: move somewhere
List<Map<String, dynamic>> bottomMenu = [
  {
    'icon': Icons.cottage,
    'icon_outline': Icons.cottage_outlined,
    'title': 'Beranda'
  },
  {
    'icon': Icons.shopping_bag,
    'icon_outline': Icons.shopping_bag_outlined,
    'title': 'Belanja'
  },
  {
    'icon': Icons.star,
    'icon_outline': Icons.star_border,
    'title': 'Promo'
  },
  {
    'icon': Icons.contact_support,
    'icon_outline': Icons.contact_support_outlined,
    'title': 'Keluhan'
  }
];

class IconButtonText extends StatelessWidget {
  const IconButtonText({super.key, required this.label, this.value, required this.icon});

  final String label;
  final String? value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary)
            ),
            const SizedBox(height: 12),
            if(value != null) Text(value!, style: Theme.of(context).textTheme.labelMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 10
              )
            )
          ],
        ),
      ),
    );
  }
}