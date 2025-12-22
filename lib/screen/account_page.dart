import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:growly/auth/login_screen.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  // ===============================
  // UPDATE NAME
  // ===============================
  Future<void> _changeName() async {
    final controller = TextEditingController(text: user?.displayName ?? "");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ubah Nama"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nama baru"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              await user!.updateDisplayName(controller.text.trim());
              await user!.reload();

              setState(() {
                user = FirebaseAuth.instance.currentUser;
              });

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ===============================
  // UPDATE PHOTO (URL BASED)
  // ===============================
  Future<void> _changePhoto() async {
    final controller = TextEditingController(text: user?.photoURL ?? "");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ubah Foto"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "URL Foto (https://...)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              await user!.updatePhotoURL(controller.text.trim());
              await user!.reload();

              setState(() {
                user = FirebaseAuth.instance.currentUser;
              });

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ===============================
  // LOGOUT (EMAIL + GOOGLE)
  // ===============================
  Future<void> _logout(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // PROFILE
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.green,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),

              const SizedBox(height: 22),

              Text(
                (user?.displayName ?? "NAMA ANDA").toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                user?.email ?? "email@domain.com",
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 40),

              // UBAH NAMA
              _menuItem(
                icon: Icons.edit,
                text: "Ubah Nama",
                onTap: _changeName,
              ),

              const SizedBox(height: 16),

              // UBAH FOTO
              _menuItem(
                icon: Icons.image,
                text: "Ubah Foto",
                onTap: _changePhoto,
              ),

              const SizedBox(height: 50),

              // LOGOUT
              GestureDetector(
                onTap: () => _logout(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 6),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================
  // MENU ITEM WIDGET
  // ===============================
  Widget _menuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 14),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
