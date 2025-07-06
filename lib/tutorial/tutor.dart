import 'package:flutter/material.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial Penggunaan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _controller,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF42A5F5),
                  Color(0xFFE3F2FD),
                ],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildTutorialStep(
                  context: context,
                  stepNumber: '01',
                  icon: Icons.login_rounded,
                  title: 'Login ke Aplikasi',
                  description:
                      'Masukkan email dan password Anda untuk masuk ke aplikasi. Jika belum punya akun, daftar terlebih dahulu.',
                  imageWidget: _buildStepImage(
                    Icons.person_outline,
                    const Color(0xFF4CAF50),
                  ),
                  color: const Color(0xFF4CAF50),
                ),
                _buildTutorialStep(
                  context: context,
                  stepNumber: '02',
                  icon: Icons.edit_note_outlined,
                  title: 'Input Data Kriteria',
                  description:
                      'Masukkan kriteria, bobot, dan alternatif. Pastikan total bobot = 1.0.',
                  imageWidget: _buildStepImage(
                    Icons.assignment_outlined,
                    const Color(0xFF2196F3),
                  ),
                  color: const Color(0xFF2196F3),
                ),
                _buildTutorialStep(
                  context: context,
                  stepNumber: '03',
                  icon: Icons.analytics_outlined,
                  title: 'Lihat Hasil Perhitungan',
                  description:
                      'Pilih menu "Hasil Akhir" untuk melihat hasil perangkingan metode SMART.',
                  imageWidget: _buildStepImage(
                    Icons.trending_up,
                    const Color(0xFFFF9800),
                  ),
                  color: const Color(0xFFFF9800),
                ),
                _buildTutorialStep(
                  context: context,
                  stepNumber: '04',
                  icon: Icons.table_chart_outlined,
                  title: 'Analisis Tabel Hasil',
                  description:
                      'Lihat hasil perhitungan dalam bentuk tabel untuk analisis mendalam.',
                  imageWidget: _buildStepImage(
                    Icons.grid_on,
                    const Color(0xFF9C27B0),
                  ),
                  color: const Color(0xFF9C27B0),
                ),
                _buildTutorialStep(
                  context: context,
                  stepNumber: '05',
                  icon: Icons.bar_chart,
                  title: 'Visualisasi Grafik',
                  description:
                      'Lihat grafik interaktif di dashboard untuk pemahaman yang lebih mudah.',
                  imageWidget: _buildStepImage(
                    Icons.show_chart,
                    const Color(0xFFE91E63),
                  ),
                  color: const Color(0xFFE91E63),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialStep({
    required BuildContext context,
    required String stepNumber,
    required IconData icon,
    required String title,
    required String description,
    required Widget imageWidget,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          stepNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(child: imageWidget),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepImage(IconData icon, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}
