import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final String? appBarTitle;

  const MainLayout({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.showBackButton = false,
    this.appBarTitle,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    int currentIndex = -1;

    if (currentRoute == '/community' ||
        currentRoute == '/post-details' ||
        currentRoute == '/create-post') {
      currentIndex = 0;
    } else if (currentRoute == '/camera' || currentRoute == '/plant-details') {
      currentIndex = 1;
    } else if (currentRoute == '/profile' || currentRoute == '/history') {
      currentIndex = 2;
    }

    final isHomePage =
        currentRoute == '/home' || currentRoute == '/' || currentRoute == '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7BB88D),
        automaticallyImplyLeading: (appBarTitle != null || isHomePage)
            ? showBackButton
            : false,
        leading: appBarTitle != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : (isHomePage
                  ? (showBackButton
                        ? IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          )
                        : null)
                  : IconButton(
                      icon: const Icon(Icons.home, color: Colors.white),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                    )),
        title: appBarTitle != null
            ? Text(
                appBarTitle!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : (isHomePage
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                "assets/images/Logo.jpg",
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "EcoSnap",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text("", style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    )
                  : null),
        actions: (appBarTitle != null || isHomePage)
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "EcoSnap",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/images/Logo.jpg",
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.chat_bubble,
                label: "Comunidade",
                isActive: currentIndex == 0,
                onTap: () {
                  if (currentIndex != 0) {
                    Navigator.pushNamed(context, '/community');
                  }
                },
              ),

              GestureDetector(
                onTap: () {
                  if (currentIndex != 1) {
                    Navigator.pushNamed(context, '/camera');
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25723E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF25723E,
                            ).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Câmera",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: currentIndex == 1
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: currentIndex == 1
                            ? const Color(0xFF1B5E20)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              _buildNavItem(
                context: context,
                icon: Icons.person,
                label: "Perfil",
                isActive: currentIndex == 2,
                onTap: () {
                  if (currentIndex != 2) {
                    Navigator.pushNamed(context, '/profile');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? const Color(0xFF1B5E20) : Colors.grey[600],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF1B5E20) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
