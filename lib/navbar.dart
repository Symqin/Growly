import 'package:flutter/material.dart';
import 'package:growly/screen/dashboard_screen.dart';
import 'package:growly/screen/account_page.dart';
import 'package:growly/screen/statistik_screen.dart';
// optional

class BottomNavApp extends StatefulWidget {
  const BottomNavApp({super.key});

  @override
  State<BottomNavApp> createState() => _BottomNavAppState();
}

class _BottomNavAppState extends State<BottomNavApp> {
  int _selectedIndex = 0;

  // Pastikan semua widget di sini terdefinisi dan TIDAK memiliki Scaffold ganda
  final List<Widget> _pages = [
    const DashboardScreen(), // index 0 - Home
    const StatisticsScreen(),
    const AccountPage(), // jika mau Account sebagai tab, tambahkan satu lagi dan sesuaikan items
    // index 1 - Statistics
  ];

  void _navigateBottomBar(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // contoh: tampilkan appBar hanya untuk hom

      // pake IndexedStack supaya state tiap halaman dipertahankan
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
