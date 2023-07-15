import 'package:flutter/material.dart';

class ItemDescription {

  static String getImage(String name) {
    if (name.contains('IMPERIAL')) return 'assets/Indostar Board Imperial.png';
    if (name.contains('MATRIC')) return 'assets/Indostar Board Matric.png';
    if (name.contains('SQUARE')) return 'assets/Indostar Board Square.png';
    if (name.contains('PLANK POLOS')) return 'assets/Indostar Plank 1.png';
    if (name.contains('PLANK MOTIF')) return 'assets/Indostar Plank Texture.png';
    if (name.contains('BES')) return 'assets/Indostar Bes.png';

    return 'assets/Indostar Board.png';
  }

  static String getLogo(String name) {
    if (name.contains('IMPERIAL')) return 'assets/INDOSTAR LOGO POST.png';
    if (name.contains('MATRIC')) 'assets/INDOSTAR LOGO POST.png';
    if (name.contains('SQUARE')) return 'assets/INDOSTAR LOGO POST.png';
    if (name.contains('PLANK POLOS')) return 'assets/Logo Indostar Plank.png';
    if (name.contains('PLANK MOTIF')) return 'assets/Logo Indostar Plank.png';
    if (name.contains('BES')) return 'assets/Logo IndostarBes.png';

    return 'assets/logo IBM p C.png';
  }

  static List getDiff(String name) {
    if (name.contains('IMPERIAL')) return ['Tebal'];
    if (name.contains('MATRIC')) return ['Tebal'];
    if (name.contains('SQUARE')) return ['Panjang'];
    if (name.contains('PLANK POLOS')) return ['Panjang', 'Lebar'];
    if (name.contains('PLANK MOTIF')) return ['Panjang', 'Lebar'];
    if (name.contains('BES')) return ['Panjang'];

    return [];
  }

  static String getDescription(String value) {
    if (value.contains('IMPERIAL')) return imperial;
    if (value.contains('MATRIC')) return matric;
    if (value.contains('SQUARE')) return square;
    if (value.contains('PLANK POLOS')) return plank;
    if (value.contains('PLANK MOTIF')) return plankTexture;
    if (value.contains('BES')) return indostarbes14;

    return error;
  }

  static const List<Map> recommenditems = [{
    'name': 'Indostar',
    'subitem': [
      {
        'name': 'Indostar Board',
        'img': 'assets/Indostar Board.png',
        'icon': 'assets/INDOSTAR LOGO POST.png',
        'type': [
          {
            'name': 'Board Imperial',
            'description': ItemDescription.imperial,
            'diff': ['Tebal']
          }, {
            'name': 'Board Matric',
            'description': ItemDescription.matric,
            'diff': ['Tebal']
          }, {
            'name': 'Board Square',
            'description': ItemDescription.square,
            'diff': ['Panjang']
          }
        ]
      }, {
        'name': 'Indostar Bes',
        'img': 'assets/Indostar Bes.png',
        'icon': 'assets/Logo IndostarBes.png',
        'type': [
          {
            'name': 'Gelombang 14',
            'description': ItemDescription.indostarbes14,
            'diff': ['Panjang']
          }, {
            'name': 'Gelombang 11',
            'description': ItemDescription.indostarbes11,
            'diff': ['Panjang']
          }
        ]
      },{
        'name': 'Indostar Plank',
        'img': 'assets/Indostar Plank.png',
        'icon': 'assets/Logo Indostar Plank.png',
        'type': [
          {
            'name': 'Plank',
            'description': ItemDescription.plank,
            'diff': ['Panjang', 'Lebar']
          }, {
            'name': 'Plank Texture',
            'description': ItemDescription.plankTexture,
            'diff': ['Panjang', 'Lebar']
          }
        ]
      },
    ],
    'img': 'assets/Logo Indostar.png',
    'bg': 'assets/background-1a.jpg',
    'color': Colors.blueGrey
  },
  {
    'name': 'ECO',
    'subitem': [
      {
        'name': 'ECO Board',
        'img': 'assets/Indostar Board.png',
        'icon': 'assets/Logo Merk ECO Board.png',
        'type': [
          {
            'name': 'Board Imperial',
            'description': ItemDescription.imperial,
            'diff': ['Tebal']
          }, {
            'name': 'Board Matric',
            'description': ItemDescription.matric,
            'diff': ['Tebal']
          }, {
            'name': 'Board Square',
            'description': ItemDescription.square,
            'diff': ['Panjang']
          }
        ]
      }, {
        'name': 'ECObes',
        'img': 'assets/Indostar Bes.png',
        'icon': 'assets/Logo ECObes.png',
        'type': [
          {
            'name': 'Gelombang 14',
            'description': ItemDescription.indostarbes14,
            'diff': ['Panjang']
          }, {
            'name': 'Gelombang 11',
            'description': ItemDescription.indostarbes11,
            'diff': ['Panjang']
          }
        ]
      }
    ],
    'img': 'assets/Logo Merk ECO.png',
    'bg': 'assets/background-3a.png',
    'color': Colors.lightGreen
  }];

  static const String imperial = 'Indostar Board Imperial sangat cocok digunakan sebagai plafon maupun partisi untuk bangunan dengan konsep menengah dan keatas, seperti kantor, rumah sakit, hotel dan sarana publik lainnya. dengan ketebalan 3.5 - 6 mm, Indostar Imperial dapat diaplikasikan dengan menggunakan rangka kayu atau hollow.';
  static const String matric = 'Indostar Board Matric sangat cocok untuk digunakan sebagai plafon maupun partisi untuk bangunan dengan konsep menengah, seperti kantor, rumah sakit, hotel, toko, dan sarana publik lainnya. Indostar Board Matric memiliki kekuatan, kelenturan dan dimensi yang stabil.';
  static const String square = 'Indostar Board Square cocok digunakan sebagai plafon untuk rumah dengan konsep sederhana. Dengan ketebalan 3 mm, Indostar square memiliki, kelenturan dan dimensi yang stabil. Selain untuk plafon, Square juga dapat diaplikasikan untuk aplikasi partisi sederhana.';
  static const String plank = 'Indostar Board Plank cocok digunakan sebagai list plank maupun sidding plank untuk rumah dengan konsep klasik dan berseni. Selain untuk list plank. Indostar Board Plank juga dapat diaplikasikan untuk plafon klasik';
  static const String plankTexture = 'Indostar Board Plank Texture cocok digunakan sebagai list plank maupun sidding plank untuk rumah dengan konsep klasik dan berseni. Indostar Board Plank Texture memiliki kekuatan, kelenturan dan dimensi yang stabil.';
  static const String indostarbes14 = 'Indostarbes adalah lembaran papan semen berstandar SNI yang berbentuk gelombang 14 simetris dengan kualitas produk yang kuat, stabil, presisi, tahan terhadap perubahan cuaca, dan mudah dalam pengaplikasiannya. sangat cocok untuk aplikasi atap bangunan rumah, selasar, garasi, teras, bangunan sarana publik, ataupun industri';
  static const String indostarbes11 = 'Indostarbes adalah lembaran papan semen berstandar SNI yang berbentuk gelombang 11 simetris dengan kualitas produk yang kuat, stabil, presisi, tahan terhadap perubahan cuaca, dan mudah dalam pengaplikasiannya. sangat cocok untuk aplikasi atap bangunan rumah, selasar, garasi, teras, bangunan sarana publik, ataupun industri';
  static const String error = 'Produk tidak memiliki keterangan';
}