import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/functions/file_pickers.dart';
import 'package:google_auth/functions/push.dart';
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
  List<PlatformFile> fileList = List.empty(growable: true);
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

  void filterFiles() {
    pickFiles().then((value) {
      for (var file in value) {
        if (file != null && !fileList.contains(file)) {

          if (fileList.isNotEmpty) {
            fileList.add(file);
          } else {
            fileList.add(file);
          }
        }
      }
    }).whenComplete(() => setState(() {}));
  }

  String setLaporan(String laporan) {
    switch (laporan) {
      case 'Harga':
        return 'Price';
      case 'Kualitas':
        return 'Quality';
      case 'Pelayanan':
        return 'Service';
      case 'Purna Jual':
        return 'After Sales';
      default:
        return laporan;
    }
  }

  void sendReport() {
    SQL.insert(
      api: 'osfb',
      item: UserReport(
        id_osfb: null,
        document_date: DateNowSQL,
        id_ousr: currentUser['id_ousr'], 
        remarks: currentUser['user_name']
      ).toMap()
    ).then((value) {
      if (value.isNotEmpty) { 
        SQL.insert(
          api: 'sfb1',
          item: UserReport1(
            id_sfb1: null, 
            id_osfb: value['id_osfb'].toString(), 
            type_feed: setLaporan(laporan), 
            description: _detailController.text
          ).toMap(), 
        ).then((value) {
          if (fileList.isNotEmpty) {
            for (var file in fileList) { 
              SQL.insertMultiPart(
                api: 'sfb2',
                filePath: file.path!,
                item: UserReport2(
                  id_sfb2: null, 
                  id_osfb: value['id_osfb'].toString(), 
                  type: setLaporan(laporan),
                  file_name: file.name, 
                  file_type: file.extension!, 
                ).toMap(), 
              );
            }
          }
        });
      }
    }).whenComplete(() {
      pushDashboard(context, currentPage: 1);
      showSnackBar(context, snackBarAuth(context: context, content: 'Terima Kasih atas Umpan Balik Anda.'));
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
            Image(image: AssetImage('assets/logo IBM p C.png'), height: 26),
            SizedBox(width: 12)
          ],
        ),
        floatingActionButton: AnimatedSlide(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          offset: _detailController.text.trim().isNotEmpty && laporan.isNotEmpty ? const Offset(0, 0) : const Offset(0, 20),
          child: FloatingActionButton.extended(
            onPressed: _detailController.text.trim().isNotEmpty && laporan.isNotEmpty ? () => sendReport() : null,
            highlightElevation: 1,
            elevation: 4,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            label: const Text('Kirim'),
            icon: const Icon(Icons.forward_to_inbox),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: isLoading 
                  ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2))
                    : _detailController.text.isEmpty
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Image.asset('assets/report_page.png', height: 120)),
                    )
                    : const SenderHeader(),
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
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 16, 30, 6),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      TextField(
                        controller: _detailController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
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
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: Styles.inputDecorationForm(
                          context: context,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          placeholder: 'Masukan Keluhan Anda...',
                          condition: _detailController.text.trim().isNotEmpty,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => filterFiles(), 
                            style: ButtonStyle(
                              textStyle: MaterialStatePropertyAll(
                                Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 0)
                              )
                            ),
                            icon: const Icon(Icons.publish, size: 22), 
                            label: const Text('Upload Foto')
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (fileList.isNotEmpty) SizedBox(
                height: fileList.isNotEmpty ? 46 : null,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: fileList.map((file) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 140,
                      child: Chip(
                        onDeleted: () => setState(() {
                          fileList.removeWhere((element) => element.name == file.name);
                        }),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.7)),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        deleteIconColor: Theme.of(context).colorScheme.tertiary,
                        avatar: const Icon(Icons.file_upload_outlined),
                        label: Text(file.name),
                        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 0),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: laporanList.isNotEmpty ? 120 : null,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(34, 12, 34, 12),
                child: ButtonReport(
                  isVisible: MediaQuery.of(context).viewInsets.bottom != 0 ? false : true,
                  enable: _detailController.text.trim().isNotEmpty && laporan.isNotEmpty,
                  onPressed: sendReport
                ),
              )
            ],
          ),
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
          child: Text('Deskripsi', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.secondary)),
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
                  Text(currentUser['user_name'], 
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 2
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('PT. Indostar', 
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1
                      )
                    ),
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
        ],
      ),
    );
  }
}