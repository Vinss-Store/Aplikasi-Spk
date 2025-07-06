import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class HasilAkhirPage extends StatefulWidget {
  const HasilAkhirPage({super.key});

  @override
  State<HasilAkhirPage> createState() => _HasilAkhirPageState();
}

class _HasilAkhirPageState extends State<HasilAkhirPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> kriteria = [];
  List<Map<String, dynamic>> alternatif = [];
  List<Map<String, dynamic>> hasil = [];
  bool loading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final kriteriaStr = prefs.getString('kriteria');
    final alternatifStr = prefs.getString('alternatif');

    if (kriteriaStr != null && alternatifStr != null) {
      kriteria = List<Map<String, dynamic>>.from(jsonDecode(kriteriaStr));
      alternatif = List<Map<String, dynamic>>.from(jsonDecode(alternatifStr));
      hasil = _hitungHasil();
    }

    setState(() => loading = false);
    _animationController.forward();
  }

  List<Map<String, dynamic>> _hitungHasil() {
    if (kriteria.isEmpty || alternatif.isEmpty) return [];

    Map<String, double> minValue = {};
    Map<String, double> maxValue = {};

    for (var k in kriteria) {
      String kode = k['kode'];
      List<double> nilaiList = alternatif.map((a) {
        if (a['nilai'] != null &&
            a['nilai'] is Map &&
            a['nilai'][kode] != null &&
            a['nilai'][kode] is num) {
          return (a['nilai'][kode] as num).toDouble();
        } else {
          return 0.0;
        }
      }).toList();
      minValue[kode] = nilaiList.reduce((a, b) => a < b ? a : b);
      maxValue[kode] = nilaiList.reduce((a, b) => a > b ? a : b);
    }

    List<Map<String, dynamic>> hasil = [];

    for (var alt in alternatif) {
      String nama = alt['nama'];
      Map<String, dynamic> nilai = (alt['nilai'] != null && alt['nilai'] is Map)
          ? Map<String, dynamic>.from(alt['nilai'])
          : <String, dynamic>{};
      double total = 0.0;

      for (var k in kriteria) {
        String kode = k['kode'];
        double bobot = (k['bobot'] as num).toDouble();
        String jenis = k['jenis'];
        double value = 0.0;
        if (nilai.containsKey(kode) &&
            nilai[kode] != null &&
            nilai[kode] is num) {
          value = (nilai[kode] as num).toDouble();
        }

        double norm = 0.0;
        if (jenis == 'Cost') {
          norm = minValue[kode]! > 0
              ? minValue[kode]! / (value == 0.0 ? 1.0 : value)
              : 0.0;
        } else {
          norm = maxValue[kode]! > 0 ? value / maxValue[kode]! : 0.0;
        }

        total += norm * bobot;
      }

      hasil.add({'nama': nama, 'skor': total});
    }

    hasil.sort((a, b) => (b['skor'] as double).compareTo(a['skor'] as double));
    return hasil;
  }

  Color _getPrimaryColor() => const Color(0xFF2196F3);
  Color _getSecondaryColor() => const Color(0xFF1976D2);

  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.leaderboard,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hasil Perangkingan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${hasil.length} Alternatif',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> item, int index) {
    final skor = item['skor'] as double;
    final isWinner = index == 0;
    final isTopThree = index < 3;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (index * 0.1).clamp(0.0, 1.0),
              ((index * 0.1) + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          )),
          child: FadeTransition(
            opacity: _animationController,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: isWinner
                    ? Border.all(color: Colors.amber, width: 2)
                    : Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Ranking Number
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getRankingColor(index),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: isTopThree
                            ? Icon(
                                _getRankingIcon(index),
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['nama'],
                                  style: TextStyle(
                                    fontSize: isWinner ? 18 : 16,
                                    fontWeight: isWinner
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: const Color(0xFF212121),
                                  ),
                                ),
                              ),
                              if (isTopThree)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRankingColor(index)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getRankingLabel(index),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _getRankingColor(index),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Score Progress
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: (skor * 0.8).clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _getRankingColor(index),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                skor.toStringAsFixed(3),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _getRankingColor(index),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRankingColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFF9800); // Orange Gold
      case 1:
        return const Color(0xFF607D8B); // Blue Grey
      case 2:
        return const Color(0xFFFF7043); // Deep Orange
      default:
        return _getPrimaryColor();
    }
  }

  IconData _getRankingIcon(int index) {
    switch (index) {
      case 0:
        return Icons.emoji_events;
      case 1:
        return Icons.military_tech;
      case 2:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  String _getRankingLabel(int index) {
    switch (index) {
      case 0:
        return 'TERBAIK';
      case 1:
        return 'BAIK';
      case 2:
        return 'CUKUP';
      default:
        return '';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tambahkan kriteria dan alternatif\nterlebih dahulu untuk melihat hasil perangkingan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> simpanHasilKeFirestore(List<Map<String, dynamic>> hasil) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('hasil_perhitungan').add({
        'hasil': hasil,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hasil berhasil disimpan ke Firestore')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Hasil Akhir',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
        ),
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: _getPrimaryColor(),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Memproses data...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : hasil.isEmpty
              ? Column(
                  children: [
                    _buildTopSection(),
                    Expanded(child: _buildEmptyState()),
                  ],
                )
              : Column(
                  children: [
                    _buildTopSection(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: hasil.length,
                        itemBuilder: (context, index) {
                          return _buildRankingCard(hasil[index], index);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: double.infinity,
                            height: 48,
                          ),
                          const SizedBox(height: 8),
                          if (hasil.isEmpty)
                            const Text(
                              "Hasil belum tersedia. Silakan lakukan perhitungan terlebih dahulu.",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: hasil.isNotEmpty
                            ? () => simpanHasilKeFirestore(hasil)
                            : null,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text("Simpan Hasil ke Firestore"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}