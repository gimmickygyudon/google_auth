import 'package:flutter/material.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/routes/keluhan/dashboard.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/widgets/snackbar.dart';

import '../../functions/sql_client.dart';
import '../../styles/theme.dart';

class LaporanRoute extends StatefulWidget {
  const LaporanRoute({super.key, required this.laporan, required this.laporanList});

  final List<Map> laporanList;
  final Map laporan;

  @override
  State<LaporanRoute> createState() => _LaporanRouteState();
}

class _LaporanRouteState extends State<LaporanRoute> {
  late TextEditingController _detailController;
  late String laporan;
  late ScrollController _scrollController;
  GlobalKey selectedKey = GlobalKey();

  @override
  void initState() {
    _detailController = TextEditingController();
    _scrollController = ScrollController();

    laporan = widget.laporan['name'];
    super.initState();
  }

  @override
  void dispose() {
    _detailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendReport() {
    SQL.insert(
      item: UserReport(
        id_osfb: null,
        document_date: DateNowSQL,
        id_ousr: currentUser['id_ousr'], 
        remarks: currentUser['name']
      ).toMap(), 
      api: 'osfb'
    ).then((value) {
      if (value.isNotEmpty) showSnackBar(context, snackBarAuth(context: context, content: 'Terima Kasih atas Umpan Balik Anda.'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Themes.appBarTheme(context),
        inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Buat Keluhan $laporan'),
          actions: const [
            Image(image: AssetImage('assets/logo IBM p C.png'), height: 32),
            SizedBox(width: 12)
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Flexible(flex: 2, child: SizedBox(height: 200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text('Keterangan', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Kritik adalah ketaksetujuan orang, bukan karena memiliki kesalahan.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              child: TextField(
                controller: _detailController,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: Styles.inputDecorationForm(
                  context: context,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  placeholder: 'Masukan Keluhan Anda...', 
                  condition: _detailController.text.trim().isNotEmpty,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: widget.laporanList.map((item) {
                  return SizedBox(
                    width: 140,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            laporan = item['name'];
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        splashColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                        highlightColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                        child: LaporanCard(
                          key: item['name'] == laporan ? selectedKey : null,
                          item: item,
                          isSelected: item['name'] == laporan,
                          pushReportPage: null, 
                          laporanList: widget.laporanList, 
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(34, 24, 34, 0),
                child: ButtonReport(
                  isVisible: true, 
                  enable: _detailController.text.trim().isNotEmpty, 
                  onPressed: () {}
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}

class ButtonReport extends StatelessWidget {
const ButtonReport(
  {
    super.key,
    required this.isVisible,
    required this.enable,
    required this.onPressed
  }
);

final bool isVisible;
final bool enable;
final Function onPressed;

@override
Widget build(BuildContext context) {
  return Visibility(
    visible: isVisible,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kembali')
        ),
        ElevatedButton(
          onPressed: enable ? () => onPressed() : null,
          style: Styles.buttonForm(context: context).copyWith(visualDensity: const VisualDensity(vertical: 1, horizontal: 2)),
          child: const Text('Kirim')
        ),
      ],
    ),
  );
}
}