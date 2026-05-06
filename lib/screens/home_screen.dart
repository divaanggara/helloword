import 'package:flutter/material.dart';
import 'data_menu.dart';
import 'cart_screen.dart';
import 'detail_screen.dart';
import 'riwayat_screen.dart';
import 'delivery_screen.dart';
import 'promo_screen.dart';
import 'help_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> searchResult = [];
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); 
  int _selectedIndex = 0;
  
  // DAFTAR FAVORIT SEDERHANA
  List<Map<String, String>> favoriteMenus = [];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Fungsi Tambah Keranjang
  void tambahKeKeranjang(Map<String, String> item) {
    setState(() {
      int index = keranjangBelanja.indexWhere((element) => element['name'] == item['name']);
      
      if (index != -1) {
        keranjangBelanja[index]['qty'] = (keranjangBelanja[index]['qty'] as int) + 1;
      } else {
        keranjangBelanja.add({
          'name': item['name'],
          'price': item['price'],
          'img': item['img'],
          'qty': 1, 
        });
      }
    });
  }

  // FUNGSI FAVORIT SEDERHANA
  void toggleFavorite(Map<String, String> item) {
    setState(() {
      // Cek apakah sudah ada di favorit
      bool sudahFavorit = false;
      for (var menu in favoriteMenus) {
        if (menu['name'] == item['name']) {
          sudahFavorit = true;
          break;
        }
      }
      
      if (sudahFavorit) {
        // Hapus dari favorit
        favoriteMenus.removeWhere((menu) => menu['name'] == item['name']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['name']} dihapus dari favorit'),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Tambah ke favorit
        favoriteMenus.add({
          'name': item['name']!,
          'price': item['price']!,
          'img': item['img']!,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['name']} ditambahkan ke favorit'),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  // Cek apakah item sudah favorit
  bool isFavorite(Map<String, String> item) {
    for (var menu in favoriteMenus) {
      if (menu['name'] == item['name']) {
        return true;
      }
    }
    return false;
  }

  void _runSearch(String query) {
    List<Map<String, String>> allProducts = [...dataMakanan, ...dataMinuman, ...dataKue, ...dataCemilan];

    if (query.isEmpty) {
      setState(() => isSearching = false);
    } else {
      setState(() {
        isSearching = true;
        searchResult = allProducts
            .where((item) => item['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _filterByCategory(String title, List<Map<String, String>> items) {
    setState(() {
      isSearching = true;
      searchResult = items;
      _searchController.text = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> allFavoriteMenus = [...dataMakanan, ...dataMinuman];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        toolbarHeight: 70,
        title: (_selectedIndex == 0 || _selectedIndex == 1)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lokasi Anda', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                      SizedBox(width: 4),
                      Text('Jl. Merdeka No. 10', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                      Icon(Icons.keyboard_arrow_down, color: Colors.orange, size: 18),
                    ],
                  )
                ],
              )
            : Text(_selectedIndex == 3 ? 'Menu Favorit' : 'Akun Saya', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: Colors.black87), onPressed: () {}),
          const SizedBox(width: 10),
        ],
      ),
      
      body: (_selectedIndex == 0 || _selectedIndex == 1)
          ? SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchBox(),
                  isSearching
                      ? _buildSearchResultSection()
                      : Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildCategoryIcons(),
                            const SizedBox(height: 25),
                            _buildFavoriteMenuSection("Menu Favorit", allFavoriteMenus),
                            const SizedBox(height: 20),
                            _buildPromoBanner(),
                            const SizedBox(height: 25),
                            _buildFeaturesSection(),
                          ],
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            )
          : _selectedIndex == 3 
              ? _buildFavoriteScreen() 
              : ProfileScreen(username: widget.username),

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode, 
          onChanged: _runSearch,
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: Colors.orange),
            hintText: 'Mau makan apa hari ini?',
            suffixIcon: isSearching ? IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: () => setState(() { isSearching = false; _searchController.clear(); })) : const Icon(Icons.qr_code, color: Colors.orangeAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcons() {
    List<Map<String, String>> allProducts = [...dataMakanan, ...dataMinuman, ...dataKue, ...dataCemilan];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconColumn(Icons.fastfood, "Makanan", Colors.orange.shade100, Colors.orange.shade800, () => _filterByCategory("Makanan", dataMakanan)),
          _buildIconColumn(Icons.local_drink, "Minuman", Colors.blue.shade100, Colors.blue.shade700, () => _filterByCategory("Minuman", dataMinuman)),
          _buildIconColumn(Icons.cake, "Dessert", Colors.pink.shade100, Colors.pink.shade600, () => _filterByCategory("Dessert", dataKue)),
          _buildIconColumn(Icons.restaurant, "Cemilan", Colors.green.shade100, Colors.green.shade700, () => _filterByCategory("Cemilan", dataCemilan)),
          _buildIconColumn(Icons.apps, "Semua", Colors.purple.shade100, Colors.purple.shade600, () => _filterByCategory("Semua Menu", allProducts)),
        ],
      ),
    );
  }

  Widget _buildIconColumn(IconData icon, String label, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 24)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))
        ],
      ),
    );
  }

  Widget _buildFavoriteMenuSection(String title, List<Map<String, String>> items) {
    List<Map<String, String>> menuUnggulan = items.take(5).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => _filterByCategory(title, items),
                child: const Row(children: [Text("Lihat semua", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)), Icon(Icons.chevron_right, color: Colors.orange, size: 18)]),
              ),
            ],
          ),
        ),
        SizedBox(height: 240, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 20), itemCount: menuUnggulan.length, itemBuilder: (context, index) => _buildItemCardColored(menuUnggulan[index]))),
      ],
    );
  }

  Widget _buildItemCardColored(Map<String, String> item) {
    bool isFav = isFavorite(item);
    
    return Container(
      width: 160, margin: const EdgeInsets.only(right: 15, bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(item: item))),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Container(
                    height: 120, width: double.infinity, color: Colors.orange.shade50,
                    child: item['img']!.startsWith('assets/') ? Image.asset(item['img']!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.fastfood, color: Colors.orange, size: 50)) : Image.network(item['img']!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.fastfood, color: Colors.orange, size: 50)),
                  ),
                ),
              ),
              // TOMBOL FAVORIT
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => toggleFavorite(item),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.grey,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: const [Icon(Icons.star, color: Colors.amber, size: 14), SizedBox(width: 4), Text("4.8 • 1,2 km", style: TextStyle(color: Colors.grey, fontSize: 11))]),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['price']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    GestureDetector(
                      onTap: () {
                        tambahKeKeranjang(item);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item['name']} ditambahkan"), duration: const Duration(milliseconds: 500), backgroundColor: Colors.orange));
                      },
                      child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, size: 16, color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.deepOrange.shade400]), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Diskon Spesial", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const Text("Up to 30%", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PromoScreen())), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.deepOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text("Lihat Promo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
                ],
              ),
            ),
            const Expanded(flex: 1, child: Icon(Icons.shopping_cart, size: 80, color: Colors.white54))
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Fitur", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeatureIcon(Icons.motorcycle, "Antar\nMakanan", Colors.orange.shade50, Colors.orange, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryScreen()));
              }),
              _buildFeatureIcon(Icons.local_offer, "Promo", Colors.red.shade50, Colors.red, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PromoScreen()));
              }),
              _buildFeatureIcon(Icons.star, "Favorit", Colors.amber.shade50, Colors.amber.shade700, () => setState(() => _selectedIndex = 3)),
              _buildFeatureIcon(Icons.receipt, "Pesanan", Colors.blue.shade50, Colors.blue, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())).then((_) => setState(() {}));
              }),
              _buildFeatureIcon(Icons.headset, "Bantuan", Colors.teal.shade50, Colors.teal, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: iconColor)),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))
        ],
      ),
    );
  }

  Widget _buildSearchResultSection() {
    return searchResult.isEmpty
        ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Menu tidak ditemukan...")))
        : GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 15, mainAxisSpacing: 15), itemCount: searchResult.length, itemBuilder: (context, index) => _buildItemCardColored(searchResult[index]));
  }

  // HALAMAN FAVORIT
  Widget _buildFavoriteScreen() {
    if (favoriteMenus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("Belum ada menu favorit", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Tekan ikon ♡ pada menu untuk menambah favorit", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ]
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        childAspectRatio: 0.65, 
        crossAxisSpacing: 15, 
        mainAxisSpacing: 15
      ),
      itemCount: favoriteMenus.length,
      itemBuilder: (context, index) {
        final item = favoriteMenus[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Container(
                      height: 120, width: double.infinity, color: Colors.orange.shade50,
                      child: item['img']!.startsWith('assets/') 
                        ? Image.asset(item['img']!, fit: BoxFit.cover) 
                        : Image.network(item['img']!, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => toggleFavorite(item),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite, color: Colors.red, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(item['price']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        tambahKeKeranjang(item);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item['name']} ditambahkan ke keranjang"), duration: const Duration(milliseconds: 500), backgroundColor: Colors.orange));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, currentIndex: _selectedIndex, selectedItemColor: Colors.orange, unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())).then((_) => setState(() {}));
        } else if (index == 1) {
          setState(() { _selectedIndex = 1; isSearching = true; }); _searchFocusNode.requestFocus();
        } else {
          setState(() { _selectedIndex = index; isSearching = false; _searchController.clear(); });
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"), 
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Cari"), 
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Pesanan"), 
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorit"), 
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(decoration: BoxDecoration(color: Colors.orange), child: Text('Menu Utama', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
          ListTile(leading: const Icon(Icons.home, color: Colors.blue), title: const Text('Home'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.history, color: Colors.orange), title: const Text('Riwayat Pesanan'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatScreen())); }),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Keluar'), onTap: () => Navigator.of(context).popUntil((route) => route.isFirst)),
        ],
      ),
    );
  }
}