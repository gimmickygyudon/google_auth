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

  String defineLaporan(String laporan) {
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

  void setLaporan(String value) {
    setState(() {
      laporan = value;
    });
  }

  void sendReport() {
    showError() {
      showSnackBar(context, snackBarError(
        context: context,
        content: 'Gagal, Coba Beberapa Saat Lagi.',
        icon: Icons.info_outline)
      );
    }

    SQL.insert(
      api: 'osfb',
      item: UserReport(
        id_osfb: null,
        document_date: DateNowSQL(),
        id_ousr: currentUser['id_ousr'],
        remarks: currentUser['user_name']
      ).toMap()
    ).onError((error, stackTrace) {
      return Future.delayed(const Duration(seconds: 3), () {
        showError();

        return Future.error(error.toString());
      });

    }).then((value) {
      if (value.isNotEmpty) {
        SQL.insert(
          api: 'sfb1',
          item: UserReport1(
            id_sfb1: null,
            id_osfb: value['id_osfb'].toString(),
            type_feed: defineLaporan(laporan),
            description: _detailController.text
          ).toMap(),
        ).onError((error, stackTrace) {
          return Future.delayed(const Duration(seconds: 3), () {
            showError();

            return Future.error(error.toString());
          });
        }).then((value) {
          if (fileList.isNotEmpty) {
            for (var file in fileList) {
              SQL.insertMultiPart(
                api: 'sfb2',
                filePath: file.path!,
                item: UserReport2(
                  id_sfb2: null,
                  id_osfb: value['id_osfb'].toString(),
                  type: defineLaporan(laporan),
                  file_name: file.name,
                  file_type: file.extension!,
                ).toMap(),
              );
            }
          }
        }).onError((error, stackTrace) {
          return Future.delayed(const Duration(seconds: 3), () {
            showError();

            return Future.error(error.toString());
          });
        });
      }
    }).then((value) {
      pushDashboard(context, currentPage: 3);
      showSnackBar(context, snackBarComplete(context: context, content: 'Terima Kasih atas Umpan Balik Anda.'));
    }).whenComplete(() => setState(() => isLoading = false));
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
          title: const Text('Buat Keluhan'),
          centerTitle: true,
          actions: const [
            Image(image: AssetImage('assets/logo IBM p C.png'), height: 26),
            SizedBox(width: 12)
          ],
        ),
        floatingActionButton: AnimatedSlide(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          offset: _detailController.text.trim().length > 10 && laporan.isNotEmpty ? const Offset(0, 0) : const Offset(0, 20),
          child: FloatingActionButton.extended(
            onPressed: _detailController.text.trim().length > 10 && laporan.isNotEmpty && isLoading == false ? () {
              setState(() {
                isLoading = true;
                sendReport();
              });
            } : null,
            highlightElevation: 1,
            elevation: 4,
            backgroundColor: isLoading ? Theme.of(context).colorScheme.scrim : Theme.of(context).colorScheme.error.withBlue(100),
            foregroundColor: isLoading ? Theme.of(context).primaryColorLight :Theme.of(context).colorScheme.surface,
            label: isLoading ? const Text('Mengirim...') : const Text('Kirim'),
            icon: isLoading
            ? Transform.scale(scale: 0.7, child: CircularProgressIndicator(color: Theme.of(context).primaryColorLight, strokeWidth: 3))
            : const Icon(Icons.flag_circle),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Image.asset('assets/start_page.png', height: MediaQuery.of(context).size.height / 5)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: laporan.isEmpty ? CrossAxisAlignment.start : CrossAxisAlignment.start,
                  children: [
                    Text('Keluhan Tentang ', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      height: 0,
                      letterSpacing: 0
                    )),
                    Text(laporan, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 0,
                      letterSpacing: 0
                    )),
                    SizedBox(height: laporan.isEmpty ? 2 : 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6, top: 2),
                          child: laporan.isEmpty
                          ? Icon(Icons.info, size: 16, color: Theme.of(context).colorScheme.primary)
                          : Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.secondary),
                        ),
                        Flexible(
                          child: Text(laporan.isEmpty
                            ? 'Pilih keluhan apa yang akan anda laporkan.'
                            : 'Pastikan keluhan yang akan Anda kirim Jelas dan Mudah dimengerti.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: laporan.isEmpty ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.secondary,
                              letterSpacing: 0,
                            )
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: laporan.isEmpty ? 12 : 36),
              AnimatedScale(
                scale: laporan.isNotEmpty ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.ease,
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: laporan.isNotEmpty ? 210 : 0),
                  child: Visibility(
                    visible: laporan.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 6, 30, 6),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          TextField(
                            controller: _detailController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 8,
                            onChanged: (value) {
                              setState(() {
                                if (_detailController.text.trim().isEmpty) {
                                  empty = true;
                                }
                              });
                            },
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: Styles.inputDecorationForm(
                              context: context,
                              alignLabelWithHint: true,
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              hintText: 'Masukan Keluhan Anda Disini...',
                              placeholder: 'Deskripsi',
                              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              condition: _detailController.text.trim().isNotEmpty,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => filterFiles(),
                                  style: ButtonStyle(
                                    textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 0)),
                                    foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.secondary)
                                  ),
                                  icon: const Icon(Icons.file_upload_outlined, size: 22),
                                  label: const Text('Upload Foto')
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  height: laporan.isNotEmpty && fileList.isNotEmpty ? 46 : 0,
                  child: Visibility(
                    visible: laporan.isNotEmpty,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: fileList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 160,
                          child: Chip(
                            onDeleted: () => setState(() {
                              fileList.removeWhere((element) => element.name == fileList[index].name);
                            }),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide.none,
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            deleteIconColor: Theme.of(context).colorScheme.inverseSurface,
                            avatar: Icon(Icons.upload_file, color: Theme.of(context).colorScheme.inverseSurface),
                            label: Text(fileList[index].name),
                            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.inverseSurface,
                              letterSpacing: 0
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ),
              ),
              if (laporan.isNotEmpty) const SizedBox(height: 12),
              AnimatedSize(
                duration: const Duration(milliseconds: 600),
                curve: Curves.ease,
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  height: laporan.isNotEmpty ? 0 : 150,
                  width: double.infinity,
                  child: Visibility(
                    visible: laporan.isEmpty,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: laporanList.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 170,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (laporan == laporanList[index]['name']) {
                                    laporan = '';
                                  } else {
                                    laporan = laporanList[index]['name'];
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              splashColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                              highlightColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                              child: HeroMode(
                                enabled: laporanList[index]['name'] == laporan,
                                child: Hero(
                                  tag: laporanList[index]['name'],
                                  child: LaporanCard(
                                    key: laporanList[index]['name'] == laporan ? selectedKey : null,
                                    item: laporanList[index],
                                    isSelected: laporanList[index]['name'] == laporan,
                                    pushReportPage: null,
                                    laporanList: laporanList,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 12, 34, 12),
                child: ButtonReport(
                  isVisible: MediaQuery.of(context).viewInsets.bottom != 0 ? false : true,
                  enable: _detailController.text.trim().isNotEmpty && laporan.isNotEmpty,
                  laporan: laporan,
                  onPressed: setLaporan
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dari:'),
              Text(currentUser['user_name'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                )
              ),
              const SizedBox(height: 6),
              Text('62${currentUser['phone_number']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
              Text(currentUser['user_email'], style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
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
              Text(DateNow(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const Divider(height: 36),
      ],
    );
  }
}

class ButtonReport extends StatelessWidget {
  const ButtonReport({
    super.key,
    required this.isVisible,
    required this.enable,
    required this.onPressed, required this.laporan
  });

  final bool isVisible;
  final bool enable;
  final Function onPressed;
  final String laporan;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => laporan.isEmpty ? Navigator.pop(context) : onPressed(''),
            style: null ,
            label: Text(laporan.isEmpty ? 'Kembali' : 'Ubah Keluhan'),
            icon: laporan.isEmpty
            ? const Icon(Icons.arrow_back_rounded)
            : const Icon(Icons.arrow_upward)
          ),
        ],
      ),
    );
  }
}
