import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growly/auth/login_screen.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // abu-abu seperti gambar
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

              // Profile circle
              CircleAvatar(
                radius: 55,
                backgroundColor: const Color.fromARGB(255, 31, 119, 55),
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),

              const SizedBox(height: 22),

              Text(
                (user?.displayName ?? "NAMA ANDA").toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                user?.email ?? "email@domain.com",
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),

              const SizedBox(height: 40),

              // CARD 1: Ubah Nama
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.settings, color: Colors.black54),
                    SizedBox(width: 14),
                    Text(
                      "Ubah Nama",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // CARD 2: Ubah Foto
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.settings, color: Colors.black54),
                    SizedBox(width: 14),
                    Text(
                      "Ubah Foto",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // LOGOUT button
              GestureDetector(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
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
}
