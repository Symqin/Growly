# 🌱 Growly — Daily Habit Tracker

**Growly** adalah aplikasi mobile habit tracker yang membantu kamu membangun kebiasaan positif setiap hari. Dilengkapi dengan **daily reminder**, **streak tracking**, dan **statistik** untuk memantau progres kebiasaanmu.

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 📋 **Habit Dashboard** | Lihat semua habit aktif, tandai selesai, dan pantau streak harian |
| ➕ **Tambah / Edit Habit** | Buat habit baru dengan deskripsi dan pengaturan reminder |
| 🔔 **Daily Reminder** | Notifikasi exact alarm — tepat waktu, bahkan saat device idle |
| 📊 **Statistik** | Lihat riwayat penyelesaian habit dan statistik keseluruhan |
| 🔥 **Streak Tracker** | Hitung streak harian secara otomatis |
| 👤 **Akun & Profil** | Kelola nama, foto, dan akun (email atau Google Sign-In) |
| 🔐 **Multi-Auth** | Login dengan Email/Password atau Google Sign-In |

---

## 🛠️ Tech Stack

| Teknologi | Fungsi |
|-----------|--------|
| **Flutter** (Dart) | Framework UI cross-platform |
| **Firebase Auth** | Autentikasi (Email + Google Sign-In) |
| **Cloud Firestore** | Database realtime untuk habit data |
| **flutter_local_notifications** | Notifikasi lokal dengan exact alarm |
| **timezone** | Timezone-aware scheduling (Asia/Jakarta) |
| **permission_handler** | Kelola izin exact alarm (Android 12+) |

---

## 📁 Struktur Proyek

```
lib/
├── main.dart                          # Entry point & Firebase init
├── navbar.dart                        # Bottom navigation (Home, Stats, Account)
├── firebase_options.dart              # Firebase config (auto-generated)
│
├── auth/
│   ├── auth_service.dart              # Login, register, logout logic
│   ├── login_screen.dart              # Halaman login
│   └── register_screen.dart           # Halaman registrasi
│
├── models/
│   └── habit_model.dart               # Model Habit (Firestore mapping, streak, dll)
│
├── screen/
│   ├── dashboard_screen.dart          # Dashboard utama — list habit + checkbox
│   ├── add_habit_screen.dart          # Form tambah/edit habit + reminder
│   ├── statistik_screen.dart          # Statistik & riwayat harian
│   ├── habit_history_screen.dart      # Riwayat habit
│   ├── history_detail_screen.dart     # Detail riwayat per tanggal
│   └── account_page.dart             # Halaman akun (profil, logout)
│
└── services/
    ├── habit_service.dart             # CRUD Firestore untuk habit
    └── notification_service.dart      # Scheduling notifikasi exact alarm
```

---

## 🚀 Getting Started

### Prasyarat

- **Flutter SDK** `>= 3.9.2`
- **Android Studio** atau **VS Code** dengan Flutter extension
- **Firebase Project** yang sudah dikonfigurasi

### Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/your-username/growly.git
   cd growly
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Firebase**
   - Pastikan `lib/firebase_options.dart` sudah ter-generate
   - Jika belum, jalankan:
     ```bash
     flutterfire configure
     ```

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

---

## 🔔 Notifikasi — Exact Alarm

Growly menggunakan **exact alarm notification** untuk memastikan reminder tepat waktu:

- **Channel**: `habit_exact` (Daily Habit Reminder)
- **Mode**: `exactAllowWhileIdle` — berjalan meski device idle
- **Repeat**: Daily, berdasarkan `DateTimeComponents.time`
- **Timezone**: `Asia/Jakarta`

### Izin yang Dibutuhkan (Android)

| Izin | Versi Android | Keterangan |
|------|---------------|------------|
| `SCHEDULE_EXACT_ALARM` | Android 12+ | Wajib untuk exact alarm |
| `POST_NOTIFICATIONS` | Android 13+ | Wajib untuk menampilkan notifikasi |

---

## 🔐 Autentikasi

Growly mendukung dua metode login:

- **Email & Password** — registrasi dan login standar melalui Firebase Auth
- **Google Sign-In** — one-tap login menggunakan akun Google

Saat logout, semua notifikasi terjadwal otomatis di-cancel untuk menghindari reminder yang tidak diinginkan.

---

## 📊 Model Data — Habit

```dart
Habit {
  String id;              // Document ID Firestore
  String title;           // Nama habit
  String? description;    // Deskripsi
  String? ownerId;        // UID pemilik
  List<String> completedDates;  // Tanggal selesai (yyyy-MM-dd)
  bool reminderEnabled;   // Reminder aktif/nonaktif
  String? reminderTime;   // Waktu reminder (HH:mm)
  String? reminderRepeat; // Pola pengulangan
  DateTime createdAt;     // Tanggal pembuatan
}
```

---

## 📄 License

This project is for educational and personal use.

---

<p align="center">
  Built with 💚 using Flutter + Firebase
</p>
