import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../styles/theme.dart';

class AddCustomerRoute extends StatefulWidget {
  const AddCustomerRoute({super.key});

  @override
  State<AddCustomerRoute> createState() => _AddCustomerRouteState();
}

class _AddCustomerRouteState extends State<AddCustomerRoute> {
  late TextEditingController _searchController;

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context),
        inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.deepOrange,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Tambah Pelanggan'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/customer_page.png'),
                    const SizedBox(height: 12),
                    Text('Pelanggan', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Menjaga pelanggan menuntut keterampilan sebanyak untuk memenangkannya', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary))
                  ]
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _searchController,
                  onChanged: (value) { 
                    setState(() {}); 
                  },
                  decoration: Styles.inputDecorationForm(
                    context: context, 
                    icon: const Icon(Icons.search),
                    placeholder: 'ID Pelanggan / Nama', 
                    condition: _searchController.text.trim().isNotEmpty
                  )
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
