import 'package:flutter/material.dart';

class ItemDescription{

  // FIXME: USE STRING.CONTAINS GETTER
  static String getImage(String value) {
    String string = value.toUpperCase().replaceAll('INDOSTAR', '').replaceAll('ECO', '').trim();

    switch (string) {
      case 'IMPERIAL':
        return 'assets/Indostar Board Imperial.png';
      case 'MATRIC':
        return 'assets/Indostar Board Matric.png';
      case 'SQUARE':
        return 'assets/Indostar Board Square.png';
      case 'PLANK POLOS':
        return 'assets/Indostar Plank 1.png';
      case 'PLANK MOTIF':
        return 'assets/Indostar Plank Texture.png';
      case 'BES':
        return 'assets/Indostar Bes.png';
      default:
        return '';
    }
  }

  static String getLogo(String value) {
    if (value.contains('ECO')) {
      String string = value.toUpperCase().replaceAll('INDOSTAR', '').replaceAll('ECO', '').trim();
      switch (string) {
        case 'IMPERIAL':
          return 'assets/Logo Merk ECO Board.png';
        case 'MATRIC':
          return 'assets/Logo Merk ECO Board.png';
        case 'SQUARE':
          return 'assets/Logo Merk ECO Board.png';
        case 'PLANK POLOS':
          return 'assets/Logo ECOplank.png';
        case 'PLANK MOTIF':
          return 'assets/Logo ECOplank.png';
        case 'BES':
          return 'assets/Logo ECObes.png';
        default:
          return '';
      }
    } else {
      String string = value.toUpperCase().replaceAll('INDOSTAR', '').replaceAll('ECO', '').trim();
      switch (string) {
        case 'IMPERIAL':
          return 'assets/INDOSTAR LOGO POST.png';
        case 'MATRIC':
          return 'assets/INDOSTAR LOGO POST.png';
        case 'SQUARE':
          return 'assets/INDOSTAR LOGO POST.png';
        case 'PLANK POLOS':
          return 'assets/Logo Indostar Plank.png';
        case 'PLANK MOTIF':
          return 'assets/Logo Indostar Plank.png';
        case 'BES':
          return 'assets/Logo IndostarBes.png';
        default:
          return '';
      }
    }
  }

  static List getDiff(String value) {
    String string = value.toUpperCase().replaceAll('INDOSTAR', '').replaceAll('ECO', '').trim();
    switch (string) {
      case 'IMPERIAL':
        return ['Tebal'];
      case 'MATRIC':
        return ['Tebal'];
      case 'SQUARE':
        return ['Panjang'];
      case 'PLANK POLOS':
        return ['Panjang', 'Lebar'];
      case 'PLANK MOTIF':
        return ['Panjang', 'Lebar'];
      case 'BES':
        return ['Panjang'];
      default:
        return [];
    }
  }

  static String getDescription(String value) {
    String string = value.toUpperCase().replaceAll('INDOSTAR', '').replaceAll('ECO', '').trim();
    switch (string) {
      case 'IMPERIAL':
        return imperial;
      case 'MATRIC':
        return matric;
      case 'SQUARE':
        return square;
      case 'PLANK POLOS':
        return plank;
      case 'PLANK MOTIF':
        return plankTexture;
      case 'BES':
        return indostarbes14;
      default:
        return '';
    }
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
}