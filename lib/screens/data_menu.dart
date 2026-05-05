// Keranjang Belanja
List<Map<String, dynamic>> isiKeranjang = [];

void tambahKeKeranjang(Map<String, dynamic> item) {
  int index = isiKeranjang.indexWhere((element) => element['name'] == item['name']);
  if (index != -1) {
    isiKeranjang[index]['qty']++;
  } else {
    isiKeranjang.add({
      "name": item['name'],
      "price": item['price'],
      "img": item['img'],
      "qty": 1,
    });
  }
}

// --- MAKANAN UTAMA (20 Produk) ---
List<Map<String, String>> dataMakanan = [
  {"name": "Mie Ayam Jamur", "price": "Rp 15.000", "img": "assets/images/mie_ayam.jpg"},
  {"name": "Nasi Goreng Spesial", "price": "Rp 20.000", "img": "assets/images/nasi_goreng.jpg"},
  {"name": "Ayam Bakar Madu", "price": "Rp 25.000", "img": "assets/images/ayam_bakar.jpg"},
  {"name": "Sate Ayam Madura", "price": "Rp 18.000", "img": "assets/images/sate_ayam.jpg"},
  {"name": "Bakso Mercon", "price": "Rp 15.000", "img": "assets/images/bakso.jpg"},
  {"name": "Ikan Bakar Nila", "price": "Rp 30.000", "img": "assets/images/ikan_bakar.jpg"},
  {"name": "Rendang Sapi", "price": "Rp 35.000", "img": "assets/images/rendang.jpg"},
  {"name": "Soto Ayam Lamongan", "price": "Rp 15.000", "img": "assets/images/soto.jpg"},
  {"name": "Gado-Gado Betawi", "price": "Rp 15.000", "img": "assets/images/gado_gado.jpg"},
  {"name": "Bebek Goreng Kremes", "price": "Rp 32.000", "img": "assets/images/bebek_goreng.jpg"},
  {"name": "Mie Goreng Jawa", "price": "Rp 15.000", "img": "assets/images/mie_goreng.jpg"},
  {"name": "Nasi Uduk Komplit", "price": "Rp 18.000", "img": "assets/images/nasi_uduk.jpg"},
  {"name": "Gulai Kambing", "price": "Rp 35.000", "img": "assets/images/gulai_kambing.jpg"},
  {"name": "Rawon Setan", "price": "Rp 30.000", "img": "assets/images/rawon.jpg"},
  {"name": "Pempek Kapal Selam", "price": "Rp 20.000", "img": "assets/images/pempek.jpg"},
  {"name": "Iga Bakar", "price": "Rp 45.000", "img": "assets/images/iga_bakar.jpg"},
  {"name": "Nasi Kuning", "price": "Rp 15.000", "img": "assets/images/nasi_kuning.jpg"},
  {"name": "Ayam Geprek Level 5", "price": "Rp 15.000", "img": "assets/images/ayam_geprek.jpg"},
  {"name": "Capcay Seafood", "price": "Rp 20.000", "img": "assets/images/Capcay Seafood.jpg"},
  {"name": "Sapo Tahu", "price": "Rp 22.000", "img": "assets/images/sapo_tahu.jpg"},
];

// --- MINUMAN SEGAR (20 Produk) ---
List<Map<String, String>> dataMinuman = [
  {"name": "Es Teh Manis", "price": "Rp 5.000", "img": "assets/images/es_teh.jpg"},
  {"name": "Jus Alpukat", "price": "Rp 12.000", "img": "assets/images/jus_alpukat.jpg"},
  {"name": "Es Jeruk Peras", "price": "Rp 8.000", "img": "assets/images/es_jeruk.jpg"},
  {"name": "Kopi Susu Gula Aren", "price": "Rp 15.000", "img": "assets/images/kopi_susu.jpg"},
  {"name": "Matcha Latte", "price": "Rp 18.000", "img": "assets/images/matcha.jpg"},
  {"name": "Es Kelapa Muda", "price": "Rp 10.000", "img": "assets/images/es_kelapa.jpg"},
  {"name": "Thai Tea Ice", "price": "Rp 10.000", "img": "assets/images/thai_tea.jpg"},
  {"name": "Es Campur", "price": "Rp 15.000", "img": "assets/images/es_campur.jpg"},
  {"name": "Es Teler", "price": "Rp 15.000", "img": "assets/images/es_teler.jpg"},
  {"name": "Jus Mangga", "price": "Rp 12.000", "img": "assets/images/jus_mangga.jpg"},
  {"name": "Jus Strawberry", "price": "Rp 12.000", "img": "assets/images/jus_strawberry.jpg"},
  {"name": "Lemon Tea", "price": "Rp 10.000", "img": "assets/images/lemon_tea.jpg"},
  {"name": "Soda Gembira", "price": "Rp 15.000", "img": "assets/images/soda_gembira.jpg"},
  {"name": "Milo Dinosaur", "price": "Rp 12.000", "img": "assets/images/milo.jpg"},
  {"name": "Cappuccino Ice", "price": "Rp 15.000", "img": "assets/images/Cappuccino Ice.jpg"},
  {"name": "Es Cincau Hijau", "price": "Rp 8.000", "img": "assets/images/es_cincau.jpg"},
  {"name": "Es Doger", "price": "Rp 10.000", "img": "assets/images/es_doger.jpg"},
  {"name": "Es Pisang Ijo", "price": "Rp 15.000", "img": "assets/images/es_pisang_ijo.jpg"},
  {"name": "Blue Ocean Soda", "price": "Rp 18.000", "img": "assets/images/blue_ocean.jpg"},
  {"name": "Wedang Jahe", "price": "Rp 8.000", "img": "assets/images/wedang_jahe.jpg"},
];

// --- KUE & DESSERT (20 Produk) ---
List<Map<String, String>> dataKue = [
  {"name": "Brownies Cokelat", "price": "Rp 25.000", "img": "assets/images/brownies.jpg"},
  {"name": "Cheesecake", "price": "Rp 30.000", "img": "assets/images/cheesecake.jpg"},
  {"name": "Donat Glaze", "price": "Rp 8.000", "img": "assets/images/donat.jpg"},
  {"name": "Pudding Mangga", "price": "Rp 12.000", "img": "assets/images/pudding.jpg"},
  {"name": "Red Velvet Cake", "price": "Rp 28.000", "img": "assets/images/red_velvet.jpg"},
  {"name": "Tiramisu", "price": "Rp 30.000", "img": "assets/images/tiramisu.jpg"},
  {"name": "Macaron Pelangi", "price": "Rp 20.000", "img": "assets/images/macaron.jpg"},
  {"name": "Cupcake Vanila", "price": "Rp 15.000", "img": "assets/images/cupcake.jpg"},
  {"name": "Kue Lumpur", "price": "Rp 5.000", "img": "assets/images/kue_lumpur.jpg"},
  {"name": "Lapis Legit", "price": "Rp 10.000", "img": "assets/images/lapis_legit.jpg"},
  {"name": "Klepon", "price": "Rp 5.000", "img": "assets/images/klepon.jpg"},
  {"name": "Onde-Onde", "price": "Rp 5.000", "img": "assets/images/onde_onde.jpg"},
  {"name": "Bika Ambon", "price": "Rp 10.000", "img": "assets/images/bika_ambon.jpg"},
  {"name": "Kue Sus", "price": "Rp 7.000", "img": "assets/images/kue_sus.jpg"},
  {"name": "Martabak Manis", "price": "Rp 30.000", "img": "assets/images/martabak.jpg"},
  {"name": "Pancake Strawberry", "price": "Rp 20.000", "img": "assets/images/pancake.jpg"},
  {"name": "Waffle Ice Cream", "price": "Rp 25.000", "img": "assets/images/waffle.jpg"},
  {"name": "Mochi Jepang", "price": "Rp 15.000", "img": "assets/images/mochi.jpg"},
  {"name": "Banana Split", "price": "Rp 25.000", "img": "assets/images/banana_split.jpg"},
  {"name": "Apple Pie", "price": "Rp 22.000", "img": "assets/images/apple_pie.jpg"},
];

// --- CEMILAN GURIH (20 Produk) ---
List<Map<String, String>> dataCemilan = [
  {"name": "Kentang Goreng", "price": "Rp 10.000", "img": "assets/images/kentang.jpg"},
  {"name": "Cireng Bumbu Rujak", "price": "Rp 12.000", "img": "assets/images/cireng.jpg"},
  {"name": "Pisang Goreng Pasir", "price": "Rp 10.000", "img": "assets/images/pisang_goreng.jpg"},
  {"name": "Tahu Bakso", "price": "Rp 15.000", "img": "assets/images/tahu_bakso.jpg"},
  {"name": "Dimsum Ayam", "price": "Rp 15.000", "img": "assets/images/dimsum.jpg"},
  {"name": "Roti Bakar", "price": "Rp 15.000", "img": "assets/images/roti_bakar.jpg"},
  {"name": "Singkong Keju", "price": "Rp 12.000", "img": "assets/images/singkong.jpg"},
  {"name": "Otak-Otak Bakar", "price": "Rp 10.000", "img": "assets/images/otak_otak.jpg"},
  {"name": "Batagor Bandung", "price": "Rp 15.000", "img": "assets/images/batagor.jpg"},
  {"name": "Somay Ikan", "price": "Rp 15.000", "img": "assets/images/siomay.jpg"},
  {"name": "Bakwan Jagung", "price": "Rp 5.000", "img": "assets/images/bakwan.jpg"},
  {"name": "Martabak Telur", "price": "Rp 25.000", "img": "assets/images/martabak_telur.jpg"},
  {"name": "Onion Rings", "price": "Rp 15.000", "img": "assets/images/onion_rings.jpg"},
  {"name": "Nugget Ayam", "price": "Rp 15.000", "img": "assets/images/nugget.jpg"},
  {"name": "Sosis Bakar XL", "price": "Rp 15.000", "img": "assets/images/sosis.jpg"},
  {"name": "Nachos Cheese", "price": "Rp 20.000", "img": "assets/images/nachos.jpg"},
  {"name": "Risol Mayo", "price": "Rp 8.000", "img": "assets/images/risol.jpg"},
  {"name": "Lumpia Semarang", "price": "Rp 10.000", "img": "assets/images/lumpia.jpg"},
  {"name": "Kebab Mini", "price": "Rp 12.000", "img": "assets/images/kebab.jpg"},
  {"name": "Jamur Crispy", "price": "Rp 10.000", "img": "assets/images/jamur_crispy.jpg"},
];

List<Map<String, dynamic>> riwayatPesanan = [];
List<Map<String, dynamic>> keranjangBelanja = [];
double diskonAktif = 0.0; 
String namaPromoAktif = "";