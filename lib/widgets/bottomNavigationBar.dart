import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({super.key, required this.currentPage});
  
  final int currentPage;

  // TODO: move somewhere
  final List<Map<String, dynamic>> bottomMenu = [
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
      'icon': Icons.question_mark,
      'icon_outline': Icons.question_mark,
      'title': 'Keluhan'
    },
    {
      'icon': Icons.notes,
      'icon_outline': Icons.notes_rounded,
      'title': 'Menu'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [ 
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -4)
          ) 
        ]
      ),
      child: BottomNavigationBar(
        currentIndex: currentPage,
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedLabelStyle: Theme.of(context).textTheme.bodySmall,
        unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
        onTap: (value) {
          switch (value) {
            case 4:
              Scaffold.of(context).openEndDrawer();
              break;
            default:
          }
        },
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
