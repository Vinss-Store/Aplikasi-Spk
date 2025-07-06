import 'package:flutter/material.dart';

class TabelHasilPage extends StatefulWidget {
  final List<Map<String, dynamic>> hasil;
  final List<Map<String, dynamic>> alternatif;
  final List<Map<String, dynamic>> kriteria;

  const TabelHasilPage({
    super.key,
    required this.hasil,
    required this.alternatif,
    required this.kriteria,
  });

  @override
  State<TabelHasilPage> createState() => _TabelHasilPageState();
}

class _TabelHasilPageState extends State<TabelHasilPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildModernAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(102, 126, 234, 1),
                      Color.fromRGBO(118, 75, 162, 1),
                      Color.fromRGBO(240, 147, 251, 1),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGlassmorphicHeader(),
                          const SizedBox(height: 28),
                          _buildSectionTitle('Tabel Penilaian', Icons.assessment_outlined),
                          const SizedBox(height: 16),
                          _buildGlassTable(
                            child: buildTabelPenilaian(widget.alternatif, widget.kriteria),
                          ),
                          const SizedBox(height: 28),
                          _buildSectionTitle('Tabel Normalisasi', Icons.analytics_outlined),
                          const SizedBox(height: 16),
                          _buildGlassTable(
                            child: buildTabelNormalisasi(widget.hasil, widget.kriteria),
                          ),
                          const SizedBox(height: 28),
                          _buildSectionTitle('Tabel Utility', Icons.emoji_events_outlined),
                          const SizedBox(height: 16),
                          _buildGlassTable(
                            child: buildTabelUtility(widget.hasil, widget.kriteria),
                          ),
                          const SizedBox(height: 32),
                          _buildActionButton(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      title: const Text(
        "Hasil Perhitungan",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
    );
  }

  Widget _buildGlassmorphicHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hasil Perhitungan SMART',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Menampilkan proses perhitungan dari penilaian awal hingga skor akhir menggunakan metode SMART',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassTable({required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/hasil-akhir'),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  ),
                ),
                child: const Icon(Icons.leaderboard, color: Colors.white, size: 20),
              ),
              label: const Text(
                "Lihat Hasil Perangkingan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTabelPenilaian(List<Map<String, dynamic>> alternatifList, List<Map<String, dynamic>> kriteriaList) {
    final columns = ['Alternatif', ...kriteriaList.map((k) => k['nama'])];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
          dataTextStyle: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          horizontalMargin: 16,
          columnSpacing: 24,
          headingRowHeight: 52,
          dataRowHeight: 48,
          border: TableBorder.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
            borderRadius: BorderRadius.circular(15),
          ),
          columns: columns.map((col) => DataColumn(
            label: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(col),
            ),
          )).toList(),
          rows: alternatifList.asMap().entries.map((entry) {
            final index = entry.key;
            final alt = entry.value;
            final nilai = alt['nilai'] as Map<String, dynamic>;
            
            return DataRow(
              color: WidgetStateProperty.all(
                index % 2 == 0 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
              ),
              cells: [
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      alt['nama'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ...kriteriaList.map((k) => DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      (nilai[k['kode']] ?? '-').toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildTabelNormalisasi(List<Map<String, dynamic>> hasilList, List<Map<String, dynamic>> kriteriaList) {
    final columns = ['Alternatif', ...kriteriaList.map((k) => k['nama'])];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
          dataTextStyle: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          horizontalMargin: 16,
          columnSpacing: 24,
          headingRowHeight: 52,
          dataRowHeight: 48,
          border: TableBorder.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
            borderRadius: BorderRadius.circular(15),
          ),
          columns: columns.map((col) => DataColumn(
            label: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(col),
            ),
          )).toList(),
          rows: hasilList.asMap().entries.map((entry) {
            final index = entry.key;
            final alt = entry.value;
            
            return DataRow(
              color: WidgetStateProperty.all(
                index % 2 == 0 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
              ),
              cells: [
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      alt['alternatif'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ...kriteriaList.map((k) => DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      ((alt[k['nama']] ?? 0.0) as double).toStringAsFixed(3),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white,
                      ),
                    ),
                  ),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildTabelUtility(List<Map<String, dynamic>> hasilList, List<Map<String, dynamic>> kriteriaList) {
    final sortedHasil = List<Map<String, dynamic>>.from(hasilList)
      ..sort((a, b) => ((b['skor'] ?? 0.0) as double).compareTo((a['skor'] ?? 0.0) as double));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        horizontalMargin: 16,
        columnSpacing: 40,
        headingRowHeight: 52,
        dataRowHeight: 48,
        border: TableBorder.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
          borderRadius: BorderRadius.circular(15),
        ),
        columns: const [
          DataColumn(label: Text('Alternatif')),
          DataColumn(label: Text('Skor Total')),
          DataColumn(label: Text('Ranking')),
        ],
        rows: sortedHasil.asMap().entries.map((entry) {
          final index = entry.key;
          final alt = entry.value;
          final skor = (alt['skor'] ?? 0.0) as double;
          
          return DataRow(
            color: WidgetStateProperty.all(
              index % 2 == 0 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
            ),
            cells: [
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    alt['alternatif'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    skor.toStringAsFixed(4),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getRankingGradient(index + 1),
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: _getRankingGradient(index + 1)[0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Color> _getRankingGradient(int rank) {
    switch (rank) {
      case 1:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)]; // Gold
      case 2:
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)]; // Silver
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)]; // Bronze
      default:
        return [const Color(0xFF4CAF50), const Color(0xFF45A049)]; // Green
    }
  }
}