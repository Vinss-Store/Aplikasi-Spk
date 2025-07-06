# 🧠 SPK SMART – Sistem Pendukung Keputusan Berbasis Flutter

**SPK SMART** adalah aplikasi mobile berbasis **Flutter** yang memanfaatkan metode **SMART (Simple Multi Attribute Rating Technique)** untuk membantu pengguna dalam mengambil keputusan **berdasarkan kriteria dan bobot yang ditentukan**.

Dengan antarmuka yang modern dan integrasi penuh dengan **Firebase**, aplikasi ini cocok untuk digunakan dalam pengambilan keputusan seperti pemilihan supplier, pemilihan produk terbaik, dan lainnya.

---

## ✨ Fitur Utama

| ✅ Fitur                           | 📋 Deskripsi                                                                 |
|-----------------------------------|------------------------------------------------------------------------------|
| 🔐 Autentikasi Aman               | Login dan registrasi dengan **Firebase Authentication**                     |
| 📊 Perhitungan SMART              | Hitung nilai & rangking alternatif berdasarkan **bobot kriteria**            |
| 📈 Grafik Analisis Visual         | Tampilkan hasil skor alternatif dalam **grafik batang interaktif**          |
| 📝 Input Data Dinamis             | Tambahkan dan kelola **kriteria, alternatif, dan bobot** secara fleksibel   |
| 👤 Manajemen Profil               | Simpan dan tampilkan data pengguna dari **Firestore**                       |
| 🎨 Tampilan Modern & Responsif    | Desain **glassmorphism**, gradient, dan animasi halus untuk pengalaman UI terbaik |

---

## 🧰 Teknologi & Tools

| 🛠️ Teknologi / Library             | Kegunaan Utama                                                   |
|-----------------------------------|------------------------------------------------------------------|
| [Flutter](https://flutter.dev)    | Framework utama untuk UI dan interaksi pengguna                  |
| [Firebase Auth](https://firebase.google.com/products/auth) | Autentikasi pengguna (login/register)                           |
| [Cloud Firestore](https://firebase.google.com/products/firestore) | Penyimpanan data real-time untuk kriteria & pengguna          |
| [FL Chart](https://pub.dev/packages/fl_chart) | Visualisasi data dalam bentuk grafik batang                      |
| [Google Fonts](https://pub.dev/packages/google_fonts) & Icons | Tampilan teks & ikon custom                                      |
| `setState` / `Provider`           | Manajemen state aplikasi                                         |

---

## 📱 Kebutuhan Sistem

| Platform  | Minimum Requirement                      |
|-----------|-------------------------------------------|
| Flutter   | Versi **3.10+**                          |
| Android   | Minimal **API 23 (Android 6.0)**         |
| iOS       | Minimal **iOS 11**                       |
| Firebase  | Sudah terkonfigurasi dan terhubung       |
| Package   | Pastikan menjalankan `flutter pub get`   |

---

## 🖼️ Cuplikan Antarmuka

| 📊 Dashboard | 🧮 Hasil SMART | 📝 Input Data |
|-------------|----------------|---------------|
| ![](screenshots/dashboard.png) | ![](screenshots/hasil.png) | ![](screenshots/input.png) |

---

## ⚙️ Cara Menjalankan Aplikasi

```bash
# Clone repo
git clone https://github.com/username/spk_smart.git

# Masuk ke direktori project
cd spk_smart

# Install dependency
flutter pub get

# Jalankan aplikasi
flutter run
