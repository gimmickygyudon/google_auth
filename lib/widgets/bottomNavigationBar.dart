import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key, required this.currentPage, required this.pageController, required this.changePage});
  
  final int currentPage;
  final PageController pageController;
  final Function changePage;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  // TODO: move somewhere
  final List<Map<String, dynamic>> bottomMenu = [
    {
      'value': 0,
      'icon': Icons.cottage,
      'icon_outline': Icons.cottage_outlined,
      'title': 'Beranda'
    },
    {
      'icon': Icons.star,
      'icon_outline': Icons.star_border,
      'title': 'Promo'
    },
    {
      'icon': Icons.shopping_bag,
      'icon_outline': Icons.shopping_bag_outlined,
      'title': 'Belanja'
    },
    {
      'icon': Icons.help,
      'icon_outline': Icons.help_outline,
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
      height: 70,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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
        currentIndex: widget.currentPage,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedLabelStyle: Theme.of(context).textTheme.bodySmall,
        unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
        onTap: (value) {
          switch (value) {
            case 0:
              widget.pageController.animateToPage(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
              break;
            case 1:
              widget.pageController.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
              break;
            case 2:
              widget.pageController.animateToPage(2, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
              break;
            case 3:
              widget.pageController.animateToPage(3, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
              break;
            case 4:
              Scaffold.of(context).openEndDrawer();
              break;
            default:
          }
        },
        items: [
          for(int i = 0; i < bottomMenu.length; i++)
          BottomNavigationBarItem(
            activeIcon: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)
              ),
              child: Icon(bottomMenu[i]['icon'])
            ),
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Icon(bottomMenu[i]['icon_outline']),
            ), 
            label: bottomMenu[i]['title']
          )
        ]
      ),
    );
  }
}
