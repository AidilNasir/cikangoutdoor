import '../models/gear_item.dart';

final List<GearItem> dummyGears = [
  GearItem(
    id: 'G01',
    name: 'Tenda Dome Arpenaz 4.1 Family',
    category: 'Tenda',
    pricePerDay: 50000,
    imageUrl: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=600',
    description:
        'Tenda kapasitas 4 orang dengan ruang kumpul (vestibule) yang luas. Menggunakan teknologi Fresh & Black yang mampu menahan panas matahari dan waterproof hingga 2000mm.',
    specifications: {
      'Kapasitas': '4 Orang Dewasa',
      'Material Flysheet': 'Polyester PU Coated 2000mm',
      'Frame': 'Fiberglass elastis kuat',
      'Berat': '9.8 kg',
      'Dimensi': '240 x 210 x 140 cm',
    },
  ),
  GearItem(
    id: 'G02',
    name: 'Carrier Deuter Aircontact 65+10L',
    category: 'Tas Carrier',
    pricePerDay: 40000,
    imageUrl: 'https://images.unsplash.com/photo-1622260614153-03223fb72052?w=600',
    description:
        'Carrier gunung premium berkapasitas besar dengan sistem sirkulasi udara Aircontact. Distribusi beban sangat seimbang pada pinggul sehingga nyaman untuk pendakian jarak jauh.',
    specifications: {
      'Kapasitas': '65 + 10 Liter',
      'Material': 'High-Density 330D Polyamide Ripstop',
      'Rain Cover': 'Sudah Termasuk',
      'Fitur': 'VariQuick System, Hip Belt Ergonomis',
    },
  ),
  GearItem(
    id: 'G03',
    name: 'Sleeping Bag Bulu Angsa Ultralight',
    category: 'Perlengkapan Tidur',
    pricePerDay: 25000,
    imageUrl: 'https://images.unsplash.com/photo-1541689592655-f5f52825a3b8?w=600',
    description:
        'Sleeping bag model mummy dengan isian bulu angsa (goose down). Sangat hangat untuk suhu dingin gunung ekstrim namun bisa dikompres hingga seukuran botol minum.',
    specifications: {
      'Comfort Temp': '8°C',
      'Limit Temp': '0°C',
      'Berat': '750 gram',
      'Insulasi': 'Goose Down 80/20 FP 650',
    },
  ),
  GearItem(
    id: 'G04',
    name: 'Kompor Portabel Windproof Camping',
    category: 'Peralatan Masak',
    pricePerDay: 15000,
    imageUrl: 'https://images.unsplash.com/photo-1510312305653-8ed496efae75?w=600',
    description:
        'Kompor lipat dengan pelindung angin model kelopak teratai yang dapat disesuaikan. Dilengkapi pemantik otomatis dan selang fleksibel untuk tabung gas kaleng butana.',
    specifications: {
      'Tipe Bahan Bakar': 'Gas Butana / Hicook',
      'Fitur': 'Windproof Baffle Lipat',
      'Pemantik': 'Piezoelektrik Otomatis',
      'Beban Maksimal': '5 kg',
    },
  ),
  GearItem(
    id: 'G05',
    name: 'Nesting Cooking Set DS-308 (4 in 1)',
    category: 'Peralatan Masak',
    pricePerDay: 20000,
    imageUrl: 'https://images.unsplash.com/photo-1525811902-f2342640856e?w=600',
    description:
        'Panci dan wajan susun serbaguna dari bahan anodized aluminium anti karat dan cepat menghantarkan panas. Pegangan dilapisi silikon tahan panas.',
    specifications: {
      'Kelengkapan': '2 Panci, 1 Wajan, 3 Mangkuk, Centong',
      'Bahan': 'Hard Anodized Aluminum',
      'Cocok Untuk': '3-4 Orang',
    },
  ),
  GearItem(
    id: 'G06',
    name: 'Lentera Tenda LED Solar & Rechargeable',
    category: 'Penerangan',
    pricePerDay: 10000,
    imageUrl: 'https://images.unsplash.com/photo-1517824806704-9040b037703b?w=600',
    description:
        'Lampu gantung serbaguna untuk tenda dan camp ground. Memiliki 3 mode kecerahan, bisa diisi ulang via kabel USB maupun tenaga surya (solar panel), dan berfungsi sebagai powerbank darurat.',
    specifications: {
      'Kapasitas Baterai': '3600 mAh',
      'Durasi Nyala': '8 - 14 Jam',
      'Fitur': 'Water Resistant IPX4, Hook Gantung',
    },
  ),
  GearItem(
    id: 'G07',
    name: 'Trekking Pole Ultralight Duralumin (Sepasang)',
    category: 'Aksesoris Gunung',
    pricePerDay: 15000,
    imageUrl: 'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?w=600',
    description:
        'Tongkat pendakian teleskopik 3 bagian berbahan duralumin 7075 yang ringan namun sangat kokoh. Membantu menjaga stabilitas dan mengurangi beban lutut saat naik/turun bukit.',
    specifications: {
      'Bahan': 'Duralumin Alloy 7075',
      'Panjang': '65 cm - 135 cm (Adjustable)',
      'Grip': 'Busa EVA Lembut & Tali Pergelangan',
    },
  ),
  GearItem(
    id: 'G08',
    name: 'Matras Foil Alumunium Double Layer',
    category: 'Perlengkapan Tidur',
    pricePerDay: 10000,
    imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=600',
    description:
        'Matras insulasi dengan lapisan aluminium ganda untuk memantulkan panas tubuh dan menangkal hawa dingin dari tanah secara maksimal. Ringan dan mudah digulung.',
    specifications: {
      'Ukuran': '200 x 150 cm',
      'Bahan': 'EVA Foam + Dual Aluminum Foil',
      'Ketebalan': '3 mm',
    },
  ),
];
