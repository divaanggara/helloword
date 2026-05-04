import 'package:flutter/material.dart';
import 'data_menu.dart';
import 'cart_screen.dart';
import 'detail_screen.dart';
import 'riwayat_screen.dart'; 

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

  // FUNGSI CARI PRODUK
  void _runSearch(String query) {
    List<Map<String, String>> allProducts = [
      ...dataMakanan,
      ...dataMinuman,
      ...dataKue,
      ...dataCemilan
    ];

    if (query.isEmpty) {
      setState(() {
        isSearching = false;
      });
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        toolbarHeight: 90, // Tinggi AppBar diperbesar agar avatar pas
        title: Column(
          children: [
            // --- AVATAR USER DENGAN BORDER ---
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 2), // Warna & tebal border
              ),
              child: const CircleAvatar(
                radius: 16, 
                backgroundColor: Color(0xFFF0F0F0),
                child: Icon(Icons.person, color: Colors.grey, size: 20),
              ),
            ),
            // ---------------------------------
            const Text('Welcome back,', style: TextStyle(color: Colors.grey, fontSize: 11)),
            Text(widget.username.toUpperCase(), style: const TextStyle(color: Color(0xFF4A1C1C), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())).then((_) => setState(() {})),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBox(),
            
            // Tampilan Berubah Jika Sedang Mencari atau Klik 'Lihat Semua'
            isSearching 
              ? _buildSearchResultSection() 
              : Column(
                  children: [
                    _buildCategorySection("🍔 Makanan Utama", dataMakanan),
                    _buildCategorySection("🍹 Minuman Segar", dataMinuman),
                    _buildCategorySection("🍰 Kue & Dessert", dataKue),
                    _buildCategorySection("🍟 Cemilan Gurih", dataCemilan),
                  ],
                ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(15)),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _runSearch(value),
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: Colors.orange),
            hintText: 'Cari menu...',
            suffixIcon: isSearching ? IconButton(
              icon: const Icon(Icons.clear), 
              onPressed: () {
                _searchController.clear();
                setState(() => isSearching = false);
              }
            ) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Menampilkan: ${_searchController.text}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => setState(() {
                isSearching = false;
                _searchController.clear();
              }), child: const Text("Reset"))
            ],
          ),
        ),
        searchResult.isEmpty 
        ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Menu tidak ditemukan...")))
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              childAspectRatio: 0.65, 
              crossAxisSpacing: 15, 
              mainAxisSpacing: 15
            ),
            itemCount: searchResult.length,
            itemBuilder: (context, index) => _buildItemCard(searchResult[index]),
          ),
      ],
    );
  }

  Widget _buildCategorySection(String title, List<Map<String, String>> items) {
    List<Map<String, String>> menuUnggulan = items.take(5).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => _filterByCategory(title, items),
                child: const Text("Lihat Semua", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: menuUnggulan.length, 
            itemBuilder: (context, index) => _buildItemCard(menuUnggulan[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, String> item) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(item: item))),
              child: Hero(
                tag: item['name']!,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: item['img']!.startsWith('assets/') 
                    ? Image.asset(item['img']!, fit: BoxFit.cover, width: double.infinity, errorBuilder: (c, e, s) => const Icon(Icons.image))
                    : Image.network(item['img']!, fit: BoxFit.cover, width: double.infinity, errorBuilder: (c, e, s) => const Icon(Icons.image)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(item['price']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () {
                          tambahKeKeranjang(item);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item['name']} masuk keranjang"), duration: const Duration(milliseconds: 500)));
                        },
                        child: const Icon(Icons.add_shopping_cart, color: Colors.orange, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () {
                          tambahKeKeranjang(item);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())).then((_) => setState(() {}));
                        },
                        child: const Text("Beli", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange), 
            child: Text('Menu Utama', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
          ),
          ListTile(
            leading: const Icon(Icons.home), 
            title: const Text('Home'), 
            onTap: () => Navigator.pop(context)
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.orange), 
            title: const Text('Riwayat Pesanan'), 
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatScreen()));
            }
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red), 
            title: const Text('Keluar'), 
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst)
          ),
        ],
      ),
    );
  }
}