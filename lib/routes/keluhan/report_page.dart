import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/routes/keluhan/dashboard.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/widgets/snackbar.dart';

import '../../functions/sql_client.dart';
import '../../styles/theme.dart';

class LaporanRoute extends StatefulWidget {
  const LaporanRoute({super.key, this.laporan, required this.laporanList});

  final List<Map> laporanList;
  final Map? laporan;

  @override
  State<LaporanRoute> createState() => _LaporanRouteState();
}

class _LaporanRouteState extends State<LaporanRoute> {
  late TextEditingController _detailController;
  late String laporan;
  List<Map> laporanList = List.empty(growable: true);
  List<Map> laporanList_ = List.empty(growable: true);
  late ScrollController _scrollController;
  GlobalKey selectedKey = GlobalKey();
  bool empty = true;

  late bool isLoading;

  @override
  void initState() {
    _detailController = TextEditingController();
    _scrollController = ScrollController();
    laporanList_.addAll(widget.laporanList);

    laporanList_.remove(widget.laporan);
    if(widget.laporan != null) { 
      laporanList.add(widget.laporan!);
      laporan = widget.laporan?['name'];
    } else {
      laporan = '';
    }
    laporanList.addAll(laporanList_);

    isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    _detailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void setLoading() {
    if(empty == true) {
      empty = false;
      isLoading = true;
      Timer(const Duration(seconds: 1), () { 
        setState(() => isLoading = false);
      });
    }
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - kToolbarHeight ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        child: SizedBox(
                          height: isLoading ? 120 : null,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: isLoading 
                              ? Flexible(flex: 2, child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)))
                                : _detailController.text.isEmpty
                                ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 32),
                                  child: Center(child: Image.asset('assets/report_page.png', height: 160)),
                                )
                                : const SenderHeader()
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 34),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Keterangan', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text('Kritik adalah ketaksetujuan orang, bukan karena memiliki kesalahan.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                          child: TextField(
                            controller: _detailController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 9,
                            onChanged: (value) {
                              setState(() {
                                if (_detailController.text.isEmpty) {
                                  empty = true;
                                } 
                                if (laporan.isNotEmpty && value.isNotEmpty) {
                                  setLoading();
                                } 
                              });
                            },
                            decoration: Styles.inputDecorationForm(
                              context: context,
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              placeholder: 'Masukan Keluhan Anda...',
                              suffixIcon: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {}, 
                                    style: ButtonStyle(
                                      textStyle: MaterialStatePropertyAll(
                                        Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 0)
                                      )
                                    ),
                                    icon: const Icon(Icons.publish), 
                                    label: const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text('Upload Foto'),
                                    )
                                  ),
                                ],
                              ),
                              condition: _detailController.text.trim().isNotEmpty,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: laporanList.map((item) {
                            return SizedBox(
                              width: 150,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (laporan == item['name']) { 
                                        laporan = ''; 
                                      } else { 
                                        laporan = item['name']; 
                                      }
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
                                    laporanList: laporanList, 
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(34, 24, 34, 0),
                          child: ButtonReport(
                            isVisible: MediaQuery.of(context).viewInsets.bottom != 0 ? false : true,
                            enable: _detailController.text.trim().isNotEmpty && laporan.isNotEmpty,
                            onPressed: () {}
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Themes.bottomFloatingBar(
              context: context,
              isVisible: MediaQuery.of(context).viewInsets.bottom != 0 ? true : false,
              child: ButtonReport(
                isVisible: MediaQuery.of(context).viewInsets.bottom != 0 ? true : false, 
                enable: _detailController.text.trim().isNotEmpty && laporan.isNotEmpty,
                onPressed: () {}
              ),
            ),
          ],
        )
      ),
    );
  }
}

class SenderHeader extends StatelessWidget {
  const SenderHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Flexible(
            child: Text('Deskripsi', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.secondary)),
          ),
        ),
        const Divider(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dari:'),
                  Text('Kepada:'),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(currentUser['user_name'], 
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 2
                      )
                    )
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('PT. Indostar', 
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1
                        )
                      ),
                    )
                  ),
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('62${currentUser['phone_number']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                  Text('(0341) 441111', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(currentUser['user_email'], style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                  Text('Jl. Rogonoto No.57B', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                ]
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tanggal Keluhan:'),
              Text(DateNow, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const Divider(height: 36),
      ],
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