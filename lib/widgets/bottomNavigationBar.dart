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
      'icon': Icons.notes,
      'icon_outline': Icons.notes_rounded,
      'title': 'Menu'
    },
    {
      'icon': Icons.help,
      'icon_outline': Icons.help_outline,
      'title': 'Keluhan'
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
      'icon': Icons.cottage,
      'icon_outline': Icons.cottage_outlined,
      'title': 'Beranda'
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
        currentIndex: widget.currentPage,
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedLabelStyle: Theme.of(context).textTheme.bodySmall,
        unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
        onTap: (value) {
          switch (value) {
            case 0:
              Scaffold.of(context).openDrawer();
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
              widget.pageController.animateToPage(4, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
              break;
            default:
          }
        },
        items: [
          for(int i = 0; i < bottomMenu.length; i++)
          BottomNavigationBarItem(
            icon: Icon(widget.currentPage != i ? bottomMenu[i]['icon_outline'] : bottomMenu[i]['icon']), 
            label: bottomMenu[i]['title']
          )
        ]
      ),
    );
  }
}
