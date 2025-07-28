import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
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
      drawer: _buildModernDrawer(context),
      appBar: _buildModernAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Main content with gradient background
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
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGlassmorphicWelcome(),
                          const SizedBox(height: 24),
                          _buildAnimatedStats(),
                          const SizedBox(height: 28),
                          _buildSectionTitle('Menu Utama', Icons.apps_rounded),
                          const SizedBox(height: 16),
                          _buildModernGrid(),
                          const SizedBox(height: 28),
                          _buildSectionTitle('Panduan Cepat', Icons.help_outline_rounded),
                          const SizedBox(height: 16),
                          _buildQuickGuide(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Footer section with different background
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(240, 147, 251, 1),
                      Color.fromRGBO(67, 56, 202, 1),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildSystemInfo(),
                      const SizedBox(height: 20),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF3498DB),
              Color(0xFF9B59B6),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 220,
              child: DrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.dashboard_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "SPK SMART",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Flexible(
                      child: Text(
                        "Decision Support System",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildModernDrawerItem(
              context,
              Icons.dashboard_outlined,
              "Dashboard",
              () => Navigator.pushReplacementNamed(context, '/dashboard'),
              isActive: true,
            ),
            _buildModernDrawerItem(
              context,
              Icons.school_outlined,
              "Tutorial",
              () => Navigator.pushNamed(context, '/tutorial'),
            ),
            _buildModernDrawerItem(
              context,
              Icons.edit_note_outlined,
              "Input Data",
              () => Navigator.pushNamed(context, '/input-data'),
            ),
            _buildModernDrawerItem(
              context,
              Icons.analytics_outlined,
              "Hasil Akhir",
              () => Navigator.pushNamed(context, '/hasil-akhir'),
            ),
            _buildModernDrawerItem(
              context,
              Icons.person_outlined,
              "Profile",
              () => Navigator.pushNamed(context, '/profile'),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildModernDrawerItem(
              context,
              Icons.logout_rounded,
              "Logout",
              () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              isDanger: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isActive = false,
    bool isDanger = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isActive
            ? LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              )
            : null,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDanger
                ? Colors.red.withOpacity(0.2)
                : Colors.white.withOpacity(0.2),
          ),
          child: Icon(
            icon,
            color: isDanger ? Colors.red[300] : Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDanger ? Colors.red[300] : Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      title: const Text(
        "Dashboard",
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

  Widget _buildGlassmorphicWelcome() {
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
              Icons.dashboard_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FittedBox(
                  child: Text(
                    'Selamat Datang! 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  child: Text(
                    'Sistem Pendukung Keputusan SMART',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStats() {
    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _buildGlassStatCard(
                  title: "Kriteria",
                  value: "5",
                  icon: Icons.category_outlined,
                  gradient: const [Color(0xFF4CAF50), Color(0xFF45A049)],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1700),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _buildGlassStatCard(
                  title: "Alternatif",
                  value: "12",
                  icon: Icons.people_outline,
                  gradient: const [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1900),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _buildGlassStatCard(
                  title: "Bobot",
                  value: "100%",
                  icon: Icons.balance_outlined,
                  gradient: const [Color(0xFFFF9800), Color(0xFFF57C00)],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlassStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
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
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: gradient),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
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

  Widget _buildModernGrid() {
    final List<Map<String, dynamic>> cards = [
      {
        'title': 'Input Data',
        'subtitle': 'Kriteria, Alternatif, Bobot',
        'route': '/input-data',
        'icon': Icons.edit_note_outlined,
        'gradient': [const Color(0xFF4CAF50), const Color(0xFF45A049)],
      },
      {
        'title': 'Hasil Akhir',
        'subtitle': 'Lihat hasil keputusan',
        'route': '/hasil-akhir',
        'icon': Icons.analytics_outlined,
        'gradient': [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      },
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 800 + (index * 200)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: _ModernDashboardCard(
                title: card['title'],
                subtitle: card['subtitle'],
                routeName: card['route'],
                icon: card['icon'],
                gradient: card['gradient'],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Data Kriteria Diperbarui',
        'subtitle': '2 jam yang lalu',
        'icon': Icons.update_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'Analisis Selesai',
        'subtitle': '1 hari yang lalu',
        'icon': Icons.check_circle_outline_rounded,
        'color': Colors.green,
      },
      {
        'title': 'Laporan Dibuat',
        'subtitle': '3 hari yang lalu',
        'icon': Icons.description_outlined,
        'color': Colors.orange,
      },
    ];

    return Column(
      children: activities.map((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activity['color'].withOpacity(0.2),
                ),
                child: Icon(
                  activity['icon'],
                  color: activity['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['subtitle'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickGuide() {
    final List<Map<String, dynamic>> guides = [
      {
        'title': 'Cara Input Data',
        'description': 'Pelajari cara memasukkan kriteria dan alternatif',
        'icon': Icons.help_outline_rounded,
      },
      {
        'title': 'Memahami Hasil',
        'description': 'Interpretasi hasil analisis SMART',
        'icon': Icons.lightbulb_outline_rounded,
      },
    ];

    return Row(
      children: guides.map((guide) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: guides.last == guide ? 0 : 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    guide['icon'],
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  guide['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  guide['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoItem(
                icon: Icons.speed_rounded,
                label: 'Performa Optimal',
                color: Colors.green,
              ),
              _buildInfoItem(
                icon: Icons.security_rounded,
                label: 'Data Aman',
                color: Colors.blue,
              ),
              _buildInfoItem(
                icon: Icons.cloud_done_rounded,
                label: 'Tersinkronisasi',
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'SPK SMART v1.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Simple Multi-Attribute Rating Technique',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 - Sistem Pendukung Keputusan',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ModernDashboardCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String routeName;
  final IconData icon;
  final List<Color> gradient;

  const _ModernDashboardCard({
    required this.title,
    required this.subtitle,
    required this.routeName,
    required this.icon,
    required this.gradient,
  });

  @override
  State<_ModernDashboardCard> createState() => _ModernDashboardCardState();
}

class _ModernDashboardCardState extends State<_ModernDashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _hoverController.forward(),
            onTapUp: (_) => _hoverController.reverse(),
            onTapCancel: () => _hoverController.reverse(),
            onTap: () => Navigator.pushNamed(context, widget.routeName),
            child: Container(
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
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: widget.gradient),
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradient[0].withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
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
}