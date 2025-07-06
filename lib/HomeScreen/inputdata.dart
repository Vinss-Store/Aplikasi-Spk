import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spk_mobile/HomeScreen/TabelHasilPage.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class InputDataPage extends StatefulWidget {
  const InputDataPage({super.key});

  @override
  State<InputDataPage> createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  List<Map<String, dynamic>> kriteria = [];
  List<Map<String, dynamic>> alternatif = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _saveData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('kriteria', jsonEncode(kriteria));
  await prefs.setString('alternatif', jsonEncode(alternatif));

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final firestore = FirebaseFirestore.instance;
  await firestore.collection('input_data').doc(user.uid).set({
    'kriteria': kriteria,
    'alternatif': alternatif,
    'timestamp': FieldValue.serverTimestamp(),
  });
}


  Future<void> _hitungSkorUtility() async {
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User belum login'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Validasi bobot dan data
  final total = kriteria.fold<double>(
    0.0, (sum, item) => sum + (item['bobot'] as num).toDouble());

  if (total == 0 || kriteria.isEmpty || alternatif.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data belum lengkap'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final hasilUtility = <Map<String, dynamic>>[];

  for (var alt in alternatif) {
    final nilai = alt['nilai'] as Map<String, dynamic>;
    double skor = 0.0;
    final detailNilai = <String, double>{};

    for (var k in kriteria) {
      final kode = k['kode'];
      final bobot = (k['bobot'] as num).toDouble();
      final jenis = k['jenis'];
      final nilaiAlt = (nilai[kode] ?? 0).toDouble();

      // Ambil semua nilai untuk normalisasi
      final semuaNilai = alternatif
          .map((a) => (a['nilai'][kode] ?? 0).toDouble())
          .toList();

      final max = semuaNilai.reduce((a, b) => a > b ? a : b);
      final min = semuaNilai.reduce((a, b) => a < b ? a : b);

      double utility;
      if (jenis == 'Benefit') {
        utility = max == 0 ? 0 : nilaiAlt / max;
      } else {
        utility = nilaiAlt == 0 ? 0 : min / nilaiAlt;
      }

      detailNilai[k['nama']] = utility;
      skor += utility * bobot;
    }

    hasilUtility.add({
      'alternatif': alt['nama'],
      ...detailNilai,
      'skor': skor,
    });
  }

  // Simpan hasil ke Firestore dalam dokumen berdasarkan UID
  await firestore.collection('utility').doc(user.uid).set({
    'hasil': hasilUtility,
    'timestamp': FieldValue.serverTimestamp(),
  });

  // Navigasi ke halaman hasil
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TabelHasilPage(
        hasil: hasilUtility,
        alternatif: alternatif,
        kriteria: kriteria,
      ),
    ),
  );
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await FirebaseAuth.instance.signOut();
}

Future<void> simpanRiwayatBobotKriteria(String aksi, Map<String, dynamic> dataKriteria) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final firestore = FirebaseFirestore.instance;
  await firestore.collection('riwayat_kriteria').add({
    'uid': user.uid,
    'aksi': aksi, // Tambah / Edit / Hapus
    'kode': dataKriteria['kode'],
    'nama': dataKriteria['nama'],
    'bobot': dataKriteria['bobot'],
    'jenis': dataKriteria['jenis'],
    'waktu': FieldValue.serverTimestamp(),
  });
}



  Future<void> _loadData() async {
  final prefs = await SharedPreferences.getInstance();
  final kriteriaString = prefs.getString('kriteria');
  final alternatifString = prefs.getString('alternatif');

  if (kriteriaString != null && alternatifString != null) {
    setState(() {
      kriteria = List<Map<String, dynamic>>.from(jsonDecode(kriteriaString));
      alternatif =
          List<Map<String, dynamic>>.from(jsonDecode(alternatifString));
    });
  } else {
    // Ambil dari Firestore jika SharedPreferences kosong
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('input_data')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            kriteria =
                List<Map<String, dynamic>>.from(data['kriteria'] ?? []);
            alternatif =
                List<Map<String, dynamic>>.from(data['alternatif'] ?? []);
          });

          // Simpan juga ke SharedPreferences agar tidak load ulang dari server terus
          await prefs.setString('kriteria', jsonEncode(kriteria));
          await prefs.setString('alternatif', jsonEncode(alternatif));
        }
      }
    }
  }
}


  double get totalBobot => kriteria.fold(
      0.0, (sum, item) => sum + (item['bobot'] as num).toDouble());

  void _hapusKriteria(int index) {
    setState(() => kriteria.removeAt(index));
    _saveData();
  }

  void _hapusAlternatif(int index) {
    setState(() => alternatif.removeAt(index));
    _saveData();
  }

  void _tampilkanFormKriteria({Map<String, dynamic>? data, int? index}) {
    final kodeController = TextEditingController(text: data?['kode'] ?? '');
    final namaController = TextEditingController(text: data?['nama'] ?? '');
    final bobotController =
        TextEditingController(text: data?['bobot']?.toString() ?? '');
    String jenis = data?['jenis'] ?? 'Benefit';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              index == null ? Icons.add_circle : Icons.edit,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              index == null ? "Tambah Kriteria" : "Edit Kriteria",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: kodeController,
                label: "Kode Kriteria",
                icon: Icons.code,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: namaController,
                label: "Nama Kriteria",
                icon: Icons.label,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: bobotController,
                label: "Bobot",
                icon: Icons.scale,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: jenis,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: ["Benefit", "Cost"]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Row(
                              children: [
                                Icon(
                                  e == "Benefit"
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  size: 20,
                                  color: e == "Benefit"
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(e),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => jenis = val!),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final newData = {
                "kode": kodeController.text,
                "nama": namaController.text,
                "bobot": double.tryParse(bobotController.text) ?? 0.0,
                "jenis": jenis
              };
              setState(() {
                if (index == null) {
                  kriteria.add(newData);
                } else {
                  kriteria[index] = newData;
                }
              });
              _saveData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void afterLoginSuccess() async {
  final user = FirebaseAuth.instance.currentUser;
  final doc = await FirebaseFirestore.instance
      .collection('input_data')
      .doc(user!.uid)
      .get();

  if (doc.exists && doc.data()?['kriteria'] != null) {
    // Langsung ke Home
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    // Minta isi data terlebih dahulu
    Navigator.pushReplacementNamed(context, '/input_data');
  }
}


  void _tampilkanFormAlternatif({Map<String, dynamic>? data, int? index}) {
    final namaController = TextEditingController(text: data?['nama'] ?? '');
    final nilai = { for (var k in kriteria) k['kode'] : TextEditingController(
          text: data?['nilai']?[k['kode']]?.toString() ?? '0') };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              index == null ? Icons.add_circle : Icons.edit,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              index == null ? "Tambah Alternatif" : "Edit Alternatif",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: namaController,
                label: "Nama Alternatif",
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              if (kriteria.isNotEmpty) ...[
                const Text(
                  "Nilai Kriteria:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...nilai.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTextField(
                        controller: e.value,
                        label: "Nilai ${e.key}",
                        icon: Icons.assessment,
                        keyboardType: TextInputType.number,
                      ),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final newData = {
                "nama": namaController.text,
                "nilai": {
                  for (var e in nilai.entries)
                    e.key: int.tryParse(e.value.text) ?? 0
                }
              };
              setState(() {
                if (index == null) {
                  alternatif.add(newData);
                } else {
                  alternatif[index] = newData;
                }
              });
              _saveData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 20),
            label: const Text("Tambah"),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKriteriaCard(Map<String, dynamic> k, int index) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor:
                k['jenis'] == 'Benefit' ? Colors.green : Colors.red,
            child: Text(
              k['kode'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            k['nama'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    k['jenis'] == 'Benefit'
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 16,
                    color: k['jenis'] == 'Benefit' ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(k['jenis']),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Bobot: ${k['bobot']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _tampilkanFormKriteria(data: k, index: index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _hapusKriteria(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlternatifCard(Map<String, dynamic> a, int index) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              "A${index + 1}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            a['nama'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    ((a['nilai'] != null && a['nilai'] is Map<String, dynamic>)
                            ? (a['nilai'] as Map<String, dynamic>)
                            : <String, dynamic>{})
                        .entries
                        .map((entry) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${entry.key}: ${entry.value}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ))
                        .toList(),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () =>
                    _tampilkanFormAlternatif(data: a, index: index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _hapusAlternatif(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Input Kriteria & Alternatif",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Kriteria Section
              _buildSectionHeader(
                  "Data Kriteria", () => _tampilkanFormKriteria()),
              const SizedBox(height: 16),

              if (kriteria.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "Belum ada kriteria",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Tambahkan kriteria untuk memulai",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ...kriteria.asMap().entries.map((entry) {
                  return _buildKriteriaCard(entry.value, entry.key);
                }),

              if (kriteria.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: totalBobot == 1.0
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: totalBobot == 1.0 ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        totalBobot == 1.0 ? Icons.check_circle : Icons.warning,
                        color: totalBobot == 1.0 ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Total Bobot: ${totalBobot.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: totalBobot == 1.0
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                      if (totalBobot != 1.0) ...[
                        const SizedBox(width: 8),
                        const Text(
                          "(Harus = 1.0)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Alternatif Section
              _buildSectionHeader(
                  "Data Alternatif", () => _tampilkanFormAlternatif()),
              const SizedBox(height: 16),

              if (alternatif.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "Belum ada alternatif",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Tambahkan alternatif untuk evaluasi",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ...alternatif.asMap().entries.map((entry) {
                  return _buildAlternatifCard(entry.value, entry.key);
                }),

              const SizedBox(height: 32),

              // Calculate Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: kriteria.isNotEmpty && alternatif.isNotEmpty
                      ? () async {
                          await _hitungSkorUtility(); // ganti dengan pemanggilan fungsi baru
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calculate, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Hitung Sekarang",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}